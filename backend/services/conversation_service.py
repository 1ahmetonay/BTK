"""
Conversation Service — Chat history yönetimi.
In-memory başlıyoruz; production'da Redis/DB'ye taşınır.
"""
import time
import uuid
from collections import defaultdict
from typing import Optional

import google.generativeai as genai

# Son N user/model çift turn (4 turn = 8 mesaj, KOBİ context için yeterli)
MAX_TURNS = 4
# Eski session'ları temizle (saat cinsinden)
SESSION_TTL_HOURS = 6


class ConversationStore:
    """In-memory conversation store. Restart'ta sıfırlanır."""

    def __init__(self):
        # conversation_id -> list[genai.protos.Content]
        self._sessions: dict[str, list] = defaultdict(list)
        self._last_access: dict[str, float] = {}

    def get_or_create(self, conversation_id: Optional[str]) -> tuple[str, list]:
        """conversation_id verilmediyse yeni üret; varsa history'yi getir."""
        self._cleanup_stale()
        if not conversation_id:
            conversation_id = str(uuid.uuid4())
        self._last_access[conversation_id] = time.time()
        return conversation_id, list(self._sessions[conversation_id])  # kopya

    def append_turn(self, conversation_id: str, user_text: str, model_text: str):
        """Sadece final user+model çiftini sakla. Tool call/response YOK."""
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

    def reset(self, conversation_id: str):
        self._sessions.pop(conversation_id, None)
        self._last_access.pop(conversation_id, None)

    def _cleanup_stale(self):
        now = time.time()
        ttl = SESSION_TTL_HOURS * 3600
        stale = [cid for cid, t in self._last_access.items() if now - t > ttl]
        for cid in stale:
            self._sessions.pop(cid, None)
            self._last_access.pop(cid, None)


conversation_store = ConversationStore()