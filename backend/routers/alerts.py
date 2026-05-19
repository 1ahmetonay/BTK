"""
KOBİ AI Asistan — Uyarilar Router
"""

import logging
from typing import Literal, Optional

from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy import func, select, update
from sqlalchemy.ext.asyncio import AsyncSession

from database import get_db, Uyari

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/api/v1/alerts", tags=["Uyarilar"])

_VALID_PRIORITIES = {"kritik", "yuksek", "normal", "dusuk"}


@router.get("")
async def get_alerts(
    oncelik: Optional[str] = Query(None, description="kritik, yuksek, normal, dusuk"),
    okunmamis: bool = Query(False, description="Sadece okunmamis"),
    db: AsyncSession = Depends(get_db),
):
    """Tum uyarilari listele."""
    if oncelik and oncelik not in _VALID_PRIORITIES:
        raise HTTPException(
            status_code=400,
            detail=f"Gecersiz oncelik: '{oncelik}'. Gecerli degerler: {', '.join(sorted(_VALID_PRIORITIES))}",
        )

    query = select(Uyari).order_by(Uyari.olusturma_tarihi.desc())

    if oncelik:
        query = query.where(Uyari.oncelik == oncelik)
    if okunmamis:
        query = query.where(Uyari.okundu == False)  # noqa: E712

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
    """Okunmamis uyari sayisi."""
    result = await db.execute(
        select(func.count(Uyari.id)).where(Uyari.okundu == False)  # noqa: E712
    )
    count = result.scalar() or 0
    return {"count": count}


@router.put("/{alert_id}/read")
async def mark_as_read(alert_id: int, db: AsyncSession = Depends(get_db)):
    """Uyariyi okundu olarak isaretle."""
    result = await db.execute(
        update(Uyari).where(Uyari.id == alert_id).values(okundu=True)
    )
    if result.rowcount == 0:
        raise HTTPException(status_code=404, detail=f"Uyari #{alert_id} bulunamadi")
    await db.commit()
    return {"success": True}


@router.put("/{alert_id}/action")
async def mark_action_taken(alert_id: int, db: AsyncSession = Depends(get_db)):
    """Uyari icin aksiyon alindi olarak isaretle."""
    result = await db.execute(
        update(Uyari).where(Uyari.id == alert_id).values(aksiyon_alindi=True, okundu=True)
    )
    if result.rowcount == 0:
        raise HTTPException(status_code=404, detail=f"Uyari #{alert_id} bulunamadi")
    await db.commit()
    return {"success": True}
