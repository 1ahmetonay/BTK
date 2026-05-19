"""
KOBİ AI Asistan — Gemini AI Servisi
Google Gemini 2.5 Flash ile belge okuma, chat, ve function calling.
"""

import base64
import json
import logging
import os
from typing import Any

import google.generativeai as genai
from dotenv import load_dotenv

load_dotenv()

logger = logging.getLogger(__name__)

# ─── API Yapılandırması ──────────────────────────────────────────────
GEMINI_API_KEY = os.getenv("GEMINI_API_KEY", "")

if GEMINI_API_KEY:
    genai.configure(api_key=GEMINI_API_KEY)

MODEL_NAME = "gemini-2.5-flash"


# ─── Belge Okuma Prompt'ları ──────────────────────────────────────────
FATURA_PROMPT = """Bu fatura/fiş belgesini analiz et. Sadece JSON döndür, başka metin ekleme.
Eğer bilgi okunamıyorsa ilgili alanı null yap.
{
  "belge_tipi": "satin_alma_faturasi veya satis_fisi veya irsaliye",
  "satici_adi": "",
  "satici_vkn": "",
  "fatura_no": "",
  "tarih": "YYYY-MM-DD",
  "kalemler": [
    {
      "urun_adi": "",
      "miktar": 0,
      "birim": "adet",
      "birim_fiyat": 0.0,
      "kdv_orani": 20,
      "kdv_tutari": 0.0,
      "satir_toplam": 0.0
    }
  ],
  "toplam_kdv": 0.0,
  "genel_toplam": 0.0,
  "para_birimi": "TRY",
  "guven_skoru": 0.95
}"""

PUANTAJ_PROMPT = """Bu puantaj tablosunu analiz et ve şu JSON formatında döndür.
Sadece JSON döndür, başka metin ekleme.
{
  "donem": {"ay": 0, "yil": 0},
  "calisanlar": [
    {
      "isim": "",
      "toplam_calisma_gunu": 0,
      "mesai_saatleri": 0,
      "izin_gunu": 0,
      "rapor_gunu": 0,
      "gunler": {"1": "X", "2": "X", "3": "-"}
    }
  ]
}
Not: X = çalıştı, - = izin/tatil, R = rapor"""


class GeminiService:
    """Google Gemini API ile etkileşim sağlar."""

    def __init__(self):
        self._model = None

    @property
    def model(self):
        if self._model is None:
            self._model = genai.GenerativeModel(MODEL_NAME)
        return self._model

    @property
    def is_configured(self) -> bool:
        return bool(GEMINI_API_KEY)

    async def read_document(self, image_data: bytes, mime_type: str = "image/jpeg") -> dict:
        """Fatura/fiş görselinden yapılandırılmış veri çıkarır."""
        if not self.is_configured:
            return {"error": "AI servisi yapılandırılmamış. GEMINI_API_KEY tanımlayın."}

        if not image_data:
            return {"error": "Belge verisi boş. Lütfen geçerli bir dosya yükleyin."}

        b64 = base64.b64encode(image_data).decode("utf-8")
        image_part = {"inline_data": {"mime_type": mime_type, "data": b64}}

        try:
            response = self.model.generate_content(
                [image_part, FATURA_PROMPT],
                generation_config=genai.GenerationConfig(
                    temperature=0.1,
                    response_mime_type="application/json",
                ),
            )
            return self._parse_json(response.text)
        except Exception as e:
            logger.error(f"Gemini belge okuma hatasi: {e}", exc_info=True)
            return {"error": f"Belge okunamadı: {str(e)}"}

    async def read_timesheet(self, image_data: bytes, mime_type: str = "image/jpeg") -> dict:
        """Kağıt puantaj fotoğrafından dijital veri çıkarır."""
        if not self.is_configured:
            return {"error": "AI servisi yapılandırılmamış. GEMINI_API_KEY tanımlayın."}

        if not image_data:
            return {"error": "Puantaj verisi boş. Lütfen geçerli bir dosya yükleyin."}

        b64 = base64.b64encode(image_data).decode("utf-8")
        image_part = {"inline_data": {"mime_type": mime_type, "data": b64}}

        try:
            response = self.model.generate_content(
                [image_part, PUANTAJ_PROMPT],
                generation_config=genai.GenerationConfig(
                    temperature=0.1,
                    response_mime_type="application/json",
                ),
            )
            return self._parse_json(response.text)
        except Exception as e:
            logger.error(f"Gemini puantaj okuma hatasi: {e}", exc_info=True)
            return {"error": f"Puantaj okunamadı: {str(e)}"}

    async def chat(self, message: str, context: str = "") -> dict:
        """Doğal dil sorgusu — bağlamla yanıt üretir."""
        if not self.is_configured:
            return {
                "response": "AI servisi yapılandırılmamış. Lütfen GEMINI_API_KEY tanımlayın.",
                "tools_used": [],
                "thinking_steps": [],
                "error": "missing_api_key",
            }

        system_prompt = f"""Sen bir KOBİ finansal asistanısın. Adın "KOBİ AI Asistan".
Türkçe yanıt ver. Kullanıcıya yardımcı ol.

Mevcut İşletme Verileri:
{context}

Kurallar:
1. Her zaman Türkçe yanıt ver
2. Sayısal verileri net göster
3. Önerilerde somut aksiyon belirt
4. Analiz yaparken hikaye biçiminde anlat (Narrative Analysis)
5. Gerekirse uyarı ver"""

        try:
            response = self.model.generate_content(
                f"{system_prompt}\n\nKullanıcı: {message}",
                generation_config=genai.GenerationConfig(temperature=0.7),
            )
            return {
                "response": response.text,
                "tools_used": [],
                "thinking_steps": [
                    {"step": "Veri analizi", "detail": "İşletme verileri değerlendirildi"},
                    {"step": "Yanıt üretimi", "detail": "Türkçe analiz raporu hazırlandı"},
                ],
            }
        except Exception as e:
            logger.error(f"Gemini chat hatasi: {e}", exc_info=True)
            return {
                "response": "Üzgünüm, şu anda yanıt üretemiyorum. Lütfen tekrar deneyin.",
                "tools_used": [],
                "thinking_steps": [],
                "error": "ai_service_error",
            }

    async def generate_morning_brief(self, data: dict) -> str:
        """Sabah brifingi üretir."""
        if not self.is_configured:
            return "AI servisi yapılandırılmamış. Sabah brifingi üretilemiyor."

        prompt = f"""Sen bir KOBİ finansal asistanısın. Aşağıdaki verilere göre kısa bir sabah brifingi hazırla.
Türkçe yaz, samimi ama profesyonel ol. "Günaydın" ile başla.

Veriler:
- Kritik stok ürünleri: {json.dumps(data.get('critical_stock', []), ensure_ascii=False)}
- Nakit durumu: {json.dumps(data.get('cash_status', {}), ensure_ascii=False)}
- Gecikmiş ödemeler: {json.dumps(data.get('overdue_payments', []), ensure_ascii=False)}
- Yaklaşan KDV tarihi: {data.get('kdv_deadline', 'Bilgi yok')}

3-4 madde halinde özetle. Her madde için bir emoji kullan."""

        try:
            response = self.model.generate_content(
                prompt,
                generation_config=genai.GenerationConfig(temperature=0.6),
            )
            return response.text
        except Exception as e:
            logger.error(f"Sabah brifingi uretme hatasi: {e}", exc_info=True)
            return "Sabah brifingi şu anda üretilemiyor. Lütfen daha sonra tekrar deneyin."

    # ─── Yardımcı Metodlar ────────────────────────────────────────────

    def _parse_json(self, text: str) -> dict:
        """Gemini yanıtından JSON çıkarır."""
        raw = text.strip()
        if raw.startswith("```"):
            raw = raw.split("```")[1]
            if raw.startswith("json"):
                raw = raw[4:]
        try:
            return json.loads(raw.strip())
        except json.JSONDecodeError:
            return {"error": "JSON parse hatası", "raw": text}


# Singleton
gemini_service = GeminiService()
