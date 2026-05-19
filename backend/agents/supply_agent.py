"""
KOBİ AI Asistan — Tedarik Ajanı
Stok kritikse devreye girer, tedarikçiye sipariş taslağı hazırlar.
"""

from datetime import date, timedelta
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from database import Urun, Tedarikci, FiyatGecmisi
from prompts.supply_agent_prompt import SUPPLY_AGENT_PROMPT


class SupplyAgent:
    """Tedarik ajanı — stok kritik seviyeye düştüğünde sipariş taslağı hazırlar."""

    def __init__(self):
        self.name = "tedarik_ajani"
        self.prompt = SUPPLY_AGENT_PROMPT

    async def handle_critical_stock(self, db: AsyncSession, urun_id: int,
                                     urun_adi: str, mevcut: int, minimum: int) -> dict:
        """Kritik stok event'i geldiğinde sipariş taslağı hazırlar."""
        # Ürünü ve varsayılan tedarikçiyi bul
        result = await db.execute(
            select(Urun, Tedarikci)
            .outerjoin(Tedarikci, Urun.varsayilan_tedarikci_id == Tedarikci.id)
            .where(Urun.id == urun_id)
        )
        row = result.first()
        if not row:
            return {"error": "Ürün bulunamadı"}

        urun, tedarikci = row

        # Sipariş miktarını hesapla (max stok hedefi)
        hedef_miktar = (urun.max_stok or minimum * 3) - mevcut
        tahmini_maliyet = hedef_miktar * (urun.son_alis_maliyeti or 0)

        # Alternatif tedarikçi bul
        alt_result = await db.execute(
            select(FiyatGecmisi, Tedarikci.isim, Tedarikci.guvenilirlik_skoru)
            .join(Tedarikci, FiyatGecmisi.tedarikci_id == Tedarikci.id)
            .where(FiyatGecmisi.urun_id == urun_id)
            .where(Tedarikci.id != (urun.varsayilan_tedarikci_id or -1))
            .order_by(FiyatGecmisi.tarih.desc())
        )
        alt_rows = alt_result.all()
        alternatif = None
        if alt_rows:
            alt = alt_rows[0]
            alternatif = {
                "tedarikci": alt[1],
                "birim_fiyat": alt[0].birim_fiyat,
                "guvenilirlik": alt[2],
            }

        teslim_gunu = tedarikci.ortalama_teslim_suresi_gun if tedarikci else 5
        teslim_tarihi = (date.today() + timedelta(days=teslim_gunu)).isoformat()

        return {
            "tip": "siparis_taslagi",
            "urun": urun_adi,
            "sku": urun.sku,
            "mevcut_stok": mevcut,
            "siparis_miktari": hedef_miktar,
            "tedarikci": tedarikci.isim if tedarikci else "Bilinmiyor",
            "birim_fiyat": urun.son_alis_maliyeti,
            "tahmini_maliyet": round(tahmini_maliyet, 2),
            "beklenen_teslim": teslim_tarihi,
            "alternatif_tedarikci": alternatif,
            "onay_bekliyor": True,
        }


supply_agent = SupplyAgent()
