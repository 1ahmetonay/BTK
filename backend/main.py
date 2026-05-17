"""
KOBİ AI Asistan — FastAPI Backend
Ana uygulama dosyası.

Çalıştırma:
  cd backend
  pip install -r requirements.txt
  python seed_data.py
  uvicorn main:app --reload --port 8000
"""

import sys
import os
from contextlib import asynccontextmanager

from pathlib import Path

from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse, FileResponse
from fastapi.staticfiles import StaticFiles
from slowapi import Limiter
from slowapi.util import get_remote_address
from slowapi.errors import RateLimitExceeded
from dotenv import load_dotenv

load_dotenv()

# Path düzeltmesi
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from database import init_db, async_session, _is_sqlite
from routers import dashboard, stock, finance, document, chat, hr, alerts, auth
from routers import invoice
from services.scheduler_service import scheduler_service
from services.event_bus import event_bus, Events

APP_ENV = os.getenv("APP_ENV", "development")


# ─── Rate Limiter ────────────────────────────────────────────────────
limiter = Limiter(key_func=get_remote_address, default_limits=["60/minute"])


# ─── Event Bus Subscriber'ları Kaydet ─────────────────────────────────
async def _on_fatura_islendi(**kwargs):
    """Fatura işlendiğinde tetiklenir."""
    fatura_id = kwargs.get("fatura_id")
    tur = kwargs.get("tur")
    print(f"[EVENT] Fatura islendi: #{fatura_id} ({tur})")


async def _on_stok_kritik(**kwargs):
    """Stok kritik seviyeye düştüğünde tetiklenir — tedarik ajanını çağırır."""
    from agents.supply_agent import supply_agent
    from agents.alert_agent import alert_agent

    urun_id = kwargs.get("urun_id")
    urun_adi = kwargs.get("urun_adi", "")
    mevcut = kwargs.get("mevcut", 0)
    minimum = kwargs.get("minimum", 0)

    print(f"[EVENT] Stok kritik: {urun_adi} ({mevcut}/{minimum})")

    async with async_session() as db:
        siparis = await supply_agent.handle_critical_stock(db, urun_id, urun_adi, mevcut, minimum)
        if siparis and not siparis.get("error"):
            print(f"[EVENT] Tedarik ajani siparis taslagi hazirladi: {siparis.get('tedarikci')}")

        await alert_agent.handle_stok_kritik(db, urun_id, urun_adi, mevcut, minimum)


async def _on_stok_guncellendi(**kwargs):
    """Stok güncellendiğinde tetiklenir."""
    urun_id = kwargs.get("urun_id")
    miktar = kwargs.get("miktar")
    print(f"[EVENT] Stok guncellendi: urun #{urun_id}, degisim: {miktar}")


async def _on_puantaj_islendi(**kwargs):
    """Puantaj işlendiğinde tetiklenir."""
    calisan_sayisi = kwargs.get("calisan_sayisi", 0)
    print(f"[EVENT] Puantaj islendi: {calisan_sayisi} calisan")


def _register_event_subscribers():
    """Tüm event subscriber'larını kaydeder."""
    event_bus.subscribe(Events.FATURA_ISLENDI, _on_fatura_islendi)
    event_bus.subscribe(Events.STOK_KRITIK, _on_stok_kritik)
    event_bus.subscribe(Events.STOK_GUNCELLENDI, _on_stok_guncellendi)
    event_bus.subscribe(Events.PUANTAJ_ISLENDI, _on_puantaj_islendi)
    print("[OK] Event bus subscriber'lari kaydedildi (4 subscriber).")


# ─── Lifespan Event ──────────────────────────────────────────────────
@asynccontextmanager
async def lifespan(app: FastAPI):
    """Uygulama başlatılırken veritabanını hazırla."""
    await init_db()
    _register_event_subscribers()
    scheduler_service.start()
    db_label = "SQLite" if _is_sqlite else "PostgreSQL"
    print(f"[START] KOBI AI Asistan Backend baslatildi! ({db_label}, {APP_ENV})")
    print("[API] Docs: http://localhost:8000/docs")
    yield
    scheduler_service.stop()
    print("[STOP] Backend kapatiliyor...")


# ─── FastAPI App ──────────────────────────────────────────────────────
app = FastAPI(
    title="KOBİ AI Asistan API",
    description=(
        "Türk KOBİ'leri için Çok-Ajanlı Otonom Finansal Zeka Sistemi.\n\n"
        "**Özellikler:**\n"
        "- Fatura/fiş tarama (Gemini Vision)\n"
        "- Stok yönetimi ve ABC analizi\n"
        "- Gelir-gider ve nakit akışı\n"
        "- KDV beyanname takibi\n"
        "- Puantaj ve maaş hesabı\n"
        "- AI asistan (doğal Türkçe sorgulama)\n"
        "- Proaktif uyarı sistemi\n"
        "- Sabah brifingi\n"
        "- E-Fatura üretimi (UBL-TR)"
    ),
    version="1.0.0",
    lifespan=lifespan,
)

# Rate limiter state
app.state.limiter = limiter


@app.exception_handler(RateLimitExceeded)
async def _rate_limit_handler(request: Request, exc: RateLimitExceeded):
    return JSONResponse(
        status_code=429,
        content={"detail": "Çok fazla istek gönderildi. Lütfen bekleyin."},
    )


# ─── CORS ─────────────────────────────────────────────────────────────
# Development: tüm origin'lere izin ver (Flutter web debug rastgele port kullanır)
_app_env = os.getenv("APP_ENV", "development")
if _app_env == "development":
    app.add_middleware(
        CORSMiddleware,
        allow_origins=["*"],
        allow_credentials=False,
        allow_methods=["*"],
        allow_headers=["*"],
    )
else:
    _cors_origins_raw = os.getenv("CORS_ORIGINS", "*")
    _cors_origins = (
        ["*"] if _cors_origins_raw == "*"
        else [o.strip() for o in _cors_origins_raw.split(",") if o.strip()]
    )
    app.add_middleware(
        CORSMiddleware,
        allow_origins=_cors_origins,
        allow_credentials=_cors_origins != ["*"],
        allow_methods=["*"],
        allow_headers=["*"],
    )


# ─── Router'ları Kaydet ───────────────────────────────────────────────
app.include_router(auth.router)
app.include_router(dashboard.router)
app.include_router(stock.router)
app.include_router(finance.router)
app.include_router(document.router)
app.include_router(chat.router)
app.include_router(hr.router)
app.include_router(alerts.router)
app.include_router(invoice.router)


# ─── Root Endpoint ────────────────────────────────────────────────────
@app.get("/api")
async def api_root():
    """API bilgi endpoint'i."""
    return {
        "name": "KOBİ AI Asistan API",
        "version": "1.0.0",
        "status": "active",
        "environment": APP_ENV,
        "database": "SQLite" if _is_sqlite else "PostgreSQL",
        "docs": "/docs",
        "endpoints": {
            "dashboard": "/api/v1/dashboard/summary",
            "stock": "/api/v1/stock/overview",
            "finance": "/api/v1/finance/pl",
            "document": "/api/v1/document/process",
            "chat": "/api/v1/chat",
            "hr": "/api/v1/hr/employees",
            "alerts": "/api/v1/alerts",
            "invoice": "/api/v1/invoice/generate",
        },
    }


@app.get("/health")
async def health():
    return {
        "status": "healthy",
        "database": "SQLite" if _is_sqlite else "PostgreSQL",
        "environment": APP_ENV,
    }


# ─── Flutter Web Static Serve ────────────────────────────────────────
# flutter build web sonrası build/web klasöründen serve eder.
# Böylece frontend ve backend aynı origin'de çalışır (CORS sorunu olmaz).
#
# Önemli: mount en sona konmalı — FastAPI önce /api/v1/... router'larını,
# sonra /health, /docs gibi tanımlı endpoint'leri dener.
# Eşleşmezse StaticFiles'a düşer (index.html = SPA fallback).
_flutter_web_dir = Path(__file__).resolve().parent.parent / "build" / "web"

if _flutter_web_dir.is_dir():
    # StaticFiles ile tüm Flutter web dosyalarını kök'ten serve et.
    # html=True → dizin istendiğinde index.html döner (SPA fallback).
    app.mount("/", StaticFiles(directory=str(_flutter_web_dir), html=True), name="flutter_web")
    print(f"[OK] Flutter web dosyalari serve ediliyor: {_flutter_web_dir}")
else:
    # Flutter build yoksa basit root endpoint
    @app.get("/")
    async def root():
        return {"message": "KOBİ AI Asistan API", "docs": "/docs", "build": "flutter build web çalıştırın"}
    print(f"[INFO] Flutter web build bulunamadi ({_flutter_web_dir}). 'flutter build web' calistirin.")
