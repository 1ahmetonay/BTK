"""
KOBİ AI Asistan — Finans Router
Gelir-gider, nakit akisi, KDV, odemeler.
"""

from typing import Optional

from fastapi import APIRouter, Depends, Query
from sqlalchemy.ext.asyncio import AsyncSession

from database import get_db
from services.finance_service import finance_service

router = APIRouter(prefix="/api/v1/finance", tags=["Finans"])


@router.get("/pl")
async def get_pl_summary(
    ay: Optional[int] = Query(None, ge=1, le=12, description="Ay (1-12)"),
    yil: Optional[int] = Query(None, ge=2020, le=2100, description="Yil"),
    db: AsyncSession = Depends(get_db),
):
    """Gelir-gider (P&L) ozeti."""
    return await finance_service.get_pl_summary(db, ay=ay, yil=yil)


@router.get("/cashflow")
async def get_cashflow(
    gun: int = Query(30, ge=1, le=365, description="Gecmis kac gun"),
    db: AsyncSession = Depends(get_db),
):
    """Nakit akisi ozeti ve projeksiyonu."""
    return await finance_service.get_cashflow(db, gun=gun)


@router.get("/kdv")
async def get_kdv_summary(
    ay: Optional[int] = Query(None, ge=1, le=12),
    yil: Optional[int] = Query(None, ge=2020, le=2100),
    db: AsyncSession = Depends(get_db),
):
    """Aylik KDV beyanname ozeti."""
    return await finance_service.get_kdv_summary(db, ay=ay, yil=yil)


@router.get("/overdue")
async def get_overdue_payments(
    tur: Optional[str] = Query(None, description="Fatura turu: satis veya satin_alma"),
    db: AsyncSession = Depends(get_db),
):
    """Gecikmis odemeler."""
    return await finance_service.get_overdue_payments(db, tur=tur)


@router.get("/invoices")
async def get_recent_invoices(
    limit: int = Query(10, ge=1, le=100, description="Son kac fatura"),
    db: AsyncSession = Depends(get_db),
):
    """Son faturalar."""
    return await finance_service.get_recent_invoices(db, limit=limit)
