"""
KOBİ AI Asistan — Tahmin Ajanı (Gemini-Powered)
30/60/90 günlük nakit + stok tahmini, mevsimsel analiz.
Gemini ile trend analizi ve tahmin açıklaması üretir.
"""

import json
import os

import google.generativeai as genai
from sqlalchemy.ext.asyncio import AsyncSession

from agents.tool_registry import tool_registry


class ForecastAgent:
    """Tahmin ajanı — veri toplar, Gemini ile gelecek projeksiyonu yapar."""

    def __init__(self):
        self.name = "tahmin_ajani"
        self._api_key = os.getenv("GEMINI_API_KEY", "")

    async def _ai_forecast(self, data: dict, task: str) -> str:
        """Gemini ile tahmin analizi yapar."""
        if not self._api_key:
            return ""
        try:
            genai.configure(api_key=self._api_key)
            model = genai.GenerativeModel("gemini-2.5-flash")
            prompt = (
                "Sen bir KOBİ finansal tahmin uzmanısın. "
                "Verilen geçmiş verilere bakarak gelecek projeksiyonu yap.\n\n"
                f"## Görev: {task}\n\n"
                f"## Veri:\n```json\n{json.dumps(data, ensure_ascii=False, default=str)}\n```\n\n"
                "Somut tarih ve tutar belirterek tahmin yap. "
                "Güven seviyesini belirt (düşük/orta/yüksek). Türkçe yaz."
            )
            response = model.generate_content(prompt)
            return response.text or ""
        except Exception as e:
            print(f"[WARN] ForecastAgent AI error: {e}")
            return ""

    async def get_cash_forecast(self, db: AsyncSession, days: int = 90) -> dict:
        """Nakit akışı projeksiyonu + AI tahmin yorumu."""
        cashflow = await tool_registry.execute(db, "get_cash_forecast", {"days": days})
        overdue = await tool_registry.execute(db, "get_overdue_payments", {})

        ai_tahmin = await self._ai_forecast(
            {"nakit_akisi": cashflow, "gecikmis_odemeler": overdue},
            f"{days} günlük nakit akışı tahmini. Hangi günlerde nakit sıkışması "
            "olabilir? Önleyici tedbirler öner."
        )

        return {
            "nakit_projeksiyon": cashflow,
            "gecikmis_odemeler": overdue,
            "ai_tahmin": ai_tahmin,
            "tahmin_tipi": "gemini_destekli",
        }

    async def get_stock_forecast(self, db: AsyncSession) -> dict:
        """Tüm ürünlerin stok eritme tahmini + AI yorum."""
        critical = await tool_registry.execute(db, "get_critical_stock", {})
        overview = await tool_registry.execute(db, "get_stock_status", {})

        ai_tahmin = await self._ai_forecast(
            {"genel_durum": overview, "kritik_urunler": critical},
            "Stok eritme hızlarına bakarak hangi ürünler ne zaman tükenecek? "
            "Sipariş planlaması için timeline öner."
        )

        return {
            "kritik_urunler": critical,
            "genel_durum": overview,
            "ai_tahmin": ai_tahmin,
            "tahmin_tipi": "gemini_destekli",
        }

    async def generate_combined_forecast(self, db: AsyncSession) -> dict:
        """Birleşik nakit + stok tahmini — karar destek raporu."""
        cash = await tool_registry.execute(db, "get_cash_forecast", {"days": 30})
        critical = await tool_registry.execute(db, "get_critical_stock", {})
        pl = await tool_registry.execute(db, "get_pl_summary", {})

        combined = {
            "nakit_30gun": cash,
            "kritik_stoklar": critical,
            "kar_zarar": pl,
        }

        ai_rapor = await self._ai_forecast(
            combined,
            "Nakit, stok ve gelir-gider verilerini birlikte değerlendir. "
            "Önümüzdeki 30 gün için bütünleşik risk haritası çıkar. "
            "Hangi aksiyonlar hangi sırayla alınmalı?"
        )

        return {**combined, "ai_karar_destek": ai_rapor}


forecast_agent = ForecastAgent()
