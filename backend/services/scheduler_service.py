"""
KOBİ AI Asistan — Arka Plan Zamanlayıcısı (Scheduler)
Sabah brifingleri, periyodik stok kontrol, nakit projeksiyonu ve KDV uyarıları.
"""

import asyncio
import json
from datetime import date, datetime
from apscheduler.schedulers.asyncio import AsyncIOScheduler
from apscheduler.triggers.cron import CronTrigger
from apscheduler.triggers.interval import IntervalTrigger

import sys, os
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from database import async_session, Uyari, BriefCache
from services.finance_service import finance_service
from services.stock_service import stock_service
from services.gemini_service import gemini_service
from services.event_bus import event_bus, Events


class SchedulerService:
    def __init__(self):
        self.scheduler = AsyncIOScheduler()

    def start(self):
        """Zamanlayıcıyı başlat ve görevleri kaydet."""
        # 1. Her sabah 03:00'te brifing hazırla (MD'deki saat)
        self.scheduler.add_job(
            self.generate_daily_briefing,
            CronTrigger(hour=3, minute=0),
            id="daily_briefing",
            replace_existing=True
        )

        # 2. Her 2 saatte bir stok kritik seviye kontrolü (MD Bölüm 13.3)
        self.scheduler.add_job(
            self.check_critical_stocks,
            IntervalTrigger(hours=2),
            id="critical_stock_check",
            replace_existing=True
        )

        # 3. Her 6 saatte nakit akışı projeksiyonu güncelleme (MD Bölüm 13.3)
        self.scheduler.add_job(
            self.update_cash_forecast,
            IntervalTrigger(hours=6),
            id="cash_forecast_update",
            replace_existing=True
        )

        # 4. Her ayın 1'inde KDV takvim uyarısı (MD Bölüm 13.3)
        self.scheduler.add_job(
            self.check_tax_deadlines,
            CronTrigger(day=1, hour=9, minute=0),
            id="tax_deadline_check",
            replace_existing=True
        )

        self.scheduler.start()
        print("[OK] Arka plan zamanlayicisi baslatildi (4 gorev aktif).")

    def stop(self):
        """Zamanlayıcıyı durdur."""
        self.scheduler.shutdown()

    async def generate_daily_briefing(self):
        """Sabah brifingini oluşturur ve veritabanına cache'ler."""
        print(f"[INFO] Sabah brifingi olusturuluyor... ({datetime.now()})")
        async with async_session() as db:
            critical = await stock_service.get_critical_products(db)
            cashflow = await finance_service.get_cashflow(db, gun=30)
            kdv = await finance_service.get_kdv_summary(db)
            overdue = await finance_service.get_overdue_payments(db)

            brief_data = {
                "critical_stock": critical[:3],
                "cash_status": {
                    "bakiye": cashflow["mevcut_bakiye"],
                    "projeksiyonlar": cashflow["projeksiyonlar"],
                },
                "overdue_payments": overdue,
                "kdv_deadline": kdv["beyanname_son_tarihi"],
            }

            # AI ile brifingi üret
            brief = await gemini_service.generate_morning_brief(brief_data)

            # Veritabanına cache'le
            from sqlalchemy import select, delete
            today = date.today()
            # Aynı gün için eski cache'i sil
            await db.execute(delete(BriefCache).where(BriefCache.tarih == today))
            cache = BriefCache(
                tarih=today,
                brief_text=brief,
                brief_data_json=json.dumps(brief_data, ensure_ascii=False, default=str),
            )
            db.add(cache)
            await db.commit()
            print("[OK] Sabah brifingi olusturuldu ve cache'lendi.")

    async def check_critical_stocks(self):
        """Periyodik olarak kritik stokları kontrol edip uyarı fırlatır."""
        async with async_session() as db:
            critical = await stock_service.get_critical_products(db)
            if critical:
                for product in critical:
                    uyari = Uyari(
                        tur="stok_kritik",
                        baslik=f"Periyodik Kontrol: {product['isim']} kritik seviyede",
                        mesaj=f"Mevcut stok: {product['mevcut_stok']}, Minimum: {product['min_stok']}. "
                              f"Tahmini {product.get('kalan_gun', '?')} kaldı. Tedarik önerilir.",
                        oncelik="kritik"
                    )
                    db.add(uyari)
                await db.commit()
                print(f"[INFO] {len(critical)} adet kritik stok uyarisi olusturuldu.")

    async def update_cash_forecast(self):
        """6 saatte bir nakit akışı projeksiyonunu günceller ve risk varsa uyarı oluşturur."""
        async with async_session() as db:
            cashflow = await finance_service.get_cashflow(db, gun=30)
            projections = cashflow.get("projeksiyonlar", [])

            for proj in projections:
                if proj.get("risk"):
                    uyari = Uyari(
                        tur="nakit_acik",
                        baslik=f"{proj['gun']} gün sonra nakit açığı riski",
                        mesaj=f"Tahmini bakiye: {proj['tahmini_bakiye']:,.0f} TL. "
                              f"Gelir artışı veya gider ötelemesi değerlendirilmeli.",
                        oncelik="kritik"
                    )
                    db.add(uyari)
                    await db.commit()
                    print(f"[WARN] {proj['gun']} gun sonrasi nakit acigi tespit edildi.")
                    break  # İlk risk noktası yeterli

    async def check_tax_deadlines(self):
        """Aylık KDV beyanname tarihi kontrolü."""
        async with async_session() as db:
            kdv = await finance_service.get_kdv_summary(db)
            kalan_gun = kdv.get("kalan_gun", 99)

            if kalan_gun <= 10:
                uyari = Uyari(
                    tur="kdv_tarihi",
                    baslik="KDV beyanname son tarihi yaklaşıyor",
                    mesaj=f"KDV beyanname son tarihi: {kdv['beyanname_son_tarihi']}. "
                          f"Kalan gün: {kalan_gun}. Ödenecek KDV: {kdv['odenecek_kdv']:,.0f} TL.",
                    oncelik="yuksek" if kalan_gun <= 5 else "normal"
                )
                db.add(uyari)
                await db.commit()
                print(f"[INFO] KDV beyanname uyarisi olusturuldu (kalan {kalan_gun} gun).")


scheduler_service = SchedulerService()
