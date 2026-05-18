"""
KOBİ AI Asistan — Chat Router
AI Asistan doğal dil sorgusu (ReAct döngüsü).
"""

import json
from typing import Optional

from fastapi import APIRouter, Depends
from pydantic import BaseModel
from sqlalchemy.ext.asyncio import AsyncSession

import sys, os
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from database import get_db
from agents.orchestrator import orchestrator
from services.stock_service import stock_service
from services.finance_service import finance_service

router = APIRouter(prefix="/api/v1/chat", tags=["AI Asistan"])


class ChatRequest(BaseModel):
    message: str
    conversation_id: Optional[str] = None
    ai_mode: Optional[str] = None  # "balanced", "careful", "proactive"


@router.post("")
async def chat_with_ai(request: ChatRequest, db: AsyncSession = Depends(get_db)):
    query = request.message
    if request.ai_mode == "careful":
        query = f"[MOD: DİKKATLİ — ...] {query}"
    elif request.ai_mode == "proactive":
        query = f"[MOD: PROAKTİF — ...] {query}"

    result = await orchestrator.handle_query(
        db,
        query,
        conversation_id=request.conversation_id,  # ← ARTIK KULLANILIYOR
    )
    return result  # response'da conversation_id artık dönüyor


@router.delete("/{conversation_id}")
async def reset_conversation(conversation_id: str):
    """Belirli bir conversation'ı sıfırlar."""
    from services.conversation_service import conversation_store
    conversation_store.reset(conversation_id)
    return {"ok": True}


@router.get("/suggestions")
async def get_ai_suggestions(db: AsyncSession = Depends(get_db)):
    """AI tarafından üretilen proaktif öneriler."""
    critical = await stock_service.get_critical_products(db)
    overdue = await finance_service.get_overdue_payments(db)

    suggestions = []

    # Stok önerileri
    for product in critical[:3]:
        suggestions.append({
            "tip": "stok",
            "icon": "warning",
            "mesaj": f"{product['isim']} ürünü {product.get('kalan_gun', '?')} içinde bitebilir. "
                     f"En az {product['min_stok']} adet sipariş önerilir.",
        })

    # Ödeme önerileri
    for payment in overdue[:2]:
        suggestions.append({
            "tip": "finans",
            "icon": "payment",
            "mesaj": f"{payment['karsi_taraf']}'ın {payment['tutar']:,.0f} TL tutarındaki ödemesi "
                     f"{payment['gecikme_gun']} gündür gecikmiş. Hatırlatma yapılması önerilir.",
        })

    # Genel öneri
    suggestions.append({
        "tip": "analiz",
        "icon": "analytics",
        "mesaj": "Kahve kategorisinde son 6 ayda %31 maliyet artışı tespit edildi. "
                 "Alternatif tedarikçi değerlendirmesi önerilir.",
    })

    return {"suggestions": suggestions}
