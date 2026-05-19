"""
KOBİ AI Asistan — Chat Router
AI Asistan doğal dil sorgusu (ReAct döngüsü + konuşma geçmişi).
"""

import logging
from typing import Optional

from fastapi import APIRouter, Depends
from pydantic import BaseModel, Field
from sqlalchemy.ext.asyncio import AsyncSession

from database import get_db
from agents.orchestrator import orchestrator
from services.stock_service import stock_service
from services.finance_service import finance_service
from services.conversation_service import conversation_store

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/api/v1/chat", tags=["AI Asistan"])


class ChatRequest(BaseModel):
    message: str = Field(..., min_length=1, max_length=4000)
    conversation_id: Optional[str] = Field(None, max_length=100)
    ai_mode: Optional[str] = Field(None, pattern="^(balanced|careful|proactive)$")


@router.post("")
async def chat_with_ai(request: ChatRequest, db: AsyncSession = Depends(get_db)):
    """AI asistan ile doğal dil sorgusu (ReAct Orchestrator + konuşma geçmişi)."""
    # Konuşma geçmişini al veya oluştur
    conversation_id, history = conversation_store.get_or_create(request.conversation_id)

    # AI modunu belirle (varsayılan: balanced)
    ai_mode = request.ai_mode or "balanced"

    # Sorguyu olduğu gibi gönder — mod artık system instruction'da.
    # Prefix hack KALDIRILDI: "[MOD: DİKKATLİ]" gibi prefix'ler
    # Gemini'nin araç seçimini bozuyordu ve bağlam kirliliği yaratıyordu.
    result = await orchestrator.handle_query(
        db,
        request.message,
        history=history,
        ai_mode=ai_mode,
    )

    # Konuşma geçmişine ekle (tool call detayları hariç, sadece user+model)
    # Hata durumunda bile kullanıcı mesajını ve hata yanıtını kaydet —
    # böylece bir sonraki mesajda bağlam korunur.
    model_response = result.get("response", "")
    if model_response:
        # Kullanılan araçları da bağlam olarak ekle
        tools = result.get("tools_used", [])
        context_suffix = ""
        if tools:
            context_suffix = f"\n\n[Bu yanıt için kullanılan araçlar: {', '.join(tools)}]"
        conversation_store.append_turn(
            conversation_id,
            request.message,
            model_response + context_suffix,
        )

    result["conversation_id"] = conversation_id
    return result


@router.get("/suggestions")
async def get_ai_suggestions(db: AsyncSession = Depends(get_db)):
    """AI tarafından üretilen proaktif öneriler — gerçek veriye dayalı."""
    suggestions = []

    try:
        # Stok önerileri
        critical = await stock_service.get_critical_products(db)
        for product in critical[:3]:
            suggestions.append({
                "tip": "stok",
                "icon": "warning",
                "mesaj": f"{product['isim']} ürünü {product.get('kalan_gun', '?')} içinde bitebilir. "
                         f"En az {product['min_stok']} adet sipariş önerilir.",
            })

        # Ödeme önerileri
        overdue = await finance_service.get_overdue_payments(db)
        for payment in overdue[:2]:
            suggestions.append({
                "tip": "finans",
                "icon": "payment",
                "mesaj": f"{payment['karsi_taraf']}'ın {payment['tutar']:,.0f} TL tutarındaki ödemesi "
                         f"{payment['gecikme_gun']} gündür gecikmiş. Hatırlatma yapılması önerilir.",
            })

        # Maliyet analiz önerisi (gerçek veriye dayalı)
        from services.stock_service import stock_service as ss
        abc = await ss.get_abc_analysis(db)
        a_count = abc.get("a_grubu", {}).get("sayi", 0)
        c_count = abc.get("c_grubu", {}).get("sayi", 0)
        if c_count > a_count:
            suggestions.append({
                "tip": "analiz",
                "icon": "analytics",
                "mesaj": f"C grubu ürün sayısı ({c_count}) A grubundan ({a_count}) fazla. "
                         f"Düşük cirolu ürünlerin tasfiyesi veya fiyat optimizasyonu önerilir.",
            })

        # Nakit akışı önerisi
        cashflow = await finance_service.get_cashflow(db, gun=30)
        for proj in cashflow.get("projeksiyonlar", []):
            if proj.get("risk"):
                suggestions.append({
                    "tip": "finans",
                    "icon": "trending_down",
                    "mesaj": f"{proj['gun']} gün sonra nakit açığı riski var. "
                             f"Tahmini bakiye: {proj['tahmini_bakiye']:,.0f} TL. Önlem alınmalı.",
                })
                break

    except Exception as e:
        logger.error(f"Öneri üretme hatası: {e}", exc_info=True)

    return {"suggestions": suggestions}


@router.delete("/conversation/{conversation_id}")
async def reset_conversation(conversation_id: str):
    """Konuşma geçmişini sıfırla."""
    conversation_store.reset(conversation_id)
    return {"success": True, "message": "Konuşma geçmişi sıfırlandı."}
