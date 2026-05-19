"""
KOBİ AI Asistan — Seed Data (Gerçekçi Senaryo)
══════════════════════════════════════════════════════════════
SENARYO: "Anadolu Kahve Evi" — İstanbul Kadıköy merkezli özel
kahve kavurma ve dağıtım şirketi. 2022'de kuruldu.
- Kafelere, restoranlara ve marketlere toptan kahve + ekipman satar
- Kendi markası altında paketli ürünler üretir
- Online satış kanalı var (Trendyol, Hepsiburada)
- 8 çalışan, 4 ana tedarikçi, ~25 aktif ürün
PostgreSQL ve SQLite uyumlu.
"""

import asyncio
import random
from datetime import date, datetime, timedelta, timezone
from database import (
    async_session, init_db, engine, _is_sqlite,
    Urun, StokHareket, FiyatGecmisi, Tedarikci, Fatura, FaturaKalem,
    Calisan, Puantaj, Uyari, NakitAkisi, KdvKayit, StokSayim, BriefCache,
    Base,
)
from sqlalchemy import text


# ─── Yardımcı ────────────────────────────────────────────────────────
_now = datetime.now(timezone.utc)
_today = date.today()
_month = _today.month
_year = _today.year


def _dt(days_ago: float = 0, hours_ago: float = 0):
    """Timezone-aware geçmiş datetime üretir."""
    return _now - timedelta(days=days_ago, hours=hours_ago)


async def _recreate_tables():
    """Tabloları sıfırdan oluşturur (şema değişikliklerini uygular)."""
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.drop_all)
        await conn.run_sync(Base.metadata.create_all)
    print("[...] Tablolar sifirdan olusturuldu.")


# ═══════════════════════════════════════════════════════════════════════
#  ANA SEED FONKSİYONU
# ═══════════════════════════════════════════════════════════════════════
async def seed_database():
    await _recreate_tables()

    async with async_session() as session:
        print("[...] Anadolu Kahve Evi demo verileri yukleniyor...")

        # ══════════════════════════════════════════════════════
        #  1. TEDARİKÇİLER (8 adet)
        # ══════════════════════════════════════════════════════
        tedarikciler = [
            # 1 — Ana kahve çekirdeği tedarikçisi (Brezilya/Kolombiya ithalat)
            Tedarikci(
                isim="Özçelik Kahve İthalat", vkn="1234567890",
                email="siparis@ozcelikkahve.com.tr", telefon="0212 543 1290",
                ortalama_teslim_suresi_gun=3, guvenilirlik_skoru=9.2,
            ),
            # 2 — Süt, şeker, gıda yan ürünleri
            Tedarikci(
                isim="Marmara Gıda Toptancılık", vkn="0987654321",
                email="satis@marmaragida.com.tr", telefon="0216 444 5678",
                ortalama_teslim_suresi_gun=2, guvenilirlik_skoru=8.5,
            ),
            # 3 — Premium tek-orijin çekirdeği (Ethiopia, Kenya)
            Tedarikci(
                isim="Ege Specialty Coffee", vkn="5678901234",
                email="order@egespecialty.com", telefon="0232 333 9012",
                ortalama_teslim_suresi_gun=5, guvenilirlik_skoru=9.4,
            ),
            # 4 — Ambalaj, bardak, etiket
            Tedarikci(
                isim="Yıldız Ambalaj San. Tic.", vkn="3456789012",
                email="info@yildizambalaj.com.tr", telefon="0224 222 3456",
                ortalama_teslim_suresi_gun=4, guvenilirlik_skoru=8.0,
            ),
            # 5 — Kahve makinesi ve ekipman
            Tedarikci(
                isim="ProBarista Ekipman", vkn="7890123456",
                email="satis@probarista.com.tr", telefon="0212 678 4500",
                ortalama_teslim_suresi_gun=7, guvenilirlik_skoru=8.8,
            ),
            # 6 — Alternatif kahve tedarikçisi (yedek)
            Tedarikci(
                isim="Karadeniz Kahve Deposu", vkn="2345678901",
                email="info@karadenizkahve.com", telefon="0462 321 7890",
                ortalama_teslim_suresi_gun=4, guvenilirlik_skoru=7.6,
            ),
            # 7 — Kargo ve lojistik
            Tedarikci(
                isim="Hızlı Kargo Lojistik", vkn="4567890123",
                email="kurumsal@hizlikargo.com.tr", telefon="0850 555 4567",
                ortalama_teslim_suresi_gun=1, guvenilirlik_skoru=7.2,
            ),
            # 8 — Temizlik ve sarf malzeme
            Tedarikci(
                isim="Net Temizlik Ürünleri", vkn="6789012345",
                email="siparis@nettemizlik.com.tr", telefon="0212 890 1234",
                ortalama_teslim_suresi_gun=2, guvenilirlik_skoru=8.1,
            ),
        ]
        session.add_all(tedarikciler)
        await session.flush()
        print(f"   -> {len(tedarikciler)} tedarikci")

        # ══════════════════════════════════════════════════════
        #  2. ÜRÜNLER (25 adet — 6 kategori)
        # ══════════════════════════════════════════════════════
        urunler = [
            # ── KAHVE ÇEKİRDEĞİ & ÖĞÜTÜLMÜŞ (ana ürünler) ──
            # 1
            Urun(sku="KHV-TK250", isim="Türk Kahvesi 250g (Öğütülmüş)", kategori="Kahve",
                 birim="paket", min_stok=40, max_stok=300, varsayilan_tedarikci_id=1,
                 son_satis_fiyati=189.90, son_alis_maliyeti=118.0, mevcut_stok=15),
            # 2
            Urun(sku="KHV-TK1000", isim="Türk Kahvesi 1kg (Öğütülmüş)", kategori="Kahve",
                 birim="paket", min_stok=25, max_stok=150, varsayilan_tedarikci_id=1,
                 son_satis_fiyati=680.0, son_alis_maliyeti=425.0, mevcut_stok=9),
            # 3
            Urun(sku="KHV-FK1000", isim="Filtre Kahve Blend 1kg", kategori="Kahve",
                 birim="paket", min_stok=20, max_stok=120, varsayilan_tedarikci_id=1,
                 son_satis_fiyati=465.0, son_alis_maliyeti=310.0, mevcut_stok=7),
            # 4
            Urun(sku="KHV-ESP1", isim="Espresso Çekirdeği Premium 1kg", kategori="Kahve",
                 birim="paket", min_stok=25, max_stok=100, varsayilan_tedarikci_id=1,
                 son_satis_fiyati=520.0, son_alis_maliyeti=340.0, mevcut_stok=38),
            # 5
            Urun(sku="KHV-COL500", isim="Colombia Supremo 500g (Çekirdeği)", kategori="Kahve",
                 birim="paket", min_stok=15, max_stok=80, varsayilan_tedarikci_id=3,
                 son_satis_fiyati=395.0, son_alis_maliyeti=265.0, mevcut_stok=22),
            # 6
            Urun(sku="KHV-ETH500", isim="Ethiopia Yirgacheffe 500g (Çekirdeği)", kategori="Kahve",
                 birim="paket", min_stok=10, max_stok=60, varsayilan_tedarikci_id=3,
                 son_satis_fiyati=450.0, son_alis_maliyeti=310.0, mevcut_stok=14),
            # 7
            Urun(sku="KHV-BRZ1", isim="Brazil Santos 1kg (Çekirdeği)", kategori="Kahve",
                 birim="paket", min_stok=20, max_stok=100, varsayilan_tedarikci_id=1,
                 son_satis_fiyati=380.0, son_alis_maliyeti=245.0, mevcut_stok=55),
            # 8
            Urun(sku="KHV-DK250", isim="Dibek Kahvesi 250g", kategori="Kahve",
                 birim="paket", min_stok=15, max_stok=100, varsayilan_tedarikci_id=6,
                 son_satis_fiyati=165.0, son_alis_maliyeti=95.0, mevcut_stok=42),
            # 9
            Urun(sku="KHV-MNK250", isim="Menengiç Kahvesi 250g", kategori="Kahve",
                 birim="paket", min_stok=10, max_stok=80, varsayilan_tedarikci_id=6,
                 son_satis_fiyati=145.0, son_alis_maliyeti=82.0, mevcut_stok=35),

            # ── İÇECEK HAMMADDE ──
            # 10
            Urun(sku="SUT-1L", isim="Tam Yağlı Süt 1L", kategori="İçecek",
                 birim="litre", min_stok=60, max_stok=250, varsayilan_tedarikci_id=2,
                 son_satis_fiyati=47.50, son_alis_maliyeti=34.0, mevcut_stok=88),
            # 11
            Urun(sku="SUT-BDM1", isim="Badem Sütü 1L", kategori="İçecek",
                 birim="litre", min_stok=20, max_stok=100, varsayilan_tedarikci_id=2,
                 son_satis_fiyati=89.90, son_alis_maliyeti=62.0, mevcut_stok=18),
            # 12
            Urun(sku="SUT-YLF1", isim="Yulaf Sütü 1L", kategori="İçecek",
                 birim="litre", min_stok=20, max_stok=100, varsayilan_tedarikci_id=2,
                 son_satis_fiyati=94.90, son_alis_maliyeti=68.0, mevcut_stok=25),
            # 13
            Urun(sku="SEK-1KG", isim="Toz Şeker 1kg", kategori="Gıda",
                 birim="kg", min_stok=25, max_stok=120, varsayilan_tedarikci_id=2,
                 son_satis_fiyati=54.90, son_alis_maliyeti=38.0, mevcut_stok=48),
            # 14
            Urun(sku="SRO-500", isim="Çikolata Sos 500ml", kategori="Gıda",
                 birim="şişe", min_stok=15, max_stok=80, varsayilan_tedarikci_id=2,
                 son_satis_fiyati=125.0, son_alis_maliyeti=82.0, mevcut_stok=12),
            # 15
            Urun(sku="VNL-100", isim="Vanilya Özütü 100ml", kategori="Gıda",
                 birim="şişe", min_stok=10, max_stok=50, varsayilan_tedarikci_id=2,
                 son_satis_fiyati=210.0, son_alis_maliyeti=145.0, mevcut_stok=8),

            # ── AMBALAJ & SARF ──
            # 16
            Urun(sku="KUP-8OZ", isim="Karton Bardak 8oz (100'lü)", kategori="Sarf",
                 birim="paket", min_stok=50, max_stok=500, varsayilan_tedarikci_id=4,
                 son_satis_fiyati=185.0, son_alis_maliyeti=120.0, mevcut_stok=145),
            # 17
            Urun(sku="KUP-12OZ", isim="Karton Bardak 12oz (100'lü)", kategori="Sarf",
                 birim="paket", min_stok=40, max_stok=400, varsayilan_tedarikci_id=4,
                 son_satis_fiyati=215.0, son_alis_maliyeti=142.0, mevcut_stok=82),
            # 18
            Urun(sku="KPK-BRD", isim="Bardak Kapağı Siyah (100'lü)", kategori="Sarf",
                 birim="paket", min_stok=50, max_stok=500, varsayilan_tedarikci_id=4,
                 son_satis_fiyati=95.0, son_alis_maliyeti=58.0, mevcut_stok=110),
            # 19
            Urun(sku="AMB-PKT-M", isim="Kraft Kargo Poşeti Orta Boy (50'li)", kategori="Ambalaj",
                 birim="paket", min_stok=30, max_stok=200, varsayilan_tedarikci_id=4,
                 son_satis_fiyati=220.0, son_alis_maliyeti=155.0, mevcut_stok=22),
            # 20
            Urun(sku="ETK-150", isim="Termal Etiket 100x150mm (500'lü rulo)", kategori="Ambalaj",
                 birim="rulo", min_stok=20, max_stok=150, varsayilan_tedarikci_id=4,
                 son_satis_fiyati=175.0, son_alis_maliyeti=110.0, mevcut_stok=8),
            # 21
            Urun(sku="AMB-VLF-250", isim="Kahve Valfi Poşet 250g (100'lü)", kategori="Ambalaj",
                 birim="paket", min_stok=25, max_stok=200, varsayilan_tedarikci_id=4,
                 son_satis_fiyati=320.0, son_alis_maliyeti=215.0, mevcut_stok=45),

            # ── EKİPMAN ──
            # 22
            Urun(sku="EKP-OGTC", isim="Kahve Öğütücü (Elektrikli)", kategori="Ekipman",
                 birim="adet", min_stok=3, max_stok=15, varsayilan_tedarikci_id=5,
                 son_satis_fiyati=4250.0, son_alis_maliyeti=2850.0, mevcut_stok=5),
            # 23
            Urun(sku="EKP-FPRESS", isim="French Press 600ml", kategori="Ekipman",
                 birim="adet", min_stok=5, max_stok=30, varsayilan_tedarikci_id=5,
                 son_satis_fiyati=450.0, son_alis_maliyeti=280.0, mevcut_stok=12),
            # 24
            Urun(sku="EKP-V60", isim="V60 Dripper Set", kategori="Ekipman",
                 birim="adet", min_stok=5, max_stok=25, varsayilan_tedarikci_id=5,
                 son_satis_fiyati=380.0, son_alis_maliyeti=225.0, mevcut_stok=8),
            # 25
            Urun(sku="EKP-CZVN", isim="Cezve (Bakır) 4 Kişilik", kategori="Ekipman",
                 birim="adet", min_stok=5, max_stok=20, varsayilan_tedarikci_id=5,
                 son_satis_fiyati=650.0, son_alis_maliyeti=390.0, mevcut_stok=6),
        ]
        session.add_all(urunler)
        await session.flush()
        print(f"   -> {len(urunler)} urun")

        # ══════════════════════════════════════════════════════
        #  3. STOK HAREKETLERİ (50+ kayıt — son 60 gün)
        # ══════════════════════════════════════════════════════
        hareketler = [
            # ── Türk Kahvesi 250g (ID=1) — Yoğun satış, stok eritiyor ──
            StokHareket(urun_id=1, miktar=100, hareket_tipi="satin_alma", birim_fiyat=115.0,
                        aciklama="Özçelik Kahve'den toplu alım", tarih=_dt(55)),
            StokHareket(urun_id=1, miktar=-25, hareket_tipi="satis", birim_fiyat=189.90,
                        aciklama="Kadıköy Kafe Sipariş toptan", tarih=_dt(50)),
            StokHareket(urun_id=1, miktar=-18, hareket_tipi="satis", birim_fiyat=189.90,
                        aciklama="Trendyol online satış", tarih=_dt(42)),
            StokHareket(urun_id=1, miktar=-12, hareket_tipi="satis", birim_fiyat=189.90,
                        aciklama="Beyoğlu Demlik Kafe toptan", tarih=_dt(35)),
            StokHareket(urun_id=1, miktar=50, hareket_tipi="satin_alma", birim_fiyat=118.0,
                        aciklama="Özçelik Kahve — fiyat artışı", tarih=_dt(30)),
            StokHareket(urun_id=1, miktar=-20, hareket_tipi="satis", birim_fiyat=189.90,
                        aciklama="Beşiktaş Kahve Durağı toptan", tarih=_dt(22)),
            StokHareket(urun_id=1, miktar=-15, hareket_tipi="satis", birim_fiyat=189.90,
                        aciklama="Hepsiburada online satış", tarih=_dt(15)),
            StokHareket(urun_id=1, miktar=-30, hareket_tipi="satis", birim_fiyat=189.90,
                        aciklama="Şişli Gourmet Market toptan", tarih=_dt(8)),
            StokHareket(urun_id=1, miktar=-15, hareket_tipi="satis", birim_fiyat=189.90,
                        aciklama="Online satış (bireysel)", tarih=_dt(2)),

            # ── Türk Kahvesi 1kg (ID=2) — Düşük stok ──
            StokHareket(urun_id=2, miktar=40, hareket_tipi="satin_alma", birim_fiyat=410.0,
                        aciklama="Özçelik Kahve toplu alım", tarih=_dt(50)),
            StokHareket(urun_id=2, miktar=-12, hareket_tipi="satis", birim_fiyat=680.0,
                        aciklama="Ankara Kahve House toptan", tarih=_dt(40)),
            StokHareket(urun_id=2, miktar=-10, hareket_tipi="satis", birim_fiyat=680.0,
                        aciklama="İzmir distribütör sevki", tarih=_dt(28)),
            StokHareket(urun_id=2, miktar=-9, hareket_tipi="satis", birim_fiyat=680.0,
                        aciklama="Toptan müşteri teslimatı", tarih=_dt(12)),

            # ── Filtre Kahve Blend (ID=3) — Kritik ──
            StokHareket(urun_id=3, miktar=30, hareket_tipi="satin_alma", birim_fiyat=298.0,
                        aciklama="Özçelik Kahve alım", tarih=_dt(45)),
            StokHareket(urun_id=3, miktar=-8, hareket_tipi="satis", birim_fiyat=465.0,
                        aciklama="Kadıköy Barista House", tarih=_dt(38)),
            StokHareket(urun_id=3, miktar=-10, hareket_tipi="satis", birim_fiyat=465.0,
                        aciklama="Bakırköy Filtre Kafe toptan", tarih=_dt(25)),
            StokHareket(urun_id=3, miktar=-5, hareket_tipi="satis", birim_fiyat=465.0,
                        aciklama="Online satış", tarih=_dt(10)),

            # ── Espresso Premium (ID=4) — Normal stok ──
            StokHareket(urun_id=4, miktar=50, hareket_tipi="satin_alma", birim_fiyat=330.0,
                        aciklama="Özçelik Kahve toplu alım", tarih=_dt(48)),
            StokHareket(urun_id=4, miktar=-12, hareket_tipi="satis", birim_fiyat=520.0,
                        aciklama="Levent The Coffee toptan", tarih=_dt(35)),

            # ── Colombia Supremo (ID=5) ──
            StokHareket(urun_id=5, miktar=30, hareket_tipi="satin_alma", birim_fiyat=258.0,
                        aciklama="Ege Specialty Coffee ithalat", tarih=_dt(40)),
            StokHareket(urun_id=5, miktar=-8, hareket_tipi="satis", birim_fiyat=395.0,
                        aciklama="Premium müşteri satış", tarih=_dt(18)),

            # ── Ethiopia Yirgacheffe (ID=6) ──
            StokHareket(urun_id=6, miktar=20, hareket_tipi="satin_alma", birim_fiyat=300.0,
                        aciklama="Ege Specialty Coffee", tarih=_dt(38)),
            StokHareket(urun_id=6, miktar=-6, hareket_tipi="satis", birim_fiyat=450.0,
                        aciklama="Specialty kafe sevki", tarih=_dt(15)),

            # ── Brazil Santos (ID=7) — İyi stok ──
            StokHareket(urun_id=7, miktar=80, hareket_tipi="satin_alma", birim_fiyat=235.0,
                        aciklama="Özçelik Kahve toplu alım", tarih=_dt(42)),
            StokHareket(urun_id=7, miktar=-15, hareket_tipi="satis", birim_fiyat=380.0,
                        aciklama="Kurumsal müşteri sevki", tarih=_dt(28)),
            StokHareket(urun_id=7, miktar=-10, hareket_tipi="satis", birim_fiyat=380.0,
                        aciklama="Online toptan satış", tarih=_dt(14)),

            # ── Süt (ID=10) — Yüksek devir hızlı ──
            StokHareket(urun_id=10, miktar=120, hareket_tipi="satin_alma", birim_fiyat=32.0,
                        aciklama="Marmara Gıda haftalık teslimat", tarih=_dt(28)),
            StokHareket(urun_id=10, miktar=-40, hareket_tipi="satis", birim_fiyat=47.50,
                        aciklama="Kafe sevkleri", tarih=_dt(21)),
            StokHareket(urun_id=10, miktar=100, hareket_tipi="satin_alma", birim_fiyat=34.0,
                        aciklama="Marmara Gıda — fiyat güncelleme", tarih=_dt(14)),
            StokHareket(urun_id=10, miktar=-55, hareket_tipi="satis", birim_fiyat=47.50,
                        aciklama="Haftalık toptan teslimat", tarih=_dt(7)),
            StokHareket(urun_id=10, miktar=-37, hareket_tipi="satis", birim_fiyat=47.50,
                        aciklama="Günlük satış", tarih=_dt(1)),

            # ── Badem Sütü (ID=11) — Düşük stok ──
            StokHareket(urun_id=11, miktar=30, hareket_tipi="satin_alma", birim_fiyat=60.0,
                        aciklama="Marmara Gıda alım", tarih=_dt(30)),
            StokHareket(urun_id=11, miktar=-12, hareket_tipi="satis", birim_fiyat=89.90,
                        aciklama="Vegan kafe siparişi", tarih=_dt(15)),

            # ── Karton Bardak 8oz (ID=16) ──
            StokHareket(urun_id=16, miktar=200, hareket_tipi="satin_alma", birim_fiyat=115.0,
                        aciklama="Yıldız Ambalaj toplu alım", tarih=_dt(35)),
            StokHareket(urun_id=16, miktar=-55, hareket_tipi="satis", birim_fiyat=185.0,
                        aciklama="Kafe zincirine sevk", tarih=_dt(20)),

            # ── Termal Etiket (ID=20) — Kritik ──
            StokHareket(urun_id=20, miktar=30, hareket_tipi="satin_alma", birim_fiyat=105.0,
                        aciklama="Yıldız Ambalaj alım", tarih=_dt(40)),
            StokHareket(urun_id=20, miktar=-15, hareket_tipi="satis", birim_fiyat=175.0,
                        aciklama="İç tüketim (paketleme)", tarih=_dt(20)),
            StokHareket(urun_id=20, miktar=-7, hareket_tipi="satis", birim_fiyat=175.0,
                        aciklama="İç tüketim", tarih=_dt(5)),

            # ── Çikolata Sos (ID=14) — Düşük stok ──
            StokHareket(urun_id=14, miktar=25, hareket_tipi="satin_alma", birim_fiyat=78.0,
                        aciklama="Marmara Gıda alım", tarih=_dt(42)),
            StokHareket(urun_id=14, miktar=-13, hareket_tipi="satis", birim_fiyat=125.0,
                        aciklama="Kafe siparişleri", tarih=_dt(22)),

            # ── Vanilya Özütü (ID=15) — Kritik ──
            StokHareket(urun_id=15, miktar=15, hareket_tipi="satin_alma", birim_fiyat=140.0,
                        aciklama="Marmara Gıda alım", tarih=_dt(50)),
            StokHareket(urun_id=15, miktar=-7, hareket_tipi="satis", birim_fiyat=210.0,
                        aciklama="Kafe teslimatları", tarih=_dt(25)),

            # ── Ekipman satışları ──
            StokHareket(urun_id=22, miktar=8, hareket_tipi="satin_alma", birim_fiyat=2850.0,
                        aciklama="ProBarista Ekipman alım", tarih=_dt(60)),
            StokHareket(urun_id=22, miktar=-3, hareket_tipi="satis", birim_fiyat=4250.0,
                        aciklama="Yeni kafe açılış ekipman paketi", tarih=_dt(30)),
            StokHareket(urun_id=23, miktar=20, hareket_tipi="satin_alma", birim_fiyat=280.0,
                        aciklama="ProBarista Ekipman alım", tarih=_dt(55)),
            StokHareket(urun_id=23, miktar=-8, hareket_tipi="satis", birim_fiyat=450.0,
                        aciklama="Online satış (bireysel)", tarih=_dt(20)),
            StokHareket(urun_id=25, miktar=10, hareket_tipi="satin_alma", birim_fiyat=390.0,
                        aciklama="ProBarista Ekipman", tarih=_dt(45)),
            StokHareket(urun_id=25, miktar=-4, hareket_tipi="satis", birim_fiyat=650.0,
                        aciklama="Hediyelik satış", tarih=_dt(10)),

            # ── Sayım farkı ──
            StokHareket(urun_id=19, miktar=-3, hareket_tipi="sayim", birim_fiyat=155.0,
                        aciklama="Aylık sayım — kayıp tespit", tarih=_dt(5)),
        ]
        session.add_all(hareketler)
        print(f"   -> {len(hareketler)} stok hareketi")

        # ══════════════════════════════════════════════════════
        #  4. FİYAT GEÇMİŞİ (Enflasyon etkisi — son 8 ay)
        # ══════════════════════════════════════════════════════
        fiyatlar = []
        # Türk Kahvesi 250g — %30 artış 8 ayda
        tk_prices = [(240, 88), (210, 92), (180, 98), (150, 103), (120, 108), (90, 112), (60, 115), (30, 118), (0, 118)]
        for days, price in tk_prices:
            fiyatlar.append(FiyatGecmisi(urun_id=1, tedarikci_id=1, tarih=_today - timedelta(days=days), birim_fiyat=price))

        # Filtre Kahve — %27 artış
        fk_prices = [(240, 244), (180, 260), (120, 278), (60, 298), (0, 310)]
        for days, price in fk_prices:
            fiyatlar.append(FiyatGecmisi(urun_id=3, tedarikci_id=1, tarih=_today - timedelta(days=days), birim_fiyat=price))

        # Espresso — %18 artış
        esp_prices = [(240, 288), (180, 298), (120, 315), (60, 330), (0, 340)]
        for days, price in esp_prices:
            fiyatlar.append(FiyatGecmisi(urun_id=4, tedarikci_id=1, tarih=_today - timedelta(days=days), birim_fiyat=price))

        # Süt — %22 artış
        sut_prices = [(240, 28.0), (180, 29.5), (120, 30.5), (60, 32.0), (0, 34.0)]
        for days, price in sut_prices:
            fiyatlar.append(FiyatGecmisi(urun_id=10, tedarikci_id=2, tarih=_today - timedelta(days=days), birim_fiyat=price))

        # Colombia — farklı tedarikçilerden karşılaştırma
        fiyatlar.extend([
            FiyatGecmisi(urun_id=5, tedarikci_id=3, tarih=_today - timedelta(days=120), birim_fiyat=245.0),
            FiyatGecmisi(urun_id=5, tedarikci_id=3, tarih=_today - timedelta(days=60), birim_fiyat=258.0),
            FiyatGecmisi(urun_id=5, tedarikci_id=3, tarih=_today, birim_fiyat=265.0),
            FiyatGecmisi(urun_id=5, tedarikci_id=1, tarih=_today, birim_fiyat=275.0),   # Alternatif tedarikçi
            FiyatGecmisi(urun_id=5, tedarikci_id=6, tarih=_today, birim_fiyat=282.0),   # En pahalı

            # Ethiopia — farklı tedarikçiler
            FiyatGecmisi(urun_id=6, tedarikci_id=3, tarih=_today - timedelta(days=90), birim_fiyat=285.0),
            FiyatGecmisi(urun_id=6, tedarikci_id=3, tarih=_today, birim_fiyat=310.0),
            FiyatGecmisi(urun_id=6, tedarikci_id=6, tarih=_today, birim_fiyat=325.0),

            # Karton bardak ambalaj fiyat artışı
            FiyatGecmisi(urun_id=16, tedarikci_id=4, tarih=_today - timedelta(days=180), birim_fiyat=98.0),
            FiyatGecmisi(urun_id=16, tedarikci_id=4, tarih=_today - timedelta(days=90), birim_fiyat=108.0),
            FiyatGecmisi(urun_id=16, tedarikci_id=4, tarih=_today, birim_fiyat=120.0),
        ])
        session.add_all(fiyatlar)
        print(f"   -> {len(fiyatlar)} fiyat gecmisi kaydi")

        # ══════════════════════════════════════════════════════
        #  5. FATURALAR (15 adet — son 45 gün)
        # ══════════════════════════════════════════════════════
        faturalar = [
            # ── SATIŞ FATURALARI ──
            # F1 — Kadıköy Kafe Sipariş — ödendi
            Fatura(fatura_no="AKE-2026-0201", tarih=_today - timedelta(days=2), tur="satis",
                   karsi_taraf_isim="Kadıköy Kafe Sipariş", karsi_taraf_vkn="1112233440",
                   toplam_tutar=18_540.0, kdv_tutari=3_090.0, net_tutar=15_450.0,
                   odeme_durumu="odendi", odeme_tarihi=_today - timedelta(days=1), islendi=True),
            # F2 — Beyoğlu Demlik Kafe — ödendi
            Fatura(fatura_no="AKE-2026-0198", tarih=_today - timedelta(days=5), tur="satis",
                   karsi_taraf_isim="Beyoğlu Demlik Kafe", karsi_taraf_vkn="2223344551",
                   toplam_tutar=8_750.0, kdv_tutari=1_458.33, net_tutar=7_291.67,
                   odeme_durumu="odendi", odeme_tarihi=_today - timedelta(days=3), islendi=True),
            # F3 — Levent The Coffee — bekliyor (vadesi gelmedi)
            Fatura(fatura_no="AKE-2026-0195", tarih=_today - timedelta(days=8), tur="satis",
                   karsi_taraf_isim="Levent The Coffee", karsi_taraf_vkn="3334455662",
                   toplam_tutar=12_480.0, kdv_tutari=2_080.0, net_tutar=10_400.0,
                   odeme_durumu="bekliyor", vade_tarihi=_today + timedelta(days=22), islendi=True),
            # F4 — Şişli Gourmet Market — GECİKMİŞ (9 gün)
            Fatura(fatura_no="AKE-2026-0188", tarih=_today - timedelta(days=18), tur="satis",
                   karsi_taraf_isim="Şişli Gourmet Market", karsi_taraf_vkn="4445566773",
                   toplam_tutar=22_350.0, kdv_tutari=3_725.0, net_tutar=18_625.0,
                   odeme_durumu="gecikti", vade_tarihi=_today - timedelta(days=9), islendi=True),
            # F5 — Ankara Kahve House — GECİKMİŞ (15 gün)
            Fatura(fatura_no="AKE-2026-0182", tarih=_today - timedelta(days=28), tur="satis",
                   karsi_taraf_isim="Ankara Kahve House", karsi_taraf_vkn="5556677884",
                   toplam_tutar=15_600.0, kdv_tutari=2_600.0, net_tutar=13_000.0,
                   odeme_durumu="gecikti", vade_tarihi=_today - timedelta(days=15), islendi=True),
            # F6 — Trendyol Online — ödendi
            Fatura(fatura_no="AKE-2026-0192", tarih=_today - timedelta(days=12), tur="satis",
                   karsi_taraf_isim="Trendyol Marketplace", karsi_taraf_vkn="6667788995",
                   toplam_tutar=9_870.0, kdv_tutari=1_645.0, net_tutar=8_225.0,
                   odeme_durumu="odendi", odeme_tarihi=_today - timedelta(days=5), islendi=True),
            # F7 — Beşiktaş Kahve Durağı — ödendi
            Fatura(fatura_no="AKE-2026-0196", tarih=_today - timedelta(days=6), tur="satis",
                   karsi_taraf_isim="Beşiktaş Kahve Durağı", karsi_taraf_vkn="7778899006",
                   toplam_tutar=6_240.0, kdv_tutari=1_040.0, net_tutar=5_200.0,
                   odeme_durumu="odendi", odeme_tarihi=_today - timedelta(days=4), islendi=True),
            # F8 — Bakırköy Filtre — bekliyor
            Fatura(fatura_no="AKE-2026-0199", tarih=_today - timedelta(days=3), tur="satis",
                   karsi_taraf_isim="Bakırköy Filtre Kafe", karsi_taraf_vkn="8889900117",
                   toplam_tutar=5_580.0, kdv_tutari=930.0, net_tutar=4_650.0,
                   odeme_durumu="bekliyor", vade_tarihi=_today + timedelta(days=27), islendi=True),

            # ── SATIN ALMA FATURALARI ──
            # F9 — Özçelik Kahve — toplu çekirdeği alım — ödendi
            Fatura(fatura_no="OZC-2026-4521", tarih=_today - timedelta(days=10), tur="satin_alma",
                   karsi_taraf_isim="Özçelik Kahve İthalat", karsi_taraf_vkn="1234567890",
                   tedarikci_id=1, toplam_tutar=38_400.0, kdv_tutari=6_400.0, net_tutar=32_000.0,
                   odeme_durumu="odendi", odeme_tarihi=_today - timedelta(days=8), islendi=True),
            # F10 — Marmara Gıda — süt, şeker — GECİKMİŞ (ödeme yapılmadı)
            Fatura(fatura_no="MG-2026-8812", tarih=_today - timedelta(days=15), tur="satin_alma",
                   karsi_taraf_isim="Marmara Gıda Toptancılık", karsi_taraf_vkn="0987654321",
                   tedarikci_id=2, toplam_tutar=8_640.0, kdv_tutari=1_440.0, net_tutar=7_200.0,
                   odeme_durumu="gecikti", vade_tarihi=_today - timedelta(days=5), islendi=True),
            # F11 — Ege Specialty — premium çekirdeği — ödendi
            Fatura(fatura_no="ESC-2026-0089", tarih=_today - timedelta(days=20), tur="satin_alma",
                   karsi_taraf_isim="Ege Specialty Coffee", karsi_taraf_vkn="5678901234",
                   tedarikci_id=3, toplam_tutar=17_100.0, kdv_tutari=2_850.0, net_tutar=14_250.0,
                   odeme_durumu="odendi", odeme_tarihi=_today - timedelta(days=18), islendi=True),
            # F12 — Yıldız Ambalaj — ambalaj malzeme — bekliyor
            Fatura(fatura_no="YA-2026-2240", tarih=_today - timedelta(days=7), tur="satin_alma",
                   karsi_taraf_isim="Yıldız Ambalaj San. Tic.", karsi_taraf_vkn="3456789012",
                   tedarikci_id=4, toplam_tutar=12_960.0, kdv_tutari=2_160.0, net_tutar=10_800.0,
                   odeme_durumu="bekliyor", vade_tarihi=_today + timedelta(days=23), islendi=True),
            # F13 — ProBarista — ekipman — ödendi
            Fatura(fatura_no="PB-2026-0445", tarih=_today - timedelta(days=30), tur="satin_alma",
                   karsi_taraf_isim="ProBarista Ekipman", karsi_taraf_vkn="7890123456",
                   tedarikci_id=5, toplam_tutar=28_500.0, kdv_tutari=4_750.0, net_tutar=23_750.0,
                   odeme_durumu="odendi", odeme_tarihi=_today - timedelta(days=25), islendi=True),
            # F14 — Kira faturası
            Fatura(fatura_no="KIRA-2026-05", tarih=_today - timedelta(days=1), tur="satin_alma",
                   karsi_taraf_isim="Kadıköy Emlak (Depo + Ofis Kira)", karsi_taraf_vkn="9990011228",
                   toplam_tutar=18_000.0, kdv_tutari=3_240.0, net_tutar=14_760.0,
                   odeme_durumu="bekliyor", vade_tarihi=_today + timedelta(days=4), islendi=True),
            # F15 — Net Temizlik
            Fatura(fatura_no="NT-2026-1102", tarih=_today - timedelta(days=4), tur="satin_alma",
                   karsi_taraf_isim="Net Temizlik Ürünleri", karsi_taraf_vkn="6789012345",
                   tedarikci_id=8, toplam_tutar=2_400.0, kdv_tutari=480.0, net_tutar=1_920.0,
                   odeme_durumu="odendi", odeme_tarihi=_today - timedelta(days=3), islendi=True),
        ]
        session.add_all(faturalar)
        await session.flush()
        print(f"   -> {len(faturalar)} fatura")

        # ══════════════════════════════════════════════════════
        #  6. FATURA KALEMLERİ
        # ══════════════════════════════════════════════════════
        kalemler = [
            # F1 — Kadıköy Kafe
            FaturaKalem(fatura_id=1, urun_adi="Türk Kahvesi 250g", urun_id=1, miktar=25,
                        birim_fiyat=189.90, kdv_orani=20, kdv_tutari=949.50, satir_toplam=5_697.0),
            FaturaKalem(fatura_id=1, urun_adi="Espresso Çekirdeği Premium 1kg", urun_id=4, miktar=12,
                        birim_fiyat=520.0, kdv_orani=20, kdv_tutari=1_248.0, satir_toplam=7_488.0),
            FaturaKalem(fatura_id=1, urun_adi="Karton Bardak 8oz (100'lü)", urun_id=16, miktar=20,
                        birim_fiyat=185.0, kdv_orani=20, kdv_tutari=740.0, satir_toplam=4_440.0),

            # F2 — Beyoğlu Demlik
            FaturaKalem(fatura_id=2, urun_adi="Türk Kahvesi 250g", urun_id=1, miktar=12,
                        birim_fiyat=189.90, kdv_orani=20, kdv_tutari=455.76, satir_toplam=2_734.56),
            FaturaKalem(fatura_id=2, urun_adi="Colombia Supremo 500g", urun_id=5, miktar=8,
                        birim_fiyat=395.0, kdv_orani=20, kdv_tutari=632.0, satir_toplam=3_792.0),
            FaturaKalem(fatura_id=2, urun_adi="French Press 600ml", urun_id=23, miktar=3,
                        birim_fiyat=450.0, kdv_orani=20, kdv_tutari=270.0, satir_toplam=1_620.0),

            # F4 — Şişli Gourmet (GECİKMİŞ)
            FaturaKalem(fatura_id=4, urun_adi="Türk Kahvesi 250g", urun_id=1, miktar=30,
                        birim_fiyat=189.90, kdv_orani=20, kdv_tutari=1_139.40, satir_toplam=6_836.40),
            FaturaKalem(fatura_id=4, urun_adi="Türk Kahvesi 1kg", urun_id=2, miktar=10,
                        birim_fiyat=680.0, kdv_orani=20, kdv_tutari=1_360.0, satir_toplam=8_160.0),
            FaturaKalem(fatura_id=4, urun_adi="Cezve Bakır 4 Kişilik", urun_id=25, miktar=4,
                        birim_fiyat=650.0, kdv_orani=20, kdv_tutari=520.0, satir_toplam=3_120.0),
            FaturaKalem(fatura_id=4, urun_adi="Dibek Kahvesi 250g", urun_id=8, miktar=15,
                        birim_fiyat=165.0, kdv_orani=20, kdv_tutari=495.0, satir_toplam=2_970.0),

            # F5 — Ankara Kahve House (GECİKMİŞ)
            FaturaKalem(fatura_id=5, urun_adi="Filtre Kahve Blend 1kg", urun_id=3, miktar=10,
                        birim_fiyat=465.0, kdv_orani=20, kdv_tutari=930.0, satir_toplam=5_580.0),
            FaturaKalem(fatura_id=5, urun_adi="Ethiopia Yirgacheffe 500g", urun_id=6, miktar=8,
                        birim_fiyat=450.0, kdv_orani=20, kdv_tutari=720.0, satir_toplam=4_320.0),
            FaturaKalem(fatura_id=5, urun_adi="V60 Dripper Set", urun_id=24, miktar=5,
                        birim_fiyat=380.0, kdv_orani=20, kdv_tutari=380.0, satir_toplam=2_280.0),

            # F9 — Özçelik Kahve (alım)
            FaturaKalem(fatura_id=9, urun_adi="Türk Kahvesi Çekirdeği (Ham)", urun_id=1, miktar=100,
                        birim_fiyat=118.0, kdv_orani=20, kdv_tutari=2_360.0, satir_toplam=14_160.0),
            FaturaKalem(fatura_id=9, urun_adi="Espresso Çekirdeği (Ham)", urun_id=4, miktar=50,
                        birim_fiyat=340.0, kdv_orani=20, kdv_tutari=3_400.0, satir_toplam=20_400.0),

            # F10 — Marmara Gıda (alım — gecikmiş ödeme)
            FaturaKalem(fatura_id=10, urun_adi="Tam Yağlı Süt 1L", urun_id=10, miktar=100,
                        birim_fiyat=34.0, kdv_orani=10, kdv_tutari=340.0, satir_toplam=3_740.0),
            FaturaKalem(fatura_id=10, urun_adi="Badem Sütü 1L", urun_id=11, miktar=30,
                        birim_fiyat=62.0, kdv_orani=20, kdv_tutari=372.0, satir_toplam=2_232.0),
            FaturaKalem(fatura_id=10, urun_adi="Toz Şeker 1kg", urun_id=13, miktar=50,
                        birim_fiyat=38.0, kdv_orani=10, kdv_tutari=190.0, satir_toplam=2_090.0),

            # F11 — Ege Specialty
            FaturaKalem(fatura_id=11, urun_adi="Colombia Supremo (Ham)", urun_id=5, miktar=30,
                        birim_fiyat=265.0, kdv_orani=20, kdv_tutari=1_590.0, satir_toplam=9_540.0),
            FaturaKalem(fatura_id=11, urun_adi="Ethiopia Yirgacheffe (Ham)", urun_id=6, miktar=20,
                        birim_fiyat=310.0, kdv_orani=20, kdv_tutari=1_240.0, satir_toplam=7_440.0),

            # F12 — Yıldız Ambalaj
            FaturaKalem(fatura_id=12, urun_adi="Karton Bardak 8oz (100'lü)", urun_id=16, miktar=50,
                        birim_fiyat=120.0, kdv_orani=20, kdv_tutari=1_200.0, satir_toplam=7_200.0),
            FaturaKalem(fatura_id=12, urun_adi="Termal Etiket 500'lü", urun_id=20, miktar=20,
                        birim_fiyat=110.0, kdv_orani=20, kdv_tutari=440.0, satir_toplam=2_640.0),
            FaturaKalem(fatura_id=12, urun_adi="Kraft Kargo Poşeti (50'li)", urun_id=19, miktar=15,
                        birim_fiyat=155.0, kdv_orani=20, kdv_tutari=465.0, satir_toplam=2_790.0),
        ]
        session.add_all(kalemler)
        print(f"   -> {len(kalemler)} fatura kalemi")

        # ══════════════════════════════════════════════════════
        #  7. ÇALIŞANLAR (8 kişi)
        # ══════════════════════════════════════════════════════
        calisanlar = [
            # 1
            Calisan(ad_soyad="Emre Yıldırım", pozisyon="Genel Müdür",
                    brut_maas=52_000.0, ise_giris_tarihi=date(2022, 3, 1)),
            # 2
            Calisan(ad_soyad="Zeynep Arslan", pozisyon="Muhasebe / Finans Sorumlusu",
                    brut_maas=38_000.0, ise_giris_tarihi=date(2022, 6, 15)),
            # 3
            Calisan(ad_soyad="Ahmet Kaya", pozisyon="Baş Kavurmacı (Roaster)",
                    brut_maas=42_000.0, ise_giris_tarihi=date(2022, 3, 1)),
            # 4
            Calisan(ad_soyad="Fatma Demir", pozisyon="Satış & Pazarlama Uzmanı",
                    brut_maas=35_000.0, ise_giris_tarihi=date(2023, 2, 1)),
            # 5
            Calisan(ad_soyad="Mehmet Şahin", pozisyon="Depo & Lojistik Sorumlusu",
                    brut_maas=30_000.0, ise_giris_tarihi=date(2023, 9, 1)),
            # 6
            Calisan(ad_soyad="Ayşe Çelik", pozisyon="Online Satış Uzmanı",
                    brut_maas=32_000.0, ise_giris_tarihi=date(2024, 1, 15)),
            # 7
            Calisan(ad_soyad="Mustafa Öztürk", pozisyon="Kurye / Teslimatçı",
                    brut_maas=26_000.0, ise_giris_tarihi=date(2024, 6, 1)),
            # 8
            Calisan(ad_soyad="Elif Koç", pozisyon="Paketleme Elemanı",
                    brut_maas=25_000.0, ise_giris_tarihi=date(2025, 1, 10)),
        ]
        session.add_all(calisanlar)
        await session.flush()
        print(f"   -> {len(calisanlar)} calisan")

        # ══════════════════════════════════════════════════════
        #  8. PUANTAJ (Mart, Nisan, Mayıs 2026 — 3 ay)
        # ══════════════════════════════════════════════════════
        puantaj_data = [
            # (calisan_id, brut_maas, [(ay, calisma, mesai, izin, rapor)])
            (1, 52000, [(3, 22, 0, 0, 0), (4, 22, 0, 0, 0), (5, 21, 0, 1, 0)]),
            (2, 38000, [(3, 22, 4, 0, 0), (4, 21, 6, 1, 0), (5, 22, 8, 0, 0)]),
            (3, 42000, [(3, 22, 18, 0, 0), (4, 22, 22, 0, 0), (5, 21, 20, 1, 0)]),
            (4, 35000, [(3, 21, 8, 1, 0), (4, 22, 10, 0, 0), (5, 20, 6, 2, 0)]),
            (5, 30000, [(3, 22, 12, 0, 0), (4, 20, 8, 0, 2), (5, 22, 14, 0, 0)]),
            (6, 32000, [(3, 22, 4, 0, 0), (4, 22, 6, 0, 0), (5, 21, 4, 1, 0)]),
            (7, 26000, [(3, 22, 16, 0, 0), (4, 21, 12, 1, 0), (5, 22, 18, 0, 0)]),
            (8, 25000, [(3, 20, 0, 0, 2), (4, 22, 4, 0, 0), (5, 19, 0, 3, 0)]),
        ]

        puantajlar = []
        for cid, brut, months in puantaj_data:
            for ay, calisma, mesai, izin, rapor in months:
                # Basit hesaplama: SGK %14, Gelir Vergisi kademeli
                sgk = round(brut * 0.14)
                # Kademeli gelir vergisi (basitleştirilmiş)
                vergi_matrah = brut - sgk
                if vergi_matrah <= 32000:
                    gelir_v = round(vergi_matrah * 0.15)
                elif vergi_matrah <= 70000:
                    gelir_v = round(32000 * 0.15 + (vergi_matrah - 32000) * 0.20)
                else:
                    gelir_v = round(32000 * 0.15 + 38000 * 0.20 + (vergi_matrah - 70000) * 0.27)
                net = brut - sgk - gelir_v
                # Mesai ücreti ekleme
                mesai_ucret = round(mesai * (brut / 225) * 1.5)
                net += mesai_ucret

                puantajlar.append(Puantaj(
                    calisan_id=cid, yil=2026, ay=ay,
                    calisma_gunleri=calisma, mesai_saat=mesai,
                    izin_gunu=izin, rapor_gunu=rapor,
                    brut_maas=brut, net_maas=round(net),
                    sgk_kesinti=sgk, gelir_vergisi=gelir_v,
                ))
        session.add_all(puantajlar)
        print(f"   -> {len(puantajlar)} puantaj kaydi (3 ay)")

        # ══════════════════════════════════════════════════════
        #  9. NAKİT AKIŞI (Son 60 gün — detaylı günlük)
        # ══════════════════════════════════════════════════════
        nakit = [
            # Mart sonu
            NakitAkisi(tarih=_today - timedelta(days=55), giris=65_000, cikis=0,
                       bakiye=165_000, aciklama="Toptan satış tahsilatları (Mart)", kategori="satis"),
            NakitAkisi(tarih=_today - timedelta(days=53), giris=0, cikis=38_500,
                       bakiye=126_500, aciklama="Özçelik Kahve tedarik ödemesi", kategori="satin_alma"),
            NakitAkisi(tarih=_today - timedelta(days=50), giris=12_800, cikis=0,
                       bakiye=139_300, aciklama="Online satışlar (Trendyol+Hepsiburada)", kategori="satis"),
            NakitAkisi(tarih=_today - timedelta(days=48), giris=0, cikis=8_200,
                       bakiye=131_100, aciklama="Marmara Gıda tedarik ödemesi", kategori="satin_alma"),
            NakitAkisi(tarih=_today - timedelta(days=45), giris=0, cikis=145_000,
                       bakiye=-13_900, aciklama="Maaş ödemeleri (Mart — 8 kişi)", kategori="maas"),
            NakitAkisi(tarih=_today - timedelta(days=44), giris=28_000, cikis=0,
                       bakiye=14_100, aciklama="Ankara müşteri tahsilatı", kategori="satis"),
            NakitAkisi(tarih=_today - timedelta(days=42), giris=0, cikis=18_000,
                       bakiye=-3_900, aciklama="Depo + ofis kira ödemesi (Nisan)", kategori="kira"),
            NakitAkisi(tarih=_today - timedelta(days=40), giris=45_200, cikis=0,
                       bakiye=41_300, aciklama="Toptan müşteri tahsilatları", kategori="satis"),
            NakitAkisi(tarih=_today - timedelta(days=38), giris=0, cikis=4_800,
                       bakiye=36_500, aciklama="Yıldız Ambalaj ödeme", kategori="satin_alma"),
            NakitAkisi(tarih=_today - timedelta(days=35), giris=22_500, cikis=0,
                       bakiye=59_000, aciklama="Kafe zincirleri toptan satış", kategori="satis"),

            # Nisan ortası
            NakitAkisi(tarih=_today - timedelta(days=32), giris=0, cikis=15_200,
                       bakiye=43_800, aciklama="Ege Specialty Coffee ödeme", kategori="satin_alma"),
            NakitAkisi(tarih=_today - timedelta(days=30), giris=18_750, cikis=0,
                       bakiye=62_550, aciklama="Beyoğlu + Beşiktaş kafe tahsilatları", kategori="satis"),
            NakitAkisi(tarih=_today - timedelta(days=28), giris=8_400, cikis=0,
                       bakiye=70_950, aciklama="Online bireysel satışlar", kategori="satis"),
            NakitAkisi(tarih=_today - timedelta(days=25), giris=0, cikis=28_500,
                       bakiye=42_450, aciklama="ProBarista ekipman ödemesi", kategori="satin_alma"),
            NakitAkisi(tarih=_today - timedelta(days=22), giris=0, cikis=6_500,
                       bakiye=35_950, aciklama="Elektrik + doğalgaz + internet", kategori="fatura"),
            NakitAkisi(tarih=_today - timedelta(days=20), giris=35_600, cikis=0,
                       bakiye=71_550, aciklama="Şişli Gourmet + Bakırköy Filtre tahsilatları", kategori="satis"),

            # Nisan sonu — Maaş
            NakitAkisi(tarih=_today - timedelta(days=15), giris=0, cikis=148_000,
                       bakiye=-76_450, aciklama="Maaş ödemeleri (Nisan — 8 kişi)", kategori="maas"),
            NakitAkisi(tarih=_today - timedelta(days=14), giris=42_000, cikis=0,
                       bakiye=-34_450, aciklama="Acil tahsilat — büyük müşteriler", kategori="satis"),
            NakitAkisi(tarih=_today - timedelta(days=12), giris=0, cikis=18_000,
                       bakiye=-52_450, aciklama="Depo + ofis kira ödemesi (Mayıs)", kategori="kira"),
            NakitAkisi(tarih=_today - timedelta(days=10), giris=58_000, cikis=0,
                       bakiye=5_550, aciklama="Toptan satış tahsilatları", kategori="satis"),
            NakitAkisi(tarih=_today - timedelta(days=8), giris=0, cikis=38_400,
                       bakiye=-32_850, aciklama="Özçelik Kahve toplu alım ödemesi", kategori="satin_alma"),

            # Mayıs başı (güncel)
            NakitAkisi(tarih=_today - timedelta(days=6), giris=27_290, cikis=0,
                       bakiye=-5_560, aciklama="Kadıköy Kafe + Beyoğlu Demlik tahsilatı", kategori="satis"),
            NakitAkisi(tarih=_today - timedelta(days=5), giris=9_870, cikis=0,
                       bakiye=4_310, aciklama="Trendyol Marketplace tahsilatı", kategori="satis"),
            NakitAkisi(tarih=_today - timedelta(days=4), giris=6_240, cikis=2_400,
                       bakiye=8_150, aciklama="Beşiktaş Kahve Durağı + Net Temizlik", kategori="genel"),
            NakitAkisi(tarih=_today - timedelta(days=2), giris=0, cikis=5_800,
                       bakiye=2_350, aciklama="KDV ödemesi (Nisan dönemi)", kategori="vergi"),
            NakitAkisi(tarih=_today - timedelta(days=1), giris=0, cikis=3_200,
                       bakiye=-850, aciklama="Kargo ve lojistik giderleri", kategori="fatura"),
            NakitAkisi(tarih=_today, giris=4_500, cikis=0,
                       bakiye=3_650, aciklama="Online satış (günlük)", kategori="satis"),
        ]
        session.add_all(nakit)
        print(f"   -> {len(nakit)} nakit akisi kaydi")

        # ══════════════════════════════════════════════════════
        #  10. KDV KAYITLARI (Nisan + Mayıs)
        # ══════════════════════════════════════════════════════
        kdv_kayitlari = [
            # Nisan satış faturaları — hesaplanan KDV
            KdvKayit(fatura_id=4, tarih=_today - timedelta(days=18), tur="hesaplanan",
                     kdv_orani=20, kdv_tutari=3_725.0, matrah=18_625.0, ay=4, yil=2026),
            KdvKayit(fatura_id=5, tarih=_today - timedelta(days=28), tur="hesaplanan",
                     kdv_orani=20, kdv_tutari=2_600.0, matrah=13_000.0, ay=4, yil=2026),

            # Nisan alım faturaları — indirilecek KDV
            KdvKayit(fatura_id=9, tarih=_today - timedelta(days=10), tur="indirilecek",
                     kdv_orani=20, kdv_tutari=6_400.0, matrah=32_000.0, ay=4, yil=2026),
            KdvKayit(fatura_id=10, tarih=_today - timedelta(days=15), tur="indirilecek",
                     kdv_orani=10, kdv_tutari=1_440.0, matrah=7_200.0, ay=4, yil=2026),
            KdvKayit(fatura_id=13, tarih=_today - timedelta(days=30), tur="indirilecek",
                     kdv_orani=20, kdv_tutari=4_750.0, matrah=23_750.0, ay=4, yil=2026),

            # Mayıs satış faturaları — hesaplanan KDV
            KdvKayit(fatura_id=1, tarih=_today - timedelta(days=2), tur="hesaplanan",
                     kdv_orani=20, kdv_tutari=3_090.0, matrah=15_450.0, ay=5, yil=2026),
            KdvKayit(fatura_id=2, tarih=_today - timedelta(days=5), tur="hesaplanan",
                     kdv_orani=20, kdv_tutari=1_458.33, matrah=7_291.67, ay=5, yil=2026),
            KdvKayit(fatura_id=3, tarih=_today - timedelta(days=8), tur="hesaplanan",
                     kdv_orani=20, kdv_tutari=2_080.0, matrah=10_400.0, ay=5, yil=2026),
            KdvKayit(fatura_id=6, tarih=_today - timedelta(days=12), tur="hesaplanan",
                     kdv_orani=20, kdv_tutari=1_645.0, matrah=8_225.0, ay=5, yil=2026),
            KdvKayit(fatura_id=7, tarih=_today - timedelta(days=6), tur="hesaplanan",
                     kdv_orani=20, kdv_tutari=1_040.0, matrah=5_200.0, ay=5, yil=2026),
            KdvKayit(fatura_id=8, tarih=_today - timedelta(days=3), tur="hesaplanan",
                     kdv_orani=20, kdv_tutari=930.0, matrah=4_650.0, ay=5, yil=2026),

            # Mayıs alım faturaları — indirilecek KDV
            KdvKayit(fatura_id=11, tarih=_today - timedelta(days=20), tur="indirilecek",
                     kdv_orani=20, kdv_tutari=2_850.0, matrah=14_250.0, ay=5, yil=2026),
            KdvKayit(fatura_id=12, tarih=_today - timedelta(days=7), tur="indirilecek",
                     kdv_orani=20, kdv_tutari=2_160.0, matrah=10_800.0, ay=5, yil=2026),
            KdvKayit(fatura_id=14, tarih=_today - timedelta(days=1), tur="indirilecek",
                     kdv_orani=18, kdv_tutari=3_240.0, matrah=14_760.0, ay=5, yil=2026),
            KdvKayit(fatura_id=15, tarih=_today - timedelta(days=4), tur="indirilecek",
                     kdv_orani=20, kdv_tutari=480.0, matrah=1_920.0, ay=5, yil=2026),
        ]
        session.add_all(kdv_kayitlari)
        print(f"   -> {len(kdv_kayitlari)} KDV kaydi")

        # ══════════════════════════════════════════════════════
        #  11. STOK SAYIMLARI
        # ══════════════════════════════════════════════════════
        sayimlar = [
            StokSayim(urun_id=1, sayim_tarihi=_today - timedelta(days=5),
                      beklenen_miktar=18, fiili_miktar=15, fark=-3, sayim_yapan="Mehmet Şahin"),
            StokSayim(urun_id=4, sayim_tarihi=_today - timedelta(days=5),
                      beklenen_miktar=38, fiili_miktar=38, fark=0, sayim_yapan="Mehmet Şahin"),
            StokSayim(urun_id=16, sayim_tarihi=_today - timedelta(days=5),
                      beklenen_miktar=148, fiili_miktar=145, fark=-3, sayim_yapan="Elif Koç"),
            StokSayim(urun_id=19, sayim_tarihi=_today - timedelta(days=5),
                      beklenen_miktar=25, fiili_miktar=22, fark=-3, sayim_yapan="Elif Koç"),
            StokSayim(urun_id=10, sayim_tarihi=_today - timedelta(days=5),
                      beklenen_miktar=90, fiili_miktar=88, fark=-2, sayim_yapan="Mehmet Şahin"),
        ]
        session.add_all(sayimlar)
        print(f"   -> {len(sayimlar)} stok sayim kaydi")

        # ══════════════════════════════════════════════════════
        #  12. UYARILAR (Gerçekçi uyarı senaryoları)
        # ══════════════════════════════════════════════════════
        uyarilar = [
            Uyari(tur="stok_kritik", baslik="Türk Kahvesi 250g kritik seviyede",
                  mesaj="Mevcut stok: 15 paket. Minimum seviye: 40. Haftalık ortalama satış: 22 paket. "
                        "Tahmini 5 günlük stok kaldı. Özçelik Kahve'ye acil sipariş önerilir (teslim: 3 gün).",
                  oncelik="kritik", ilgili_entity_tipi="urun", ilgili_entity_id=1),
            Uyari(tur="stok_kritik", baslik="Türk Kahvesi 1kg kritik seviyede",
                  mesaj="Mevcut stok: 9 paket. Minimum seviye: 25. Ankara + İzmir distribütör talepleri bekliyor.",
                  oncelik="kritik", ilgili_entity_tipi="urun", ilgili_entity_id=2),
            Uyari(tur="stok_kritik", baslik="Filtre Kahve Blend 1kg kritik stok",
                  mesaj="Mevcut stok: 7. Minimum: 20. Bakırköy Filtre Kafe'nin haftalık siparişi karşılanamayabilir.",
                  oncelik="kritik", ilgili_entity_tipi="urun", ilgili_entity_id=3),
            Uyari(tur="stok_kritik", baslik="Termal Etiket 100x150 düşük seviyede",
                  mesaj="Mevcut: 8 rulo. Minimum: 20. Paketleme işlemleri 3 gün içinde duracak. Yıldız Ambalaj'a sipariş ver.",
                  oncelik="yuksek", ilgili_entity_tipi="urun", ilgili_entity_id=20),
            Uyari(tur="stok_kritik", baslik="Vanilya Özütü düşük stok",
                  mesaj="Mevcut: 8 şişe. Minimum: 10. Specialty kafe siparişlerinde kullanılıyor.",
                  oncelik="normal", ilgili_entity_tipi="urun", ilgili_entity_id=15),

            Uyari(tur="gecikmis_odeme", baslik="Şişli Gourmet Market — 9 gün gecikmiş",
                  mesaj="22.350 TL tutarındaki satış faturası (AKE-2026-0188) 9 gündür ödenmedi. "
                        "Müşteriye 2. hatırlatma yapılması ve tahsilat takibi önerilir.",
                  oncelik="kritik", ilgili_entity_tipi="fatura", ilgili_entity_id=4),
            Uyari(tur="gecikmis_odeme", baslik="Ankara Kahve House — 15 gün gecikmiş",
                  mesaj="15.600 TL tutarındaki fatura (AKE-2026-0182) 15 gündür ödenmedi. "
                        "Toplam gecikmiş alacak: 37.950 TL. Hukuki süreç değerlendirilmeli.",
                  oncelik="kritik", ilgili_entity_tipi="fatura", ilgili_entity_id=5),
            Uyari(tur="gecikmis_odeme", baslik="Marmara Gıda'ya ödeme gecikmesi",
                  mesaj="8.640 TL tutarındaki tedarik faturası (MG-2026-8812) 5 gündür ödenmedi. "
                        "Tedarikçi ilişkisi risk altında. Nakit durumuna göre kısmi ödeme düşünülebilir.",
                  oncelik="yuksek", ilgili_entity_tipi="fatura", ilgili_entity_id=10),

            Uyari(tur="nakit_acik", baslik="Nakit akışı — kritik seviye",
                  mesaj="Güncel bakiye: 3.650 TL. Önümüzdeki 5 gün içinde 18.000 TL kira + tahmini 10.000 TL "
                        "operasyonel gider bekleniyor. Maaş ödemelerine 10 gün var (~150.000 TL). "
                        "Gecikmiş 37.950 TL alacağın acil tahsili gerekli.",
                  oncelik="kritik"),
            Uyari(tur="nakit_acik", baslik="Maaş ödemesi riski — 10 gün",
                  mesaj="Mayıs maaşları (~150.000 TL) yaklaşıyor. Mevcut bakiye yetersiz. "
                        "Acil tahsilat + olası vadeli mevduat bozma gerekebilir.",
                  oncelik="yuksek"),

            Uyari(tur="kdv_tarihi", baslik="KDV beyanname son tarihi: 26 Haziran",
                  mesaj="Mayıs dönemi KDV beyannamesi için son tarih: 26 Haziran 2026. "
                        "Hesaplanan KDV: ~10.243 TL. İndirilecek KDV: ~8.730 TL. Ödenecek: ~1.513 TL.",
                  oncelik="normal"),

            Uyari(tur="stok_kritik", baslik="Sayım farkı tespit edildi",
                  mesaj="Son sayımda 3 üründe toplam -8 adet fark tespit edildi. "
                        "En büyük fark: Kraft Kargo Poşeti (-3 paket). Kontrol önerilir.",
                  oncelik="normal"),
        ]
        session.add_all(uyarilar)
        print(f"   -> {len(uyarilar)} uyari")

        # ══════════════════════════════════════════════════════
        #  COMMIT
        # ══════════════════════════════════════════════════════
        await session.commit()

        print()
        print("=" * 58)
        print("  ANADOLU KAHVE EVİ — Demo Veriler Başarıyla Yüklendi!")
        print("=" * 58)
        print(f"  Tedarikçi     : {len(tedarikciler)}")
        print(f"  Ürün          : {len(urunler)}")
        print(f"  Stok Hareketi : {len(hareketler)}")
        print(f"  Fiyat Geçmişi : {len(fiyatlar)}")
        print(f"  Fatura        : {len(faturalar)}")
        print(f"  Fatura Kalemi : {len(kalemler)}")
        print(f"  Çalışan       : {len(calisanlar)}")
        print(f"  Puantaj       : {len(puantajlar)}")
        print(f"  Nakit Akışı   : {len(nakit)}")
        print(f"  KDV Kaydı     : {len(kdv_kayitlari)}")
        print(f"  Stok Sayımı   : {len(sayimlar)}")
        print(f"  Uyarı         : {len(uyarilar)}")
        print("=" * 58)


if __name__ == "__main__":
    asyncio.run(seed_database())
