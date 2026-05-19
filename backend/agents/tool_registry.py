"""
KOBİ AI Asistan — Tool Registry (Araç Kaydı)
Tüm ajan araçlarının merkezi tanım ve yönetim noktası.
Gemini Function Calling ile uyumlu tool definitions.
"""

from typing import Dict, Any, List, Optional
from sqlalchemy.ext.asyncio import AsyncSession

from services.stock_service import stock_service
from services.finance_service import finance_service


# ═══════════════════════════════════════════════════════════════════════
#  Gemini Function Calling Tool Tanımları
# ═══════════════════════════════════════════════════════════════════════

TOOL_DEFINITIONS = [
    # ─── Stok Araçları ────────────────────────────────────────────────
    {
        "name": "get_stock_status",
        "description": "Genel stok durumunu, aktif ürün sayısını, kritik stok sayısını ve toplam stok değerini getirir.",
        "parameters": {
            "type": "object",
            "properties": {},
            "required": []
        }
    },
    {
        "name": "get_critical_stock",
        "description": "Minimum seviyenin altına düşmüş kritik stoklu ürünleri listeler.",
        "parameters": {
            "type": "object",
            "properties": {},
            "required": []
        }
    },
    {
        "name": "get_product_movements",
        "description": "Belirtilen SKU koduna sahip ürünün stok giriş/çıkış hareketlerini döndürür.",
        "parameters": {
            "type": "object",
            "properties": {
                "sku": {"type": "string", "description": "Ürün SKU kodu (ör: KHV-250)"}
            },
            "required": ["sku"]
        }
    },
    {
        "name": "get_abc_analysis",
        "description": "ABC stok analizini döndürür. Ürünleri ciro etkisine göre A/B/C gruplarına ayırır.",
        "parameters": {
            "type": "object",
            "properties": {},
            "required": []
        }
    },
    {
        "name": "get_seasonality_pattern",
        "description": "Belirtilen ürünün aylık satış/hareket pattern'ını analiz eder ve mevsimsel eğilimleri döndürür.",
        "parameters": {
            "type": "object",
            "properties": {
                "sku": {"type": "string", "description": "Ürün SKU kodu"}
            },
            "required": ["sku"]
        }
    },
    {
        "name": "compare_suppliers",
        "description": "Aynı ürün için farklı tedarikçilerin fiyat, teslim süresi ve güvenilirlik karşılaştırmasını yapar.",
        "parameters": {
            "type": "object",
            "properties": {
                "sku": {"type": "string", "description": "Ürün SKU kodu"}
            },
            "required": ["sku"]
        }
    },
    {
        "name": "simulate_price_change",
        "description": "Fiyat değişikliğinin stok eritme hızına etkisini simüle eder. What-if analizi yapar.",
        "parameters": {
            "type": "object",
            "properties": {
                "sku": {"type": "string", "description": "Ürün SKU kodu"},
                "price_change_pct": {"type": "number", "description": "Fiyat değişim yüzdesi (ör: -15 = %15 indirim)"}
            },
            "required": ["sku", "price_change_pct"]
        }
    },
    # ─── Finans Araçları ──────────────────────────────────────────────
    {
        "name": "get_pl_summary",
        "description": "Gelir-gider (P&L kâr-zarar) özetini döndürür. Aylık gelir, gider, net kâr ve kâr marjı bilgilerini içerir.",
        "parameters": {
            "type": "object",
            "properties": {
                "month": {"type": "integer", "description": "Ay (1-12). Boş bırakılırsa mevcut ay."},
                "year": {"type": "integer", "description": "Yıl. Boş bırakılırsa mevcut yıl."}
            },
            "required": []
        }
    },
    {
        "name": "get_cash_forecast",
        "description": "Nakit akışı tahmini — 7/14/30/60/90 günlük bakiye projeksiyonu yapar.",
        "parameters": {
            "type": "object",
            "properties": {
                "days": {"type": "integer", "description": "Geçmiş kaç günlük veri kullanılsın (varsayılan 30)"}
            },
            "required": []
        }
    },
    {
        "name": "get_overdue_payments",
        "description": "Vadesi geçmiş, henüz ödenmemiş faturaları listeler.",
        "parameters": {
            "type": "object",
            "properties": {},
            "required": []
        }
    },
    {
        "name": "get_kdv_summary",
        "description": "Aylık KDV beyanname özetini döndürür: hesaplanan KDV, indirilecek KDV, ödenecek KDV ve beyanname son tarihi.",
        "parameters": {
            "type": "object",
            "properties": {
                "month": {"type": "integer", "description": "Ay (1-12)"},
                "year": {"type": "integer", "description": "Yıl"}
            },
            "required": []
        }
    },
    # ─── Puantaj Araçları ─────────────────────────────────────────────
    {
        "name": "get_employee_attendance",
        "description": "Belirtilen çalışanın devam/devamsızlık, mesai ve izin kaydını döndürür.",
        "parameters": {
            "type": "object",
            "properties": {
                "employee_name": {"type": "string", "description": "Çalışan adı (ör: Ahmet Yılmaz)"},
                "month": {"type": "integer", "description": "Ay"},
                "year": {"type": "integer", "description": "Yıl"}
            },
            "required": ["employee_name"]
        }
    },
    {
        "name": "calculate_salary",
        "description": "Belirtilen çalışanın puantaj verisinden brüt/net maaş, SGK ve vergi kesintilerini hesaplar.",
        "parameters": {
            "type": "object",
            "properties": {
                "employee_name": {"type": "string", "description": "Çalışan adı"},
                "month": {"type": "integer", "description": "Ay"},
                "year": {"type": "integer", "description": "Yıl"}
            },
            "required": ["employee_name"]
        }
    },
    # ─── AI Analiz Araçları (Gemini-Powered) ─────────────────────────
    {
        "name": "generate_stock_report",
        "description": "Tüm stok durumunu AI ile analiz eder. ABC analizi, kritik ürünler ve envanter stratejisi önerisi içerir.",
        "parameters": {
            "type": "object",
            "properties": {},
            "required": []
        }
    },
    {
        "name": "generate_financial_health_report",
        "description": "İşletmenin tam finansal sağlık raporunu AI ile üretir. P&L, nakit akışı, KDV ve tahsilat durumunu kapsar.",
        "parameters": {
            "type": "object",
            "properties": {},
            "required": []
        }
    },
    {
        "name": "assess_payment_risk",
        "description": "Gecikmiş ödemeler ve nakit durumunu analiz ederek ödeme risk değerlendirmesi yapar.",
        "parameters": {
            "type": "object",
            "properties": {},
            "required": []
        }
    },
    {
        "name": "detect_stock_anomalies",
        "description": "Stok anomalilerini (beklenmeyen tükenme, anormal hareket) tespit eder ve AI ile açıklar.",
        "parameters": {
            "type": "object",
            "properties": {},
            "required": []
        }
    },
    {
        "name": "generate_combined_forecast",
        "description": "Nakit, stok ve gelir-gider verilerini birlikte değerlendirerek 30 günlük birleşik tahmin ve karar destek raporu üretir.",
        "parameters": {
            "type": "object",
            "properties": {},
            "required": []
        }
    },
]


class ToolRegistry:
    """Merkezi araç kaydı — tüm ajanların kullanabileceği araçları yönetir."""

    def __init__(self):
        self._tools = {t["name"]: t for t in TOOL_DEFINITIONS}

    def get_all_definitions(self) -> list[dict]:
        """Tüm araç tanımlarını döndürür (Gemini FC formatında)."""
        return TOOL_DEFINITIONS

    def get_subset(self, keywords: list[str]) -> list[dict]:
        """Anahtar kelimeye göre araç alt kümesi döndürür."""
        result = []
        for tool in TOOL_DEFINITIONS:
            for kw in keywords:
                if kw.lower() in tool["name"].lower() or kw.lower() in tool["description"].lower():
                    result.append(tool)
                    break
        return result

    def get_tool_names(self) -> list[str]:
        """Tüm araç isimlerini döndürür."""
        return list(self._tools.keys())

    async def execute(self, db: AsyncSession, tool_name: str, params: Dict[str, Any]) -> Any:
        """Aracı çalıştırır ve sonucu döndürür."""
        executor = _EXECUTORS.get(tool_name)
        if not executor:
            return {"error": f"Bilinmeyen araç: {tool_name}"}
        try:
            return await executor(db, params)
        except Exception as e:
            return {"error": f"Araç çalıştırma hatası ({tool_name}): {str(e)}"}


# ═══════════════════════════════════════════════════════════════════════
#  Tool Executor Fonksiyonları
# ═══════════════════════════════════════════════════════════════════════

async def _exec_get_stock_status(db: AsyncSession, params: dict) -> dict:
    overview = await stock_service.get_overview(db)
    return {
        "toplam_sku": overview["toplam_sku"],
        "kritik_stok": overview["kritik_stok_sayisi"],
        "stok_degeri": overview["stok_degeri"],
        "devir_hizi": overview["ortalama_devir_hizi"],
    }

async def _exec_get_critical_stock(db: AsyncSession, params: dict) -> list:
    return await stock_service.get_critical_products(db)

async def _exec_get_product_movements(db: AsyncSession, params: dict) -> dict:
    sku = params.get("sku", "")
    analysis = await stock_service.get_product_analysis(db, sku)
    if "error" in analysis:
        return analysis
    return {
        "urun": analysis["urun"]["isim"],
        "hareketler": analysis["hareketler"][:10],
        "maliyet_degisimi": analysis["maliyet_degisimi_yuzde"],
    }

async def _exec_get_abc_analysis(db: AsyncSession, params: dict) -> dict:
    return await stock_service.get_abc_analysis(db)

async def _exec_get_seasonality(db: AsyncSession, params: dict) -> dict:
    sku = params.get("sku", "")
    return await stock_service.get_seasonality_pattern(db, sku)

async def _exec_compare_suppliers(db: AsyncSession, params: dict) -> dict:
    sku = params.get("sku", "")
    return await stock_service.get_supplier_comparison(db, sku)

async def _exec_simulate_price(db: AsyncSession, params: dict) -> dict:
    sku = params.get("sku", "")
    pct = params.get("price_change_pct", 0)
    return await stock_service.simulate_price_change(db, sku, pct)

async def _exec_get_pl_summary(db: AsyncSession, params: dict) -> dict:
    return await finance_service.get_pl_summary(db, ay=params.get("month"), yil=params.get("year"))

async def _exec_get_cash_forecast(db: AsyncSession, params: dict) -> dict:
    days = params.get("days", 30)
    result = await finance_service.get_cashflow(db, gun=days)
    return {
        "mevcut_bakiye": result["mevcut_bakiye"],
        "toplam_giris": result["toplam_giris"],
        "toplam_cikis": result["toplam_cikis"],
        "projeksiyonlar": result["projeksiyonlar"],
    }

async def _exec_get_overdue(db: AsyncSession, params: dict) -> list:
    return await finance_service.get_overdue_payments(db)

async def _exec_get_kdv(db: AsyncSession, params: dict) -> dict:
    return await finance_service.get_kdv_summary(db, ay=params.get("month"), yil=params.get("year"))

async def _exec_get_attendance(db: AsyncSession, params: dict) -> dict:
    from database import Calisan, Puantaj
    from sqlalchemy import select
    from datetime import date
    name = params.get("employee_name", "")
    month = params.get("month", date.today().month)
    year = params.get("year", date.today().year)
    result = await db.execute(
        select(Puantaj, Calisan.ad_soyad)
        .join(Calisan, Puantaj.calisan_id == Calisan.id)
        .where(Calisan.ad_soyad.ilike(f"%{name}%"), Puantaj.ay == month, Puantaj.yil == year)
    )
    row = result.first()
    if not row:
        return {"error": f"'{name}' için {month}/{year} dönemi puantaj bulunamadı."}
    p, ad = row
    return {
        "calisan": ad, "donem": f"{month}/{year}",
        "calisma_gunu": p.calisma_gunleri, "mesai_saat": p.mesai_saat,
        "izin_gunu": p.izin_gunu, "rapor_gunu": p.rapor_gunu,
    }

async def _exec_calculate_salary(db: AsyncSession, params: dict) -> dict:
    from database import Calisan, Puantaj
    from sqlalchemy import select
    from datetime import date
    name = params.get("employee_name", "")
    month = params.get("month", date.today().month)
    year = params.get("year", date.today().year)
    result = await db.execute(
        select(Puantaj, Calisan.ad_soyad, Calisan.brut_maas)
        .join(Calisan, Puantaj.calisan_id == Calisan.id)
        .where(Calisan.ad_soyad.ilike(f"%{name}%"), Puantaj.ay == month, Puantaj.yil == year)
    )
    row = result.first()
    if not row:
        return {"error": f"'{name}' için puantaj bulunamadı."}
    p, ad, base = row
    return {
        "calisan": ad, "brut_maas": p.brut_maas, "net_maas": p.net_maas,
        "sgk_kesinti": p.sgk_kesinti, "gelir_vergisi": p.gelir_vergisi,
        "calisma_gunu": p.calisma_gunleri, "mesai_saat": p.mesai_saat,
    }


# ─── AI-Powered Executor'lar ─────────────────────────────────────
async def _exec_stock_report(db: AsyncSession, params: dict) -> dict:
    from agents.stock_agent import stock_agent
    return await stock_agent.generate_stock_report(db)

async def _exec_financial_health(db: AsyncSession, params: dict) -> dict:
    from agents.finance_agent import finance_agent
    return await finance_agent.generate_financial_health_report(db)

async def _exec_payment_risk(db: AsyncSession, params: dict) -> dict:
    from agents.finance_agent import finance_agent
    return await finance_agent.assess_payment_risk(db)

async def _exec_stock_anomalies(db: AsyncSession, params: dict) -> dict:
    from agents.stock_agent import stock_agent
    return await stock_agent.detect_anomalies(db)

async def _exec_combined_forecast(db: AsyncSession, params: dict) -> dict:
    from agents.forecast_agent import forecast_agent
    return await forecast_agent.generate_combined_forecast(db)


# Araç adı → executor fonksiyonu eşleştirmesi
_EXECUTORS = {
    "get_stock_status": _exec_get_stock_status,
    "get_critical_stock": _exec_get_critical_stock,
    "get_product_movements": _exec_get_product_movements,
    "get_abc_analysis": _exec_get_abc_analysis,
    "get_seasonality_pattern": _exec_get_seasonality,
    "compare_suppliers": _exec_compare_suppliers,
    "simulate_price_change": _exec_simulate_price,
    "get_pl_summary": _exec_get_pl_summary,
    "get_cash_forecast": _exec_get_cash_forecast,
    "get_overdue_payments": _exec_get_overdue,
    "get_kdv_summary": _exec_get_kdv,
    "get_employee_attendance": _exec_get_attendance,
    "calculate_salary": _exec_calculate_salary,
    # AI-Powered tools
    "generate_stock_report": _exec_stock_report,
    "generate_financial_health_report": _exec_financial_health,
    "assess_payment_risk": _exec_payment_risk,
    "detect_stock_anomalies": _exec_stock_anomalies,
    "generate_combined_forecast": _exec_combined_forecast,
}


# Singleton
tool_registry = ToolRegistry()
