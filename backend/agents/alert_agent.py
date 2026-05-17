"""
KOBİ AI Asistan — Uyarı Ajanı
Diğer ajanların çıktılarından uyarı üretir, öncelik sıralar.
"""

from datetime import datetime
from sqlalchemy.ext.asyncio import AsyncSession

import sys, os
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from database import Uyari


class AlertAgent:
    """Uyarı ajanı — push notification ve öncelik sıralaması."""

    def __init__(self):
        self.name = "uyari_ajani"

    async def create_alert(self, db: AsyncSession, tur: str, baslik: str,
                            mesaj: str, oncelik: str = "normal",
                            entity_tipi: str = None, entity_id: int = None) -> dict:
        """Yeni uyarı oluşturur."""
        uyari = Uyari(
            tur=tur,
            baslik=baslik,
            mesaj=mesaj,
            oncelik=oncelik,
            ilgili_entity_tipi=entity_tipi,
            ilgili_entity_id=entity_id,
        )
        db.add(uyari)
        await db.commit()
        return {
            "id": uyari.id,
            "baslik": baslik,
            "oncelik": oncelik,
            "olusturuldu": True,
        }

    async def handle_stok_kritik(self, db: AsyncSession, urun_id: int,
                                  urun_adi: str, mevcut: int, minimum: int) -> dict:
        """Stok kritik event'i geldiğinde uyarı oluşturur."""
        return await self.create_alert(
            db,
            tur="stok_kritik",
            baslik=f"{urun_adi} kritik seviyeye düştü",
            mesaj=f"Mevcut stok: {mevcut} adet. Minimum seviye: {minimum}. Acil tedarik önerilir.",
            oncelik="kritik",
            entity_tipi="urun",
            entity_id=urun_id,
        )

    async def handle_nakit_risk(self, db: AsyncSession, gun: int, tutar: float) -> dict:
        """Nakit açığı riski uyarısı."""
        return await self.create_alert(
            db,
            tur="nakit_acik",
            baslik=f"{gun} gün sonra nakit açığı riski",
            mesaj=f"Önümüzdeki {gun} gün içinde {tutar:,.0f} TL nakit açığı oluşması bekleniyor.",
            oncelik="kritik",
        )


alert_agent = AlertAgent()
