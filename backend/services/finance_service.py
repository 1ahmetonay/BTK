"""
KOBİ AI Asistan — Finans Servisi
Gelir-gider, KDV, nakit akışı, gecikmiş ödemeler.
"""

from datetime import date, datetime, timedelta
from typing import Optional

from sqlalchemy import func, select, and_, or_
from sqlalchemy.ext.asyncio import AsyncSession

import sys, os
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from database import Fatura, FaturaKalem, NakitAkisi, KdvKayit, Uyari


class FinanceService:
    """Finansal yönetim servisi."""

    async def get_pl_summary(self, db: AsyncSession, ay: Optional[int] = None,
                              yil: Optional[int] = None) -> dict:
        """Gelir-gider (P&L) özeti."""
        today = date.today()
        ay = ay or today.month
        yil = yil or today.year

        # Satış gelirleri
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

        # Satın alma giderleri
        result = await db.execute(
            select(func.sum(Fatura.net_tutar)).where(
                and_(
                    Fatura.tur == "satin_alma",
                    func.extract("month", Fatura.tarih) == ay,
                    func.extract("year", Fatura.tarih) == yil,
                )
            )
        )
        gider = result.scalar() or 0

        # Diğer giderler (maaş, kira vs) nakit akışından
        result = await db.execute(
            select(func.sum(NakitAkisi.cikis)).where(
                and_(
                    NakitAkisi.kategori.in_(["maas", "kira", "fatura"]),
                    func.extract("month", NakitAkisi.tarih) == ay,
                    func.extract("year", NakitAkisi.tarih) == yil,
                )
            )
        )
        diger_gider = result.scalar() or 0

        # Maaş giderleri (puantajdan gerçek hesaplama)
        from database import Puantaj
        result = await db.execute(
            select(func.sum(Puantaj.brut_maas)).where(
                and_(Puantaj.ay == ay, Puantaj.yil == yil)
            )
        )
        maas_gideri = result.scalar() or 0

        # Kira gideri (nakit akışından)
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

        toplam_gider = gider + maas_gideri + kira_gideri + diger_gider
        kar = gelir - toplam_gider
        kar_marji = round((kar / gelir * 100), 1) if gelir > 0 else 0

        return {
            "donem": f"{ay}/{yil}",
            "gelir": round(gelir, 2),
            "satin_alma_gideri": round(gider, 2),
            "diger_giderler": round(diger_gider, 2),
            "toplam_gider": round(toplam_gider, 2),
            "net_kar": round(kar, 2),
            "kar_marji_yuzde": kar_marji,
            "gider_dagilimi": [
                {"kategori": "Satın Alma", "tutar": round(gider, 2)},
                {"kategori": "Maaş", "tutar": round(maas_gideri, 2)},
                {"kategori": "Kira", "tutar": round(kira_gideri, 2)},
                {"kategori": "Diğer", "tutar": round(diger_gider, 2)},
            ],
        }

    async def get_cashflow(self, db: AsyncSession, gun: int = 30) -> dict:
        """Nakit akışı özeti ve projeksiyonu."""
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
        mevcut_bakiye = records[-1].bakiye if records else 0

        # Basit projeksiyon
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
        """Aylık KDV beyanname özeti."""
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

        # Beyanname son tarihi (her ayın 26'sı)
        import calendar
        last_day = min(26, calendar.monthrange(yil, ay)[1])
        son_tarih = date(yil, ay, last_day)
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

    async def get_overdue_payments(self, db: AsyncSession) -> list[dict]:
        """Gecikmiş ödemeler."""
        today = date.today()
        result = await db.execute(
            select(Fatura).where(
                and_(
                    Fatura.odeme_durumu == "gecikti",
                    Fatura.vade_tarihi < today,
                )
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
