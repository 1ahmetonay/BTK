"""
Sentetik Tedarikçi Verisi — Mevcut seed_data üzerine ek veri yükler.

Kullanım:
  cd backend
  python seed_suppliers.py
"""

import asyncio
from datetime import date, timedelta
from database import (
    async_session, init_db,
    Tedarikci, Urun, FiyatGecmisi, Fatura, FaturaKalem,
    StokHareket, NakitAkisi, KdvKayit,
)


async def seed_suppliers():
    await init_db()
    today = date.today()

    async with async_session() as s:

        # ─── 8 Yeni Tedarikçi ─────────────────────────
        yeni_tedarikciler = [
            Tedarikci(isim="Karadeniz Çay A.Ş.", vkn="1110002220",
                      email="satis@karadenizcay.com.tr", telefon="0462 321 1122",
                      ortalama_teslim_suresi_gun=4, guvenilirlik_skoru=9.3),
            Tedarikci(isim="Anadolu Baharatçılık", vkn="2220003330",
                      email="info@anadolubaharat.com", telefon="0352 225 3344",
                      ortalama_teslim_suresi_gun=6, guvenilirlik_skoru=7.4),
            Tedarikci(isim="İstanbul Kağıtçılık", vkn="3330004440",
                      email="siparis@istkagit.com.tr", telefon="0212 678 9900",
                      ortalama_teslim_suresi_gun=2, guvenilirlik_skoru=8.9),
            Tedarikci(isim="Doğa Organik Gıda", vkn="4440005550",
                      email="organik@dogagida.com", telefon="0242 312 5566",
                      ortalama_teslim_suresi_gun=7, guvenilirlik_skoru=6.8),
            Tedarikci(isim="Güneş Süt Ürünleri", vkn="5550006660",
                      email="toptan@gunessut.com.tr", telefon="0222 411 7788",
                      ortalama_teslim_suresi_gun=1, guvenilirlik_skoru=9.5),
            Tedarikci(isim="Merkez Ambalaj San.", vkn="6660007770",
                      email="satis@merkezambalaj.com", telefon="0264 275 1234",
                      ortalama_teslim_suresi_gun=3, guvenilirlik_skoru=8.0),
            Tedarikci(isim="Trakya Şekerleme", vkn="7770008880",
                      email="info@trakyaseker.com.tr", telefon="0284 213 4455",
                      ortalama_teslim_suresi_gun=5, guvenilirlik_skoru=7.6),
            Tedarikci(isim="Akdeniz İthalat", vkn="8880009990",
                      email="ithalat@akdeniztr.com", telefon="0324 336 6677",
                      ortalama_teslim_suresi_gun=10, guvenilirlik_skoru=6.2),
        ]
        s.add_all(yeni_tedarikciler)
        await s.flush()

        # ─── 10 Yeni Ürün ─────────────────────────────
        yeni_urunler = [
            Urun(sku="CAY-500", isim="Rize Çayı 500g", kategori="İçecek", birim="adet",
                 min_stok=40, max_stok=300, varsayilan_tedarikci_id=5,
                 son_satis_fiyati=95.0, son_alis_maliyeti=62.0, mevcut_stok=78),
            Urun(sku="CAY-DML", isim="Demlik Poşet Çay 100'lü", kategori="İçecek", birim="kutu",
                 min_stok=25, max_stok=150, varsayilan_tedarikci_id=5,
                 son_satis_fiyati=140.0, son_alis_maliyeti=88.0, mevcut_stok=15),
            Urun(sku="BHR-TAR", isim="Toz Tarçın 250g", kategori="Baharat", birim="adet",
                 min_stok=15, max_stok=80, varsayilan_tedarikci_id=6,
                 son_satis_fiyati=68.0, son_alis_maliyeti=42.0, mevcut_stok=52),
            Urun(sku="BHR-ZNC", isim="Toz Zencefil 200g", kategori="Baharat", birim="adet",
                 min_stok=10, max_stok=60, varsayilan_tedarikci_id=6,
                 son_satis_fiyati=85.0, son_alis_maliyeti=55.0, mevcut_stok=7),
            Urun(sku="KRM-SUT", isim="Krema (Süt) 1L", kategori="Süt Ürünü", birim="litre",
                 min_stok=30, max_stok=120, varsayilan_tedarikci_id=9,
                 son_satis_fiyati=72.0, son_alis_maliyeti=48.0, mevcut_stok=55),
            Urun(sku="CKL-250", isim="Sıcak Çikolata Tozu 250g", kategori="İçecek", birim="adet",
                 min_stok=20, max_stok=100, varsayilan_tedarikci_id=12,
                 son_satis_fiyati=165.0, son_alis_maliyeti=110.0, mevcut_stok=18),
            Urun(sku="AMB-KCK", isim="Kargo Poşeti Küçük Boy", kategori="Ambalaj", birim="adet",
                 min_stok=100, max_stok=2000, varsayilan_tedarikci_id=10,
                 son_satis_fiyati=5.50, son_alis_maliyeti=3.20, mevcut_stok=450),
            Urun(sku="KUP-12", isim="Karton Bardak 12oz", kategori="Sarf", birim="adet",
                 min_stok=300, max_stok=4000, varsayilan_tedarikci_id=10,
                 son_satis_fiyati=2.40, son_alis_maliyeti=1.60, mevcut_stok=180),
            Urun(sku="SEK-ESM", isim="Esmer Şeker 1kg", kategori="Gıda", birim="kg",
                 min_stok=15, max_stok=80, varsayilan_tedarikci_id=11,
                 son_satis_fiyati=75.0, son_alis_maliyeti=52.0, mevcut_stok=38),
            Urun(sku="BAL-500", isim="Çiçek Balı 500g", kategori="Gıda", birim="adet",
                 min_stok=10, max_stok=50, varsayilan_tedarikci_id=8,
                 son_satis_fiyati=220.0, son_alis_maliyeti=155.0, mevcut_stok=22),
        ]
        s.add_all(yeni_urunler)
        await s.flush()

        # ─── Çapraz Fiyat Geçmişi (Rekabet Analizi) ───
        # Mevcut ürünler için alternatif tedarikçi fiyatları
        # urun_id 1-8: mevcut ürünler, 9-18: yeni ürünler
        # tedarikci_id 1-4: mevcut, 5-12: yeni
        fiyat_kayitlari = [
            # Türk Kahvesi — 3 farklı tedarikçiden fiyat takibi
            FiyatGecmisi(urun_id=1, tedarikci_id=3, tarih=today - timedelta(days=90), birim_fiyat=125.0),
            FiyatGecmisi(urun_id=1, tedarikci_id=3, tarih=today, birim_fiyat=132.0),
            FiyatGecmisi(urun_id=1, tedarikci_id=12, tarih=today, birim_fiyat=115.0),
            # Süt — 2 tedarikçi
            FiyatGecmisi(urun_id=7, tedarikci_id=2, tarih=today - timedelta(days=120), birim_fiyat=26.0),
            FiyatGecmisi(urun_id=7, tedarikci_id=2, tarih=today - timedelta(days=60), birim_fiyat=29.0),
            FiyatGecmisi(urun_id=7, tedarikci_id=2, tarih=today, birim_fiyat=32.0),
            FiyatGecmisi(urun_id=7, tedarikci_id=9, tarih=today, birim_fiyat=28.5),
            # Rize Çayı — tedarikçi fiyat geçmişi
            FiyatGecmisi(urun_id=9, tedarikci_id=5, tarih=today - timedelta(days=150), birim_fiyat=48.0),
            FiyatGecmisi(urun_id=9, tedarikci_id=5, tarih=today - timedelta(days=90), birim_fiyat=54.0),
            FiyatGecmisi(urun_id=9, tedarikci_id=5, tarih=today - timedelta(days=30), birim_fiyat=59.0),
            FiyatGecmisi(urun_id=9, tedarikci_id=5, tarih=today, birim_fiyat=62.0),
            # Sıcak Çikolata — ithalat fiyatı artışı
            FiyatGecmisi(urun_id=14, tedarikci_id=12, tarih=today - timedelta(days=180), birim_fiyat=78.0),
            FiyatGecmisi(urun_id=14, tedarikci_id=12, tarih=today - timedelta(days=120), birim_fiyat=85.0),
            FiyatGecmisi(urun_id=14, tedarikci_id=12, tarih=today - timedelta(days=60), birim_fiyat=98.0),
            FiyatGecmisi(urun_id=14, tedarikci_id=12, tarih=today, birim_fiyat=110.0),
            # Zencefil — alternatif tedarikçi
            FiyatGecmisi(urun_id=12, tedarikci_id=6, tarih=today, birim_fiyat=55.0),
            FiyatGecmisi(urun_id=12, tedarikci_id=8, tarih=today, birim_fiyat=62.0),
            # Krema — 2 tedarikçi karşılaştırma
            FiyatGecmisi(urun_id=13, tedarikci_id=9, tarih=today - timedelta(days=60), birim_fiyat=42.0),
            FiyatGecmisi(urun_id=13, tedarikci_id=9, tarih=today, birim_fiyat=48.0),
            FiyatGecmisi(urun_id=13, tedarikci_id=2, tarih=today, birim_fiyat=51.0),
            # Bal — mevsimsel fiyat
            FiyatGecmisi(urun_id=18, tedarikci_id=8, tarih=today - timedelta(days=180), birim_fiyat=120.0),
            FiyatGecmisi(urun_id=18, tedarikci_id=8, tarih=today - timedelta(days=90), birim_fiyat=140.0),
            FiyatGecmisi(urun_id=18, tedarikci_id=8, tarih=today, birim_fiyat=155.0),
        ]
        s.add_all(fiyat_kayitlari)

        # ─── Yeni Tedarikçilerden Faturalar ────────────
        faturalar = [
            Fatura(fatura_no="FAT-2026-0150", tarih=today - timedelta(days=5), tur="satin_alma",
                   karsi_taraf_isim="Karadeniz Çay A.Ş.", karsi_taraf_vkn="1110002220",
                   tedarikci_id=5, toplam_tutar=9300.0, kdv_tutari=1550.0, net_tutar=7750.0,
                   odeme_durumu="bekliyor", vade_tarihi=today + timedelta(days=25), islendi=True),
            Fatura(fatura_no="FAT-2026-0151", tarih=today - timedelta(days=3), tur="satin_alma",
                   karsi_taraf_isim="Anadolu Baharatçılık", karsi_taraf_vkn="2220003330",
                   tedarikci_id=6, toplam_tutar=4200.0, kdv_tutari=700.0, net_tutar=3500.0,
                   odeme_durumu="bekliyor", vade_tarihi=today + timedelta(days=15), islendi=True),
            Fatura(fatura_no="FAT-2026-0152", tarih=today - timedelta(days=12), tur="satis",
                   karsi_taraf_isim="Saray Pastanesi", karsi_taraf_vkn="6543217890",
                   toplam_tutar=15600.0, kdv_tutari=2600.0, net_tutar=13000.0,
                   odeme_durumu="gecikti", vade_tarihi=today - timedelta(days=5), islendi=True),
            Fatura(fatura_no="FAT-2026-0153", tarih=today - timedelta(days=1), tur="satin_alma",
                   karsi_taraf_isim="Güneş Süt Ürünleri", karsi_taraf_vkn="5550006660",
                   tedarikci_id=9, toplam_tutar=6480.0, kdv_tutari=1080.0, net_tutar=5400.0,
                   odeme_durumu="odendi", odeme_tarihi=today, islendi=True),
            Fatura(fatura_no="FAT-2026-0154", tarih=today, tur="satis",
                   karsi_taraf_isim="Deniz Otel Grubu", karsi_taraf_vkn="7891234560",
                   toplam_tutar=28800.0, kdv_tutari=4800.0, net_tutar=24000.0,
                   odeme_durumu="bekliyor", vade_tarihi=today + timedelta(days=30), islendi=True),
        ]
        s.add_all(faturalar)
        await s.flush()

        # ─── Stok Hareketleri ──────────────────────────
        from datetime import datetime
        now = datetime.utcnow()
        hareketler = [
            StokHareket(urun_id=9, miktar=100, hareket_tipi="satin_alma", birim_fiyat=62.0,
                        aciklama="Karadeniz Çay'dan alım", tarih=now - timedelta(days=5)),
            StokHareket(urun_id=9, miktar=-22, hareket_tipi="satis", birim_fiyat=95.0,
                        aciklama="Saray Pastanesi satışı", tarih=now - timedelta(days=3)),
            StokHareket(urun_id=12, miktar=-3, hareket_tipi="satis", birim_fiyat=85.0,
                        aciklama="Online satış", tarih=now - timedelta(days=2)),
            StokHareket(urun_id=14, miktar=30, hareket_tipi="satin_alma", birim_fiyat=110.0,
                        aciklama="Akdeniz İthalat sipariş", tarih=now - timedelta(days=7)),
            StokHareket(urun_id=14, miktar=-12, hareket_tipi="satis", birim_fiyat=165.0,
                        aciklama="Deniz Otel toptan", tarih=now - timedelta(days=1)),
            StokHareket(urun_id=13, miktar=60, hareket_tipi="satin_alma", birim_fiyat=48.0,
                        aciklama="Güneş Süt sipariş", tarih=now - timedelta(days=1)),
            StokHareket(urun_id=13, miktar=-5, hareket_tipi="satis", birim_fiyat=72.0,
                        aciklama="Günlük satış", tarih=now - timedelta(hours=6)),
            StokHareket(urun_id=16, miktar=-270, hareket_tipi="satis", birim_fiyat=2.40,
                        aciklama="Toptan bardak satışı", tarih=now - timedelta(days=4)),
            StokHareket(urun_id=18, miktar=15, hareket_tipi="satin_alma", birim_fiyat=155.0,
                        aciklama="Doğa Organik bal alımı", tarih=now - timedelta(days=10)),
        ]
        s.add_all(hareketler)

        # ─── Nakit Akışı (yeni tedarikçi ödemeleri) ────
        nakit = [
            NakitAkisi(tarih=today - timedelta(days=5), giris=0, cikis=9300, bakiye=82300,
                       aciklama="Karadeniz Çay A.Ş. ödeme", kategori="satin_alma"),
            NakitAkisi(tarih=today - timedelta(days=3), giris=0, cikis=4200, bakiye=78100,
                       aciklama="Anadolu Baharatçılık ödeme", kategori="satin_alma"),
            NakitAkisi(tarih=today - timedelta(days=1), giris=0, cikis=6480, bakiye=71620,
                       aciklama="Güneş Süt Ürünleri ödeme", kategori="satin_alma"),
            NakitAkisi(tarih=today, giris=28800, cikis=0, bakiye=100420,
                       aciklama="Deniz Otel Grubu tahsilat", kategori="satis"),
        ]
        s.add_all(nakit)

        # ─── KDV Kayıtları ─────────────────────────────
        ay, yil = today.month, today.year
        kdv = [
            KdvKayit(tarih=today - timedelta(days=5), tur="indirilecek", kdv_orani=20,
                     kdv_tutari=1550.0, matrah=7750.0, ay=ay, yil=yil),
            KdvKayit(tarih=today - timedelta(days=3), tur="indirilecek", kdv_orani=20,
                     kdv_tutari=700.0, matrah=3500.0, ay=ay, yil=yil),
            KdvKayit(tarih=today - timedelta(days=12), tur="hesaplanan", kdv_orani=20,
                     kdv_tutari=2600.0, matrah=13000.0, ay=ay, yil=yil),
            KdvKayit(tarih=today - timedelta(days=1), tur="indirilecek", kdv_orani=20,
                     kdv_tutari=1080.0, matrah=5400.0, ay=ay, yil=yil),
            KdvKayit(tarih=today, tur="hesaplanan", kdv_orani=20,
                     kdv_tutari=4800.0, matrah=24000.0, ay=ay, yil=yil),
        ]
        s.add_all(kdv)

        await s.commit()
        print("[OK] Sentetik tedarikci verileri yuklendi!")
        print(f"   -> {len(yeni_tedarikciler)} yeni tedarikci")
        print(f"   -> {len(yeni_urunler)} yeni urun")
        print(f"   -> {len(fiyat_kayitlari)} fiyat gecmisi kaydi")
        print(f"   -> {len(faturalar)} fatura")
        print(f"   -> {len(hareketler)} stok hareketi")
        print(f"   -> {len(nakit)} nakit akisi kaydi")
        print(f"   -> {len(kdv)} KDV kaydi")


if __name__ == "__main__":
    asyncio.run(seed_suppliers())
