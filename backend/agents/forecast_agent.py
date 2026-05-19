"""
KOBİ AI Asistan — Tahmin Ajanı (Gemini-Powered)
30/60/90 günlük nakit + stok tahmini, mevsimsel analiz.
Gemini ile trend analizi ve tahmin açıklaması üretir.
"""

import json
import logging
import os

import google.generativeai as genai
from sqlalchemy.ext.asyncio import AsyncSession

from agents.tool_registry import tool_registry

logger = logging.getLogger(__name__)


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
                "Güven seviyesini belirt (düşük/orta/yüksek). "
                "Türkçe yaz. Verileri çapraz değerlendir.\n"
                "En iyi/en kötü/beklenen senaryo belirt.\n"
                "Her tahmin için somut önleyici tedbir öner."
            )
            response = model.generate_content(
                prompt,
                generation_config=genai.GenerationConfig(temperature=0.5),
            )
            return response.text or ""
        except Exception as e:
            logger.error(f"ForecastAgent AI tahmin hatasi: {e}", exc_info=True)
            return ""

    async def get_cash_forecast(self, db: AsyncSession, days: int = 90) -> dict:
        """Nakit akışı projeksiyonu + AI tahmin yorumu."""
        cashflow = await tool_registry.execute(db, "get_cash_forecast", {"days": days})
        overdue = await tool_registry.execute(db, "get_overdue_payments", {})

        ai_tahmin = await self._ai_forecast(
            {"nakit_akisi": cashflow, "gecikmis_odemeler": overdue},
            f"{days} günlük nakit akışı tahmini. Hangi günlerde nakit sıkışması "
            "olabilir? Gecikmiş tahsilatlar tahsil edilirse nakit nasıl değişir? "
            "En iyi/en kötü senaryo ile birlikte somut önleyici tedbirler öner."
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
            "Her kritik ürün için tahmini tükenme tarihi ve önerilen sipariş "
            "zamanlaması belirt. Toplam tedarik maliyetini hesapla."
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
            "Nakit, stok ve gelir-gider verilerini BİRLİKTE değerlendir. "
            "Önümüzdeki 30 gün için bütünleşik risk haritası çıkar.\n"
            "Şu çapraz analizleri yap:\n"
            "1. Kritik stok tedarik maliyeti vs mevcut nakit → yeterli mi?\n"
            "2. Kâr marjı trendi → düşüş varsa neden?\n"
            "3. Nakit projeksiyonunda en riskli gün → hangi gider/ödeme çakışıyor?\n"
            "Hangi aksiyonlar hangi sırayla alınmalı? Öncelik matrisi oluştur."
        )

        return {**combined, "ai_karar_destek": ai_rapor}


forecast_agent = ForecastAgent()
