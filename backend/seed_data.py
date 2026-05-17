"""
KOBİ AI Asistan — Seed Data
Veritabanını demo verileriyle doldurur.
"""

import asyncio
from datetime import date, datetime, timedelta
from database import (
    async_session, init_db,
    Urun, StokHareket, FiyatGecmisi, Tedarikci, Fatura, FaturaKalem,
    Calisan, Puantaj, Uyari, NakitAkisi, KdvKayit,
)


async def seed_database():
    """Veritabanını demo verilerle doldurur."""
    await init_db()

    async with async_session() as session:
        # ─── Tedarikçiler ─────────────────────────────
        tedarikciler = [
            Tedarikci(
                isim="Aksoy Tedarik", vkn="1234567890", email="info@aksoytedarik.com",
                telefon="0212 555 1234", ortalama_teslim_suresi_gun=3, guvenilirlik_skoru=8.7,
            ),
            Tedarikci(
                isim="Marmara Gıda", vkn="0987654321", email="siparis@marmaragida.com",
                telefon="0216 444 5678", ortalama_teslim_suresi_gun=5, guvenilirlik_skoru=7.9,
            ),
            Tedarikci(
                isim="Ege Kahve Deposu", vkn="5678901234", email="satis@egekahve.com",
                telefon="0232 333 9012", ortalama_teslim_suresi_gun=2, guvenilirlik_skoru=9.1,
            ),
            Tedarikci(
                isim="Yıldız Ambalaj", vkn="3456789012", email="info@yildizambalaj.com",
                telefon="0224 222 3456", ortalama_teslim_suresi_gun=4, guvenilirlik_skoru=8.2,
            ),
        ]
        session.add_all(tedarikciler)
        await session.flush()

        # ─── Ürünler ──────────────────────────────────
        urunler = [
            Urun(sku="KHV-250", isim="Türk Kahvesi 250g", kategori="Kahve", birim="adet",
                 min_stok=30, max_stok=200, varsayilan_tedarikci_id=1,
                 son_satis_fiyati=180.0, son_alis_maliyeti=120.0, mevcut_stok=12),
            Urun(sku="KHV-1000", isim="Filtre Kahve 1kg", kategori="Kahve", birim="adet",
                 min_stok=20, max_stok=100, varsayilan_tedarikci_id=1,
                 son_satis_fiyati=450.0, son_alis_maliyeti=310.0, mevcut_stok=8),
            Urun(sku="KHV-ESP", isim="Espresso Çekirdeği 1kg", kategori="Kahve", birim="adet",
                 min_stok=20, max_stok=80, varsayilan_tedarikci_id=3,
                 son_satis_fiyati=420.0, son_alis_maliyeti=285.0, mevcut_stok=42),
            Urun(sku="ETK-150", isim="Termal Etiket 100x150", kategori="Ambalaj", birim="rulo",
                 min_stok=50, max_stok=300, varsayilan_tedarikci_id=4,
                 son_satis_fiyati=25.0, son_alis_maliyeti=17.50, mevcut_stok=24),
            Urun(sku="AMB-001", isim="Kargo Poşeti Orta Boy", kategori="Ambalaj", birim="adet",
                 min_stok=80, max_stok=1000, varsayilan_tedarikci_id=4,
                 son_satis_fiyati=8.0, son_alis_maliyeti=5.50, mevcut_stok=31),
            Urun(sku="KUP-001", isim="Karton Bardak 8oz", kategori="Sarf", birim="adet",
                 min_stok=400, max_stok=5000, varsayilan_tedarikci_id=4,
                 son_satis_fiyati=1.80, son_alis_maliyeti=1.20, mevcut_stok=1200),
            Urun(sku="SUT-1L", isim="Süt 1L", kategori="İçecek", birim="litre",
                 min_stok=50, max_stok=200, varsayilan_tedarikci_id=2,
                 son_satis_fiyati=45.0, son_alis_maliyeti=32.0, mevcut_stok=85),
            Urun(sku="SEK-1KG", isim="Toz Şeker 1kg", kategori="Gıda", birim="kg",
                 min_stok=20, max_stok=100, varsayilan_tedarikci_id=2,
                 son_satis_fiyati=55.0, son_alis_maliyeti=38.0, mevcut_stok=45),
        ]
        session.add_all(urunler)
        await session.flush()

        # ─── Stok Hareketleri ─────────────────────────
        now = datetime.utcnow()
        hareketler = [
            StokHareket(urun_id=1, miktar=50, hareket_tipi="satin_alma", birim_fiyat=120.0,
                        aciklama="Aksoy Tedarik'ten alım", tarih=now - timedelta(hours=2)),
            StokHareket(urun_id=2, miktar=-30, hareket_tipi="satis", birim_fiyat=450.0,
                        aciklama="Online satış", tarih=now - timedelta(hours=4)),
            StokHareket(urun_id=5, miktar=500, hareket_tipi="satin_alma", birim_fiyat=5.50,
                        aciklama="Yıldız Ambalaj sipariş", tarih=now - timedelta(days=1)),
            StokHareket(urun_id=4, miktar=-6, hareket_tipi="sayim", birim_fiyat=17.50,
                        aciklama="Manuel sayım farkı", tarih=now - timedelta(days=1, hours=10)),
            StokHareket(urun_id=1, miktar=-38, hareket_tipi="satis", birim_fiyat=180.0,
                        aciklama="Toptan satış", tarih=now - timedelta(days=3)),
            StokHareket(urun_id=3, miktar=20, hareket_tipi="satin_alma", birim_fiyat=285.0,
                        aciklama="Ege Kahve'den alım", tarih=now - timedelta(days=5)),
            StokHareket(urun_id=7, miktar=100, hareket_tipi="satin_alma", birim_fiyat=32.0,
                        aciklama="Marmara Gıda sipariş", tarih=now - timedelta(days=7)),
            StokHareket(urun_id=7, miktar=-15, hareket_tipi="satis", birim_fiyat=45.0,
                        aciklama="Günlük satış", tarih=now - timedelta(days=1)),
        ]
        session.add_all(hareketler)

        # ─── Fiyat Geçmişi ───────────────────────────
        today = date.today()
        fiyatlar = [
            # Türk Kahvesi - son 6 ay maliyet artışı
            FiyatGecmisi(urun_id=1, tedarikci_id=1, tarih=today - timedelta(days=180), birim_fiyat=92.0),
            FiyatGecmisi(urun_id=1, tedarikci_id=1, tarih=today - timedelta(days=150), birim_fiyat=98.0),
            FiyatGecmisi(urun_id=1, tedarikci_id=1, tarih=today - timedelta(days=120), birim_fiyat=105.0),
            FiyatGecmisi(urun_id=1, tedarikci_id=1, tarih=today - timedelta(days=90), birim_fiyat=110.0),
            FiyatGecmisi(urun_id=1, tedarikci_id=1, tarih=today - timedelta(days=60), birim_fiyat=115.0),
            FiyatGecmisi(urun_id=1, tedarikci_id=1, tarih=today - timedelta(days=30), birim_fiyat=118.0),
            FiyatGecmisi(urun_id=1, tedarikci_id=1, tarih=today, birim_fiyat=120.0),
            # Filtre Kahve - daha yüksek artış
            FiyatGecmisi(urun_id=2, tedarikci_id=1, tarih=today - timedelta(days=180), birim_fiyat=236.0),
            FiyatGecmisi(urun_id=2, tedarikci_id=1, tarih=today - timedelta(days=120), birim_fiyat=260.0),
            FiyatGecmisi(urun_id=2, tedarikci_id=1, tarih=today - timedelta(days=60), birim_fiyat=290.0),
            FiyatGecmisi(urun_id=2, tedarikci_id=1, tarih=today, birim_fiyat=310.0),
            # Filtre Kahve - farklı tedarikçiler
            FiyatGecmisi(urun_id=2, tedarikci_id=2, tarih=today, birim_fiyat=298.0),
            FiyatGecmisi(urun_id=2, tedarikci_id=3, tarih=today, birim_fiyat=322.0),
        ]
        session.add_all(fiyatlar)

        # ─── Faturalar ────────────────────────────────
        faturalar = [
            Fatura(
                fatura_no="FAT-2026-0142", tarih=today, tur="satin_alma",
                karsi_taraf_isim="Aksoy Tedarik", karsi_taraf_vkn="1234567890",
                tedarikci_id=1, toplam_tutar=7200.0, kdv_tutari=1200.0, net_tutar=6000.0,
                odeme_durumu="bekliyor", vade_tarihi=today + timedelta(days=30),
                islendi=True,
            ),
            Fatura(
                fatura_no="FAT-2026-0141", tarih=today - timedelta(days=2), tur="satis",
                karsi_taraf_isim="Yılmaz Market", karsi_taraf_vkn="9876543210",
                toplam_tutar=13500.0, kdv_tutari=2250.0, net_tutar=11250.0,
                odeme_durumu="odendi", odeme_tarihi=today - timedelta(days=1),
                islendi=True,
            ),
            Fatura(
                fatura_no="FAT-2026-0138", tarih=today - timedelta(days=9), tur="satin_alma",
                karsi_taraf_isim="Marmara Gıda", karsi_taraf_vkn="0987654321",
                tedarikci_id=2, toplam_tutar=3200.0, kdv_tutari=640.0, net_tutar=2560.0,
                odeme_durumu="gecikti", vade_tarihi=today - timedelta(days=2),
                islendi=True,
            ),
            Fatura(
                fatura_no="FAT-2026-0135", tarih=today - timedelta(days=15), tur="satis",
                karsi_taraf_isim="Ahmet Usta Kafe", karsi_taraf_vkn="4567891230",
                toplam_tutar=8750.0, kdv_tutari=1458.0, net_tutar=7292.0,
                odeme_durumu="gecikti", vade_tarihi=today - timedelta(days=9),
                islendi=True,
            ),
        ]
        session.add_all(faturalar)
        await session.flush()

        # ─── Fatura Kalemleri ──────────────────────────
        kalemler = [
            FaturaKalem(fatura_id=1, urun_adi="Türk Kahvesi 250g", urun_id=1, miktar=50,
                        birim_fiyat=120.0, kdv_orani=20, kdv_tutari=1200.0, satir_toplam=7200.0),
            FaturaKalem(fatura_id=2, urun_adi="Filtre Kahve 1kg", urun_id=2, miktar=30,
                        birim_fiyat=450.0, kdv_orani=20, kdv_tutari=2250.0, satir_toplam=13500.0),
            FaturaKalem(fatura_id=3, urun_adi="Süt 1L", urun_id=7, miktar=100,
                        birim_fiyat=32.0, kdv_orani=10, kdv_tutari=320.0, satir_toplam=3200.0),
            FaturaKalem(fatura_id=4, urun_adi="Espresso Çekirdeği 1kg", urun_id=3, miktar=15,
                        birim_fiyat=420.0, kdv_orani=20, kdv_tutari=1050.0, satir_toplam=6300.0),
            FaturaKalem(fatura_id=4, urun_adi="Karton Bardak 8oz", urun_id=6, miktar=500,
                        birim_fiyat=1.80, kdv_orani=20, kdv_tutari=150.0, satir_toplam=900.0),
        ]
        session.add_all(kalemler)

        # ─── Çalışanlar ───────────────────────────────
        calisanlar = [
            Calisan(ad_soyad="Ahmet Yılmaz", pozisyon="Barista", brut_maas=28000.0,
                    ise_giris_tarihi=date(2024, 3, 15)),
            Calisan(ad_soyad="Fatma Demir", pozisyon="Kasiyer", brut_maas=25000.0,
                    ise_giris_tarihi=date(2024, 6, 1)),
            Calisan(ad_soyad="Mehmet Kaya", pozisyon="Depocu", brut_maas=26000.0,
                    ise_giris_tarihi=date(2025, 1, 10)),
            Calisan(ad_soyad="Ayşe Çelik", pozisyon="Satış Sorumlusu", brut_maas=30000.0,
                    ise_giris_tarihi=date(2023, 9, 1)),
            Calisan(ad_soyad="Mustafa Öz", pozisyon="Kurye", brut_maas=24000.0,
                    ise_giris_tarihi=date(2025, 4, 15)),
        ]
        session.add_all(calisanlar)
        await session.flush()

        # ─── Puantaj (Nisan 2026) ─────────────────────
        puantajlar = [
            Puantaj(calisan_id=1, yil=2026, ay=4, calisma_gunleri=22, mesai_saat=12,
                    izin_gunu=0, rapor_gunu=0, brut_maas=28000, net_maas=22540,
                    sgk_kesinti=3920, gelir_vergisi=1540),
            Puantaj(calisan_id=2, yil=2026, ay=4, calisma_gunleri=20, mesai_saat=0,
                    izin_gunu=2, rapor_gunu=0, brut_maas=25000, net_maas=19975,
                    sgk_kesinti=3500, gelir_vergisi=1525),
            Puantaj(calisan_id=3, yil=2026, ay=4, calisma_gunleri=21, mesai_saat=8,
                    izin_gunu=1, rapor_gunu=0, brut_maas=26000, net_maas=20930,
                    sgk_kesinti=3640, gelir_vergisi=1430),
            Puantaj(calisan_id=4, yil=2026, ay=4, calisma_gunleri=22, mesai_saat=16,
                    izin_gunu=0, rapor_gunu=0, brut_maas=30000, net_maas=24150,
                    sgk_kesinti=4200, gelir_vergisi=1650),
            Puantaj(calisan_id=5, yil=2026, ay=4, calisma_gunleri=18, mesai_saat=0,
                    izin_gunu=1, rapor_gunu=3, brut_maas=24000, net_maas=17280,
                    sgk_kesinti=3360, gelir_vergisi=1360),
            # ─── Puantaj (Mayıs 2026 — güncel ay) ─────────
            Puantaj(calisan_id=1, yil=2026, ay=5, calisma_gunleri=21, mesai_saat=14,
                    izin_gunu=1, rapor_gunu=0, brut_maas=28000, net_maas=22800,
                    sgk_kesinti=3920, gelir_vergisi=1280),
            Puantaj(calisan_id=2, yil=2026, ay=5, calisma_gunleri=22, mesai_saat=0,
                    izin_gunu=0, rapor_gunu=0, brut_maas=25000, net_maas=20100,
                    sgk_kesinti=3500, gelir_vergisi=1400),
            Puantaj(calisan_id=3, yil=2026, ay=5, calisma_gunleri=19, mesai_saat=6,
                    izin_gunu=3, rapor_gunu=0, brut_maas=26000, net_maas=20650,
                    sgk_kesinti=3640, gelir_vergisi=1710),
            Puantaj(calisan_id=4, yil=2026, ay=5, calisma_gunleri=22, mesai_saat=18,
                    izin_gunu=0, rapor_gunu=0, brut_maas=30000, net_maas=24500,
                    sgk_kesinti=4200, gelir_vergisi=1300),
            Puantaj(calisan_id=5, yil=2026, ay=5, calisma_gunleri=20, mesai_saat=2,
                    izin_gunu=2, rapor_gunu=0, brut_maas=24000, net_maas=18900,
                    sgk_kesinti=3360, gelir_vergisi=1740),
        ]
        session.add_all(puantajlar)

        # ─── Uyarılar ─────────────────────────────────
        uyarilar = [
            Uyari(
                tur="stok_kritik", baslik="Türk Kahvesi 250g kritik seviyede",
                mesaj="Mevcut stok: 12 adet. Minimum seviye: 30. Tahmini 4 günlük stok kaldı. Tedarikçi Aksoy Tedarik'e sipariş önerilir.",
                oncelik="kritik", ilgili_entity_tipi="urun", ilgili_entity_id=1,
            ),
            Uyari(
                tur="stok_kritik", baslik="Filtre Kahve 1kg kritik seviyede",
                mesaj="Mevcut stok: 8 adet. Minimum seviye: 20. Tahmini 6 günlük stok kaldı.",
                oncelik="kritik", ilgili_entity_tipi="urun", ilgili_entity_id=2,
            ),
            Uyari(
                tur="nakit_acik", baslik="14 gün sonra nakit açığı riski",
                mesaj="Önümüzdeki 14 gün içinde 42.000 TL nakit açığı oluşması bekleniyor. Gecikmiş ödemelerin tahsili ve giderlerin ötelenmesi değerlendirilmeli.",
                oncelik="kritik",
            ),
            Uyari(
                tur="gecikmis_odeme", baslik="Ahmet Usta Kafe 9 günlük gecikmiş ödeme",
                mesaj="8.750 TL tutarındaki satış faturası 9 gündür ödenmedi. Hatırlatma yapılması önerilir.",
                oncelik="yuksek", ilgili_entity_tipi="fatura", ilgili_entity_id=4,
            ),
            Uyari(
                tur="kdv_tarihi", baslik="KDV beyanname son tarihi yaklaşıyor",
                mesaj="Bu ay KDV beyanname son tarihi: 26 Mayıs. Toplam hesaplanan KDV: 18.400 TL.",
                oncelik="yuksek",
            ),
            Uyari(
                tur="stok_kritik", baslik="Termal Etiket 100x150 düşük seviyede",
                mesaj="Mevcut stok: 24. Minimum seviye: 50. 9 günlük stok kaldı.",
                oncelik="normal", ilgili_entity_tipi="urun", ilgili_entity_id=4,
            ),
        ]
        session.add_all(uyarilar)

        # ─── Nakit Akışı ──────────────────────────────
        nakit_kayitlari = [
            NakitAkisi(tarih=today - timedelta(days=30), giris=45000, cikis=0, bakiye=145000,
                       aciklama="Satış gelirleri", kategori="satis"),
            NakitAkisi(tarih=today - timedelta(days=28), giris=0, cikis=25000, bakiye=120000,
                       aciklama="Tedarikçi ödemeleri", kategori="satin_alma"),
            NakitAkisi(tarih=today - timedelta(days=25), giris=0, cikis=65000, bakiye=55000,
                       aciklama="Maaş ödemeleri", kategori="maas"),
            NakitAkisi(tarih=today - timedelta(days=20), giris=32000, cikis=0, bakiye=87000,
                       aciklama="Toptan satış tahsilatı", kategori="satis"),
            NakitAkisi(tarih=today - timedelta(days=15), giris=0, cikis=12000, bakiye=75000,
                       aciklama="Kira ödemesi", kategori="kira"),
            NakitAkisi(tarih=today - timedelta(days=10), giris=18500, cikis=0, bakiye=93500,
                       aciklama="Online satış", kategori="satis"),
            NakitAkisi(tarih=today - timedelta(days=5), giris=0, cikis=8200, bakiye=85300,
                       aciklama="Fatura ödemeleri", kategori="fatura"),
            NakitAkisi(tarih=today, giris=13500, cikis=7200, bakiye=91600,
                       aciklama="Günlük işlemler", kategori="genel"),
        ]
        session.add_all(nakit_kayitlari)

        # ─── KDV Kayıtları ────────────────────────────
        current_month = today.month
        current_year = today.year
        kdv_kayitlari = [
            KdvKayit(fatura_id=1, tarih=today, tur="indirilecek", kdv_orani=20,
                     kdv_tutari=1200.0, matrah=6000.0, ay=current_month, yil=current_year),
            KdvKayit(fatura_id=2, tarih=today - timedelta(days=2), tur="hesaplanan", kdv_orani=20,
                     kdv_tutari=2250.0, matrah=11250.0, ay=current_month, yil=current_year),
            KdvKayit(fatura_id=3, tarih=today - timedelta(days=9), tur="indirilecek", kdv_orani=10,
                     kdv_tutari=640.0, matrah=6400.0, ay=current_month, yil=current_year),
            KdvKayit(fatura_id=4, tarih=today - timedelta(days=15), tur="hesaplanan", kdv_orani=20,
                     kdv_tutari=1458.0, matrah=7292.0, ay=current_month, yil=current_year),
        ]
        session.add_all(kdv_kayitlari)

        await session.commit()
        print("[OK] Demo verileri basariyla yuklendi!")
        print(f"   -> {len(tedarikciler)} tedarikci")
        print(f"   -> {len(urunler)} urun")
        print(f"   -> {len(hareketler)} stok hareketi")
        print(f"   -> {len(faturalar)} fatura")
        print(f"   -> {len(calisanlar)} calisan")
        print(f"   -> {len(uyarilar)} uyari")


if __name__ == "__main__":
    asyncio.run(seed_database())
