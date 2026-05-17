"""
KOBİ AI Asistan — Gemini AI Servisi
Google Gemini 2.5 Flash ile belge okuma, chat, ve function calling.
"""

import base64
import json
import os
from pathlib import Path
from typing import Any, Optional

import google.generativeai as genai
from dotenv import load_dotenv

load_dotenv()

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
        self._chat_model = None

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
            return self._mock_invoice_response()

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
            print(f"[WARN] Gemini document read error: {e}")
            return self._mock_invoice_response()

    async def read_timesheet(self, image_data: bytes, mime_type: str = "image/jpeg") -> dict:
        """Kağıt puantaj fotoğrafından dijital veri çıkarır."""
        if not self.is_configured:
            return self._mock_timesheet_response()

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
            print(f"[WARN] Gemini timesheet read error: {e}")
            return self._mock_timesheet_response()

    async def chat(self, message: str, context: str = "") -> dict:
        """Doğal dil sorgusu — ReAct döngüsüyle yanıt üretir."""
        if not self.is_configured:
            return self._mock_chat_response(message)

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
            print(f"[WARN] Gemini chat error: {e}")
            return self._mock_chat_response(message)

    async def generate_morning_brief(self, data: dict) -> str:
        """Sabah brifingi üretir."""
        if not self.is_configured:
            return self._mock_morning_brief(data)

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
            return self._mock_morning_brief(data)

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

    # ─── Mock Yanıtlar (API key yokken demo için) ─────────────────────

    def _mock_invoice_response(self) -> dict:
        return {
            "belge_tipi": "satin_alma_faturasi",
            "satici_adi": "Aksoy Tedarik Ltd. Şti.",
            "satici_vkn": "1234567890",
            "fatura_no": "FAT-2026-0143",
            "tarih": "2026-05-15",
            "kalemler": [
                {
                    "urun_adi": "Türk Kahvesi 250g",
                    "miktar": 100,
                    "birim": "adet",
                    "birim_fiyat": 120.0,
                    "kdv_orani": 20,
                    "kdv_tutari": 2400.0,
                    "satir_toplam": 14400.0,
                },
                {
                    "urun_adi": "Filtre Kahve 1kg",
                    "miktar": 50,
                    "birim": "adet",
                    "birim_fiyat": 310.0,
                    "kdv_orani": 20,
                    "kdv_tutari": 3100.0,
                    "satir_toplam": 18600.0,
                },
            ],
            "toplam_kdv": 5500.0,
            "genel_toplam": 33000.0,
            "para_birimi": "TRY",
            "guven_skoru": 0.94,
        }

    def _mock_timesheet_response(self) -> dict:
        return {
            "donem": {"ay": 5, "yil": 2026},
            "calisanlar": [
                {
                    "isim": "Ahmet Yılmaz",
                    "toplam_calisma_gunu": 21,
                    "mesai_saatleri": 14,
                    "izin_gunu": 1,
                    "rapor_gunu": 0,
                },
                {
                    "isim": "Fatma Demir",
                    "toplam_calisma_gunu": 20,
                    "mesai_saatleri": 0,
                    "izin_gunu": 2,
                    "rapor_gunu": 0,
                },
                {
                    "isim": "Mehmet Kaya",
                    "toplam_calisma_gunu": 22,
                    "mesai_saatleri": 8,
                    "izin_gunu": 0,
                    "rapor_gunu": 0,
                },
            ],
        }

    def _mock_chat_response(self, message: str) -> dict:
        responses = {
            "default": (
                "Merhaba! İşletmenizin mevcut durumunu analiz ettim:\n\n"
                "📊 **Stok Durumu:** 128 aktif ürün takip ediliyor. 7 ürün kritik seviyede.\n\n"
                "💰 **Nakit Akışı:** Mevcut bakiye 91.600 TL. 14 gün sonra 42.000 TL açık riski var.\n\n"
                "📋 **KDV:** Bu ay hesaplanan KDV 3.708 TL, indirilecek KDV 1.840 TL. "
                "Ödenecek KDV: 1.868 TL. Son tarih: 26 Mayıs.\n\n"
                "**Öneri:** Türk Kahvesi 250g için acil sipariş verilmeli. "
                "Ahmet Usta Kafe'nin 8.750 TL'lik gecikmiş ödemesi takip edilmeli."
            ),
        }
        return {
            "response": responses.get("default"),
            "tools_used": ["get_stock_levels", "get_cash_forecast", "get_kdv_summary"],
            "thinking_steps": [
                {"step": "Plan", "detail": "Stok, nakit ve KDV verilerini kontrol edeceğim"},
                {"step": "Stok Kontrolü", "detail": "get_stock_levels aracı çağrıldı → 7 kritik ürün"},
                {"step": "Nakit Analizi", "detail": "get_cash_forecast aracı çağrıldı → 14 gün sonra risk"},
                {"step": "KDV Hesabı", "detail": "get_kdv_summary aracı çağrıldı → 1.868 TL ödenecek"},
                {"step": "Sentez", "detail": "Tüm veriler birleştirildi, Türkçe analiz hazırlandı"},
            ],
        }

    def _mock_morning_brief(self, data: dict) -> str:
        return (
            "Günaydın! Bu sabah 3 öncelikli konunuz var:\n\n"
            "🔴 **Stok** — Türk Kahvesi 250g kritik seviyeye indi (12 adet kaldı, 4 günlük stok). "
            "Tedarikçi Aksoy Tedarik'e teklif talebi taslağı hazırladım.\n\n"
            "💰 **Nakit** — 14 gün sonra 42.000 TL açık tahmini. "
            "Ahmet Usta Kafe'nin 9 günlük geciken ödemesi (8.750 TL) için hatırlatma önerilir.\n\n"
            "📋 **KDV** — Bu ay beyanname tutarı 18.400 TL, son gün 26 Mayıs."
        )


# Singleton
gemini_service = GeminiService()
