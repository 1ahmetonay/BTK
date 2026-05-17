"""
KOBİ AI Asistan — Uyarılar Router
"""

from typing import Optional

from fastapi import APIRouter, Depends, Query
from sqlalchemy import select, update
from sqlalchemy.ext.asyncio import AsyncSession

import sys, os
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from database import get_db, Uyari

router = APIRouter(prefix="/api/v1/alerts", tags=["Uyarılar"])


@router.get("")
async def get_alerts(
    oncelik: Optional[str] = Query(None, description="kritik, yuksek, normal, dusuk"),
    okunmamis: bool = Query(False, description="Sadece okunmamış"),
    db: AsyncSession = Depends(get_db),
):
    """Tüm uyarıları listele."""
    query = select(Uyari).order_by(Uyari.olusturma_tarihi.desc())

    if oncelik:
        query = query.where(Uyari.oncelik == oncelik)
    if okunmamis:
        query = query.where(Uyari.okundu == False)

    result = await db.execute(query)
    alerts = result.scalars().all()

    return [
        {
            "id": a.id,
            "tur": a.tur,
            "baslik": a.baslik,
            "mesaj": a.mesaj,
            "oncelik": a.oncelik,
            "tarih": a.olusturma_tarihi.isoformat() if a.olusturma_tarihi else None,
            "okundu": a.okundu,
            "aksiyon_alindi": a.aksiyon_alindi,
        }
        for a in alerts
    ]


@router.get("/count")
async def get_unread_count(db: AsyncSession = Depends(get_db)):
    """Okunmamış uyarı sayısı."""
    from sqlalchemy import func
    result = await db.execute(
        select(func.count(Uyari.id)).where(Uyari.okundu == False)
    )
    count = result.scalar() or 0
    return {"count": count}


@router.put("/{alert_id}/read")
async def mark_as_read(alert_id: int, db: AsyncSession = Depends(get_db)):
    """Uyarıyı okundu olarak işaretle."""
    await db.execute(
        update(Uyari).where(Uyari.id == alert_id).values(okundu=True)
    )
    await db.commit()
    return {"success": True}


@router.put("/{alert_id}/action")
async def mark_action_taken(alert_id: int, db: AsyncSession = Depends(get_db)):
    """Uyarı için aksiyon alındı olarak işaretle."""
    await db.execute(
        update(Uyari).where(Uyari.id == alert_id).values(aksiyon_alindi=True, okundu=True)
    )
    await db.commit()
    return {"success": True}
