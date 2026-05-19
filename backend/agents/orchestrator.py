"""
KOBİ AI Asistan — Orkestratör Ajanı (ReAct Pattern)
Kullanıcı sorgularını analiz edip doğru araçlara yönlendirir.
Gemini Native Function Calling ile çok adımlı ReAct döngüsü.
Mod-bazlı system instruction + konuşma bağlamı desteği.
"""

import asyncio
import json
import logging
import os
from typing import Any

import google.generativeai as genai
from sqlalchemy.ext.asyncio import AsyncSession

from agents.tool_registry import tool_registry, TOOL_DEFINITIONS
from prompts.orchestrator_prompt import MODE_PROMPTS, ORCHESTRATOR_SYSTEM_PROMPT

logger = logging.getLogger(__name__)

# ─── Mod-Bazlı Yapılandırma ─────────────────────────────────────────────
_MODE_CONFIG = {
    "balanced": {
        "temperature": 0.7,
        "max_iterations": 5,
    },
    "careful": {
        "temperature": 0.3,
        "max_iterations": 3,     # Daha az araç çağrısı, daha güvenli
    },
    "proactive": {
        "temperature": 0.8,
        "max_iterations": 5,     # Daha fazla araç, çapraz analiz
    },
}


class OrchestratorAgent:
    """Ana orkestratör — ReAct döngüsü ile çok araçlı ajan koordinasyonu."""

    DEFAULT_MAX_ITERATIONS = 5

    def __init__(self):
        self.api_key = os.getenv("GEMINI_API_KEY", "")
        self._models: dict[str, Any] = {}   # mode -> model cache
        self._init_lock = asyncio.Lock()
        self._fc_tools = None  # Shared tool definitions

    def _build_fc_tools(self):
        """Function Calling tool tanımlarını oluştur (tek sefer)."""
        if self._fc_tools is not None:
            return self._fc_tools
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
        self._fc_tools = fc_tools
        return fc_tools

    async def _get_model(self, mode: str = "balanced"):
        """Thread-safe lazy init — mod bazlı Gemini modeli oluşturur."""
        if mode in self._models:
            return self._models[mode]
        async with self._init_lock:
            if mode in self._models:
                return self._models[mode]
            if not self.api_key:
                return None
            genai.configure(api_key=self.api_key)
            fc_tools = self._build_fc_tools()
            system_prompt = MODE_PROMPTS.get(mode, ORCHESTRATOR_SYSTEM_PROMPT)
            model = genai.GenerativeModel(
                model_name="gemini-2.5-flash",
                tools=fc_tools,
                system_instruction=system_prompt,
            )
            self._models[mode] = model
            return model

    async def handle_query(self, db: AsyncSession, query: str,
                           history: list = None,
                           ai_mode: str = "balanced") -> dict:
        """Kullanıcı sorusunu ReAct pattern ile işler (çok adımlı döngü).

        Args:
            db: Veritabanı oturumu
            query: Kullanıcının sorusu (temiz — mod prefix'i eklenmez)
            history: Önceki konuşma geçmişi (genai.protos.Content listesi)
            ai_mode: AI çalışma modu (balanced/careful/proactive)
        """
        mode = ai_mode if ai_mode in _MODE_CONFIG else "balanced"
        config = _MODE_CONFIG[mode]
        max_iterations = config["max_iterations"]
        temperature = config["temperature"]

        model = await self._get_model(mode)
        if not self.api_key or not model:
            return {
                "response": "AI servisi yapılandırılmamış. Lütfen GEMINI_API_KEY tanımlayın.",
                "tools_used": [],
                "thinking_steps": [],
                "error": "missing_api_key",
            }

        thinking_steps = []
        tools_used = []

        try:
            chat = model.start_chat(history=history or [])
            response = chat.send_message(
                query,
                generation_config=genai.GenerationConfig(
                    temperature=temperature,
                ),
            )

            # ─── ReAct Döngüsü ─────────────────────────────────────────
            iteration = 0
            while iteration < max_iterations:
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

            thinking_steps.append({
                "step": "Sentez",
                "detail": f"Toplam {len(tools_used)} araç kullanılarak yanıt üretildi."
            })

            return {
                "response": final_text,
                "tools_used": tools_used,
                "thinking_steps": thinking_steps,
                "iterations": iteration,
                "ai_mode": mode,
            }

        except Exception as e:
            logger.error(f"Orchestrator ReAct hatasi: {e}", exc_info=True)
            # ─── Tek katmanlı temiz fallback ─────────────────────────
            # ReAct başarısız olursa açık hata mesajı ver.
            # "context_fallback" adında sahte araç gösterme.
            error_detail = str(e)[:200]

            # Hata türüne göre kullanıcıya yardımcı mesaj
            if "quota" in error_detail.lower() or "429" in error_detail:
                user_msg = (
                    "AI servisi şu anda yoğun. Lütfen birkaç saniye bekleyip tekrar deneyin. "
                    "Sorunuz kaydedildi, bir sonraki mesajınızda bağlam korunacaktır."
                )
            elif "api_key" in error_detail.lower() or "401" in error_detail:
                user_msg = "AI servisi yapılandırma hatası. Lütfen sistem yöneticisine bildirin."
            else:
                user_msg = (
                    "Analiz sırasında bir hata oluştu. Lütfen sorunuzu biraz farklı "
                    "şekilde sormayı deneyin veya daha spesifik bir soru sorun.\n\n"
                    f"Teknik detay: {error_detail}"
                )

            return {
                "response": user_msg,
                "tools_used": [],
                "thinking_steps": [
                    {"step": "Hata", "detail": error_detail}
                ],
                "error": "react_error",
                "ai_mode": mode,
            }

    async def synthesize_morning_brief(self, data: dict) -> str:
        """Sabah brifingi sentezler."""
        from services.gemini_service import gemini_service
        return await gemini_service.generate_morning_brief(data)

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
