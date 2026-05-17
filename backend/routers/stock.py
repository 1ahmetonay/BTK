"""
KOBİ AI Asistan — Stok Router
Stok yönetimi API endpoint'leri.
"""

from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession

import sys, os
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from database import get_db
from services.stock_service import stock_service

router = APIRouter(prefix="/api/v1/stock", tags=["Stok"])


@router.get("/overview")
async def get_stock_overview(db: AsyncSession = Depends(get_db)):
    """Stok genel durumu: toplam SKU, kritik, değer, ürün listesi."""
    return await stock_service.get_overview(db)


@router.get("/critical")
async def get_critical_stock(db: AsyncSession = Depends(get_db)):
    """Kritik seviyedeki ürünler."""
    return await stock_service.get_critical_products(db)


@router.get("/movements")
async def get_stock_movements(limit: int = 20, db: AsyncSession = Depends(get_db)):
    """Son stok hareketleri."""
    return await stock_service.get_movements(db, limit=limit)


@router.get("/abc-analysis")
async def get_abc_analysis(db: AsyncSession = Depends(get_db)):
    """ABC stok analizi."""
    return await stock_service.get_abc_analysis(db)


@router.get("/{sku}/analysis")
async def get_product_analysis(sku: str, db: AsyncSession = Depends(get_db)):
    """Tek ürün için detaylı analiz."""
    return await stock_service.get_product_analysis(db, sku)


@router.get("/{sku}/suppliers")
async def get_supplier_comparison(sku: str, db: AsyncSession = Depends(get_db)):
    """Ürün için tedarikçi karşılaştırması."""
    return await stock_service.get_supplier_comparison(db, sku)


@router.get("/{sku}/seasonality")
async def get_seasonality_pattern(sku: str, db: AsyncSession = Depends(get_db)):
    """Ürünün aylık hareket pattern'ını analiz eder."""
    return await stock_service.get_seasonality_pattern(db, sku)


from pydantic import BaseModel

class SimulateRequest(BaseModel):
    price_change_pct: float

@router.post("/{sku}/simulate")
async def simulate_price_change(sku: str, request: SimulateRequest, db: AsyncSession = Depends(get_db)):
    """Fiyat değişikliğinin stok eritme hızına etkisini simüle eder."""
    return await stock_service.simulate_price_change(db, sku, request.price_change_pct)

