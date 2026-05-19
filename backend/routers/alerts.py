"""
KOBİ AI Asistan — Uyarilar Router
"""

import logging
from datetime import date, datetime, time
from typing import Literal, Optional

from fastapi import APIRouter, Depends, HTTPException, Query
from pydantic import BaseModel, Field
from sqlalchemy import func, select, update
from sqlalchemy.ext.asyncio import AsyncSession

from database import get_db, Uyari

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/api/v1/alerts", tags=["Uyarilar"])

_VALID_PRIORITIES = {"kritik", "yuksek", "normal", "dusuk"}


class ReminderCreateRequest(BaseModel):
    customer_name: str = Field(..., min_length=1, max_length=200)
    reminder_date: date
    draft_text: str = Field(..., min_length=1)
    amount: Optional[str] = Field(None, max_length=80)
    delay: Optional[str] = Field(None, max_length=80)


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

    now = datetime.now()
    query = (
        select(Uyari)
        .where(Uyari.olusturma_tarihi <= now)
        .order_by(Uyari.olusturma_tarihi.desc())
    )

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
    now = datetime.now()
    result = await db.execute(
        select(func.count(Uyari.id)).where(
            Uyari.okundu == False,  # noqa: E712
            Uyari.olusturma_tarihi <= now,
        )
    )
    count = result.scalar() or 0
    return {"count": count}


@router.post("/reminders")
async def create_payment_reminder(
    request: ReminderCreateRequest,
    db: AsyncSession = Depends(get_db),
):
    """Odeme hatirlatma taslagini tarihli uyari olarak kaydet."""
    reminder_at = datetime.combine(request.reminder_date, time.min)
    detail_parts = [
        f"Müşteri: {request.customer_name}",
        f"Hatırlatma tarihi: {request.reminder_date.isoformat()}",
    ]
    if request.amount:
        detail_parts.append(f"Tutar: {request.amount}")
    if request.delay:
        detail_parts.append(f"Gecikme: {request.delay}")

    message = "\n".join([
        *detail_parts,
        "",
        "Hatırlatma taslağı:",
        request.draft_text,
    ])
    alert = Uyari(
        tur="odeme_hatirlatici",
        baslik=f"{request.customer_name} ödeme hatırlatma taslağı",
        mesaj=message,
        oncelik="normal",
        olusturma_tarihi=reminder_at,
        okundu=False,
        aksiyon_alindi=False,
        ilgili_entity_tipi="payment_reminder",
    )
    db.add(alert)
    await db.commit()
    await db.refresh(alert)
    return {
        "id": alert.id,
        "tur": alert.tur,
        "baslik": alert.baslik,
        "mesaj": alert.mesaj,
        "oncelik": alert.oncelik,
        "tarih": alert.olusturma_tarihi.isoformat() if alert.olusturma_tarihi else None,
        "okundu": alert.okundu,
        "aksiyon_alindi": alert.aksiyon_alindi,
    }


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
