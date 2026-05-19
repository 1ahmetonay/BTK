"""
KOBİ AI Asistan — E-Fatura Router
E-fatura üretimi, listeleme ve DB kaydı.
"""

from typing import List, Optional

from fastapi import APIRouter, Depends, Query
from pydantic import BaseModel, Field
from sqlalchemy import select, desc
from sqlalchemy.ext.asyncio import AsyncSession

from database import get_db, Fatura, FaturaKalem, NakitAkisi, Urun, StokHareket
from services.invoice_service import invoice_service
from services.event_bus import event_bus, Events


router = APIRouter(prefix="/api/v1/invoice", tags=["E-Fatura"])


class InvoiceItem(BaseModel):
    urun_adi: str = Field(..., min_length=1, max_length=200)
    miktar: float = Field(..., gt=0, le=1_000_000)
    birim: str = Field(default="adet", max_length=20)
    birim_fiyat: float = Field(..., ge=0, le=100_000_000)
    kdv_orani: float = Field(default=20, ge=0, le=100)
    kdv_tutari: float = 0
    satir_toplam: float = 0


class InvoiceRequest(BaseModel):
    musteri_adi: str = Field(..., min_length=1, max_length=200)
    musteri_vkn: str = Field(default="", max_length=20)
    satici_adi: str = Field(default="KOBİ AI Demo İşletmesi", max_length=200)
    satici_vkn: str = Field(default="1234567890", max_length=20)
    kalemler: List[InvoiceItem] = Field(..., min_length=1, max_length=100)
    para_birimi: str = Field(default="TRY", max_length=5)
    fatura_no: Optional[str] = Field(default=None, max_length=50)


@router.post("/generate")
async def generate_efatura(request: InvoiceRequest, db: AsyncSession = Depends(get_db)):
    """E-fatura üret (UBL-TR XML + QR kod + PDF).

    Akış:
    1. Kalem bilgileri alınır, KDV otomatik hesaplanır
    2. UBL-TR 1.2 XML üretilir
    3. GİB doğrulama QR kodu eklenir
    4. Profesyonel PDF render edilir
    5. Fatura DB'ye kaydedilir
    6. Stok düşülür + nakit akışı güncellenir
    """
    # KDV hesapla
    kalemler = []
    toplam_kdv = 0
    net_tutar = 0

    for k in request.kalemler:
        matrah = k.miktar * k.birim_fiyat
        kdv_tutari = matrah * k.kdv_orani / 100
        satir_toplam = matrah + kdv_tutari

        kalemler.append({
            "urun_adi": k.urun_adi,
            "miktar": k.miktar,
            "birim": k.birim,
            "birim_fiyat": k.birim_fiyat,
            "kdv_orani": k.kdv_orani,
            "kdv_tutari": round(kdv_tutari, 2),
            "satir_toplam": round(satir_toplam, 2),
        })
        toplam_kdv += kdv_tutari
        net_tutar += matrah

    invoice_data = {
        "musteri_adi": request.musteri_adi,
        "musteri_vkn": request.musteri_vkn,
        "satici_adi": request.satici_adi,
        "satici_vkn": request.satici_vkn,
        "kalemler": kalemler,
        "toplam_kdv": round(toplam_kdv, 2),
        "net_tutar": round(net_tutar, 2),
        "genel_toplam": round(net_tutar + toplam_kdv, 2),
        "para_birimi": request.para_birimi,
        "fatura_no": request.fatura_no,
    }

    # PDF + XML + QR üret
    result = invoice_service.generate_efatura(invoice_data)

    # DB'ye kaydet
    from datetime import date
    fatura = Fatura(
        fatura_no=result["fatura_no"],
        tarih=date.today(),
        tur="satis",
        karsi_taraf_isim=request.musteri_adi,
        karsi_taraf_vkn=request.musteri_vkn,
        toplam_tutar=invoice_data["genel_toplam"],
        kdv_tutari=invoice_data["toplam_kdv"],
        net_tutar=invoice_data["net_tutar"],
        odeme_durumu="bekliyor",
        islendi=True,
    )
    db.add(fatura)
    await db.flush()

    # Fatura kalemlerini kaydet + stok düş
    for k in kalemler:
        # Ürün eşleştir
        urun_result = await db.execute(
            select(Urun).where(Urun.isim.ilike(f"%{k['urun_adi']}%"))
        )
        urun = urun_result.scalar_one_or_none()

        fatura_kalem = FaturaKalem(
            fatura_id=fatura.id,
            urun_adi=k["urun_adi"],
            urun_id=urun.id if urun else None,
            miktar=k["miktar"],
            birim=k["birim"],
            birim_fiyat=k["birim_fiyat"],
            kdv_orani=k["kdv_orani"],
            kdv_tutari=k["kdv_tutari"],
            satir_toplam=k["satir_toplam"],
        )
        db.add(fatura_kalem)

        # Stok düş (satış faturası → stoktan çıkış)
        if urun:
            hareket = StokHareket(
                urun_id=urun.id,
                miktar=-k["miktar"],
                hareket_tipi="satis",
                kaynak_belge_id=fatura.id,
                birim_fiyat=k["birim_fiyat"],
            )
            db.add(hareket)
            urun.mevcut_stok = max(0, (urun.mevcut_stok or 0) - int(k["miktar"]))

    # Nakit akışı kaydı (gelir)
    nakit = NakitAkisi(
        tarih=date.today(),
        giris=invoice_data["genel_toplam"],
        aciklama=f"E-Fatura: {result['fatura_no']} - {request.musteri_adi}",
        kategori="satis",
        kaynak_belge_id=fatura.id,
    )
    db.add(nakit)

    await db.commit()

    # Event tetikle
    await event_bus.emit(Events.FATURA_ISLENDI, fatura_id=fatura.id, tur="satis")

    result["fatura_id"] = fatura.id
    return result


@router.get("/list")
async def list_invoices(
    limit: int = Query(20, ge=1, le=200),
    tur: Optional[str] = Query(None, max_length=30),
    db: AsyncSession = Depends(get_db),
):
    """Kesilen faturaları listele."""
    query = select(Fatura).order_by(desc(Fatura.olusturma_tarihi)).limit(limit)
    if tur:
        query = query.where(Fatura.tur == tur)

    result = await db.execute(query)
    faturalar = result.scalars().all()

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
        for f in faturalar
    ]


@router.post("/generate-demo")
async def generate_demo_efatura(db: AsyncSession = Depends(get_db)):
    """Demo e-fatura üret — hazır verilerle."""
    demo_data = {
        "musteri_adi": "Yılmaz Market",
        "musteri_vkn": "9876543210",
        "satici_adi": "KOBİ AI Demo İşletmesi",
        "satici_vkn": "1234567890",
        "kalemler": [
            {
                "urun_adi": "Türk Kahvesi 250g",
                "miktar": 50,
                "birim": "adet",
                "birim_fiyat": 180.0,
                "kdv_orani": 20,
                "kdv_tutari": 1800.0,
                "satir_toplam": 10800.0,
            },
            {
                "urun_adi": "Filtre Kahve 1kg",
                "miktar": 20,
                "birim": "adet",
                "birim_fiyat": 450.0,
                "kdv_orani": 20,
                "kdv_tutari": 1800.0,
                "satir_toplam": 10800.0,
            },
        ],
        "toplam_kdv": 3600.0,
        "net_tutar": 18000.0,
        "genel_toplam": 21600.0,
        "para_birimi": "TRY",
    }
    return invoice_service.generate_efatura(demo_data)
