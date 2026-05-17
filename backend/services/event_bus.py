"""
KOBİ AI Asistan — Event Bus (Olay Yolu)
Fatura yüklendiğinde stok, KDV, nakit akışı ajanlarını tetikler.
"""

import asyncio
from collections import defaultdict
from typing import Any, Callable, Coroutine


class EventBus:
    """Basit async event bus — observer pattern ile modüller arası iletişim sağlar."""

    def __init__(self):
        self._listeners: dict[str, list[Callable[..., Coroutine]]] = defaultdict(list)

    def subscribe(self, event_name: str, handler: Callable[..., Coroutine]):
        """Bir olaya abone ol."""
        self._listeners[event_name].append(handler)

    def unsubscribe(self, event_name: str, handler: Callable[..., Coroutine]):
        """Aboneliği kaldır."""
        self._listeners[event_name] = [
            h for h in self._listeners[event_name] if h != handler
        ]

    async def emit(self, event_name: str, **kwargs: Any):
        """Olayı tetikle — tüm abone handler'ları paralel çalıştır."""
        handlers = self._listeners.get(event_name, [])
        if not handlers:
            return

        tasks = [handler(**kwargs) for handler in handlers]
        results = await asyncio.gather(*tasks, return_exceptions=True)

        for i, result in enumerate(results):
            if isinstance(result, Exception):
                print(f"[WARN] Event '{event_name}' handler error: {result}")

        return results


# Singleton event bus
event_bus = EventBus()


# ─── Event İsimleri ───────────────────────────────────────────────────
class Events:
    """Sistemdeki tüm event isimleri."""
    FATURA_ISLENDI = "fatura_islendi"          # Fatura Gemini ile okundu ve kaydedildi
    STOK_GUNCELLENDI = "stok_guncellendi"      # Stok miktarı değişti
    STOK_KRITIK = "stok_kritik"                # Stok kritik seviyeye düştü
    KDV_GUNCELLENDI = "kdv_guncellendi"        # KDV kaydı güncellendi
    NAKIT_GUNCELLENDI = "nakit_guncellendi"     # Nakit akışı güncellendi
    PUANTAJ_ISLENDI = "puantaj_islendi"         # Puantaj Gemini ile okundu
    UYARI_OLUSTURULDU = "uyari_olusturuldu"    # Yeni uyarı oluşturuldu
    TEDARIK_GEREKLI = "tedarik_gerekli"        # Tedarikçiye sipariş gerekiyor
