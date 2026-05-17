"""
KOBİ AI Asistan — Ajan Araçları (Tools)
Ajanların çağırabileceği veritabanı operasyonları.
"""
from typing import Dict, Any
from sqlalchemy.ext.asyncio import AsyncSession
from services.stock_service import stock_service
from services.finance_service import finance_service

class AgentTools:
    """Yapay zeka ajanları için yetenek tanımlamaları (Tools)"""
    
    @staticmethod
    def get_tool_descriptions() -> list[Dict[str, Any]]:
        return [
            {
                "name": "get_stock_status",
                "description": "Genel stok durumunu, aktif ürün sayısını ve stok değerini getirir.",
                "parameters": {
                    "type": "object",
                    "properties": {}
                }
            },
            {
                "name": "get_critical_stock",
                "description": "Minimum seviyenin altına düşmüş kritik stoklu ürünleri getirir.",
                "parameters": {
                    "type": "object",
                    "properties": {}
                }
            },
            {
                "name": "get_cash_flow",
                "description": "Mevcut nakit akışını ve 14/30 günlük nakit projeksiyonunu getirir.",
                "parameters": {
                    "type": "object",
                    "properties": {
                        "days": {"type": "integer", "description": "Kaç günlük veri isteniyor (varsayılan 30)"}
                    }
                }
            },
            {
                "name": "get_overdue_payments",
                "description": "Gecikmiş ödemeleri ve tutarlarını listeler.",
                "parameters": {
                    "type": "object",
                    "properties": {}
                }
            }
        ]

    @staticmethod
    async def execute_tool(db: AsyncSession, tool_name: str, params: Dict[str, Any]) -> Any:
        if tool_name == "get_stock_status":
            res = await stock_service.get_overview(db)
            return {"toplam_sku": res.get("toplam_sku"), "stok_degeri": res.get("stok_degeri")}
        elif tool_name == "get_critical_stock":
            return await stock_service.get_critical_products(db)
        elif tool_name == "get_cash_flow":
            days = params.get("days", 30)
            return await finance_service.get_cashflow(db, gun=days)
        elif tool_name == "get_overdue_payments":
            return await finance_service.get_overdue_payments(db)
        else:
            return {"error": f"Bilinmeyen araç: {tool_name}"}

agent_tools = AgentTools()
