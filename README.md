# KOBİ AI Asistan

Türk KOBİ'leri için çok-ajanlı otonom finansal zeka sistemi.

Fatura okuma, stok yönetimi, nakit akışı takibi, KDV beyanname desteği, puantaj yönetimi ve doğal dil ile işletme verisi sorgulama — hepsi tek bir AI destekli platformda.

**Canlı Demo:** [https://1ahmetonay.github.io/BTK/](https://1ahmetonay.github.io/BTK/)

---

## Proje Mimarisi

```
┌──────────────────────────┐     ┌──────────────────────────┐
│  Flutter Web Frontend    │────▶│  FastAPI Backend          │
│  (GitHub Pages)          │ API │  (Render)                 │
│  1ahmetonay.github.io/BTK│     │  kobi-ai-backend.onrender│
└──────────────────────────┘     └─────────┬────────────────┘
                                           │
                              ┌────────────┼────────────┐
                              ▼            ▼            ▼
                         PostgreSQL   Gemini 2.5    Scheduler
                         (Neon.tech)  Flash API     (APScheduler)
```

| Katman | Teknoloji | Konum |
|--------|-----------|-------|
| Frontend | Flutter Web (Dart) | GitHub Pages |
| Backend | FastAPI (Python, async) | Render |
| Database | PostgreSQL (production) / SQLite (dev) | Neon.tech |
| AI | Google Gemini 2.5 Flash | Google Cloud |

---

## Yerel Geliştirme

### Backend

```bash
cd backend
python -m venv venv
source venv/bin/activate    # macOS/Linux
# venv\Scripts\activate     # Windows

pip install -r requirements.txt

# .env dosyası oluştur (.env.example'dan kopyala)
cp .env.example .env
# GEMINI_API_KEY değerini düzenle

# Demo verilerini yükle
python seed_data.py
python seed_detailed_data.py
python seed_suppliers.py

# Sunucuyu başlat
uvicorn main:app --reload --port 8000
# API docs: http://localhost:8000/docs
```

### Frontend

```bash
# Proje kök dizininde
flutter pub get
flutter run -d chrome
```

Debug modda frontend otomatik olarak `http://localhost:8000`'e bağlanır.

---

## Production Deploy

### Backend → Render

1. [render.com](https://render.com) hesabı oluştur
2. "New Web Service" → GitHub reposunu bağla
3. Ayarlar:

| Ayar | Değer |
|------|-------|
| **Root Directory** | `backend` |
| **Build Command** | `pip install -r requirements.txt` |
| **Start Command** | `uvicorn main:app --host 0.0.0.0 --port $PORT` |

4. Environment Variables ekle:

| Değişken | Değer | Açıklama |
|----------|-------|----------|
| `APP_ENV` | `production` | Uygulama modu |
| `GEMINI_API_KEY` | `AIza...` | Google Gemini API anahtarı |
| `DATABASE_URL` | `postgresql+asyncpg://...` | Neon.tech bağlantı URL'i |
| `JWT_SECRET` | (otomatik üretilir) | JWT imzalama anahtarı |
| `CORS_ORIGINS` | `https://1ahmetonay.github.io` | İzinli frontend origin'leri |

5. Deploy et ve URL'i not al (ör: `https://kobi-ai-backend.onrender.com`)

6. Health check test:
```bash
curl https://kobi-ai-backend.onrender.com/health
# {"status":"healthy","database":"PostgreSQL","environment":"production"}
```

### Frontend → GitHub Pages

Backend deploy edildikten sonra Flutter'ı backend URL ile build et:

```bash
flutter build web --release \
  --base-href /BTK/ \
  --dart-define=API_BASE_URL=https://kobi-ai-backend.onrender.com
```

Build çıktısını GitHub Pages branch'ine pushla:

```bash
cd build/web
git init
git add .
git commit -m "Deploy frontend"
git remote add origin https://github.com/1ahmetonay/BTK.git
git push -f origin HEAD:gh-pages
```

Veya `gh-pages` npm paketi ya da GitHub Actions kullanılabilir.

---

## Environment Variables

| Değişken | Varsayılan | Açıklama |
|----------|-----------|----------|
| `GEMINI_API_KEY` | — | Google Gemini API anahtarı (zorunlu) |
| `DATABASE_URL` | `sqlite+aiosqlite:///./kobi_ai.db` | DB bağlantı URL'i |
| `APP_ENV` | `development` | `development` / `production` |
| `JWT_SECRET` | Otomatik üretilir | JWT token imzalama anahtarı |
| `CORS_ORIGINS` | GitHub Pages + localhost | Virgülle ayrılmış izinli origin'ler |
| `AUTH_DEMO_USER` | `demo` | Demo kullanıcı adı |
| `AUTH_DEMO_PASS` | `demo` | Demo şifre |

---

## CORS Açıklaması

Frontend (GitHub Pages) ve backend (Render) farklı domain'lerde çalışır. Backend, `CORS_ORIGINS` env var ile hangi origin'lerden gelen isteklere izin vereceğini belirler.

Varsayılan izinli origin'ler:
- `https://1ahmetonay.github.io` (production frontend)
- `http://localhost:3000`, `http://localhost:5000`, `http://localhost:8080`, `http://localhost:5173` (geliştirme)

Development modda (`APP_ENV=development`) tüm origin'lere izin verilir.

---

## API Test

```bash
# Health check
curl https://kobi-ai-backend.onrender.com/health

# API bilgisi
curl https://kobi-ai-backend.onrender.com/api

# Dashboard özeti
curl https://kobi-ai-backend.onrender.com/api/v1/dashboard/summary

# AI asistan
curl -X POST https://kobi-ai-backend.onrender.com/api/v1/chat \
  -H "Content-Type: application/json" \
  -d '{"message": "Stok durumumu özetle"}'
```
