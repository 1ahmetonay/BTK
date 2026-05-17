"""
KOBİ AI Asistan — Veritabanı Modelleri ve Kurulum
SQLAlchemy ORM — PostgreSQL (production) / SQLite (development)
"""

import os
from datetime import date, datetime
from typing import Optional

from sqlalchemy import (
    Boolean, Column, Date, DateTime, Float, ForeignKey, Integer, String, Text,
    text,
)
from sqlalchemy.ext.asyncio import AsyncSession, async_sessionmaker, create_async_engine
from sqlalchemy.orm import DeclarativeBase, relationship
from dotenv import load_dotenv

load_dotenv()


# ─── Base ───────────────────────────────────────────────────────────
class Base(DeclarativeBase):
    pass


# ─── Ürünler (Stok Master) ──────────────────────────────────────────
class Urun(Base):
    __tablename__ = "urunler"

    id = Column(Integer, primary_key=True, autoincrement=True)
    sku = Column(String(50), unique=True, nullable=False, index=True)
    isim = Column(String(200), nullable=False)
    kategori = Column(String(100))
    birim = Column(String(20), default="adet")
    min_stok = Column(Integer, default=0)
    max_stok = Column(Integer, nullable=True)
    varsayilan_tedarikci_id = Column(Integer, ForeignKey("tedarikciler.id"), nullable=True)
    son_satis_fiyati = Column(Float, nullable=True)
    son_alis_maliyeti = Column(Float, nullable=True)
    mevcut_stok = Column(Integer, default=0)
    aktif = Column(Boolean, default=True)
    olusturma_tarihi = Column(DateTime, default=datetime.utcnow)

    hareketler = relationship("StokHareket", back_populates="urun", lazy="selectin")
    fiyat_gecmisi = relationship("FiyatGecmisi", back_populates="urun", lazy="selectin")
    sayimlar = relationship("StokSayim", back_populates="urun", lazy="selectin")
    varsayilan_tedarikci = relationship("Tedarikci", back_populates="urunler", lazy="selectin")


# ─── Stok Hareketleri ────────────────────────────────────────────────
class StokHareket(Base):
    __tablename__ = "stok_hareketleri"

    id = Column(Integer, primary_key=True, autoincrement=True)
    urun_id = Column(Integer, ForeignKey("urunler.id"), nullable=False, index=True)
    tarih = Column(DateTime, default=datetime.utcnow)
    miktar = Column(Float, nullable=False)
    hareket_tipi = Column(String(30))
    kaynak_belge_id = Column(Integer, nullable=True)
    birim_fiyat = Column(Float, nullable=True)
    aciklama = Column(Text, nullable=True)

    urun = relationship("Urun", back_populates="hareketler")


# ─── Fiyat Geçmişi (Enflasyon Takibi) ───────────────────────────────
class FiyatGecmisi(Base):
    __tablename__ = "fiyat_gecmisi"

    id = Column(Integer, primary_key=True, autoincrement=True)
    urun_id = Column(Integer, ForeignKey("urunler.id"), nullable=False, index=True)
    tedarikci_id = Column(Integer, ForeignKey("tedarikciler.id"), nullable=True)
    tarih = Column(Date, default=date.today)
    birim_fiyat = Column(Float, nullable=False)
    para_birimi = Column(String(5), default="TRY")

    urun = relationship("Urun", back_populates="fiyat_gecmisi")
    tedarikci = relationship("Tedarikci", lazy="selectin")


# ─── Stok Sayımları ──────────────────────────────────────────────────
class StokSayim(Base):
    __tablename__ = "stok_sayimlari"

    id = Column(Integer, primary_key=True, autoincrement=True)
    urun_id = Column(Integer, ForeignKey("urunler.id"), nullable=False)
    sayim_tarihi = Column(Date, default=date.today)
    beklenen_miktar = Column(Float, nullable=True)
    fiili_miktar = Column(Float, nullable=False)
    fark = Column(Float, nullable=True)
    sayim_yapan = Column(String(100))

    urun = relationship("Urun", back_populates="sayimlar")


# ─── Tedarikçiler ────────────────────────────────────────────────────
class Tedarikci(Base):
    __tablename__ = "tedarikciler"

    id = Column(Integer, primary_key=True, autoincrement=True)
    isim = Column(String(200), nullable=False)
    vkn = Column(String(20), nullable=True)
    email = Column(String(200), nullable=True)
    telefon = Column(String(20), nullable=True)
    ortalama_teslim_suresi_gun = Column(Integer, nullable=True)
    guvenilirlik_skoru = Column(Float, default=5.0)
    aktif = Column(Boolean, default=True)

    urunler = relationship("Urun", back_populates="varsayilan_tedarikci", lazy="selectin")
    faturalar = relationship("Fatura", back_populates="tedarikci", lazy="selectin")


# ─── Faturalar ────────────────────────────────────────────────────────
class Fatura(Base):
    __tablename__ = "faturalar"

    id = Column(Integer, primary_key=True, autoincrement=True)
    fatura_no = Column(String(50), nullable=True)
    tarih = Column(Date, default=date.today)
    tur = Column(String(30))
    karsi_taraf_isim = Column(String(200))
    karsi_taraf_vkn = Column(String(20), nullable=True)
    tedarikci_id = Column(Integer, ForeignKey("tedarikciler.id"), nullable=True)
    toplam_tutar = Column(Float, default=0)
    kdv_tutari = Column(Float, default=0)
    net_tutar = Column(Float, default=0)
    odeme_durumu = Column(String(20), default="bekliyor")
    odeme_tarihi = Column(Date, nullable=True)
    vade_tarihi = Column(Date, nullable=True)
    belge_url = Column(Text, nullable=True)
    gemini_raw_json = Column(Text, nullable=True)
    islendi = Column(Boolean, default=False)
    olusturma_tarihi = Column(DateTime, default=datetime.utcnow)

    tedarikci = relationship("Tedarikci", back_populates="faturalar", lazy="selectin")
    kalemler = relationship("FaturaKalem", back_populates="fatura", lazy="selectin", cascade="all, delete-orphan")


# ─── Fatura Kalemleri ─────────────────────────────────────────────────
class FaturaKalem(Base):
    __tablename__ = "fatura_kalemleri"

    id = Column(Integer, primary_key=True, autoincrement=True)
    fatura_id = Column(Integer, ForeignKey("faturalar.id"), nullable=False, index=True)
    urun_adi = Column(String(200), nullable=False)
    urun_id = Column(Integer, ForeignKey("urunler.id"), nullable=True)
    miktar = Column(Float, nullable=False)
    birim = Column(String(20), default="adet")
    birim_fiyat = Column(Float, nullable=False)
    kdv_orani = Column(Float, default=20)
    kdv_tutari = Column(Float, default=0)
    satir_toplam = Column(Float, default=0)

    fatura = relationship("Fatura", back_populates="kalemler")
    urun = relationship("Urun", lazy="selectin")


# ─── Çalışanlar ───────────────────────────────────────────────────────
class Calisan(Base):
    __tablename__ = "calisanlar"

    id = Column(Integer, primary_key=True, autoincrement=True)
    ad_soyad = Column(String(200), nullable=False)
    pozisyon = Column(String(100), nullable=True)
    brut_maas = Column(Float, nullable=True)
    ise_giris_tarihi = Column(Date, nullable=True)
    aktif = Column(Boolean, default=True)

    puantajlar = relationship("Puantaj", back_populates="calisan", lazy="selectin")


# ─── Puantaj Kayıtları ────────────────────────────────────────────────
class Puantaj(Base):
    __tablename__ = "puantaj"

    id = Column(Integer, primary_key=True, autoincrement=True)
    calisan_id = Column(Integer, ForeignKey("calisanlar.id"), nullable=False, index=True)
    yil = Column(Integer, nullable=False)
    ay = Column(Integer, nullable=False)
    calisma_gunleri = Column(Integer, default=0)
    mesai_saat = Column(Float, default=0)
    izin_gunu = Column(Integer, default=0)
    rapor_gunu = Column(Integer, default=0)
    brut_maas = Column(Float, nullable=True)
    net_maas = Column(Float, nullable=True)
    sgk_kesinti = Column(Float, nullable=True)
    gelir_vergisi = Column(Float, nullable=True)
    gemini_ham_veri = Column(Text, nullable=True)
    olusturma_tarihi = Column(DateTime, default=datetime.utcnow)

    calisan = relationship("Calisan", back_populates="puantajlar")


# ─── Uyarılar ─────────────────────────────────────────────────────────
class Uyari(Base):
    __tablename__ = "uyarilar"

    id = Column(Integer, primary_key=True, autoincrement=True)
    tur = Column(String(30))
    baslik = Column(String(200), nullable=False)
    mesaj = Column(Text, nullable=False)
    oncelik = Column(String(20), default="normal")
    olusturma_tarihi = Column(DateTime, default=datetime.utcnow)
    okundu = Column(Boolean, default=False)
    aksiyon_alindi = Column(Boolean, default=False)
    ilgili_entity_tipi = Column(String(30), nullable=True)
    ilgili_entity_id = Column(Integer, nullable=True)


# ─── Nakit Akışı ──────────────────────────────────────────────────────
class NakitAkisi(Base):
    __tablename__ = "nakit_akisi"

    id = Column(Integer, primary_key=True, autoincrement=True)
    tarih = Column(Date, default=date.today)
    giris = Column(Float, default=0)
    cikis = Column(Float, default=0)
    bakiye = Column(Float, default=0)
    aciklama = Column(Text, nullable=True)
    kategori = Column(String(50), nullable=True)
    kaynak_belge_id = Column(Integer, nullable=True)


# ─── Sabah Brifingi Cache ──────────────────────────────────────────
class BriefCache(Base):
    __tablename__ = "brief_cache"

    id = Column(Integer, primary_key=True, autoincrement=True)
    tarih = Column(Date, default=date.today, unique=True)
    brief_text = Column(Text, nullable=False)
    brief_data_json = Column(Text, nullable=True)
    olusturma_tarihi = Column(DateTime, default=datetime.utcnow)


# ─── KDV Kayıtları ────────────────────────────────────────────────────
class KdvKayit(Base):
    __tablename__ = "kdv_kayitlari"

    id = Column(Integer, primary_key=True, autoincrement=True)
    fatura_id = Column(Integer, ForeignKey("faturalar.id"), nullable=True)
    tarih = Column(Date, default=date.today)
    tur = Column(String(20))
    kdv_orani = Column(Float)
    kdv_tutari = Column(Float)
    matrah = Column(Float)
    ay = Column(Integer)
    yil = Column(Integer)


# ═══════════════════════════════════════════════════════════════════════
#  Veritabanı Motor Kurulumu — PostgreSQL / SQLite dual support
# ═══════════════════════════════════════════════════════════════════════

DATABASE_URL = os.getenv("DATABASE_URL", "sqlite+aiosqlite:///./kobi_ai.db")

_is_sqlite = DATABASE_URL.startswith("sqlite")

_engine_kwargs: dict = {"echo": False}
if _is_sqlite:
    _engine_kwargs["connect_args"] = {"check_same_thread": False}

engine = create_async_engine(DATABASE_URL, **_engine_kwargs)

async_session = async_sessionmaker(
    engine,
    class_=AsyncSession,
    expire_on_commit=False,
)


async def get_db():
    """FastAPI dependency: async veritabanı oturumu sağlar."""
    async with async_session() as session:
        try:
            yield session
        finally:
            await session.close()


async def init_db():
    """Veritabanı tablolarını oluşturur."""
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)
        if _is_sqlite:
            await conn.execute(text("PRAGMA journal_mode=WAL"))
            print("[OK] Veritabani tablolari olusturuldu (SQLite WAL mode).")
        else:
            print("[OK] Veritabani tablolari olusturuldu (PostgreSQL).")
