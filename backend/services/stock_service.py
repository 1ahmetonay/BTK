"""
KOBİ AI Asistan — Stok Servisi
Stok yönetimi, kritik kontrol, ABC analizi, tedarikçi karşılaştırma.
"""

from datetime import date, datetime, timedelta, timezone
from typing import Optional
import unicodedata

from sqlalchemy import func, select, and_, or_
from sqlalchemy.ext.asyncio import AsyncSession

from database import Urun, StokHareket, FiyatGecmisi, Tedarikci
from services.event_bus import event_bus, Events


class StockService:
    """Stok yönetimi servisi."""

    async def get_overview(self, db: AsyncSession) -> dict:
        """Stok genel durumu: toplam SKU, kritik stok, stok değeri, devir hızı."""
        # Toplam aktif ürün
        result = await db.execute(select(func.count(Urun.id)).where(Urun.aktif == True))
        total_sku = result.scalar() or 0

        # Kritik stok sayısı
        result = await db.execute(
            select(func.count(Urun.id)).where(
                and_(Urun.aktif == True, Urun.mevcut_stok < Urun.min_stok)
            )
        )
        critical_count = result.scalar() or 0

        # Toplam stok değeri
        result = await db.execute(
            select(func.sum(Urun.mevcut_stok * Urun.son_alis_maliyeti)).where(Urun.aktif == True)
        )
        stock_value = result.scalar() or 0

        # Gerçek ortalama devir hızı hesabı (son 30 gündeki çıkış hareketleri)
        thirty_days_ago = datetime.now(timezone.utc) - timedelta(days=30)
        result = await db.execute(
            select(func.sum(func.abs(StokHareket.miktar)))
            .where(StokHareket.miktar < 0, StokHareket.tarih >= thirty_days_ago)
        )
        total_out = result.scalar() or 1
        result = await db.execute(
            select(func.sum(Urun.mevcut_stok)).where(Urun.aktif == True)
        )
        total_stock = result.scalar() or 1
        devir_gun = round(total_stock / (total_out / 30), 1) if total_out > 0 else 0

        # Tüm ürünler
        result = await db.execute(
            select(Urun).where(Urun.aktif == True).order_by(Urun.mevcut_stok.asc())
        )
        products = result.scalars().all()

        return {
            "toplam_sku": total_sku,
            "kritik_stok_sayisi": critical_count,
            "stok_degeri": round(stock_value, 2),
            "ortalama_devir_hizi": f"{devir_gun} gün" if devir_gun > 0 else "Hesaplanamadı",
            "urunler": [self._product_to_dict(p) for p in products],
        }

    async def get_critical_products(self, db: AsyncSession) -> list[dict]:
        """Kritik seviyedeki ürünleri getirir."""
        result = await db.execute(
            select(Urun).where(
                and_(Urun.aktif == True, Urun.mevcut_stok < Urun.min_stok)
            ).order_by(Urun.mevcut_stok.asc())
        )
        products = result.scalars().all()
        return [self._product_to_dict(p) for p in products]

    async def get_product_analysis(self, db: AsyncSession, sku: str) -> dict:
        """Tek ürün için detaylı analiz."""
        product = await self._find_product(db, sku)
        if not product:
            return {"error": f"Ürün bulunamadı: {sku}"}

        # Son hareketler
        result = await db.execute(
            select(StokHareket)
            .where(StokHareket.urun_id == product.id)
            .order_by(StokHareket.tarih.desc())
            .limit(20)
        )
        movements = result.scalars().all()

        # Fiyat geçmişi
        result = await db.execute(
            select(FiyatGecmisi)
            .where(FiyatGecmisi.urun_id == product.id)
            .order_by(FiyatGecmisi.tarih.asc())
        )
        prices = result.scalars().all()

        # Maliyet artışı hesapla
        cost_change = 0
        if len(prices) >= 2:
            first_price = prices[0].birim_fiyat
            last_price = prices[-1].birim_fiyat
            cost_change = round(((last_price - first_price) / first_price) * 100, 1)

        return {
            "urun": self._product_to_dict(product),
            "hareketler": [
                {
                    "tarih": m.tarih.isoformat() if m.tarih else None,
                    "miktar": m.miktar,
                    "tip": m.hareket_tipi,
                    "birim_fiyat": m.birim_fiyat,
                    "aciklama": m.aciklama,
                }
                for m in movements
            ],
            "fiyat_gecmisi": [
                {
                    "tarih": f.tarih.isoformat() if f.tarih else None,
                    "birim_fiyat": f.birim_fiyat,
                }
                for f in prices
            ],
            "maliyet_degisimi_yuzde": cost_change,
        }

    async def get_movements(self, db: AsyncSession, limit: int = 20) -> list[dict]:
        """Son stok hareketleri."""
        result = await db.execute(
            select(StokHareket, Urun.isim, Urun.sku)
            .join(Urun, StokHareket.urun_id == Urun.id)
            .order_by(StokHareket.tarih.desc())
            .limit(limit)
        )
        rows = result.all()
        return [
            {
                "id": row[0].id,
                "urun_adi": row[1],
                "sku": row[2],
                "miktar": row[0].miktar,
                "tip": row[0].hareket_tipi,
                "birim_fiyat": row[0].birim_fiyat,
                "aciklama": row[0].aciklama,
                "tarih": row[0].tarih.isoformat() if row[0].tarih else None,
            }
            for row in rows
        ]

    async def get_supplier_comparison(self, db: AsyncSession, sku: str) -> dict:
        """Bir ürün için tedarikçi karşılaştırması."""
        product = await self._find_product(db, sku)
        if not product:
            return {"error": f"Ürün bulunamadı: {sku}"}

        # Her tedarikçinin son fiyatını bul
        result = await db.execute(
            select(FiyatGecmisi, Tedarikci.isim, Tedarikci.ortalama_teslim_suresi_gun,
                   Tedarikci.guvenilirlik_skoru)
            .join(Tedarikci, FiyatGecmisi.tedarikci_id == Tedarikci.id)
            .where(FiyatGecmisi.urun_id == product.id)
            .order_by(FiyatGecmisi.tarih.desc())
        )
        rows = result.all()

        # Tedarikçi bazında en son fiyatı al
        seen = set()
        suppliers = []
        for row in rows:
            if row[1] not in seen:
                seen.add(row[1])
                suppliers.append({
                    "tedarikci_adi": row[1],
                    "birim_fiyat": row[0].birim_fiyat,
                    "teslim_suresi": f"{row[2]} gün" if row[2] else "Bilinmiyor",
                    "guvenilirlik": row[3],
                })

        return {
            "urun": product.isim,
            "sku": product.sku,
            "tedarikciler": suppliers,
        }

    async def get_abc_analysis(self, db: AsyncSession) -> dict:
        """ABC stok analizi — ciro etkisine göre ürün sınıflandırması."""
        result = await db.execute(
            select(Urun).where(Urun.aktif == True)
        )
        products = result.scalars().all()

        # Tahmini ciro etkisi (stok × satış fiyatı)
        items = []
        for p in products:
            revenue = (p.mevcut_stok or 0) * (p.son_satis_fiyati or 0)
            items.append({"urun": p.isim, "sku": p.sku, "ciro": revenue})

        items.sort(key=lambda x: x["ciro"], reverse=True)
        total = sum(i["ciro"] for i in items) or 1

        a_items, b_items, c_items = [], [], []
        cumulative = 0
        for item in items:
            cumulative += item["ciro"]
            pct = cumulative / total
            item["yuzde"] = round(item["ciro"] / total * 100, 1)
            if pct <= 0.70:
                item["grup"] = "A"
                a_items.append(item)
            elif pct <= 0.90:
                item["grup"] = "B"
                b_items.append(item)
            else:
                item["grup"] = "C"
                c_items.append(item)

        return {
            "a_grubu": {"sayi": len(a_items), "urunler": a_items},
            "b_grubu": {"sayi": len(b_items), "urunler": b_items},
            "c_grubu": {"sayi": len(c_items), "urunler": c_items},
        }

    async def update_stock_from_invoice(
        self, db: AsyncSession, urun_id: int, miktar: float,
        birim_fiyat: float, hareket_tipi: str, fatura_id: Optional[int] = None
    ) -> dict:
        """Fatura işlendiğinde stoku günceller ve gerekirse uyarı fırlatır."""
        result = await db.execute(select(Urun).where(Urun.id == urun_id))
        product = result.scalar_one_or_none()
        if not product:
            return {"error": "Ürün bulunamadı"}

        # Stok hareketi kaydet
        hareket = StokHareket(
            urun_id=urun_id,
            miktar=miktar,
            hareket_tipi=hareket_tipi,
            kaynak_belge_id=fatura_id,
            birim_fiyat=birim_fiyat,
        )
        db.add(hareket)

        # Mevcut stoku güncelle
        product.mevcut_stok = (product.mevcut_stok or 0) + int(miktar)
        if hareket_tipi == "satin_alma":
            product.son_alis_maliyeti = birim_fiyat

        await db.flush()

        # Kritik kontrol
        is_critical = product.mevcut_stok < product.min_stok
        if is_critical:
            await event_bus.emit(
                Events.STOK_KRITIK,
                urun_id=product.id,
                urun_adi=product.isim,
                mevcut=product.mevcut_stok,
                minimum=product.min_stok,
            )

        await event_bus.emit(
            Events.STOK_GUNCELLENDI,
            urun_id=product.id,
            miktar=miktar,
        )

        return {
            "urun": product.isim,
            "yeni_stok": product.mevcut_stok,
            "kritik": is_critical,
        }

    async def get_seasonality_pattern(self, db: AsyncSession, sku: str) -> dict:
        """Ürünün aylık hareket pattern'ını analiz eder (mevsimsellik)."""
        product = await self._find_product(db, sku)
        if not product:
            return {"error": f"Ürün bulunamadı: {sku}"}

        # Aylık hareket toplamları
        result = await db.execute(
            select(
                func.extract("month", StokHareket.tarih).label("ay"),
                func.sum(func.abs(StokHareket.miktar)).label("toplam_hareket"),
                func.count(StokHareket.id).label("islem_sayisi"),
            )
            .where(StokHareket.urun_id == product.id)
            .group_by(func.extract("month", StokHareket.tarih))
            .order_by("ay")
        )
        rows = result.all()

        ay_isimleri = {
            1: "Ocak", 2: "Şubat", 3: "Mart", 4: "Nisan", 5: "Mayıs",
            6: "Haziran", 7: "Temmuz", 8: "Ağustos", 9: "Eylül",
            10: "Ekim", 11: "Kasım", 12: "Aralık"
        }

        pattern = []
        for row in rows:
            ay = int(row[0]) if row[0] else 0
            pattern.append({
                "ay": ay,
                "ay_adi": ay_isimleri.get(ay, "?"),
                "toplam_hareket": float(row[1] or 0),
                "islem_sayisi": int(row[2] or 0),
            })

        # En yoğun ve en düşük ayları bul
        if pattern:
            en_yogun = max(pattern, key=lambda x: x["toplam_hareket"])
            en_dusuk = min(pattern, key=lambda x: x["toplam_hareket"])
        else:
            en_yogun = en_dusuk = None

        return {
            "urun": product.isim,
            "sku": product.sku,
            "aylik_pattern": pattern,
            "en_yogun_ay": en_yogun,
            "en_dusuk_ay": en_dusuk,
            "veri_sayisi": len(pattern),
        }

    async def simulate_price_change(self, db: AsyncSession, sku: str, price_change_pct: float) -> dict:
        """Fiyat değişikliğinin stok eritme hızına etkisini simüle eder (What-If)."""
        product = await self._find_product(db, sku)
        if not product:
            return {"error": f"Ürün bulunamadı: {sku}"}

        mevcut_fiyat = product.son_satis_fiyati or 0
        yeni_fiyat = mevcut_fiyat * (1 + price_change_pct / 100)

        # Basit fiyat-talep elastikiyeti (-1.2 varsayılan)
        elastikiyet = -1.2
        talep_degisimi = price_change_pct * elastikiyet  # %15 indirim → %18 talep artışı

        # Mevcut günlük tüketim tahmini
        daily_usage = max((product.min_stok or 1) / 7, 1)
        yeni_daily = daily_usage * (1 + talep_degisimi / 100)

        mevcut_stok = product.mevcut_stok or 0
        mevcut_kalan_gun = int(mevcut_stok / daily_usage) if daily_usage > 0 else 0
        yeni_kalan_gun = int(mevcut_stok / yeni_daily) if yeni_daily > 0 else 0

        # Gelir etkisi (aylık)
        aylik_satis_mevcut = daily_usage * 30 * mevcut_fiyat
        aylik_satis_yeni = yeni_daily * 30 * yeni_fiyat

        return {
            "urun": product.isim,
            "sku": product.sku,
            "mevcut_fiyat": round(mevcut_fiyat, 2),
            "yeni_fiyat": round(yeni_fiyat, 2),
            "fiyat_degisimi_pct": price_change_pct,
            "tahmini_talep_degisimi_pct": round(talep_degisimi, 1),
            "mevcut_stok": mevcut_stok,
            "mevcut_kalan_gun": mevcut_kalan_gun,
            "yeni_kalan_gun": yeni_kalan_gun,
            "aylik_gelir_mevcut": round(aylik_satis_mevcut, 2),
            "aylik_gelir_yeni": round(aylik_satis_yeni, 2),
            "gelir_farki": round(aylik_satis_yeni - aylik_satis_mevcut, 2),
        }

    async def _find_product(self, db: AsyncSession, sku_or_name: str) -> Optional[Urun]:
        """SKU'yu toleranslı çözer; AI ürün adı gönderirse ada göre de eşleştirir."""
        lookup = (sku_or_name or "").strip()
        if not lookup:
            return None

        normalized = lookup.upper()
        result = await db.execute(
            select(Urun)
            .where(
                and_(
                    Urun.aktif == True,
                    func.upper(func.trim(Urun.sku)) == normalized,
                )
            )
            .limit(1)
        )
        product = result.scalar_one_or_none()
        if product:
            return product

        name_lookup = lookup.lower()
        result = await db.execute(
            select(Urun)
            .where(
                and_(
                    Urun.aktif == True,
                    or_(
                        func.lower(func.trim(Urun.isim)) == name_lookup,
                        func.lower(Urun.isim).like(f"%{name_lookup}%"),
                    ),
                )
            )
            .order_by(Urun.isim.asc())
            .limit(1)
        )
        product = result.scalar_one_or_none()
        if product:
            return product

        normalized_lookup = self._normalize_lookup(lookup)
        result = await db.execute(
            select(Urun).where(Urun.aktif == True).order_by(Urun.isim.asc())
        )
        products = result.scalars().all()
        for product in products:
            if self._normalize_lookup(product.sku) == normalized_lookup:
                return product

        for product in products:
            normalized_name = self._normalize_lookup(product.isim)
            if normalized_name == normalized_lookup or normalized_lookup in normalized_name:
                return product

        return None

    def _normalize_lookup(self, value: str) -> str:
        """Arama değerini case/aksan/Türkçe karakter farklarından arındırır."""
        translated = (value or "").strip().casefold().translate(str.maketrans({
            "ı": "i",
            "ğ": "g",
            "ü": "u",
            "ş": "s",
            "ö": "o",
            "ç": "c",
        }))
        decomposed = unicodedata.normalize("NFKD", translated)
        return "".join(ch for ch in decomposed if not unicodedata.combining(ch))

    def _product_to_dict(self, p: Urun) -> dict:
        """Urun nesnesini dict'e çevirir."""
        is_critical = (p.mevcut_stok or 0) < (p.min_stok or 0)
        is_low = (p.mevcut_stok or 0) < (p.min_stok or 0) * 1.5

        if is_critical:
            status = "Kritik"
            tone = "danger"
        elif is_low:
            status = "Düşük"
            tone = "warning"
        else:
            status = "Normal"
            tone = "success"

        # Tahmini kalan gün (basit hesaplama)
        daily_usage = max((p.min_stok or 1) / 7, 1)  # haftalık min stok / 7
        days_remaining = int((p.mevcut_stok or 0) / daily_usage)

        return {
            "id": p.id,
            "sku": p.sku,
            "isim": p.isim,
            "kategori": p.kategori,
            "birim": p.birim,
            "mevcut_stok": p.mevcut_stok,
            "min_stok": p.min_stok,
            "max_stok": p.max_stok,
            "son_alis_maliyeti": p.son_alis_maliyeti,
            "son_satis_fiyati": p.son_satis_fiyati,
            "durum": status,
            "durum_ton": tone,
            "kalan_gun": f"{days_remaining} gün",
        }


# Singleton
stock_service = StockService()
