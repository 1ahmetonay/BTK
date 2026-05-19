"""
KOBİ AI Asistan — Belge İşleme Servisi
Fatura ve puantaj belgelerini Gemini ile işler, veritabanını günceller.
"""

import json
from datetime import date, datetime
from typing import Optional

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from database import (
    Fatura, FaturaKalem, Urun, StokHareket, KdvKayit, NakitAkisi,
    Calisan, Puantaj, Uyari,
)
from services.gemini_service import gemini_service
from services.event_bus import event_bus, Events


class DocumentService:
    """Belge işleme servisi — Gemini ile okur, veritabanını günceller."""

    async def process_document(self, db: AsyncSession, image_data: bytes,
                                mime_type: str = "image/jpeg") -> dict:
        """Fatura/fiş belgesini işler: oku → kaydet → stok güncelle → KDV güncelle."""

        # 1) Gemini ile oku
        parsed = await gemini_service.read_document(image_data, mime_type)

        if "error" in parsed:
            return {"success": False, "error": parsed["error"]}

        # 2) Fatura kaydı oluştur
        belge_tipi = parsed.get("belge_tipi", "satin_alma_faturasi")
        tur = "satin_alma" if "satin" in belge_tipi else "satis"

        fatura = Fatura(
            fatura_no=parsed.get("fatura_no"),
            tarih=self._parse_date(parsed.get("tarih")),
            tur=tur,
            karsi_taraf_isim=parsed.get("satici_adi", ""),
            karsi_taraf_vkn=parsed.get("satici_vkn"),
            toplam_tutar=parsed.get("genel_toplam", 0),
            kdv_tutari=parsed.get("toplam_kdv", 0),
            net_tutar=parsed.get("genel_toplam", 0) - parsed.get("toplam_kdv", 0),
            odeme_durumu="bekliyor",
            gemini_raw_json=json.dumps(parsed, ensure_ascii=False),
            islendi=True,
        )
        db.add(fatura)
        await db.flush()

        # 3) Fatura kalemlerini kaydet
        kalemler = parsed.get("kalemler", [])
        stok_sonuclari = []

        for kalem in kalemler:
            urun_adi = kalem.get("urun_adi", "")
            miktar = kalem.get("miktar", 0)
            birim_fiyat = kalem.get("birim_fiyat", 0)
            kdv_orani = kalem.get("kdv_orani", 20)

            # Ürün eşleştirme (mevcut ürünlerle)
            urun_id = await self._match_product(db, urun_adi)

            fatura_kalem = FaturaKalem(
                fatura_id=fatura.id,
                urun_adi=urun_adi,
                urun_id=urun_id,
                miktar=miktar,
                birim=kalem.get("birim", "adet"),
                birim_fiyat=birim_fiyat,
                kdv_orani=kdv_orani,
                kdv_tutari=kalem.get("kdv_tutari", 0),
                satir_toplam=kalem.get("satir_toplam", 0),
            )
            db.add(fatura_kalem)

            # 4) Stok güncelle (eşleşen ürünler için)
            if urun_id:
                stok_miktar = miktar if tur == "satin_alma" else -miktar
                result = await db.execute(select(Urun).where(Urun.id == urun_id))
                urun = result.scalar_one_or_none()
                if urun:
                    hareket = StokHareket(
                        urun_id=urun_id,
                        miktar=stok_miktar,
                        hareket_tipi=tur,
                        kaynak_belge_id=fatura.id,
                        birim_fiyat=birim_fiyat,
                    )
                    db.add(hareket)
                    urun.mevcut_stok = (urun.mevcut_stok or 0) + int(stok_miktar)
                    if tur == "satin_alma":
                        urun.son_alis_maliyeti = birim_fiyat

                    stok_sonuclari.append({
                        "urun": urun.isim,
                        "urun_id": urun.id,
                        "degisim": stok_miktar,
                        "yeni_stok": urun.mevcut_stok,
                        "min_stok": urun.min_stok or 0,
                        "kritik": urun.mevcut_stok < urun.min_stok,
                    })

        # 5) KDV kaydı
        today = date.today()
        kdv_kayit = KdvKayit(
            fatura_id=fatura.id,
            tarih=fatura.tarih or today,
            tur="indirilecek" if tur == "satin_alma" else "hesaplanan",
            kdv_orani=kalemler[0].get("kdv_orani", 20) if kalemler else 20,
            kdv_tutari=parsed.get("toplam_kdv", 0),
            matrah=parsed.get("genel_toplam", 0) - parsed.get("toplam_kdv", 0),
            ay=(fatura.tarih or today).month,
            yil=(fatura.tarih or today).year,
        )
        db.add(kdv_kayit)

        # 6) Nakit akışı kaydı
        nakit = NakitAkisi(
            tarih=fatura.tarih or today,
            giris=fatura.toplam_tutar if tur == "satis" else 0,
            cikis=fatura.toplam_tutar if tur == "satin_alma" else 0,
            aciklama=f"Fatura: {fatura.fatura_no or 'Yeni'} - {fatura.karsi_taraf_isim}",
            kategori=tur,
            kaynak_belge_id=fatura.id,
        )
        db.add(nakit)

        await db.commit()

        # 7) Olayları tetikle
        await event_bus.emit(
            Events.FATURA_ISLENDI,
            fatura_id=fatura.id,
            tur=tur,
        )

        # Kritik stok kontrolü — hem uyarı oluştur hem event bus'ı tetikle
        for stok in stok_sonuclari:
            if stok["kritik"]:
                # DB'ye uyarı yaz
                uyari = Uyari(
                    tur="stok_kritik",
                    baslik=f"{stok['urun']} kritik seviyeye düştü",
                    mesaj=f"Mevcut stok: {stok['yeni_stok']}. Acil tedarik önerilir.",
                    oncelik="kritik",
                )
                db.add(uyari)
                await db.commit()

                # EK-2 DÜZELTMESİ: STOK_KRITIK event'ini tetikle
                # → main.py'deki _on_stok_kritik subscriber devreye girer
                # → supply_agent sipariş taslağı hazırlar
                # → alert_agent ek bildirim oluşturur
                await event_bus.emit(
                    Events.STOK_KRITIK,
                    urun_id=stok.get("urun_id"),
                    urun_adi=stok["urun"],
                    mevcut=stok["yeni_stok"],
                    minimum=stok.get("min_stok", 0),
                )

        return {
            "success": True,
            "fatura_id": fatura.id,
            "fatura_no": fatura.fatura_no,
            "tur": tur,
            "toplam_tutar": fatura.toplam_tutar,
            "kdv_tutari": fatura.kdv_tutari,
            "guven_skoru": parsed.get("guven_skoru", 0),
            "kalem_sayisi": len(kalemler),
            "stok_guncellemeleri": stok_sonuclari,
            "gemini_output": parsed,
        }


    async def analyze_timesheet(self, db: AsyncSession, image_data: bytes,
                                mime_type: str = "image/jpeg") -> dict:
        """Puantaj belgesini Gemini ile okur, sonuçları döndürür (DB'ye KAYDETMEZ).
        Kullanıcı onayladıktan sonra approve_timesheet ile kaydedilir."""

        parsed = await gemini_service.read_timesheet(image_data, mime_type)

        if "error" in parsed:
            return {"success": False, "error": parsed["error"]}

        donem = parsed.get("donem", {})
        ay = donem.get("ay", date.today().month)
        yil = donem.get("yil", date.today().year)

        sonuclar = []

        for calisan_data in parsed.get("calisanlar", []):
            isim = calisan_data.get("isim", "")
            calisma_gunleri = calisan_data.get("toplam_calisma_gunu", 0)
            mesai = calisan_data.get("mesai_saatleri", 0)
            izin = calisan_data.get("izin_gunu", 0)
            rapor = calisan_data.get("rapor_gunu", 0)

            result = await db.execute(
                select(Calisan).where(Calisan.ad_soyad.ilike(f"%{isim}%"))
            )
            calisan = result.scalar_one_or_none()

            if calisan:
                brut = calisan.brut_maas or 0
                gunluk = brut / 30
                mesai_ucreti = mesai * (gunluk / 8) * 1.5
                brut_toplam = calisma_gunleri * gunluk + mesai_ucreti

                sgk = brut_toplam * 0.14
                gelir_vergisi = (brut_toplam - sgk) * 0.15
                net = brut_toplam - sgk - gelir_vergisi

                sonuclar.append({
                    "calisan_id": calisan.id,
                    "calisan": calisan.ad_soyad,
                    "pozisyon": calisan.pozisyon,
                    "calisma_gunu": calisma_gunleri,
                    "mesai_saat": mesai,
                    "izin_gunu": izin,
                    "rapor_gunu": rapor,
                    "brut_maas": round(brut_toplam, 2),
                    "net_maas": round(net, 2),
                    "sgk": round(sgk, 2),
                    "gelir_vergisi": round(gelir_vergisi, 2),
                    "gemini_ham": calisan_data,
                })
            else:
                sonuclar.append({
                    "calisan": isim,
                    "uyari": "Çalışan sistemde bulunamadı",
                })

        toplam_maas = sum(s.get("brut_maas", 0) for s in sonuclar if "brut_maas" in s)

        return {
            "success": True,
            "donem": f"{ay}/{yil}",
            "ay": ay,
            "yil": yil,
            "calisan_sayisi": len(sonuclar),
            "toplam_brut_maas": round(toplam_maas, 2),
            "sonuclar": sonuclar,
        }

    async def approve_timesheet(self, db: AsyncSession, analiz_data: dict) -> dict:
        """Analiz edilmiş puantaj verisini onaylar ve DB'ye kaydeder."""

        ay = analiz_data.get("ay", date.today().month)
        yil = analiz_data.get("yil", date.today().year)
        sonuclar = analiz_data.get("sonuclar", [])

        kaydedilen = []

        for s in sonuclar:
            calisan_id = s.get("calisan_id")
            if not calisan_id:
                continue

            puantaj = Puantaj(
                calisan_id=calisan_id,
                yil=yil,
                ay=ay,
                calisma_gunleri=s.get("calisma_gunu", 0),
                mesai_saat=s.get("mesai_saat", 0),
                izin_gunu=s.get("izin_gunu", 0),
                rapor_gunu=s.get("rapor_gunu", 0),
                brut_maas=s.get("brut_maas", 0),
                net_maas=s.get("net_maas", 0),
                sgk_kesinti=s.get("sgk", 0),
                gelir_vergisi=s.get("gelir_vergisi", 0),
                gemini_ham_veri=json.dumps(s.get("gemini_ham", {}), ensure_ascii=False),
                onaylandi=True,
            )
            db.add(puantaj)
            kaydedilen.append({
                "calisan": s.get("calisan", ""),
                "brut_maas": s.get("brut_maas", 0),
                "net_maas": s.get("net_maas", 0),
            })

        await db.commit()

        toplam_maas = sum(s.get("brut_maas", 0) for s in kaydedilen)
        if toplam_maas > 0:
            nakit = NakitAkisi(
                tarih=date.today(),
                cikis=toplam_maas,
                aciklama=f"Maaş ödemeleri — {ay}/{yil}",
                kategori="maas",
            )
            db.add(nakit)
            await db.commit()

        await event_bus.emit(
            Events.FATURA_ISLENDI,
            fatura_id=None,
            tur="maas",
        )

        return {
            "success": True,
            "donem": f"{ay}/{yil}",
            "calisan_sayisi": len(kaydedilen),
            "toplam_brut_maas": round(toplam_maas, 2),
            "kaydedilen": kaydedilen,
        }

    async def _match_product(self, db: AsyncSession, urun_adi: str) -> Optional[int]:
        """Ürün adını veritabanındaki ürünlerle eşleştirir.
        Üç aşamalı: tam eşleşme → normalize eşleşme → kelime bazlı eşleşme.
        """
        if not urun_adi or not urun_adi.strip():
            return None

        # 1. Tam eşleşme
        result = await db.execute(
            select(Urun.id).where(Urun.isim == urun_adi)
        )
        urun_id = result.scalar_one_or_none()
        if urun_id:
            return urun_id

        # 2. Normalize edilmiş kısmi eşleşme (küçük harf, birim kısaltmaları standardize)
        normalized = self._normalize_product_name(urun_adi)
        result = await db.execute(
            select(Urun.id).where(Urun.isim.ilike(f"%{normalized}%"))
        )
        urun_id = result.scalar_one_or_none()
        if urun_id:
            return urun_id

        # 3. Kelime bazlı eşleşme — ürün adındaki her kelimeyi ayrı ayrı ara
        words = [w for w in normalized.split() if len(w) > 2]
        if words:
            # İlk anlamlı kelime ile ara (genelde ürün adının özü)
            result = await db.execute(
                select(Urun.id, Urun.isim).where(Urun.isim.ilike(f"%{words[0]}%"))
            )
            candidates = result.all()
            if len(candidates) == 1:
                return candidates[0][0]
            # Birden fazla aday varsa, en çok kelime eşleşeni seç
            if candidates:
                best_match = None
                best_score = 0
                for cid, cname in candidates:
                    cname_lower = cname.lower()
                    score = sum(1 for w in words if w in cname_lower)
                    if score > best_score:
                        best_score = score
                        best_match = cid
                return best_match

        return None

    @staticmethod
    def _normalize_product_name(name: str) -> str:
        """Ürün adını normalize eder: birim kısaltmalarını standardize et."""
        normalized = name.lower().strip()
        # Yaygın birim varyasyonları
        replacements = {
            "gr": "g", "gram": "g",
            "kg": "kg", "kilogram": "kg",
            "lt": "l", "litre": "l", "liter": "l",
            "ml": "ml", "mililitre": "ml",
            "ad.": "adet", "ad": "adet",
        }
        for old, new in replacements.items():
            # Sadece kelime sınırında değiştir
            normalized = normalized.replace(old, new)
        return normalized

    def _parse_date(self, date_str: Optional[str]) -> Optional[date]:
        """Tarih string'ini date objesine çevirir."""
        if not date_str:
            return date.today()
        try:
            return datetime.strptime(date_str, "%Y-%m-%d").date()
        except ValueError:
            return date.today()


# Singleton
document_service = DocumentService()
