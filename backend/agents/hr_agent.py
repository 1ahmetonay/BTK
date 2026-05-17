"""
KOBİ AI Asistan — HR/Puantaj Ajanı
Puantaj okuma, maaş hesabı, performans skoru.
"""

from sqlalchemy.ext.asyncio import AsyncSession
from agents.tool_registry import tool_registry
from prompts.hr_agent_prompt import HR_AGENT_PROMPT


class HrAgent:
    """HR/Puantaj ajanı — çalışan yönetimi ve maaş hesapları."""

    def __init__(self):
        self.name = "hr_ajani"
        self.prompt = HR_AGENT_PROMPT
        self.tools = ["get_employee_attendance", "calculate_salary"]

    async def check_late_timesheets(self, db: AsyncSession) -> dict:
        """Eksik puantaj kayıtlarını kontrol eder."""
        from database import Calisan, Puantaj
        from sqlalchemy import select
        from datetime import date
        today = date.today()

        # Bu ay için puantajı olmayan çalışanlar
        result = await db.execute(select(Calisan).where(Calisan.aktif == True))
        calisanlar = result.scalars().all()

        eksik = []
        for c in calisanlar:
            result = await db.execute(
                select(Puantaj).where(
                    Puantaj.calisan_id == c.id,
                    Puantaj.ay == today.month,
                    Puantaj.yil == today.year,
                )
            )
            if not result.scalar_one_or_none():
                eksik.append({"calisan": c.ad_soyad, "pozisyon": c.pozisyon})

        return {
            "donem": f"{today.month}/{today.year}",
            "eksik_puantaj_sayisi": len(eksik),
            "eksik_calisanlar": eksik,
        }

    async def calculate_performance_score(self, db: AsyncSession, employee_name: str) -> dict:
        """Çalışan performans skoru hesaplar (son 3 ay)."""
        from database import Calisan, Puantaj
        from sqlalchemy import select
        from datetime import date

        result = await db.execute(
            select(Puantaj, Calisan.ad_soyad)
            .join(Calisan, Puantaj.calisan_id == Calisan.id)
            .where(Calisan.ad_soyad.ilike(f"%{employee_name}%"))
            .order_by(Puantaj.yil.desc(), Puantaj.ay.desc())
            .limit(3)
        )
        rows = result.all()
        if not rows:
            return {"error": f"'{employee_name}' için performans verisi bulunamadı."}

        # Devam skoru (%40)
        avg_days = sum(r[0].calisma_gunleri for r in rows) / len(rows)
        attendance_score = min(avg_days / 22, 1.0)

        # Mesai düzeni (%30)
        avg_overtime = sum(r[0].mesai_saat for r in rows) / len(rows)
        punctuality_score = min(1.0, 0.7 + avg_overtime * 0.03)

        # Basit üretkenlik (%30)
        avg_absence = sum((r[0].izin_gunu or 0) + (r[0].rapor_gunu or 0) for r in rows) / len(rows)
        productivity_score = max(0, 1.0 - avg_absence * 0.1)

        total = attendance_score * 0.4 + punctuality_score * 0.3 + productivity_score * 0.3

        return {
            "calisan": rows[0][1],
            "performans_skoru": round(total * 100, 1),
            "devam_skoru": round(attendance_score * 100, 1),
            "mesai_skoru": round(punctuality_score * 100, 1),
            "uretkenlik_skoru": round(productivity_score * 100, 1),
        }


hr_agent = HrAgent()
