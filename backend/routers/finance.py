"""
KOBİ AI Asistan — Finans Router
Gelir-gider, nakit akışı, KDV, ödemeler.
"""

from typing import Optional

from fastapi import APIRouter, Depends, Query
from sqlalchemy.ext.asyncio import AsyncSession

import sys, os
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from database import get_db
from services.finance_service import finance_service

router = APIRouter(prefix="/api/v1/finance", tags=["Finans"])


@router.get("/pl")
async def get_pl_summary(
    ay: Optional[int] = Query(None, description="Ay (1-12)"),
    yil: Optional[int] = Query(None, description="Yıl"),
    db: AsyncSession = Depends(get_db),
):
    """Gelir-gider (P&L) özeti."""
    return await finance_service.get_pl_summary(db, ay=ay, yil=yil)


@router.get("/cashflow")
async def get_cashflow(
    gun: int = Query(30, description="Geçmiş kaç gün"),
    db: AsyncSession = Depends(get_db),
):
    """Nakit akışı özeti ve projeksiyonu."""
    return await finance_service.get_cashflow(db, gun=gun)


@router.get("/kdv")
async def get_kdv_summary(
    ay: Optional[int] = Query(None),
    yil: Optional[int] = Query(None),
    db: AsyncSession = Depends(get_db),
):
    """Aylık KDV beyanname özeti."""
    return await finance_service.get_kdv_summary(db, ay=ay, yil=yil)


@router.get("/overdue")
async def get_overdue_payments(db: AsyncSession = Depends(get_db)):
    """Gecikmiş ödemeler."""
    return await finance_service.get_overdue_payments(db)


@router.get("/invoices")
async def get_recent_invoices(
    limit: int = Query(10, description="Son kaç fatura"),
    db: AsyncSession = Depends(get_db),
):
    """Son faturalar."""
    return await finance_service.get_recent_invoices(db, limit=limit)
