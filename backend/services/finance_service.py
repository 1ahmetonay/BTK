"""
KOBİ AI Asistan — Finans Servisi
Gelir-gider, KDV, nakit akışı, gecikmiş ödemeler.
"""

import calendar
import logging
from datetime import date, timedelta
from typing import Optional

from sqlalchemy import func, select, and_
from sqlalchemy.ext.asyncio import AsyncSession

from database import Fatura, FaturaKalem, NakitAkisi, KdvKayit, Uyari

logger = logging.getLogger(__name__)


class FinanceService:
    """Finansal yönetim servisi."""

    async def get_pl_summary(self, db: AsyncSession, ay: Optional[int] = None,
                              yil: Optional[int] = None) -> dict:
        """Gelir-gider (P&L) özeti.
        Gelir: satış faturaları (net_tutar)
        Gider: satın alma faturaları + maaş (Puantaj tablosundan) + kira (NakitAkisi)
        """
        today = date.today()
        ay = ay or today.month
        yil = yil or today.year

        # Satış gelirleri (Fatura tablosundan)
        result = await db.execute(
            select(func.sum(Fatura.net_tutar)).where(
                and_(
                    Fatura.tur == "satis",
                    func.extract("month", Fatura.tarih) == ay,
                    func.extract("year", Fatura.tarih) == yil,
                )
            )
        )
        gelir = result.scalar() or 0

        # Satın alma giderleri (Fatura tablosundan)
        result = await db.execute(
            select(func.sum(Fatura.net_tutar)).where(
                and_(
                    Fatura.tur == "satin_alma",
                    func.extract("month", Fatura.tarih) == ay,
                    func.extract("year", Fatura.tarih) == yil,
                )
            )
        )
        satin_alma_gider = result.scalar() or 0

        # Maaş giderleri (Puantaj tablosundan — gerçek hesaplama)
        from database import Puantaj
        result = await db.execute(
            select(func.sum(Puantaj.brut_maas)).where(
                and_(Puantaj.ay == ay, Puantaj.yil == yil)
            )
        )
        maas_gideri = result.scalar() or 0

        # Kira gideri (NakitAkisi tablosundan)
        result = await db.execute(
            select(func.sum(NakitAkisi.cikis)).where(
                and_(
                    NakitAkisi.kategori == "kira",
                    func.extract("month", NakitAkisi.tarih) == ay,
                    func.extract("year", NakitAkisi.tarih) == yil,
                )
            )
        )
        kira_gideri = result.scalar() or 0

        toplam_gider = satin_alma_gider + maas_gideri + kira_gideri
        kar = gelir - toplam_gider
        kar_marji = round((kar / gelir * 100), 1) if gelir > 0 else 0

        return {
            "donem": f"{ay}/{yil}",
            "gelir": round(gelir, 2),
            "satin_alma_gideri": round(satin_alma_gider, 2),
            "toplam_gider": round(toplam_gider, 2),
            "net_kar": round(kar, 2),
            "kar_marji_yuzde": kar_marji,
            "gider_dagilimi": [
                {"kategori": "Satın Alma", "tutar": round(satin_alma_gider, 2)},
                {"kategori": "Maaş", "tutar": round(maas_gideri, 2)},
                {"kategori": "Kira", "tutar": round(kira_gideri, 2)},
            ],
        }

    async def get_cashflow(self, db: AsyncSession, gun: int = 30) -> dict:
        """Nakit akışı özeti ve projeksiyonu.
        Bakiye = toplam giriş - toplam çıkış (running total, bakiye alanına güvenmez).
        """
        today = date.today()
        start = today - timedelta(days=gun)

        result = await db.execute(
            select(NakitAkisi)
            .where(NakitAkisi.tarih >= start)
            .order_by(NakitAkisi.tarih.asc())
        )
        records = result.scalars().all()

        toplam_giris = sum(r.giris for r in records)
        toplam_cikis = sum(r.cikis for r in records)

        # Bakiyeyi dinamik hesapla: tüm zamanların toplam giriş - çıkış
        all_result = await db.execute(
            select(
                func.sum(NakitAkisi.giris).label("total_in"),
                func.sum(NakitAkisi.cikis).label("total_out"),
            )
        )
        row = all_result.one()
        mevcut_bakiye = (row.total_in or 0) - (row.total_out or 0)

        # Basit projeksiyon (günlük ortalamaya dayalı)
        daily_avg_in = toplam_giris / max(gun, 1)
        daily_avg_out = toplam_cikis / max(gun, 1)
        net_daily = daily_avg_in - daily_avg_out

        projections = []
        bakiye = mevcut_bakiye
        for i in range(1, 91):
            bakiye += net_daily
            if i in [7, 14, 30, 60, 90]:
                projections.append({
                    "gun": i,
                    "tahmini_bakiye": round(bakiye, 2),
                    "risk": bakiye < 0,
                })

        return {
            "donem_gun": gun,
            "toplam_giris": round(toplam_giris, 2),
            "toplam_cikis": round(toplam_cikis, 2),
            "net": round(toplam_giris - toplam_cikis, 2),
            "mevcut_bakiye": round(mevcut_bakiye, 2),
            "gunluk_ortalama_giris": round(daily_avg_in, 2),
            "gunluk_ortalama_cikis": round(daily_avg_out, 2),
            "projeksiyonlar": projections,
            "kayitlar": [
                {
                    "tarih": r.tarih.isoformat() if r.tarih else None,
                    "giris": r.giris,
                    "cikis": r.cikis,
                    "bakiye": r.bakiye,
                    "aciklama": r.aciklama,
                    "kategori": r.kategori,
                }
                for r in records
            ],
        }

    async def get_kdv_summary(self, db: AsyncSession, ay: Optional[int] = None,
                               yil: Optional[int] = None) -> dict:
        """Aylık KDV beyanname özeti.
        Türkiye'de KDV beyannamesi bir sonraki ayın 26'sına kadar verilir.
        Örn: Mayıs KDV'si → Haziran 26'ya kadar.
        """
        today = date.today()
        ay = ay or today.month
        yil = yil or today.year

        # Hesaplanan KDV (satışlardan)
        result = await db.execute(
            select(func.sum(KdvKayit.kdv_tutari)).where(
                and_(
                    KdvKayit.tur == "hesaplanan",
                    KdvKayit.ay == ay,
                    KdvKayit.yil == yil,
                )
            )
        )
        hesaplanan = result.scalar() or 0

        # İndirilecek KDV (alışlardan)
        result = await db.execute(
            select(func.sum(KdvKayit.kdv_tutari)).where(
                and_(
                    KdvKayit.tur == "indirilecek",
                    KdvKayit.ay == ay,
                    KdvKayit.yil == yil,
                )
            )
        )
        indirilecek = result.scalar() or 0

        odenecek = max(hesaplanan - indirilecek, 0)

        # Beyanname son tarihi: bir sonraki ayın 26'sı
        if ay == 12:
            son_ay, son_yil = 1, yil + 1
        else:
            son_ay, son_yil = ay + 1, yil
        last_day = min(26, calendar.monthrange(son_yil, son_ay)[1])
        son_tarih = date(son_yil, son_ay, last_day)
        kalan_gun = (son_tarih - today).days

        return {
            "donem": f"{ay}/{yil}",
            "hesaplanan_kdv": round(hesaplanan, 2),
            "indirilecek_kdv": round(indirilecek, 2),
            "odenecek_kdv": round(odenecek, 2),
            "beyanname_son_tarihi": son_tarih.isoformat(),
            "kalan_gun": max(kalan_gun, 0),
            "uyari": kalan_gun <= 5,
        }

    async def get_overdue_payments(self, db: AsyncSession, tur: Optional[str] = None) -> list[dict]:
        """Gecikmiş ödemeler."""
        today = date.today()
        filters = [
            Fatura.odeme_durumu == "gecikti",
            Fatura.vade_tarihi < today,
        ]
        if tur:
            filters.append(Fatura.tur == tur)

        result = await db.execute(
            select(Fatura).where(
                and_(*filters)
            ).order_by(Fatura.vade_tarihi.asc())
        )
        invoices = result.scalars().all()

        return [
            {
                "fatura_id": f.id,
                "fatura_no": f.fatura_no,
                "karsi_taraf": f.karsi_taraf_isim,
                "tutar": f.toplam_tutar,
                "vade_tarihi": f.vade_tarihi.isoformat() if f.vade_tarihi else None,
                "gecikme_gun": (today - f.vade_tarihi).days if f.vade_tarihi else 0,
                "tur": f.tur,
            }
            for f in invoices
        ]

    async def get_recent_invoices(self, db: AsyncSession, limit: int = 10) -> list[dict]:
        """Son faturalar."""
        result = await db.execute(
            select(Fatura).order_by(Fatura.tarih.desc()).limit(limit)
        )
        invoices = result.scalars().all()

        return [
            {
                "id": f.id,
                "fatura_no": f.fatura_no,
                "tarih": f.tarih.isoformat() if f.tarih else None,
                "tur": f.tur,
                "karsi_taraf": f.karsi_taraf_isim,
                "toplam_tutar": f.toplam_tutar,
                "kdv_tutari": f.kdv_tutari,
                "odeme_durumu": f.odeme_durumu,
            }
            for f in invoices
        ]


# Singleton
finance_service = FinanceService()
