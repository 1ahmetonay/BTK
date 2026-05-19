"""
KOBİ AI Asistan — Arka Plan Zamanlayıcısı (Scheduler)
Sabah brifingleri, periyodik stok kontrol, nakit projeksiyonu ve KDV uyarıları.
"""

import json
import logging
from datetime import date, datetime, timedelta, timezone
from apscheduler.schedulers.asyncio import AsyncIOScheduler
from apscheduler.triggers.cron import CronTrigger
from apscheduler.triggers.interval import IntervalTrigger

from sqlalchemy import select

from database import async_session, Uyari, BriefCache
from services.finance_service import finance_service
from services.stock_service import stock_service
from services.gemini_service import gemini_service

logger = logging.getLogger(__name__)


class SchedulerService:
    def __init__(self):
        self.scheduler = AsyncIOScheduler()

    def start(self):
        """Zamanlayıcıyı başlat ve görevleri kaydet."""
        # 1. Her sabah 03:00'te brifing hazırla
        self.scheduler.add_job(
            self.generate_daily_briefing,
            CronTrigger(hour=3, minute=0),
            id="daily_briefing",
            replace_existing=True
        )

        # 2. Her 2 saatte bir stok kritik seviye kontrolü
        self.scheduler.add_job(
            self.check_critical_stocks,
            IntervalTrigger(hours=2),
            id="critical_stock_check",
            replace_existing=True
        )

        # 3. Her 6 saatte nakit akışı projeksiyonu güncelleme
        self.scheduler.add_job(
            self.update_cash_forecast,
            IntervalTrigger(hours=6),
            id="cash_forecast_update",
            replace_existing=True
        )

        # 4. Her ayın 1'inde KDV takvim uyarısı
        self.scheduler.add_job(
            self.check_tax_deadlines,
            CronTrigger(day=1, hour=9, minute=0),
            id="tax_deadline_check",
            replace_existing=True
        )

        self.scheduler.start()
        logger.info("Arka plan zamanlayicisi baslatildi (4 gorev aktif).")

    def stop(self):
        """Zamanlayıcıyı durdur."""
        self.scheduler.shutdown()

    async def generate_daily_briefing(self):
        """Sabah brifingini oluşturur ve veritabanına cache'ler."""
        logger.info("Sabah brifingi olusturuluyor...")
        async with async_session() as db:
            try:
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
                from sqlalchemy import delete
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
                logger.info("Sabah brifingi olusturuldu ve cache'lendi.")
            except Exception as e:
                logger.error(f"Sabah brifingi olusturulurken hata: {e}", exc_info=True)

    async def check_critical_stocks(self):
        """Periyodik olarak kritik stokları kontrol edip uyarı fırlatır.
        Son 24 saat içinde aynı ürün için uyarı varsa tekrar oluşturmaz (dedup).
        """
        async with async_session() as db:
            try:
                critical = await stock_service.get_critical_products(db)
                if not critical:
                    return

                created = 0
                cutoff = datetime.now(timezone.utc) - timedelta(hours=24)

                for product in critical:
                    urun_id = product.get("id")
                    # Dedup: Son 24 saatte aynı ürün için uyarı var mı?
                    existing = await db.execute(
                        select(Uyari.id).where(
                            Uyari.ilgili_entity_id == urun_id,
                            Uyari.ilgili_entity_tipi == "urun",
                            Uyari.tur == "stok_kritik",
                            Uyari.olusturma_tarihi > cutoff,
                        )
                    )
                    if existing.scalar_one_or_none() is not None:
                        continue  # Zaten uyarı var, atla

                    uyari = Uyari(
                        tur="stok_kritik",
                        baslik=f"Periyodik Kontrol: {product['isim']} kritik seviyede",
                        mesaj=f"Mevcut stok: {product['mevcut_stok']}, Minimum: {product['min_stok']}. "
                              f"Tahmini {product.get('kalan_gun', '?')} kaldı. Tedarik önerilir.",
                        oncelik="kritik",
                        ilgili_entity_tipi="urun",
                        ilgili_entity_id=urun_id,
                    )
                    db.add(uyari)
                    created += 1

                if created:
                    await db.commit()
                    logger.info(f"{created} adet kritik stok uyarisi olusturuldu.")
            except Exception as e:
                logger.error(f"Kritik stok kontrolunde hata: {e}", exc_info=True)

    async def update_cash_forecast(self):
        """6 saatte bir nakit akışı projeksiyonunu günceller ve risk varsa uyarı oluşturur."""
        async with async_session() as db:
            try:
                cashflow = await finance_service.get_cashflow(db, gun=30)
                projections = cashflow.get("projeksiyonlar", [])

                cutoff = datetime.now(timezone.utc) - timedelta(hours=24)

                for proj in projections:
                    if proj.get("risk"):
                        # Dedup: Son 24 saatte nakit açık uyarısı var mı?
                        existing = await db.execute(
                            select(Uyari.id).where(
                                Uyari.tur == "nakit_acik",
                                Uyari.olusturma_tarihi > cutoff,
                            )
                        )
                        if existing.scalar_one_or_none() is not None:
                            break  # Zaten uyarı var

                        uyari = Uyari(
                            tur="nakit_acik",
                            baslik=f"{proj['gun']} gün sonra nakit açığı riski",
                            mesaj=f"Tahmini bakiye: {proj['tahmini_bakiye']:,.0f} TL. "
                                  f"Gelir artışı veya gider ötelemesi değerlendirilmeli.",
                            oncelik="kritik"
                        )
                        db.add(uyari)
                        await db.commit()
                        logger.warning(f"{proj['gun']} gun sonrasi nakit acigi tespit edildi.")
                        break  # İlk risk noktası yeterli
            except Exception as e:
                logger.error(f"Nakit projeksiyonu guncellenirken hata: {e}", exc_info=True)

    async def check_tax_deadlines(self):
        """Aylık KDV beyanname tarihi kontrolü."""
        async with async_session() as db:
            try:
                kdv = await finance_service.get_kdv_summary(db)
                kalan_gun = kdv.get("kalan_gun", 99)

                if kalan_gun <= 10:
                    # Dedup: Bu ay zaten KDV uyarısı oluşturulmuş mu?
                    cutoff = datetime.now(timezone.utc) - timedelta(days=25)
                    existing = await db.execute(
                        select(Uyari.id).where(
                            Uyari.tur == "kdv_tarihi",
                            Uyari.olusturma_tarihi > cutoff,
                        )
                    )
                    if existing.scalar_one_or_none() is not None:
                        return

                    uyari = Uyari(
                        tur="kdv_tarihi",
                        baslik="KDV beyanname son tarihi yaklaşıyor",
                        mesaj=f"KDV beyanname son tarihi: {kdv['beyanname_son_tarihi']}. "
                              f"Kalan gün: {kalan_gun}. Ödenecek KDV: {kdv['odenecek_kdv']:,.0f} TL.",
                        oncelik="yuksek" if kalan_gun <= 5 else "normal"
                    )
                    db.add(uyari)
                    await db.commit()
                    logger.info(f"KDV beyanname uyarisi olusturuldu (kalan {kalan_gun} gun).")
            except Exception as e:
                logger.error(f"KDV kontrol hatasi: {e}", exc_info=True)


scheduler_service = SchedulerService()
