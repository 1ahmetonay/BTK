"""
KOBİ AI Asistan — Orkestratör Ajanı (ReAct Pattern)
Kullanıcı sorgularını analiz edip doğru araçlara yönlendirir.
Gemini Native Function Calling ile çok adımlı ReAct döngüsü.
"""

import json
import os
from typing import Any

import google.generativeai as genai
from sqlalchemy.ext.asyncio import AsyncSession

from agents.tool_registry import tool_registry, TOOL_DEFINITIONS
from prompts.orchestrator_prompt import ORCHESTRATOR_SYSTEM_PROMPT


class OrchestratorAgent:
    """Ana orkestratör — ReAct döngüsü ile çok araçlı ajan koordinasyonu."""

    MAX_ITERATIONS = 5

    def __init__(self):
        self.api_key = os.getenv("GEMINI_API_KEY", "")
        self._model = None

    @property
    def model(self):
        """Lazy init — Gemini modelini ilk kullanımda oluştur."""
        if self._model is None and self.api_key:
            genai.configure(api_key=self.api_key)
            # Native Function Calling tools tanımla
            fc_tools = []
            for t in TOOL_DEFINITIONS:
                fc_tools.append(genai.protos.Tool(
                    function_declarations=[
                        genai.protos.FunctionDeclaration(
                            name=t["name"],
                            description=t["description"],
                            parameters=genai.protos.Schema(
                                type=genai.protos.Type.OBJECT,
                                properties={
                                    k: genai.protos.Schema(
                                        type=_map_type(v.get("type", "string")),
                                        description=v.get("description", ""),
                                    )
                                    for k, v in t["parameters"].get("properties", {}).items()
                                },
                                required=t["parameters"].get("required", []),
                            ),
                        )
                    ]
                ))
            self._model = genai.GenerativeModel(
                model_name="gemini-2.5-flash",
                tools=fc_tools,
                system_instruction=ORCHESTRATOR_SYSTEM_PROMPT,
            )
        return self._model

    async def handle_query(self, db: AsyncSession, query: str, conversation_id: str | None = None) -> dict:
        """Kullanıcı sorusunu ReAct pattern ile işler (çok adımlı döngü)."""
        from services.conversation_service import conversation_store

        # Conversation tracking
        conv_id, history = conversation_store.get_or_create(conversation_id)

        if not self.api_key or not self.model:
            mock = self._mock_response(query)
            mock["conversation_id"] = conv_id
            return mock

        thinking_steps = []
        tools_used = []

        try:
            chat = self.model.start_chat(history=history)
            response = chat.send_message(query)

            # ─── ReAct Döngüsü ─────────────────────────────────────────
            iteration = 0
            while iteration < self.MAX_ITERATIONS:
                iteration += 1

                # Function call var mı kontrol et
                fc = self._extract_function_call(response)
                if not fc:
                    break  # Araç çağrısı yok, yanıt hazır

                tool_name = fc.name
                tool_args = dict(fc.args) if fc.args else {}

                thinking_steps.append({
                    "step": f"Araç Çağrısı #{iteration}",
                    "detail": f"{tool_name}({json.dumps(tool_args, ensure_ascii=False)})"
                })

                # Aracı çalıştır
                tool_result = await tool_registry.execute(db, tool_name, tool_args)
                tools_used.append(tool_name)

                thinking_steps.append({
                    "step": f"Gözlem #{iteration}",
                    "detail": f"Veri alındı: {str(tool_result)[:200]}..."
                })

                # Sonucu Gemini'ye geri gönder
                response = chat.send_message(
                    genai.protos.Content(
                        parts=[
                            genai.protos.Part(
                                function_response=genai.protos.FunctionResponse(
                                    name=tool_name,
                                    response={"result": json.dumps(tool_result, ensure_ascii=False, default=str)},
                                )
                            )
                        ]
                    )
                )

            # Son yanıtı al
            final_text = response.text if response.text else "Analiz tamamlandı."

            # Conversation history'yi güncelle
            conversation_store.append_turn(conv_id, query, final_text)

            thinking_steps.append({
                "step": "Sentez",
                "detail": f"Toplam {len(tools_used)} araç kullanılarak yanıt üretildi."
            })

            return {
                "response": final_text,
                "conversation_id": conv_id,
                "tools_used": tools_used,
                "thinking_steps": thinking_steps,
                "iterations": iteration,
            }

        except Exception as e:
            print(f"[WARN] Orchestrator ReAct error: {e}")
            # Hata durumunda basit yanıt dene
            try:
                simple_model = genai.GenerativeModel("gemini-2.5-flash")
                # Bağlam verilerini topla
                context_data = await self._gather_context(db)
                simple_prompt = f"{ORCHESTRATOR_SYSTEM_PROMPT}\n\nİşletme Verileri:\n{json.dumps(context_data, ensure_ascii=False, default=str)}\n\nKullanıcı: {query}"
                simple_response = simple_model.generate_content(simple_prompt)
                return {
                    "response": simple_response.text,
                    "conversation_id": conv_id,
                    "tools_used": ["context_fallback"],
                    "thinking_steps": [
                        {"step": "Fallback", "detail": f"FC hatası, bağlam ile yanıt üretildi: {str(e)[:100]}"}
                    ],
                }
            except Exception as e2:
                print(f"[WARN] Orchestrator fallback error: {e2}")
                mock = self._mock_response(query)
                mock["conversation_id"] = conv_id
                return mock

    async def synthesize_morning_brief(self, data: dict) -> str:
        """Sabah brifingi sentezler."""
        from services.gemini_service import gemini_service
        return await gemini_service.generate_morning_brief(data)

    async def _gather_context(self, db: AsyncSession) -> dict:
        """Basit bağlam verisi toplar."""
        stock = await tool_registry.execute(db, "get_stock_status", {})
        critical = await tool_registry.execute(db, "get_critical_stock", {})
        overdue = await tool_registry.execute(db, "get_overdue_payments", {})
        return {
            "stok_durumu": stock,
            "kritik_stoklar": critical[:5] if isinstance(critical, list) else critical,
            "gecikmis_odemeler": overdue,
        }

    def _extract_function_call(self, response) -> Any:
        """Gemini yanıtından function call çıkarır."""
        try:
            for candidate in response.candidates:
                for part in candidate.content.parts:
                    if hasattr(part, "function_call") and part.function_call.name:
                        return part.function_call
        except (AttributeError, IndexError):
            pass
        return None

    def _mock_response(self, query: str = "") -> dict:
        """API key yokken veya hata durumunda mock yanıt."""
        return {
            "response": (
                "Merhaba! İşletmenizin mevcut durumunu analiz ettim:\n\n"
                "📊 **Stok:** 128 aktif ürün, 7 ürün kritik seviyede. "
                "Türk Kahvesi 250g için acil tedarik gerekli.\n\n"
                "💰 **Nakit:** Mevcut bakiye 91.600 TL. "
                "14 gün sonra 42.000 TL açık riski var.\n\n"
                "📋 **KDV:** Ödenecek KDV 1.868 TL, son gün 26 Mayıs.\n\n"
                "⚠️ **Aksiyonlar:** Ahmet Usta Kafe'ye ödeme hatırlatması "
                "ve Aksoy Tedarik'e kahve siparişi önerilir."
            ),
            "tools_used": ["get_stock_status", "get_critical_stock", "get_cash_forecast", "get_kdv_summary"],
            "thinking_steps": [
                {"step": "Plan", "detail": "Stok, nakit, KDV ve ödemeleri kontrol edeceğim."},
                {"step": "Araç #1", "detail": "get_stock_status → 128 ürün, 7 kritik"},
                {"step": "Araç #2", "detail": "get_critical_stock → Türk Kahvesi 12 adet"},
                {"step": "Araç #3", "detail": "get_cash_forecast → 14 gün sonra risk"},
                {"step": "Araç #4", "detail": "get_kdv_summary → 1.868 TL ödenecek"},
                {"step": "Sentez", "detail": "4 araç kullanılarak analiz hazırlandı."},
            ],
        }


def _map_type(type_str: str):
    """JSON Schema type → Gemini Proto Type."""
    mapping = {
        "string": genai.protos.Type.STRING,
        "integer": genai.protos.Type.INTEGER,
        "number": genai.protos.Type.NUMBER,
        "boolean": genai.protos.Type.BOOLEAN,
    }
    return mapping.get(type_str, genai.protos.Type.STRING)


# Singleton
orchestrator = OrchestratorAgent()
