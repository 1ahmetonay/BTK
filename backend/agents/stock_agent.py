"""
KOBİ AI Asistan — Stok Ajanı (Gemini-Powered)
Stok güncelleme, kritik tespit, ABC analizi, anomali kontrolü.
Gemini ile akıllı analiz ve öneri üretir.
"""

import json
import logging
import os

import google.generativeai as genai
from sqlalchemy.ext.asyncio import AsyncSession

from agents.tool_registry import tool_registry
from prompts.stock_agent_prompt import STOCK_AGENT_PROMPT

logger = logging.getLogger(__name__)


class StockAgent:
    """Stok yönetimi ajanı — veri toplar, Gemini ile analiz eder, öneri üretir."""

    def __init__(self):
        self.name = "stok_ajani"
        self.prompt = STOCK_AGENT_PROMPT
        self.tools = [
            "get_stock_status", "get_critical_stock", "get_product_movements",
            "get_abc_analysis", "get_seasonality_pattern", "compare_suppliers",
            "simulate_price_change",
        ]
        self._api_key = os.getenv("GEMINI_API_KEY", "")

    async def _ai_analyze(self, data: dict, task: str) -> str:
        """Gemini ile veri analizi yapar ve Türkçe öneri üretir."""
        if not self._api_key:
            return ""
        try:
            genai.configure(api_key=self._api_key)
            model = genai.GenerativeModel("gemini-2.5-flash")
            prompt = (
                f"{STOCK_AGENT_PROMPT}\n\n"
                f"## Görev: {task}\n\n"
                f"## Veri:\n```json\n{json.dumps(data, ensure_ascii=False, default=str)}\n```\n\n"
                "Verileri derinlemesine analiz et. Yüzeysel özet YAPMA.\n"
                "Her bulgu için somut aksiyon öner (ne yapılmalı, ne kadar, ne zaman).\n"
                "Veriler arasında korelasyon ve çapraz ilişki ara.\n"
                "Maksimum 4-5 madde. Her maddede sayısal veri ve somut öneri olmalı."
            )
            response = model.generate_content(
                prompt,
                generation_config=genai.GenerationConfig(temperature=0.4),
            )
            return response.text or ""
        except Exception as e:
            logger.error(f"StockAgent AI analiz hatasi: {e}", exc_info=True)
            return ""

    async def check_critical_items(self, db: AsyncSession) -> list[dict]:
        """Kritik stok ürünlerini tarar."""
        return await tool_registry.execute(db, "get_critical_stock", {})

    async def analyze_product(self, db: AsyncSession, sku: str) -> dict:
        """Tek ürün analizi — hareket + fiyat + mevsimsellik + AI yorum."""
        movements = await tool_registry.execute(db, "get_product_movements", {"sku": sku})
        suppliers = await tool_registry.execute(db, "compare_suppliers", {"sku": sku})
        seasonality = await tool_registry.execute(db, "get_seasonality_pattern", {"sku": sku})

        raw_data = {
            "hareketler": movements,
            "tedarikciler": suppliers,
            "mevsimsellik": seasonality,
        }

        ai_yorum = await self._ai_analyze(
            raw_data,
            f"SKU: {sku} ürününün stok hareketleri, tedarikçi karşılaştırması "
            "ve mevsimsel patternini analiz et. Sipariş zamanlaması öner. "
            "En uygun tedarikçiyi neden seçtiğini gerekçelendir."
        )

        return {**raw_data, "ai_analiz": ai_yorum}

    async def generate_stock_report(self, db: AsyncSession) -> dict:
        """Tüm stok durumunu analiz edip AI yorumlu rapor üretir."""
        overview = await tool_registry.execute(db, "get_stock_status", {})
        critical = await tool_registry.execute(db, "get_critical_stock", {})
        abc = await tool_registry.execute(db, "get_abc_analysis", {})

        data = {
            "genel_durum": overview,
            "kritik_urunler": critical[:5] if isinstance(critical, list) else critical,
            "abc_analizi": abc,
        }

        ai_rapor = await self._ai_analyze(
            data,
            "Genel stok sağlığını değerlendir. ABC analizine göre envanter "
            "stratejisi öner. Kritik ürünler için aciliyet sıralı aksiyon planı hazırla. "
            "C grubu ürünlerin bağladığı sermayeyi hesapla ve tasfiye önerisi ver."
        )

        return {**data, "ai_rapor": ai_rapor}

    async def detect_anomalies(self, db: AsyncSession) -> dict:
        """Stok anomalilerini tespit eder ve AI ile açıklar."""
        overview = await tool_registry.execute(db, "get_stock_status", {})
        critical = await tool_registry.execute(db, "get_critical_stock", {})

        anomaliler = []
        if isinstance(critical, list):
            for item in critical:
                if isinstance(item, dict):
                    kalan = item.get("kalan_gun", 999)
                    if isinstance(kalan, (int, float)) and kalan < 5:
                        anomaliler.append({
                            "tip": "acil_stok_tukenmesi",
                            "urun": item.get("isim", "?"),
                            "sku": item.get("sku", "?"),
                            "kalan_gun": kalan,
                            "mevcut_stok": item.get("mevcut_stok", 0),
                            "min_stok": item.get("min_stok", 0),
                        })

        ai_yorum = ""
        if anomaliler:
            ai_yorum = await self._ai_analyze(
                {"anomaliler": anomaliler, "genel": overview},
                "Tespit edilen stok anomalilerini açıkla ve her biri için "
                "acil müdahale planı öner. Her anomali için: olası neden, "
                "risk seviyesi (kritik/yüksek/orta), önerilen aksiyon ve tahmini maliyet."
            )
        else:
            ai_yorum = "Stok anomalisi tespit edilmedi. Tüm ürünler normal parametrelerde."

        return {
            "anomali_sayisi": len(anomaliler),
            "anomaliler": anomaliler,
            "ai_aciklama": ai_yorum,
        }


stock_agent = StockAgent()
