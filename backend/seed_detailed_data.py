"""
KOBİ AI Asistan — Detaylı Seed Data
Veritabanını detaylı, birbiriyle mantıksal olarak bağlantılı verilerle doldurur.
"""

import asyncio
import random
from datetime import date, datetime, timedelta
from database import (
    async_session, init_db, engine,
    Urun, StokHareket, FiyatGecmisi, Tedarikci, Fatura, FaturaKalem,
    Calisan, Puantaj, Uyari, NakitAkisi, KdvKayit, Base, StokSayim
)

async def clear_db(session):
    # Tabloları temizle
    await session.execute(KdvKayit.__table__.delete())
    await session.execute(NakitAkisi.__table__.delete())
    await session.execute(Uyari.__table__.delete())
    await session.execute(Puantaj.__table__.delete())
    await session.execute(Calisan.__table__.delete())
    await session.execute(FaturaKalem.__table__.delete())
    await session.execute(Fatura.__table__.delete())
    await session.execute(FiyatGecmisi.__table__.delete())
    await session.execute(StokHareket.__table__.delete())
    await session.execute(Urun.__table__.delete())
    await session.execute(Tedarikci.__table__.delete())
    await session.commit()

async def seed_database():
    await init_db()
    
    async with async_session() as session:
        await clear_db(session)
        
        today = date.today()
        now = datetime.now()
        
        # ─── 1. Tedarikçiler ───
        tedarikci_isimleri = ["Aksoy Tedarik", "Marmara Gıda", "Ege Kahve", "Yıldız Ambalaj", "Karadeniz Çay", "Balkan Süt", "Mega Toptan", "Güven Lojistik"]
        tedarikciler = []
        for i, isim in enumerate(tedarikci_isimleri):
            t = Tedarikci(
                isim=isim, vkn=f"{1000000000+i}", email=f"info@{isim.split()[0].lower()}.com",
                telefon=f"0555 111 22 3{i}", ortalama_teslim_suresi_gun=random.randint(1, 7),
                guvenilirlik_skoru=round(random.uniform(7.0, 9.9), 1)
            )
            tedarikciler.append(t)
            session.add(t)
        await session.flush()

        # ─── 2. Ürünler ───
        kategoriler = ["Kahve", "Çay", "Süt Ürünleri", "Ambalaj", "Temizlik", "Atıştırmalık"]
        urunler = []
        for i in range(1, 31): # 30 Ürün
            kat = random.choice(kategoriler)
            alis = round(random.uniform(10, 500), 2)
            satis = round(alis * random.uniform(1.2, 2.5), 2)
            mevcut = random.randint(5, 500)
            min_s = random.randint(10, 100)
            
            u = Urun(
                sku=f"PRD-{1000+i}", isim=f"{kat} Ürünü {i}", kategori=kat,
                min_stok=min_s, max_stok=min_s*5, varsayilan_tedarikci_id=random.choice(tedarikciler).id,
                son_satis_fiyati=satis, son_alis_maliyeti=alis, mevcut_stok=mevcut
            )
            urunler.append(u)
            session.add(u)
        await session.flush()

        # ─── 2.5. Fiyat Geçmişi (Tedarikçi Karşılaştırma) ve Stok Sayımları ───
        fiyat_gecmisleri = []
        sayimlar = []
        for u in urunler:
            # Her ürün için 2-3 farklı tedarikçi fiyatı (Karşılaştırma için şart)
            secilen_tedarikciler = random.sample(tedarikciler, random.randint(2, 3))
            for t in secilen_tedarikciler:
                # Fiyatı +- %10 dalgalandır
                fiyat = round(u.son_alis_maliyeti * random.uniform(0.9, 1.1), 2)
                fg = FiyatGecmisi(
                    urun_id=u.id, tedarikci_id=t.id, tarih=today - timedelta(days=random.randint(1, 30)),
                    birim_fiyat=fiyat, para_birimi="TRY"
                )
                fiyat_gecmisleri.append(fg)
                session.add(fg)
            
            # Stok Sayımı
            if random.choice([True, False]): # Ürünlerin yarısı için sayım yapılmış olsun
                fark = random.choice([0, 0, 0, -1, -2, 1, 2]) # Çoğunlukla tam tutar
                sayim = StokSayim(
                    urun_id=u.id, sayim_tarihi=today - timedelta(days=random.randint(1, 15)),
                    beklenen_miktar=u.mevcut_stok - fark, fiili_miktar=u.mevcut_stok,
                    fark=fark, sayim_yapan=random.choice(["Ahmet", "Mehmet", "Ayşe"])
                )
                sayimlar.append(sayim)
                session.add(sayim)
        await session.flush()

        # ─── 3. Müşteriler (Fatura İçin) ───
        musteriler = ["Ahmet Kafe", "Merkez Restoran", "Köşe Büfe", "Plaza Kantin", "Deniz Otel"]

        # ─── 4. Faturalar ve Kalemler, KDV, Nakit Akışı ───
        faturalar = []
        kdv_kayitlari = []
        nakit_akisi = []
        
        # Son 60 gün içinde rastgele 50 fatura oluştur
        mevcut_bakiye = 150000.0 # Başlangıç bakiyesi
        
        for i in range(1, 51):
            gun_farki = random.randint(0, 60)
            islem_tarihi = today - timedelta(days=gun_farki)
            
            tur = random.choice(["satis", "satin_alma"])
            karsi_taraf = random.choice(musteriler) if tur == "satis" else random.choice(tedarikciler).isim
            tedarikci_id = None
            if tur == "satin_alma":
                t_obj = next(t for t in tedarikciler if t.isim == karsi_taraf)
                tedarikci_id = t_obj.id
                
            fatura = Fatura(
                fatura_no=f"FAT-{2026}{str(i).zfill(4)}", tarih=islem_tarihi, tur=tur,
                karsi_taraf_isim=karsi_taraf, tedarikci_id=tedarikci_id,
                odeme_durumu=random.choice(["odendi", "odendi", "odendi", "bekliyor", "gecikti"])
            )
            
            # Vade ve Ödeme tarihleri
            if fatura.odeme_durumu == "odendi":
                fatura.odeme_tarihi = islem_tarihi + timedelta(days=random.randint(0, 5))
            elif fatura.odeme_durumu == "gecikti":
                fatura.vade_tarihi = islem_tarihi + timedelta(days=7) # Vade geçmiş
            else:
                fatura.vade_tarihi = islem_tarihi + timedelta(days=30)
                
            session.add(fatura)
            await session.flush()
            
            # Fatura kalemleri
            toplam_matrah = 0
            toplam_kdv = 0
            kalem_sayisi = random.randint(1, 5)
            secilen_urunler = random.sample(urunler, kalem_sayisi)
            
            for u in secilen_urunler:
                miktar = random.randint(5, 50)
                birim_f = u.son_satis_fiyati if tur == "satis" else u.son_alis_maliyeti
                kdv_o = 20
                matrah = round(miktar * birim_f, 2)
                kdv = round(matrah * (kdv_o / 100), 2)
                
                kalem = FaturaKalem(
                    fatura_id=fatura.id, urun_adi=u.isim, urun_id=u.id,
                    miktar=miktar, birim_fiyat=birim_f, kdv_orani=kdv_o, kdv_tutari=kdv, satir_toplam=matrah+kdv
                )
                session.add(kalem)
                
                toplam_matrah += matrah
                toplam_kdv += kdv
                
                # Stok Hareketi
                stok_h = StokHareket(
                    urun_id=u.id, tarih=islem_tarihi, 
                    miktar=-miktar if tur == "satis" else miktar,
                    hareket_tipi=tur, kaynak_belge_id=fatura.id, birim_fiyat=birim_f
                )
                session.add(stok_h)
            
            fatura.net_tutar = toplam_matrah
            fatura.kdv_tutari = toplam_kdv
            fatura.toplam_tutar = toplam_matrah + toplam_kdv
            faturalar.append(fatura)
            
            # KDV Kaydı
            kdv_tur = "hesaplanan" if tur == "satis" else "indirilecek"
            kdv_k = KdvKayit(
                fatura_id=fatura.id, tarih=islem_tarihi, tur=kdv_tur, kdv_orani=20,
                kdv_tutari=toplam_kdv, matrah=toplam_matrah, ay=islem_tarihi.month, yil=islem_tarihi.year
            )
            kdv_kayitlari.append(kdv_k)
            session.add(kdv_k)
            
            # Nakit Akışı (Eğer ödendiyse)
            if fatura.odeme_durumu == "odendi":
                giris = fatura.toplam_tutar if tur == "satis" else 0
                cikis = fatura.toplam_tutar if tur == "satin_alma" else 0
                mevcut_bakiye += (giris - cikis)
                nakit = NakitAkisi(
                    tarih=fatura.odeme_tarihi, giris=giris, cikis=cikis, bakiye=mevcut_bakiye,
                    kategori=tur, kaynak_belge_id=fatura.id, aciklama=f"{fatura.fatura_no} ödemesi"
                )
                nakit_akisi.append(nakit)
                session.add(nakit)
                
        # ─── 5. Çalışanlar ve Puantajlar ───
        isimler = ["Ayşe Yılmaz", "Veli Demir", "Fatma Kaya", "Can Öz", "Elif Şen", "Kaan Kurt", "Zeynep Arslan", "Burak Çelik"]
        calisanlar = []
        for i, isim in enumerate(isimler):
            c = Calisan(ad_soyad=isim, pozisyon="Personel", brut_maas=random.randint(25000, 45000), ise_giris_tarihi=date(2023, 1, 15))
            calisanlar.append(c)
            session.add(c)
        await session.flush()
        
        # Son 3 ay puantaj
        for m_offset in range(3):
            p_date = today.replace(day=1) - timedelta(days=30*m_offset)
            for c in calisanlar:
                net = c.brut_maas * 0.8 # Basit hesap
                p = Puantaj(
                    calisan_id=c.id, yil=p_date.year, ay=p_date.month, calisma_gunleri=random.randint(18, 22),
                    mesai_saat=random.randint(0, 20), brut_maas=c.brut_maas, net_maas=net
                )
                session.add(p)
                
                # Maaş ödemesi nakit çıkışı (ayın 5'inde)
                odeme_tarihi = date(p_date.year, p_date.month, 5)
                if odeme_tarihi <= today:
                    mevcut_bakiye -= net
                    nakit = NakitAkisi(
                        tarih=odeme_tarihi, giris=0, cikis=net, bakiye=mevcut_bakiye,
                        kategori="maas", aciklama=f"{c.ad_soyad} {p_date.month}/{p_date.year} maaşı"
                    )
                    session.add(nakit)

        # ─── 6. Uyarılar (Dinamik) ───
        for u in urunler:
            if u.mevcut_stok <= u.min_stok:
                session.add(Uyari(
                    tur="stok_kritik", baslik=f"{u.isim} stokta azalıyor",
                    mesaj=f"Mevcut stok ({u.mevcut_stok}), minimum seviyenin ({u.min_stok}) altında.",
                    oncelik="kritik", ilgili_entity_tipi="urun", ilgili_entity_id=u.id
                ))
                
        for f in faturalar:
            if f.odeme_durumu == "gecikti":
                session.add(Uyari(
                    tur="gecikmis_odeme", baslik=f"Gecikmiş Fatura: {f.karsi_taraf_isim}",
                    mesaj=f"{f.toplam_tutar:.2f} TL tutarındaki fatura gecikmede.",
                    oncelik="yuksek", ilgili_entity_tipi="fatura", ilgili_entity_id=f.id
                ))

        await session.commit()
        print("[OK] Detayli ve baglantili seed data basariyla olusturuldu!")
        print(f" -> Toplam Urun: {len(urunler)}")
        print(f" -> Toplam Fatura: {len(faturalar)}")
        print(f" -> Toplam Calisan: {len(calisanlar)}")
        print(f" -> Nakit Islemi: {len(nakit_akisi)}")
        print(f" -> Fiyat Gecmisi (Tedarikci karsilastirma): {len(fiyat_gecmisleri)}")
        print(f" -> Stok Sayimi: {len(sayimlar)}")

if __name__ == "__main__":
    asyncio.run(seed_database())
