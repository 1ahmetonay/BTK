"""
Conversation Service — Chat history yönetimi.
In-memory başlıyoruz; production'da Redis/DB'ye taşınır.
Sliding window ile son N turn saklanır.
Tool context bilgisi model yanıtına eklenerek bağlam korunur.
"""
import time
import uuid
from collections import defaultdict
from typing import Optional

import google.generativeai as genai

# Son N user/model çift turn (6 turn = 12 mesaj — daha derin bağlam)
# "Bunu detaylandır", "peki bu ne anlama geliyor?" gibi referans soruları
# için en az 3-4 turn gerekli. 6 turn ile güvenli bir bağlam penceresi sağlanır.
MAX_TURNS = 6
# Eski session'ları temizle (saat cinsinden)
SESSION_TTL_HOURS = 6


class ConversationStore:
    """In-memory conversation store. Restart'ta sıfırlanır."""

    def __init__(self):
        # conversation_id -> list[genai.protos.Content]
        self._sessions: dict[str, list] = defaultdict(list)
        self._last_access: dict[str, float] = {}
        # Her session için kullanılan mod geçmişi
        self._session_modes: dict[str, str] = {}

    def get_or_create(self, conversation_id: Optional[str]) -> tuple[str, list]:
        """conversation_id verilmediyse yeni üret; varsa history'yi getir."""
        self._cleanup_stale()
        if not conversation_id:
            conversation_id = str(uuid.uuid4())
        self._last_access[conversation_id] = time.time()
        return conversation_id, list(self._sessions[conversation_id])  # kopya

    def append_turn(self, conversation_id: str, user_text: str, model_text: str):
        """User+model çiftini sakla.

        model_text, araç bilgisi suffix'i içerebilir:
        "Analiz sonucu...\n\n[Bu yanıt için kullanılan araçlar: get_stock_status, get_critical_stock]"

        Bu sayede Gemini bir sonraki turn'de hangi araçların kullanıldığını bilir
        ve "bunu detaylandır" gibi referans sorularını doğru yanıtlayabilir.
        """
        history = self._sessions[conversation_id]
        history.append(genai.protos.Content(
            role="user",
            parts=[genai.protos.Part(text=user_text)],
        ))
        history.append(genai.protos.Content(
            role="model",
            parts=[genai.protos.Part(text=model_text)],
        ))
        # Sliding window — son MAX_TURNS turn'ü tut
        if len(history) > MAX_TURNS * 2:
            self._sessions[conversation_id] = history[-MAX_TURNS * 2:]

    def get_turn_count(self, conversation_id: str) -> int:
        """Mevcut turn sayısını döndürür."""
        return len(self._sessions.get(conversation_id, [])) // 2

    def reset(self, conversation_id: str):
        self._sessions.pop(conversation_id, None)
        self._last_access.pop(conversation_id, None)
        self._session_modes.pop(conversation_id, None)

    def _cleanup_stale(self):
        now = time.time()
        ttl = SESSION_TTL_HOURS * 3600
        stale = [cid for cid, t in self._last_access.items() if now - t > ttl]
        for cid in stale:
            self._sessions.pop(cid, None)
            self._last_access.pop(cid, None)
            self._session_modes.pop(cid, None)


conversation_store = ConversationStore()
