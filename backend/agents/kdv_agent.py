"""
KOBİ AI Asistan — KDV Ajanı
KDV hesabı, beyanname özeti, takvim uyarıları.
"""

from sqlalchemy.ext.asyncio import AsyncSession
from agents.tool_registry import tool_registry
from prompts.finance_agent_prompt import KDV_AGENT_PROMPT


class KdvAgent:
    """KDV ajanı — beyanname özeti ve son tarih uyarıları."""

    def __init__(self):
        self.name = "kdv_ajani"
        self.prompt = KDV_AGENT_PROMPT
        self.tools = ["get_kdv_summary"]

    async def get_upcoming_deadlines(self, db: AsyncSession) -> dict:
        """Yaklaşan KDV beyanname tarihi ve özet."""
        return await tool_registry.execute(db, "get_kdv_summary", {})


kdv_agent = KdvAgent()
