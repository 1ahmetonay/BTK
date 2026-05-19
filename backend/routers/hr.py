"""
KOBİ AI Asistan — HR (Puantaj/Çalışanlar) Router
"""

from typing import Optional

from fastapi import APIRouter, Body, Depends, File, Query, UploadFile
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from database import get_db, Calisan, Puantaj
from services.document_service import document_service

router = APIRouter(prefix="/api/v1/hr", tags=["İK / Puantaj"])


@router.post("/timesheet/analyze")
async def analyze_timesheet(
    file: UploadFile = File(...),
    db: AsyncSession = Depends(get_db),
):
    """Puantaj belgesini Gemini ile analiz et (DB'ye kaydetmez).
    Sonuçlar kullanıcıya gösterilir, onay sonrası /approve ile kaydedilir."""
    content = await file.read()
    mime_type = file.content_type or "image/jpeg"
    return await document_service.analyze_timesheet(db, content, mime_type)


@router.post("/timesheet/analyze-demo")
async def analyze_timesheet_demo(db: AsyncSession = Depends(get_db)):
    """Demo modunda puantaj analiz et."""
    return await document_service.analyze_timesheet(db, b"", "image/jpeg")


@router.post("/timesheet/approve")
async def approve_timesheet(
    analiz_data: dict = Body(...),
    db: AsyncSession = Depends(get_db),
):
    """Analiz edilmiş puantaj verisini onayla ve DB'ye kaydet."""
    return await document_service.approve_timesheet(db, analiz_data)


@router.get("/employees")
async def get_employees(db: AsyncSession = Depends(get_db)):
    """Tüm çalışanları listele."""
    result = await db.execute(
        select(Calisan).where(Calisan.aktif == True).order_by(Calisan.ad_soyad)
    )
    employees = result.scalars().all()
    return [
        {
            "id": e.id,
            "ad_soyad": e.ad_soyad,
            "pozisyon": e.pozisyon,
            "brut_maas": e.brut_maas,
            "ise_giris_tarihi": e.ise_giris_tarihi.isoformat() if e.ise_giris_tarihi else None,
        }
        for e in employees
    ]


@router.get("/payroll")
async def get_payroll(
    ay: Optional[int] = Query(None, ge=1, le=12),
    yil: Optional[int] = Query(None, ge=2020, le=2100),
    db: AsyncSession = Depends(get_db),
):
    """Belirli ay/yıl için maaş bordrosu."""
    from datetime import date
    today = date.today()
    ay = ay or today.month
    yil = yil or today.year

    result = await db.execute(
        select(Puantaj, Calisan.ad_soyad, Calisan.pozisyon)
        .join(Calisan, Puantaj.calisan_id == Calisan.id)
        .where(Puantaj.ay == ay, Puantaj.yil == yil, Puantaj.onaylandi == True)
        .order_by(Calisan.ad_soyad)
    )
    rows = result.all()

    toplam_brut = sum(r[0].brut_maas or 0 for r in rows)
    toplam_net = sum(r[0].net_maas or 0 for r in rows)

    return {
        "donem": f"{ay}/{yil}",
        "calisan_sayisi": len(rows),
        "toplam_brut": round(toplam_brut, 2),
        "toplam_net": round(toplam_net, 2),
        "bordro": [
            {
                "calisan": r[1],
                "pozisyon": r[2],
                "calisma_gunu": r[0].calisma_gunleri,
                "mesai_saat": r[0].mesai_saat,
                "izin_gunu": r[0].izin_gunu,
                "rapor_gunu": r[0].rapor_gunu,
                "brut_maas": r[0].brut_maas,
                "net_maas": r[0].net_maas,
                "sgk": r[0].sgk_kesinti,
                "gelir_vergisi": r[0].gelir_vergisi,
            }
            for r in rows
        ],
    }
