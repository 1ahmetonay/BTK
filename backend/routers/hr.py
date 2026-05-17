"""
KOBİ AI Asistan — HR (Puantaj/Çalışanlar) Router
"""

from typing import Optional

from fastapi import APIRouter, Depends, File, Query, UploadFile
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

import sys, os
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from database import get_db, Calisan, Puantaj
from services.document_service import document_service

router = APIRouter(prefix="/api/v1/hr", tags=["İK / Puantaj"])


@router.post("/timesheet/process")
async def process_timesheet(
    file: UploadFile = File(...),
    db: AsyncSession = Depends(get_db),
):
    """Kağıt puantaj fotoğrafını yükle ve işle.
    
    Akış:
    1. Gemini Vision ile puantaj tablosunu oku
    2. Çalışanları eşleştir
    3. Maaş hesapla
    4. Puantaj kaydı oluştur
    5. Nakit akışına gider olarak ekle
    """
    content = await file.read()
    mime_type = file.content_type or "image/jpeg"
    return await document_service.process_timesheet(db, content, mime_type)


@router.post("/timesheet/process-demo")
async def process_timesheet_demo(db: AsyncSession = Depends(get_db)):
    """Demo modunda puantaj işle."""
    return await document_service.process_timesheet(db, b"", "image/jpeg")


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
    ay: Optional[int] = Query(None),
    yil: Optional[int] = Query(None),
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
        .where(Puantaj.ay == ay, Puantaj.yil == yil)
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
