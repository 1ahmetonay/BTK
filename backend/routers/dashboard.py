"""
KOBİ AI Asistan — Dashboard Router
Ana sayfa özet verileri.
"""

from datetime import date

from fastapi import APIRouter, Depends
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

import sys, os
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from database import get_db, BriefCache
from services.stock_service import stock_service
from services.finance_service import finance_service
from services.gemini_service import gemini_service

router = APIRouter(prefix="/api/v1/dashboard", tags=["Dashboard"])


@router.get("/summary")
async def get_dashboard_summary(db: AsyncSession = Depends(get_db)):
    """Ana sayfa için tüm özet veriler."""
    stock_overview = await stock_service.get_overview(db)
    critical = await stock_service.get_critical_products(db)
    cashflow = await finance_service.get_cashflow(db, gun=30)
    kdv = await finance_service.get_kdv_summary(db)
    overdue = await finance_service.get_overdue_payments(db)

    # Sabah brifingi — önce cache'den dene
    morning_brief = await _get_cached_brief(db)

    if not morning_brief:
        brief_data = {
            "critical_stock": critical[:3],
            "cash_status": {
                "bakiye": cashflow["mevcut_bakiye"],
                "projeksiyonlar": cashflow["projeksiyonlar"],
            },
            "overdue_payments": overdue,
            "kdv_deadline": kdv["beyanname_son_tarihi"],
        }
        morning_brief = await gemini_service.generate_morning_brief(brief_data)

    return {
        "stats": {
            "toplam_sku": stock_overview["toplam_sku"],
            "kritik_stok": stock_overview["kritik_stok_sayisi"],
            "stok_degeri": stock_overview["stok_degeri"],
            "mevcut_bakiye": cashflow["mevcut_bakiye"],
            "bekleyen_odeme": sum(o["tutar"] for o in overdue),
            "odenecek_kdv": kdv["odenecek_kdv"],
        },
        "sabah_brifingi": morning_brief,
        "kritik_stoklar": critical[:5],
        "gecikmis_odemeler": overdue,
        "kdv_ozet": kdv,
        "nakit_akisi_ozet": {
            "mevcut_bakiye": cashflow["mevcut_bakiye"],
            "toplam_giris": cashflow["toplam_giris"],
            "toplam_cikis": cashflow["toplam_cikis"],
        },
    }


@router.get("/morning-brief")
async def get_morning_brief(db: AsyncSession = Depends(get_db)):
    """Sabah brifingi — önce cache'den okur, yoksa AI ile üretir."""
    # Cache'den dene
    cached = await _get_cached_brief(db)
    if cached:
        return {"brief": cached, "source": "cache"}

    # Cache yoksa canlı üret
    critical = await stock_service.get_critical_products(db)
    cashflow = await finance_service.get_cashflow(db, gun=30)
    kdv = await finance_service.get_kdv_summary(db)
    overdue = await finance_service.get_overdue_payments(db)

    brief_data = {
        "critical_stock": critical,
        "cash_status": {
            "bakiye": cashflow["mevcut_bakiye"],
            "projeksiyonlar": cashflow["projeksiyonlar"],
        },
        "overdue_payments": overdue,
        "kdv_deadline": kdv["beyanname_son_tarihi"],
    }

    brief = await gemini_service.generate_morning_brief(brief_data)
    return {"brief": brief, "source": "live"}


async def _get_cached_brief(db: AsyncSession) -> str | None:
    """Bugünün cache'lenmiş brifingi varsa döndürür."""
    today = date.today()
    result = await db.execute(
        select(BriefCache).where(BriefCache.tarih == today)
    )
    cache = result.scalar_one_or_none()
    return cache.brief_text if cache else None
