"""
KOBİ AI Asistan — Finans Ajanı (Gemini-Powered)
P&L, nakit akışı, ödeme takibi, KDV analizi.
Gemini ile akıllı finansal yorum ve risk analizi üretir.
"""

import json
import logging
import os

import google.generativeai as genai
from sqlalchemy.ext.asyncio import AsyncSession

from agents.tool_registry import tool_registry
from prompts.finance_agent_prompt import FINANCE_AGENT_PROMPT

logger = logging.getLogger(__name__)


class FinanceAgent:
    """Finans ajanı — veri toplar, Gemini ile analiz eder, risk değerlendirir."""

    def __init__(self):
        self.name = "finans_ajani"
        self.prompt = FINANCE_AGENT_PROMPT
        self.tools = ["get_pl_summary", "get_cash_forecast", "get_overdue_payments", "get_kdv_summary"]
        self._api_key = os.getenv("GEMINI_API_KEY", "")

    async def _ai_analyze(self, data: dict, task: str) -> str:
        """Gemini ile finansal analiz yapar."""
        if not self._api_key:
            return ""
        try:
            genai.configure(api_key=self._api_key)
            model = genai.GenerativeModel("gemini-2.5-flash")
            prompt = (
                f"{FINANCE_AGENT_PROMPT}\n\n"
                f"## Görev: {task}\n\n"
                f"## Veri:\n```json\n{json.dumps(data, ensure_ascii=False, default=str)}\n```\n\n"
                "Verileri derinlemesine analiz et. Yüzeysel özet YAPMA.\n"
                "Risk seviyesi belirt (düşük/orta/yüksek/kritik) ve gerekçelendir.\n"
                "Somut tutarlar ve tarihlerle aksiyon öner.\n"
                "Veriler arasında çapraz ilişki kur (ör: gecikmiş tahsilat → nakit etkisi).\n"
                "Maksimum 4-5 madde."
            )
            response = model.generate_content(
                prompt,
                generation_config=genai.GenerationConfig(temperature=0.4),
            )
            return response.text or ""
        except Exception as e:
            logger.error(f"FinanceAgent AI analiz hatasi: {e}", exc_info=True)
            return ""

    async def check_30day_cash_forecast(self, db: AsyncSession) -> dict:
        """30 günlük nakit projeksiyonu + AI yorum."""
        cashflow = await tool_registry.execute(db, "get_cash_forecast", {"days": 30})
        overdue = await tool_registry.execute(db, "get_overdue_payments", {})

        data = {"nakit_akisi": cashflow, "gecikmis_odemeler": overdue}
        ai_yorum = await self._ai_analyze(
            data,
            "30 günlük nakit akışı projeksiyonunu analiz et. "
            "Nakit sıkışması riski varsa tam tarih ve tutar belirt. "
            "Gecikmiş ödemeler tahsil edilirse nakit pozisyon nasıl değişir hesapla. "
            "Tahsilat öncelik sıralaması yap (tutar × gecikme gün ağırlıklı)."
        )

        return {**data, "ai_analiz": ai_yorum}

    async def get_overdue_payments(self, db: AsyncSession) -> list:
        """Gecikmiş ödemeler."""
        return await tool_registry.execute(db, "get_overdue_payments", {})

    async def get_monthly_pl(self, db: AsyncSession, month: int = None, year: int = None) -> dict:
        """Aylık P&L özeti."""
        return await tool_registry.execute(db, "get_pl_summary", {"month": month, "year": year})

    async def generate_financial_health_report(self, db: AsyncSession) -> dict:
        """Tam finansal sağlık raporu — P&L + nakit + KDV + AI yorum."""
        pl = await tool_registry.execute(db, "get_pl_summary", {})
        cashflow = await tool_registry.execute(db, "get_cash_forecast", {"days": 30})
        kdv = await tool_registry.execute(db, "get_kdv_summary", {})
        overdue = await tool_registry.execute(db, "get_overdue_payments", {})

        data = {
            "kar_zarar": pl,
            "nakit_akisi": cashflow,
            "kdv": kdv,
            "gecikmis_odemeler": overdue,
        }

        ai_rapor = await self._ai_analyze(
            data,
            "İşletmenin finansal sağlığını kapsamlı değerlendir. "
            "P&L marjları, nakit pozisyonu, KDV yükümlülüğü ve tahsilat "
            "durumunu BİRLİKTE analiz et — her birini ayrı değil, ilişkili değerlendir. "
            "Genel risk skoru ver (1-10) ve gerekçelendir. "
            "Somut iyileştirme adımları öner, öncelik sırasıyla."
        )

        return {**data, "ai_rapor": ai_rapor}

    async def assess_payment_risk(self, db: AsyncSession) -> dict:
        """Ödeme riski analizi — gecikmiş ödemeler + nakit durumu + AI."""
        overdue = await tool_registry.execute(db, "get_overdue_payments", {})
        cashflow = await tool_registry.execute(db, "get_cash_forecast", {"days": 30})

        toplam_geciken = sum(
            o.get("tutar", 0) for o in overdue
        ) if isinstance(overdue, list) else 0

        bakiye = cashflow.get("mevcut_bakiye", 0) if isinstance(cashflow, dict) else 0

        risk_data = {
            "gecikmis_odemeler": overdue,
            "toplam_geciken_tutar": toplam_geciken,
            "mevcut_bakiye": bakiye,
            "karsilama_orani": round(bakiye / toplam_geciken * 100, 1) if toplam_geciken > 0 else 100,
        }

        ai_yorum = await self._ai_analyze(
            risk_data,
            "Ödeme risk analizini yap. "
            "Hangi ödemelere öncelik verilmeli? Karşılama oranını yorumla. "
            "Nakit yetersizse: (1) hangi tahsilat hızlandırılmalı, "
            "(2) hangi gider ertelenebilir, (3) alternatif finansman seçenekleri. "
            "Her gecikmiş ödeme için risk skoru (1-5) ve önerilen aksiyon belirt."
        )

        return {**risk_data, "ai_analiz": ai_yorum}


finance_agent = FinanceAgent()
