"""
KOBİ AI Asistan — Stok Router
Stok yönetimi API endpoint'leri.
"""

import logging

from fastapi import APIRouter, Depends, HTTPException, Path, Query
from pydantic import BaseModel, Field
from sqlalchemy.ext.asyncio import AsyncSession

from database import get_db
from services.stock_service import stock_service

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/api/v1/stock", tags=["Stok"])


@router.get("/overview")
async def get_stock_overview(db: AsyncSession = Depends(get_db)):
    """Stok genel durumu: toplam SKU, kritik, deger, urun listesi."""
    return await stock_service.get_overview(db)


@router.get("/critical")
async def get_critical_stock(db: AsyncSession = Depends(get_db)):
    """Kritik seviyedeki urunler."""
    return await stock_service.get_critical_products(db)


@router.get("/movements")
async def get_stock_movements(
    limit: int = Query(20, ge=1, le=200, description="Son kac hareket"),
    db: AsyncSession = Depends(get_db),
):
    """Son stok hareketleri."""
    return await stock_service.get_movements(db, limit=limit)


@router.get("/abc-analysis")
async def get_abc_analysis(db: AsyncSession = Depends(get_db)):
    """ABC stok analizi."""
    return await stock_service.get_abc_analysis(db)


@router.get("/{sku}/analysis")
async def get_product_analysis(
    sku: str = Path(..., min_length=1, max_length=50, description="Urun SKU kodu"),
    db: AsyncSession = Depends(get_db),
):
    """Tek urun icin detayli analiz."""
    result = await stock_service.get_product_analysis(db, sku)
    if not result or (isinstance(result, dict) and result.get("error")):
        raise HTTPException(status_code=404, detail=f"SKU '{sku}' bulunamadi")
    return result


@router.get("/{sku}/suppliers")
async def get_supplier_comparison(
    sku: str = Path(..., min_length=1, max_length=50),
    db: AsyncSession = Depends(get_db),
):
    """Urun icin tedarikci karsilastirmasi."""
    return await stock_service.get_supplier_comparison(db, sku)


@router.get("/{sku}/seasonality")
async def get_seasonality_pattern(
    sku: str = Path(..., min_length=1, max_length=50),
    db: AsyncSession = Depends(get_db),
):
    """Urunun aylik hareket pattern'ini analiz eder."""
    return await stock_service.get_seasonality_pattern(db, sku)


class SimulateRequest(BaseModel):
    price_change_pct: float = Field(..., ge=-99, le=1000, description="Fiyat degisim yuzdesi")


@router.post("/{sku}/simulate")
async def simulate_price_change(
    request: SimulateRequest,
    sku: str = Path(..., min_length=1, max_length=50),
    db: AsyncSession = Depends(get_db),
):
    """Fiyat degisikliginin stok eritme hizina etkisini simule eder."""
    return await stock_service.simulate_price_change(db, sku, request.price_change_pct)
