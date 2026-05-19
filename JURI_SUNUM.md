# KOBİ AI Asistan - Jüri Sunum Dosyası

> **Türk KOBİ'leri için Çok-Ajanlı Otonom Finansal Zeka Sistemi**
>
> Fatura okuma, stok yönetimi, nakit akışı takibi, KDV beyanname desteği, puantaj yönetimi ve doğal dil ile işletme verisi sorgulama — hepsi tek bir AI destekli platformda.

---

## 1. Proje Özeti

**KOBİ AI Asistan**, Türkiye'deki küçük ve orta ölçekli işletmelerin günlük finansal ve operasyonel süreçlerini dijitalleştiren, yapay zeka destekli bir işletme yönetim platformudur.

Proje, **Google Gemini 2.5 Flash** modeli üzerine inşa edilmiş çok-ajanlı bir mimari kullanarak fatura/fiş okuma, stok takibi, nakit akışı yönetimi, KDV beyanname desteği, çalışan puantaj yönetimi ve doğal dil ile veri sorgulama gibi kritik iş süreçlerini tek bir platformda birleştirir.

**Temel Değer Önerisi:** KOBİ sahiplerinin muhasebeci, stokçu veya finans uzmanı olmadan, kendi işletme verilerini anlayabilmesi, analiz edebilmesi ve doğru kararlar alabilmesi.

| Özellik | Açıklama |
|---------|----------|
| **Platform** | Flutter Web + Mobile (cross-platform) |
| **Backend** | Python FastAPI (async) |
| **AI Motor** | Google Gemini 2.5 Flash |
| **Mimari** | Çok-Ajanlı ReAct Pattern |
| **Hedef Kitle** | Türk KOBİ'leri (bakkal, market, toptancı, atölye vb.) |

---

## 2. Problem Tanımı

Türkiye'deki 3.5 milyonun üzerindeki KOBİ, dijitalleşme sürecinde ciddi sorunlarla karşı karşıyadır:

### Belge Yönetimi Sorunu
- Fatura ve fişler kağıt ortamında kalıyor, dijitalleştirilemiyor
- Elle veri girişi hataya açık ve zaman kaybettiriyor
- Belgeler arşivlenemiyor, aranıp bulunamıyor

### Stok Kontrolü Sorunu
- Stok seviyeleri takip edilmiyor, kritik ürünler fark edilmiyor
- Tedarikçi karşılaştırması yapılamıyor
- Mevsimsel talep değişimleri öngörülemiyor, gereksiz stok maliyeti oluşuyor

### Finansal Görünürlük Sorunu
- Gelir-gider dengesi net olarak bilinmiyor
- Nakit akışı takip edilmiyor, beklenmedik nakit sıkışıkları yaşanıyor
- Gecikmiş ödemeler ve alacaklar kontrol altında tutulmuyor
- KDV beyanname tarihleri kaçırılıyor, cezai yaptırımlarla karşılaşılıyor

### Çalışan ve Puantaj Sorunu
- Kağıt puantaj tabloları dijitalleştirilemiyor
- Maaş hesaplamaları elle yapılıyor, hata riski yüksek
- SGK ve vergi kesintileri doğru hesaplanamıyor

### Karar Alma Sorunu
- İşletme sahibi, verilerine dayalı karar alamıyor
- Karmaşık raporlama araçlarını kullanamıyor
- Proaktif uyarılar bulunmuyor; sorunlar ancak kriz haline geldiğinde fark ediliyor

---

## 3. Çözüm Yaklaşımı

KOBİ AI Asistan, bu problemleri **yapay zeka destekli otonom ajan mimarisi** ile çözer:

### 3.1 AI Destekli Belge Okuma
Fatura, fiş veya puantaj belgesinin fotoğrafı sisteme yüklenir. Gemini Vision API belgeden yapılandırılmış veri çıkarır (ürün adları, miktarlar, fiyatlar, KDV oranları). Çıkarılan veri otomatik olarak stok, finans, KDV ve arşiv modüllerine dağıtılır.

### 3.2 Çok-Ajanlı Otonom Sistem
Tek bir monolitik AI yerine, **uzman ajanlar** koordineli çalışır:
- **Orkestratör Ajan**: Kullanıcı sorgusunu analiz eder, doğru ajanları seçer
- **Stok Ajanı**: ABC analizi, anomali tespiti, mevsimsellik analizi
- **Finans Ajanı**: P&L, nakit akışı, ödeme riski değerlendirmesi
- **Tahmin Ajanı**: 30/60/90 günlük birleşik projeksiyon
- **Tedarik Ajanı**: Kritik stokta otomatik sipariş taslağı
- **KDV Ajanı**: Beyanname özeti ve son tarih uyarıları
- **Uyarı Ajanı**: Proaktif bildirim üretimi

### 3.3 Doğal Dil ile Sorgulama
İşletme sahibi, teknik bilgi gerektirmeden doğal Türkçe ile sorular sorar:
- *"Bu ay en çok hangi ürüne harcama yaptım?"*
- *"Yaklaşan ödemelerim neler?"*
- *"Stok durumumu değerlendir"*

AI asistan, ReAct (Reasoning + Acting) döngüsü ile gerçek veritabanı verilerine erişir, birden fazla araç kullanarak çapraz analiz yapar ve Türkçe yanıt üretir.

### 3.4 Proaktif Uyarı ve Brifing Sistemi
Sistem, beklemek yerine **önceden harekete geçer**:
- Kritik stok düştüğünde otomatik uyarı ve sipariş taslağı
- KDV beyanname tarihi yaklaştığında hatırlatma
- Nakit açığı riski tespit edildiğinde bildirim
- Her sabah AI destekli işletme brifingi

---

## 4. Temel Özellikler

### 4.1 Dashboard (Ana Sayfa)
**Ne işe yarar:** İşletmenin günlük durumunu tek ekranda özetler.

**Kullanıcıya faydası:** Uygulamayı açtığında stok değeri, nakit bakiye, kritik stoklar, gecikmiş ödemeler ve KDV durumunu anında görür.

**Sistem verileri:** Stok servisi, finans servisi, uyarı sistemi ve AI brifingi bir araya getirilir. Dashboard API'si (`/api/v1/dashboard/summary`) tüm özet verileri tek çağrıda döndürür.

**Alt bileşenler:**
- Stat kartları (Stok Değeri, Nakit Bakiye, Kritik Stok, Bekleyen Ödeme)
- Sabah brifingi kartı (AI tarafından üretilen günlük özet)
- Kritik stok listesi
- Nakit akışı özeti
- AI önerileri kartı (proaktif tavsiyeler)
- Son işlenen belgeler

---

### 4.2 Belge / Fatura / Fiş Okuma
**Ne işe yarar:** Kağıt fatura veya fiş fotoğrafını yükleyerek otomatik dijitalleştirme sağlar.

**Kullanıcıya faydası:** Elle veri girişi ortadan kalkar. Belge yüklenir, AI okur, kullanıcı kontrol eder, onaylar. Tek belge ile stok, finans, KDV ve arşiv otomatik güncellenir.

**İş akışı:**
1. Kullanıcı belge yükler (JPEG, PNG, PDF, TIFF, WebP — maks 10 MB)
2. Gemini Vision API belgeyi analiz eder → yapılandırılmış JSON çıkarır
3. Fatura kaydı oluşturulur, kalemler ayrıştırılır
4. Eşleşen ürünlerin stoku güncellenir (alım → stok artırma, satış → stok düşme)
5. KDV kaydı oluşturulur (hesaplanan/indirilecek)
6. Nakit akışı kaydı oluşturulur
7. Kritik stok tespit edilirse uyarı ve sipariş taslağı oluşturulur

**Sistem verileri:** `Fatura`, `FaturaKalem`, `Urun`, `StokHareket`, `KdvKayit`, `NakitAkisi`, `Uyari` tabloları ile ilişkilidir.

---

### 4.3 Arşiv Yönetimi (Arşiv Defteri)
**Ne işe yarar:** İşlenen faturalar, e-faturalar ve belgelerin arşivlenip listelenmesini sağlar.

**Kullanıcıya faydası:** Geçmiş faturalara kolayca erişim, ödeme durumu takibi ve fatura arama imkanı sunar.

**Sistem verileri:** `Fatura` tablosundan `GET /api/v1/invoice/list` endpoint'i ile listelenir. Ödeme durumu güncellenebilir (`bekliyor`, `odendi`, `gecikti`).

---

### 4.4 AI Chat Asistanı
**Ne işe yarar:** İşletme verilerini doğal Türkçe ile sorgulamayı sağlar.

**Kullanıcıya faydası:** Karmaşık raporlama araçlarına ihtiyaç duymadan, konuşma diliyle işletme analizi yapabilir. Takip soruları ile derinleşebilir.

**Teknik detay:**
- **ReAct Pattern**: Düşün → Eylem (araç çağır) → Gözlem → Tekrar → Yanıt
- **18 farklı araç**: Stok durumu, kritik stok, ABC analizi, mevsimsellik, tedarikçi karşılaştırması, fiyat simülasyonu, P&L özeti, nakit akışı, KDV özeti, gecikmiş ödemeler, puantaj sorgusu, maaş hesaplama, AI raporlama araçları
- **Konuşma geçmişi**: 6 turn sliding window ile bağlam korunur
- **3 çalışma modu**:
  - **Dengeli**: Standart analiz (temperature: 0.7)
  - **Dikkatli**: Yalnızca doğrulanmış veriyle çalışır, güven aralığı verir (temperature: 0.3)
  - **Proaktif**: Ek araç çağrıları yapar, risk tarar, fırsat tespit eder (temperature: 0.8)
- **Çapraz analiz**: Stok ↔ Finans, Gecikmiş Ödeme ↔ Nakit, KDV ↔ Takvim, Devir Hızı ↔ Maliyet korelasyonları

**Sistem verileri:** Tüm veritabanı tablolarına araçlar üzerinden erişir. `ConversationStore` ile sohbet geçmişi yönetilir.

---

### 4.5 Stok Yönetimi
**Ne işe yarar:** Ürün envanteri, stok hareketleri, kritik stok takibi ve gelişmiş analizler sunar.

**Kullanıcıya faydası:** Hangi ürünün ne kadar kaldığını, hangisinin kritik seviyede olduğunu, devir hızını ve tedarikçi karşılaştırmalarını görür.

**Özellikler:**
- Stok genel durumu (toplam SKU, stok değeri, ortalama devir hızı)
- Kritik stok listesi (minimum seviyenin altındaki ürünler + kalan gün tahmini)
- ABC analizi (ürünleri ciro etkisine göre A/B/C gruplarına ayırma)
- Ürün bazlı detaylı analiz (hareket geçmişi, maliyet değişimi)
- Tedarikçi karşılaştırması (fiyat, teslim süresi, güvenilirlik skoru)
- Mevsimsellik analizi (aylık hareket pattern'ı)
- Fiyat simülasyonu (What-If: fiyat değişikliğinin stok eritme hızına etkisi)

**Sistem verileri:** `Urun`, `StokHareket`, `FiyatGecmisi`, `StokSayim`, `Tedarikci` tabloları.

---

### 4.6 Finans ve Nakit Akışı Takibi
**Ne işe yarar:** Gelir-gider dengesi, nakit akışı projeksiyonu, gecikmiş ödemeler ve fatura yönetimi sağlar.

**Kullanıcıya faydası:** İşletmenin finansal sağlığını anlık olarak görür. Nakit sıkışması önceden tespit edilir.

**Özellikler:**
- P&L (Kâr-Zarar) özeti — aylık gelir, gider, net kâr, kâr marjı
- Nakit akışı — giriş/çıkış takibi + 7/14/30/60/90 günlük projeksiyon
- Gecikmiş ödemeler — vade tarihi geçmiş faturaların listesi
- Son faturalar — gelir/gider akışı

**Sistem verileri:** `Fatura`, `FaturaKalem`, `NakitAkisi`, `KdvKayit` tabloları.

---

### 4.7 KDV Takibi
**Ne işe yarar:** Aylık KDV beyanname özetini sunar, hesaplanan/indirilecek KDV dengesini gösterir.

**Kullanıcıya faydası:** KDV yükümlülüğünü bilir, beyanname son tarihini kaçırmaz, ödenecek tutarı önceden planlar.

**Özellikler:**
- Hesaplanan KDV (satış faturaları)
- İndirilecek KDV (alım faturaları)
- Ödenecek KDV (net yükümlülük)
- Beyanname son tarihi ve kalan gün

**Sistem verileri:** `KdvKayit` tablosu, fatura bazlı otomatik KDV kaydı oluşturma.

---

### 4.8 Çalışan ve Puantaj Yönetimi
**Ne işe yarar:** Çalışan listesi, puantaj kaydı, maaş hesaplama ve bordro yönetimi sağlar.

**Kullanıcıya faydası:** Kağıt puantajı dijitalleştirir, maaş ve kesintileri otomatik hesaplar, bordro raporu alır.

**İş akışı (Analiz → Onay):**
1. Puantaj belgesi yüklenir veya demo çalıştırılır
2. Gemini AI belgeyi okur, çalışan/gün/mesai verilerini çıkarır
3. Sistem çalışanları eşleştirir, maaş ve kesintileri hesaplar (SGK %14, Gelir Vergisi %15)
4. Kullanıcı sonuçları inceler
5. Onay ile veriler DB'ye kaydedilir, nakit akışına maaş gideri eklenir
6. Sistemde bulunmayan çalışanlar otomatik oluşturulur

**Sistem verileri:** `Calisan`, `Puantaj` tabloları. Maaş ödemeleri `NakitAkisi` tablosuna yansır.

---

### 4.9 Proaktif Uyarılar
**Ne işe yarar:** Sistemin otomatik olarak risk ve fırsatları tespit edip kullanıcıyı bilgilendirmesi.

**Kullanıcıya faydası:** Sorunlar kriz haline gelmeden haberdar olur, erken aksiyon alabilir.

**Uyarı türleri:**
- `stok_kritik` — Ürün minimum seviyenin altına düştü
- `nakit_acik` — Belirli gün sonra nakit açığı riski
- `kdv_tarihi` — KDV beyanname son tarihi yaklaşıyor
- `odeme_hatirlatici` — Ödeme hatırlatma taslağı (tarihli)

**Uyarı kaynakları:**
- Belge işleme sırasında (stok düştüğünde)
- Periyodik kontroller (2 saatte bir stok, 6 saatte bir nakit, ayda bir KDV)
- Event Bus sistemi (STOK_KRITIK event'i → tedarik ajanı + uyarı ajanı tetiklenir)

**Dedup mekanizması:** Son 24 saat içinde aynı ürün/konu için mükerrer uyarı oluşturulmaz.

**Sistem verileri:** `Uyari` tablosu. Öncelik seviyeleri: `kritik`, `yuksek`, `normal`, `dusuk`.

---

### 4.10 Sabah Brifingi / İşletme Özeti
**Ne işe yarar:** Her gün otomatik olarak işletmenin günlük durumunu özetleyen AI destekli brifing üretir.

**Kullanıcıya faydası:** Uygulamayı açtığında 30 saniyede günün durumunu kavrar.

**Teknik detay:**
- Scheduler her sabah 03:00'te brifing üretir
- Veri kaynakları: kritik stoklar, nakit durumu, gecikmiş ödemeler, KDV son tarihi
- Gemini AI bu verileri sentezleyip Türkçe, samimi ama profesyonel bir brifing oluşturur
- `BriefCache` tablosunda günlük cache'lenir, böylece tekrar tekrar AI çağrısı yapılmaz

---

### 4.11 E-Fatura Üretimi
**Ne işe yarar:** UBL-TR 1.2 standardında e-fatura üretir; XML, QR kod ve PDF çıktısı sağlar.

**Kullanıcıya faydası:** Profesyonel e-fatura oluşturabilir, müşterilerine gönderebilir.

**Teknik detay:**
- UBL-TR 1.2 formatında XML üretimi (GİB uyumlu)
- QR kod (GİB doğrulama linki)
- ReportLab ile profesyonel PDF render
- Fatura kesildiğinde otomatik olarak: stok düşülür, nakit akışı güncellenir, event tetiklenir

---

### 4.12 Ayarlar ve Kullanıcı Deneyimi
**Ne işe yarar:** İşletme profili, AI ayarları, bildirim tercihleri, entegrasyon durumu ve güvenlik ayarlarını yönetir.

**Kullanıcıya faydası:** Sistemi kendi iş ihtiyaçlarına göre özelleştirebilir.

**Alt bölümler:**
- İşletme profili ayarları
- AI asistan yapılandırması
- Belge işleme tercihleri
- Bildirim ayarları
- Entegrasyon durumu
- Güvenlik ve veri yönetimi

---

## 5. Teknik Mimari

### 5.1 Genel Mimari Diyagramı

```
┌─────────────────────────────────────────────────────┐
│                    Kullanıcı                         │
└──────────────────────┬──────────────────────────────┘
                       │
┌──────────────────────▼──────────────────────────────┐
│          Flutter Web / Mobile Arayüz                 │
│  ┌─────────┐ ┌────────┐ ┌───────┐ ┌──────────────┐ │
│  │Dashboard│ │ Belgeler│ │ Stok  │ │AI Asistan    │ │
│  │  Page   │ │  Page   │ │ Page  │ │  Chat Page   │ │
│  └─────────┘ └────────┘ └───────┘ └──────────────┘ │
│  ┌─────────┐ ┌────────┐ ┌───────┐ ┌──────────────┐ │
│  │ Finans  │ │Puantaj │ │Uyarılar│ │  Ayarlar    │ │
│  │  Page   │ │  Page  │ │ Page  │ │   Page       │ │
│  └─────────┘ └────────┘ └───────┘ └──────────────┘ │
│                    Dio HTTP Client                    │
└──────────────────────┬──────────────────────────────┘
                       │ REST API (JSON)
┌──────────────────────▼──────────────────────────────┐
│              FastAPI Backend (Async)                  │
│  ┌──────────────────────────────────────────────┐   │
│  │            Router Katmanı                     │   │
│  │  dashboard │ stock │ finance │ document │     │   │
│  │  chat │ hr │ alerts │ invoice │ auth          │   │
│  └──────────────────────┬───────────────────────┘   │
│  ┌──────────────────────▼───────────────────────┐   │
│  │           Service Katmanı                     │   │
│  │  stock_service │ finance_service │            │   │
│  │  document_service │ invoice_service │         │   │
│  │  gemini_service │ conversation_service │      │   │
│  │  scheduler_service │ event_bus │ security     │   │
│  └──────────────────────┬───────────────────────┘   │
│  ┌──────────────────────▼───────────────────────┐   │
│  │            Ajan Katmanı                       │   │
│  │  orchestrator │ stock_agent │ finance_agent │ │   │
│  │  forecast_agent │ supply_agent │             │   │
│  │  alert_agent │ kdv_agent │ tool_registry     │   │
│  └──────────────────────┬───────────────────────┘   │
│  ┌──────────────────────▼───────────────────────┐   │
│  │          Prompt Katmanı                       │   │
│  │  orchestrator_prompt │ stock_agent_prompt │   │   │
│  │  finance_agent_prompt │ hr_agent_prompt │     │   │
│  │  supply_agent_prompt                          │   │
│  └──────────────────────────────────────────────┘   │
└──────────────────────┬──────────────────────────────┘
           ┌───────────┴───────────┐
┌──────────▼──────────┐ ┌─────────▼──────────┐
│   SQLAlchemy ORM    │ │  Gemini 2.5 Flash  │
│  ┌───────────────┐  │ │  ┌──────────────┐  │
│  │SQLite (dev)   │  │ │  │Vision API    │  │
│  │PostgreSQL(prod│  │ │  │Function Call  │  │
│  └───────────────┘  │ │  │Chat API      │  │
│                      │ │  └──────────────┘  │
└──────────────────────┘ └────────────────────┘
```

### 5.2 Flutter Frontend Mimarisi

**Feature-Based Klasör Yapısı:**
```
lib/
├── main.dart                    # Uygulama giriş noktası
├── app.dart                     # MaterialApp + Scaffold yapısı
├── core/
│   ├── constants/               # Renkler, stringler
│   ├── providers/               # Riverpod provider'lar
│   ├── routing/                 # Sayfa yönlendirme
│   ├── services/                # API servisi, chat storage
│   ├── theme/                   # Tema yapılandırması
│   └── utils/                   # Responsive helper, dosya indirme
├── features/
│   ├── dashboard/presentation/  # Ana sayfa + widget'lar
│   ├── documents/presentation/  # Belge işleme + widget'lar
│   ├── archive/presentation/    # Arşiv defteri
│   ├── stock/presentation/      # Stok yönetimi + widget'lar
│   ├── finance/presentation/    # Finans + widget'lar
│   ├── chat/presentation/       # AI asistan + widget'lar
│   ├── alerts/presentation/     # Uyarılar + widget'lar
│   ├── employees/presentation/  # Puantaj + widget'lar
│   └── settings/presentation/   # Ayarlar + widget'lar
└── shared/widgets/              # Paylaşılan UI bileşenleri
```

**Responsive UI Yaklaşımı:**
- `Responsive` utility sınıfı ile ekran genişliğine göre grid sistemi:
  - ≥1280px → 4 sütun (masaüstü)
  - ≥900px → 3 sütun (tablet yatay)
  - ≥620px → 2 sütun (tablet dikey)
  - <620px → 1 sütun (mobil)
- Sidebar navigasyon (masaüstü) / Bottom navigation (mobil)
- Mobil için özel stat strip ve action card widget'ları

**State Management:** Flutter Riverpod ile provider tabanlı durum yönetimi. `dashboardProvider`, `conversationIdProvider` gibi provider'lar ile veri akışı kontrol edilir.

**API İletişimi:** Dio HTTP client ile singleton `ApiService` üzerinden. Platform algılama ile akıllı base URL seçimi:
- Web debug → `localhost:8000`
- Web release → same-origin (CORS sorunu yok)
- Android emülatör → `10.0.2.2:8000`
- Environment override → `API_BASE_URL` dart-define

---

### 5.3 FastAPI Backend Mimarisi

**Router-Service Yapısı:**
```
backend/
├── main.py              # FastAPI uygulaması, CORS, lifespan
├── database.py          # SQLAlchemy modelleri + engine
├── routers/             # API endpoint'leri (9 router)
│   ├── dashboard.py     # /api/v1/dashboard/*
│   ├── stock.py         # /api/v1/stock/*
│   ├── finance.py       # /api/v1/finance/*
│   ├── document.py      # /api/v1/document/*
│   ├── chat.py          # /api/v1/chat/*
│   ├── hr.py            # /api/v1/hr/*
│   ├── alerts.py        # /api/v1/alerts/*
│   ├── invoice.py       # /api/v1/invoice/*
│   └── auth.py          # /api/v1/auth/*
├── services/            # İş mantığı katmanı
│   ├── stock_service.py
│   ├── finance_service.py
│   ├── document_service.py
│   ├── invoice_service.py
│   ├── gemini_service.py
│   ├── conversation_service.py
│   ├── scheduler_service.py
│   ├── event_bus.py
│   └── security.py
├── agents/              # AI ajan katmanı (7 ajan)
│   ├── orchestrator.py
│   ├── stock_agent.py
│   ├── finance_agent.py
│   ├── forecast_agent.py
│   ├── supply_agent.py
│   ├── alert_agent.py
│   ├── kdv_agent.py
│   └── tool_registry.py
└── prompts/             # AI prompt şablonları
    ├── orchestrator_prompt.py
    ├── stock_agent_prompt.py
    ├── finance_agent_prompt.py
    ├── hr_agent_prompt.py
    └── supply_agent_prompt.py
```

**Event Bus Sistemi:**
Modüller arası iletişim, async observer pattern ile sağlanır:

| Event | Tetikleyici | Subscriber |
|-------|------------|------------|
| `FATURA_ISLENDI` | Belge işleme | Loglama |
| `STOK_KRITIK` | Stok güncelleme | Tedarik ajanı + Uyarı ajanı |
| `STOK_GUNCELLENDI` | Stok hareketi | Loglama |
| `PUANTAJ_ISLENDI` | Puantaj onayı | Loglama |

**Scheduler (Arka Plan Zamanlayıcı):**
APScheduler ile 4 periyodik görev:

| Görev | Zamanlama | İşlev |
|-------|-----------|-------|
| Sabah Brifingi | Her gün 03:00 | AI ile günlük brifing üretimi |
| Kritik Stok Kontrolü | Her 2 saat | Stok seviyelerini tarayıp uyarı oluşturma |
| Nakit Projeksiyonu | Her 6 saat | Nakit akışı risk analizi |
| KDV Takvimi | Her ayın 1'i, 09:00 | KDV beyanname son tarihi uyarısı |

**Rate Limiting:** slowapi ile `60 istek/dakika` limiti. Aşıldığında Türkçe hata mesajı.

---

### 5.4 Frontend-Backend İletişimi

| Frontend Çağrısı | Backend Endpoint | Açıklama |
|-------------------|-----------------|----------|
| `getDashboardSummary()` | `GET /api/v1/dashboard/summary` | Tüm özet veriler |
| `getMorningBrief()` | `GET /api/v1/dashboard/morning-brief` | AI sabah brifingi |
| `processDocument()` | `POST /api/v1/document/process` | Fatura/fiş işleme |
| `sendChat()` | `POST /api/v1/chat` | AI asistan sorgusu |
| `getStockOverview()` | `GET /api/v1/stock/overview` | Stok genel durumu |
| `getPlSummary()` | `GET /api/v1/finance/pl` | Gelir-gider özeti |
| `getKdvSummary()` | `GET /api/v1/finance/kdv` | KDV beyanname özeti |
| `analyzeTimesheet()` | `POST /api/v1/hr/timesheet/analyze` | Puantaj analizi |
| `approveTimesheet()` | `POST /api/v1/hr/timesheet/approve` | Puantaj onayı |
| `getAlerts()` | `GET /api/v1/alerts` | Uyarı listesi |
| `generateEfatura()` | `POST /api/v1/invoice/generate` | E-fatura üretimi |

---

## 6. Kullanılan Teknolojiler

### Frontend

| Teknoloji | Sürüm | Kullanım Amacı |
|-----------|-------|----------------|
| **Flutter** | SDK ≥3.9.2 | Cross-platform UI framework |
| **Dart** | ≥3.9.2 | Programlama dili |
| **Dio** | ^5.7.0 | HTTP client — backend iletişimi |
| **Flutter Riverpod** | ^2.6.1 | State management |
| **fl_chart** | ^0.70.2 | Grafik ve chart bileşenleri |
| **image_picker** | ^1.1.2 | Kameradan/galeriden belge seçimi |
| **file_picker** | ^8.1.7 | Dosya seçimi (fatura yükleme) |
| **shared_preferences** | ^2.3.4 | Yerel depolama (chat geçmişi, ayarlar) |

### Backend

| Teknoloji | Sürüm | Kullanım Amacı |
|-----------|-------|----------------|
| **Python** | 3.x | Backend programlama dili |
| **FastAPI** | 0.115.12 | Async web framework |
| **SQLAlchemy** | 2.0.41 | Async ORM — veritabanı erişimi |
| **aiosqlite** | 0.21.0 | SQLite async driver (development) |
| **asyncpg** | 0.30.0 | PostgreSQL async driver (production) |
| **Pydantic** | 2.11.3 | Veri doğrulama ve serializasyon |
| **APScheduler** | 3.11.0 | Arka plan zamanlayıcı |
| **python-jose** | 3.3.0 | JWT token yönetimi |
| **slowapi** | 0.1.9 | Rate limiting |
| **python-dotenv** | 1.1.0 | Environment variable yönetimi |

### AI

| Teknoloji | Sürüm | Kullanım Amacı |
|-----------|-------|----------------|
| **Google Gemini** | 2.5 Flash | Ana AI modeli |
| **google-generativeai** | 0.8.5 | Gemini Python SDK |
| — | — | Vision API (belge okuma) |
| — | — | Function Calling (araç kullanımı) |
| — | — | Chat API (sohbet + ReAct) |

### E-Fatura / Raporlama

| Teknoloji | Sürüm | Kullanım Amacı |
|-----------|-------|----------------|
| **Jinja2** | 3.1.6 | UBL-TR XML template engine |
| **lxml** | 5.4.0 | XML işleme |
| **ReportLab** | 4.4.0 | PDF üretimi |
| **qrcode** | 8.0 | GİB doğrulama QR kodu |
| **Pillow** | 11.2.1 | Görsel işleme |

### Veritabanı

| Ortam | Teknoloji | Açıklama |
|-------|-----------|----------|
| **Development** | SQLite + aiosqlite | Kurulum gerektirmez, WAL mode |
| **Production** | PostgreSQL + asyncpg | Neon.tech üzerinden (bağlantı havuzu: 10+20) |

---

## 7. AI Entegrasyonu

AI, bu projede **sadece bir sohbet aracı değil**, sistemin sinir sistemidir. Her katmanda AI entegrasyonu bulunur:

### 7.1 Belge Anlama (Gemini Vision)
Fatura veya fiş fotoğrafı yüklenir. Gemini Vision API, belgedeki:
- Satıcı bilgileri (ad, VKN)
- Fatura numarası ve tarih
- Ürün kalemleri (ad, miktar, birim fiyat)
- KDV oranları ve tutarları
- Genel toplam ve para birimi

bilgilerini yapılandırılmış JSON formatında çıkarır. Bu veri doğrudan veritabanı kayıtlarına dönüştürülür.

**Güven skoru** ile AI'ın okuma güvenilirliği ölçülür. Okunamayan alanlar `null` olarak döner.

### 7.2 Puantaj Okuma (Gemini Vision)
Kağıt puantaj tablosu fotoğrafı yüklenir. Gemini:
- Dönem bilgisi (ay/yıl)
- Çalışan listesi
- Her çalışan için: çalışma günü, mesai saati, izin günü, rapor günü
- Günlük detay (X = çalıştı, - = izin, R = rapor)

bilgilerini JSON formatında çıkarır. Maaş ve kesinti hesaplamaları backend'de yapılır.

### 7.3 Çok-Ajanlı Orkestrasyon (ReAct Pattern)
Kullanıcı doğal dille soru sorduğunda:

```
Kullanıcı: "İşletmemin finansal durumunu değerlendir"
     │
     ▼
Orkestratör → DÜŞÜN: Kapsamlı analiz gerekiyor
     │
     ▼ Araç Çağrısı #1
     │ generate_financial_health_report()
     │     ├── get_pl_summary() → P&L verisi
     │     ├── get_cash_forecast() → Nakit projeksiyon
     │     ├── get_kdv_summary() → KDV durumu
     │     └── get_overdue_payments() → Gecikmiş ödemeler
     │
     ▼ Gözlem #1: Veriler toplandı
     │
     ▼ Araç Çağrısı #2 (Proaktif modda)
     │ get_critical_stock() → Stok-Finans çapraz analiz
     │
     ▼ Sentez
     │ AI tüm verileri birlikte değerlendirir,
     │ risk skoru verir, somut aksiyon önerir
     │
     ▼
Türkçe Analiz Raporu
```

### 7.4 Araç Seti (18 Function Calling Tool)

| Araç Adı | Açıklama |
|-----------|----------|
| `get_stock_status` | Genel stok durumu |
| `get_critical_stock` | Kritik seviyedeki ürünler |
| `get_product_movements` | Ürün stok hareketleri |
| `get_abc_analysis` | ABC stok analizi |
| `get_seasonality_pattern` | Mevsimsel eğilim analizi |
| `compare_suppliers` | Tedarikçi karşılaştırması |
| `simulate_price_change` | Fiyat değişikliği simülasyonu |
| `get_pl_summary` | Gelir-gider özeti |
| `get_cash_forecast` | Nakit akışı projeksiyonu |
| `get_overdue_payments` | Gecikmiş ödemeler |
| `get_kdv_summary` | KDV beyanname özeti |
| `get_employee_attendance` | Çalışan devam kaydı |
| `calculate_salary` | Maaş hesaplama |
| `generate_stock_report` | AI stok sağlık raporu |
| `generate_financial_health_report` | AI finansal sağlık raporu |
| `assess_payment_risk` | Ödeme riski analizi |
| `detect_stock_anomalies` | Stok anomali tespiti |
| `generate_combined_forecast` | 30 günlük birleşik tahmin |

### 7.5 Sabah Brifingi
Her gün, sistemdeki kritik stoklar, nakit durumu, gecikmiş ödemeler ve KDV takvimi verilerini toplayarak AI ile sentezlenen, samimi ama profesyonel bir günlük brifing üretilir. Brifing cache'lenir, gün boyunca tekrar AI çağrısı yapılmaz.

### 7.6 Proaktif AI Önerileri
`/api/v1/chat/suggestions` endpoint'i gerçek veritabanı verilerine dayalı proaktif öneriler üretir:
- Kritik stok için tedarik önerisi
- Gecikmiş ödemeler için hatırlatma önerisi
- ABC analizi bazlı C grubu ürün tasfiye önerisi
- Nakit açığı riski uyarısı

### 7.7 Konuşma Bağlamı ve Mod Desteği
- **Sliding window**: Son 6 konuşma turu (12 mesaj) bağlam olarak saklanır
- **Referans çözümleme**: "Bunu detaylandır", "peki bu ne anlama geliyor?" gibi takip soruları desteklenir
- **Araç bağlamı**: Kullanılan araçlar model yanıtına eklenerek bağlam korunur
- **3 mod**: Dengeli, Dikkatli, Proaktif — her mod farklı system instruction ve temperature kullanır

---

## 8. Veri Modeli ve İş Mantığı

### Veritabanı Modelleri

| Model | Tablo Adı | Sistemdeki Rolü |
|-------|-----------|-----------------|
| **Urun** | `urunler` | Ürün master verisi: SKU, isim, kategori, birim, min/max stok, tedarikçi, fiyat bilgileri, mevcut stok |
| **StokHareket** | `stok_hareketleri` | Her stok giriş/çıkışının kaydı: ürün, tarih, miktar, hareket tipi, kaynak belge, birim fiyat |
| **FiyatGecmisi** | `fiyat_gecmisi` | Ürün fiyatlarının tarihsel takibi: tedarikçi bazlı birim fiyat, para birimi (enflasyon analizi) |
| **StokSayim** | `stok_sayimlari` | Fiziki stok sayım kayıtları: beklenen vs fiili miktar, fark, sayım yapan |
| **Tedarikci** | `tedarikciler` | Tedarikçi bilgileri: isim, VKN, iletişim, ortalama teslim süresi, güvenilirlik skoru |
| **Fatura** | `faturalar` | Fatura kayıtları: numara, tarih, tür (satış/alım), tutarlar, KDV, ödeme durumu, vade, Gemini ham çıktısı |
| **FaturaKalem** | `fatura_kalemleri` | Fatura satırları: ürün adı, eşleşen ürün, miktar, fiyat, KDV oranı/tutarı |
| **Calisan** | `calisanlar` | Çalışan master verisi: ad, pozisyon, brüt maaş, işe giriş tarihi, aktiflik durumu |
| **Puantaj** | `puantaj` | Aylık puantaj kaydı: çalışma günü, mesai, izin, rapor, brüt/net maaş, SGK, gelir vergisi, onay durumu |
| **NakitAkisi** | `nakit_akisi` | Nakit giriş/çıkış kayıtları: tarih, giriş, çıkış, bakiye, açıklama, kategori, kaynak belge |
| **KdvKayit** | `kdv_kayitlari` | KDV kayıtları: fatura bazlı, tür (hesaplanan/indirilecek), oran, tutar, matrah, dönem |
| **Uyari** | `uyarilar` | Sistem uyarıları: tür, başlık, mesaj, öncelik, okundu/aksiyon durumu, ilgili entity |
| **BriefCache** | `brief_cache` | Sabah brifingi cache: tarih, brifing metni, kaynak veri JSON'ı |

### İlişki Diyagramı

```
Tedarikci ──┐
            ├── Urun ──┬── StokHareket
            │          ├── FiyatGecmisi
            │          └── StokSayim
            │
            └── Fatura ──┬── FaturaKalem ── Urun (nullable)
                         └── KdvKayit

Calisan ── Puantaj

NakitAkisi (bağımsız, kaynak_belge_id ile faturaya referans)
Uyari (bağımsız, ilgili_entity_tipi/id ile herhangi entity'ye referans)
BriefCache (bağımsız, günlük cache)
```

---

## 9. Kullanıcı Senaryoları

### Senaryo 1: Fatura Yükleme ve Otomatik İşleme

**Durum:** Mehmet Bey, küçük bir market işletiyor. Toptancıdan aldığı kahve ve çay faturasını sisteme yüklemek istiyor.

**Akış:**
1. Mehmet Bey, "Belge İşleme" ekranına gider
2. Faturanın fotoğrafını çeker veya dosya olarak yükler
3. Sistem faturayı Gemini Vision ile analiz eder:
   - Satıcı: Aroma Toptancılık
   - 3 kalem ürün tespit edilir (Türk Kahvesi, Filtre Kahve, Yeşil Çay)
   - KDV tutarları ayrıştırılır
4. Sonuçlar ekranda gösterilir (güven skoru: %95)
5. Sistem otomatik olarak:
   - Fatura kaydı oluşturur
   - Eşleşen ürünlerin stokunu artırır
   - KDV kaydı oluşturur (indirilecek KDV)
   - Nakit akışına gider kaydı ekler
6. Yeşil Çay kritik seviyeye düştüğünü fark ederse uyarı oluşturur

**Değer:** Tek fotoğraf ile 6 farklı işlem otomatik tamamlanır.

---

### Senaryo 2: Kritik Stok Uyarısı ve Tedarik Taslağı

**Durum:** Sistem 2 saatlik periyodik kontrolde "Türk Kahvesi 250g" ürününün minimum stok seviyesinin altına düştüğünü tespit eder.

**Akış:**
1. Scheduler `check_critical_stocks()` çalışır
2. "Türk Kahvesi 250g" — mevcut: 15, minimum: 50 olarak tespit edilir
3. Sistem otomatik olarak:
   - `stok_kritik` uyarısı oluşturur (öncelik: kritik)
   - Event Bus `STOK_KRITIK` olayını tetikler
   - Tedarik Ajanı devreye girer:
     - Varsayılan tedarikçiyi bulur
     - Sipariş miktarını hesaplar (max_stok hedefine göre)
     - Tahmini maliyeti hesaplar
     - Alternatif tedarikçi varsa karşılaştırır
     - Sipariş taslağı hazırlar
4. Kullanıcı uygulamayı açtığında dashboard'da ve uyarılar ekranında bilgilendirilir

**Değer:** Stok tükenme riski, kullanıcı farkına varmadan tespit edilip çözüm taslağı hazırlanır.

---

### Senaryo 3: AI Asistan ile Doğal Dil Sorgulama

**Durum:** Ayşe Hanım, bu ayki finansal durumunu anlamak istiyor.

**Akış:**
1. AI Asistan ekranını açar
2. Yazar: *"Bu ayın gelir-gider durumunu özetle"*
3. Orkestratör ReAct döngüsüne girer:
   - Araç #1: `get_pl_summary()` → Aylık gelir: 185.000 TL, gider: 142.000 TL
   - Sentez: "Net kâr 43.000 TL, kâr marjı %23.2"
4. Ayşe Hanım devam eder: *"Peki nakit sıkışması riski var mı?"*
5. Konuşma bağlamı korunur, orkestratör:
   - Araç #2: `get_cash_forecast()` → 30 günlük projeksiyon
   - Araç #3: `get_overdue_payments()` → 2 adet gecikmiş ödeme
   - Çapraz analiz: Gecikmiş tahsilatlar tahsil edilirse nakit pozisyon iyileşir
6. Ayşe Hanım: *"En riskli müşteri hangisi?"*
7. AI, önceki yanıttaki gecikmiş ödemeleri referans alarak, en yüksek tutarlı ve en uzun geciken müşteriyi belirler

**Değer:** Muhasebeci veya finans uzmanı olmadan, konuşma diliyle derinlemesine finansal analiz.

---

### Senaryo 4: Günlük İşletme Özeti (Sabah Brifingi)

**Durum:** Ali Bey her sabah uygulamayı açtığında günün durumunu kavramak istiyor.

**Akış:**
1. Sistem gece 03:00'te sabah brifingini hazırlar
2. Ali Bey uygulamayı açtığında dashboard'da gösterilir:
   - Nakit bakiye: 47.500 TL (pozitif)
   - 3 ürün kritik stokta — en acil: Filtre Kahve (3 gün kaldı)
   - 2 gecikmiş ödeme: toplam 12.800 TL
   - KDV beyanname tarihi: 7 gün kaldı, ödenecek: 8.200 TL
3. Stat kartları ile stok değeri, nakit bakiye, kritik stok sayısı ve bekleyen ödemeler tek bakışta görülür

**Değer:** 30 saniyede günün operasyonel durumu kavranır.

---

### Senaryo 5: Puantaj Yönetimi

**Durum:** Zeynep Hanım, atölyesindeki 8 çalışanının aylık puantaj tablosunu sisteme girmek istiyor.

**Akış:**
1. "Puantaj / Çalışanlar" ekranına gider
2. Kağıt puantaj tablosunun fotoğrafını yükler
3. Gemini AI tabloyu okur:
   - 8 çalışan tespit edilir
   - Her çalışan için çalışma günü, mesai, izin, rapor günleri çıkarılır
4. Sistem mevcut çalışanlarla eşleştirir
5. Brüt maaş üzerinden hesaplama yapar:
   - Mesai ücreti (1.5 kat)
   - SGK kesintisi (%14)
   - Gelir vergisi (%15)
   - Net maaş
6. Zeynep Hanım sonuçları inceler ve onaylar
7. Onay sonrası:
   - Puantaj kayıtları DB'ye yazılır
   - Nakit akışına maaş gideri eklenir
   - Sistemde bulunmayan yeni çalışan otomatik oluşturulur

**Değer:** Kağıt puantaj tablosu tek fotoğrafla dijitalleşir, maaş hesaplamaları otomatik yapılır.

---

## 10. Projenin Güçlü Yönleri

### Teknik Güçlü Yönler
- **Full-stack mimari**: Flutter frontend + FastAPI backend, tek ekip tarafından uçtan uca geliştirilmiş
- **Async-first tasarım**: Backend tamamen async (SQLAlchemy async, FastAPI async, aiosqlite/asyncpg)
- **Çok-ajanlı AI sistemi**: 7 uzmanlaşmış ajan, merkezi orkestrasyon, 18 araç
- **Event-driven mimari**: Event Bus ile modüller arası gevşek bağlı iletişim
- **Dual database desteği**: Development'ta SQLite, production'da PostgreSQL — sıfır kod değişikliği
- **Modüler ve genişletilebilir**: Yeni ajan, araç veya modül eklemek mevcut yapıyı bozmaz
- **Rate limiting ve güvenlik katmanı**: slowapi, JWT authentication, CORS kontrol
- **Responsive tasarım**: Masaüstü, tablet ve mobil uyumlu arayüz

### Ürün Güçlü Yönleri
- **Gerçek iş problemi çözümü**: KOBİ'lerin günlük yaşadığı somut sorunlara odaklanır
- **Düşük bariyerli kullanım**: Doğal dil ile sorgulama, belge yükleme ile otomatik işleme
- **Entegre modüller**: Stok + Finans + HR + KDV tek sistemde — veri siloları yok
- **Proaktif sistem**: Beklemek yerine önceden harekete geçen AI (uyarılar, brifing, sipariş taslağı)
- **Türkçe odaklı**: Tüm AI yanıtları, uyarılar ve arayüz Türkçe
- **Demo dostu**: Her modülde demo modu ile API key olmadan çalışabilme

---

## 11. Yenilikçi Yönler

Bu projeyi klasik muhasebe veya stok takip uygulamalarından ayıran noktalar:

### 1. AI Destekli Belge Anlama
Klasik sistemler: kullanıcı veriyi elle girer. Bu sistem: belge fotoğrafı yüklenir, AI okur, veri otomatik dağılır. **Tek belge ile 6 farklı tablo güncellenir.**

### 2. Doğal Dil ile İşletme Verisi Sorgulama
Klasik sistemler: önceden tanımlı raporlar. Bu sistem: kullanıcı istediği soruyu doğal dille sorar, AI gerçek veritabanı verilerine erişerek yanıt üretir. **Takip soruları ile derinleşme** desteklenir.

### 3. Çok-Ajanlı Otonom Karar Desteği
Klasik sistemler: pasif veri gösterimi. Bu sistem: ajanlar verileri çapraz analiz eder (stok ↔ finans ↔ KDV ↔ nakit), risk skorları üretir, somut aksiyon planları önerir.

### 4. Proaktif Uyarı ve Otonom Aksiyon
Klasik sistemler: kullanıcı kontrol etmezse sorun görülmez. Bu sistem: arka planda periyodik tarama yapar, risk tespit eder, uyarı oluşturur, sipariş taslağı hazırlar.

### 5. AI Sabah Brifingi
Her gün, AI tarafından üretilen kişiselleştirilmiş işletme brifingi — endüstride nadir bir özellik.

### 6. Farklı İş Süreçlerinin Tek Platformda Birleşimi
Stok + Finans + KDV + HR + Belge İşleme + AI Asistan + E-Fatura → **tek platform, tek veri tabanı, çapraz analiz imkanı**. KOBİ'lerin farklı yazılımlar arasında veri taşıma zorunluluğu ortadan kalkar.

---

## 12. Kurulum ve Çalıştırma

### Backend (Python / FastAPI)

```bash
# 1. Proje dizinine git
cd backend

# 2. Sanal ortam oluştur ve aktifleştir
python -m venv venv
source venv/bin/activate  # macOS/Linux
# venv\Scripts\activate   # Windows

# 3. Bağımlılıkları kur
pip install -r requirements.txt

# 4. Environment variable ayarla
# .env dosyası oluştur (veya export et):
# GEMINI_API_KEY=your_gemini_api_key_here
# DATABASE_URL=sqlite+aiosqlite:///./kobi_ai.db  (varsayılan)
# APP_ENV=development  (varsayılan)

# 5. Demo verilerini yükle (opsiyonel)
python seed_data.py
python seed_detailed_data.py
python seed_suppliers.py

# 6. Sunucuyu başlat
uvicorn main:app --reload --port 8000

# API Docs: http://localhost:8000/docs
```

### Frontend (Flutter)

```bash
# 1. Proje kök dizinine git
cd ..  # (backend'den çık)

# 2. Flutter bağımlılıklarını kur
flutter pub get

# 3. Web modunda çalıştır (geliştirme)
flutter run -d chrome

# 4. Web build al (production)
flutter build web

# 5. Build'ı backend ile serve et
# flutter build web sonrası build/web klasörü backend tarafından
# otomatik olarak serve edilir (same-origin, CORS sorunu yok)
```

### Ortam Değişkenleri

| Değişken | Varsayılan | Açıklama |
|----------|-----------|----------|
| `GEMINI_API_KEY` | — | Google Gemini API anahtarı (zorunlu, AI için) |
| `DATABASE_URL` | `sqlite+aiosqlite:///./kobi_ai.db` | Veritabanı bağlantı URL'i |
| `APP_ENV` | `development` | Ortam: `development` / `production` |
| `JWT_SECRET` | Otomatik üretilir | JWT token imzalama anahtarı |
| `CORS_ORIGINS` | `*` (dev) | Production CORS izinli origin'ler |
| `AUTH_DEMO_USER` | `demo` | Demo kullanıcı adı |
| `AUTH_DEMO_PASS` | `demo` | Demo şifre |

---

## 13. Canlı Demo ve Jüri İncelemesi

### Demo Akışı (Önerilen Sıra)

**1. Ana Dashboard (2 dk)**
- Uygulamayı açın, genel durumu gösterin
- Stat kartlarını işaret edin: Stok Değeri, Nakit Bakiye, Kritik Stok, Bekleyen Ödeme
- Sabah brifingi kartını okuyun — AI'ın günlük özeti nasıl ürettiğini anlatın

**2. Belge İşleme — Fatura Okuma (3 dk)**
- "Belge İşleme" ekranına geçin
- Bir fatura fotoğrafı yükleyin (veya demo modunu kullanın)
- AI'ın belgeyi nasıl okuduğunu, ürünleri, tutarları ve KDV'yi nasıl çıkardığını gösterin
- Stok, finans ve KDV modüllerinin otomatik güncellendiğini vurgulayın

**3. AI Asistan — Doğal Dil Sorgusu (3 dk)**
- "AI Asistan" ekranına geçin
- Örnek sorular sorun:
  - *"Bu ayın gelir-gider durumu nasıl?"*
  - *"Kritik stoktaki ürünleri listele"*
  - *"Nakit akışı tahmini yap"*
- ReAct düşünme adımlarını ve kullanılan araçları gösterin
- Takip sorusu ile bağlam korunumunu gösterin

**4. Stok Yönetimi (2 dk)**
- Stok genel durumu, kritik ürünler
- ABC analizi kartı
- Tedarikçi karşılaştırması

**5. Finans ve KDV (2 dk)**
- Gelir-gider özeti
- Nakit akışı ve projeksiyon
- KDV beyanname özeti

**6. Puantaj / Çalışanlar (2 dk)**
- Puantaj belgesi yükleme (veya demo)
- Analiz → onay akışını gösterin
- Maaş hesaplama detaylarını açıklayın

**7. Uyarılar ve Proaktif Sistem (1 dk)**
- Uyarılar ekranını açın
- Kritik stok, nakit açığı, KDV uyarılarını gösterin
- Event Bus ve scheduler mantığını kısaca anlatın

**8. E-Fatura Üretimi (1 dk)**
- Demo e-fatura üretimi
- PDF çıktısını gösterin

### Jüriye Özellikle Gösterilmesi Gereken Noktalar
- Tek belge yükleme ile 6 tablonun otomatik güncellenmesi
- AI asistanın gerçek veritabanı verileriyle çalışması (mock değil)
- ReAct düşünme adımlarının şeffaf gösterimi
- Proaktif uyarı sistemi ve event-driven mimari
- Responsive tasarımın farklı ekran boyutlarındaki davranışı

---

## 14. Güvenlik ve Üretim Ortamı Önerileri

### Mevcut Güvenlik Önlemleri
- JWT tabanlı kimlik doğrulama altyapısı hazırlanmıştır
- Rate limiting (60 istek/dakika) aktiftir
- CORS, production modda `CORS_ORIGINS` ile sınırlandırılabilir yapıdadır
- Pydantic ile giriş verisi doğrulaması yapılmaktadır
- Dosya yükleme: tür (MIME) ve boyut (10 MB) kontrolü mevcuttur

### Production Ortamı İçin Öneriler

| Alan | Mevcut Durum | Öneri |
|------|-------------|-------|
| **API Anahtarları** | `.env` dosyası ile yönetiliyor | Production'da environment variable veya secret manager kullanılmalı |
| **JWT Secret** | Development'ta her restart'ta yenileniyor | Production'da sabit `JWT_SECRET` tanımlanmalı |
| **SQLite dosyaları** | Repoda mevcut (`kobi_ai.db`) | `.gitignore`'a eklenmeli, production'da PostgreSQL kullanılmalı |
| **venv klasörü** | `.gitignore`'da zaten hariç tutuluyor | Doğru yapılandırılmış |
| **CORS** | Development'ta `allow_origins=["*"]` | Production'da spesifik origin'lerle sınırlandırılmalı |
| **Auth** | Demo kullanıcı hard-coded | Kullanıcı veritabanı ve bcrypt ile güçlendirilmeli |
| **Rate Limiting** | Temel seviyede aktif | IP bazlı ve endpoint bazlı ayrıntılı limitler eklenebilir |
| **Loglama** | Konsol loglama aktif | Yapılandırılmış log dosyası ve hata izleme (Sentry vb.) eklenebilir |
| **HTTPS** | Geliştirme ortamında HTTP | Production'da SSL/TLS zorunlu |
| **Input Sanitization** | Pydantic ile temel doğrulama | SQL injection için ek koruma katmanları değerlendirilebilir |

Bu öneriler, projenin hackathon aşamasından üretime geçiş sürecinde dikkate alınması gereken yapısal iyileştirmelerdir. Mevcut altyapı, bu geçişi kolaylaştıracak şekilde tasarlanmıştır.

---

## 15. Geliştirme Yol Haritası

### Kısa Vadeli (1-3 ay)
- Çoklu şirket desteği (multi-tenant)
- Rol bazlı yetkilendirme (admin, muhasebeci, çalışan)
- PDF ve Excel raporlama / dışa aktarma
- Gelişmiş arama ve filtreleme

### Orta Vadeli (3-6 ay)
- E-fatura GİB entegrasyonu (gerçek gönderim)
- Banka hareketleri otomatik eşleştirme
- WhatsApp / Telegram bildirim entegrasyonu
- Mobil push notification desteği
- Gerçek zamanlı dashboard (WebSocket)

### Uzun Vadeli (6-12 ay)
- Muhasebe programlarıyla entegrasyon (Luca, Logo, Mikro vb.)
- Çok dilli destek (İngilizce, Arapça)
- Abonelik / SaaS yapısı
- Gelişmiş AI: trend tahminleme, fiyat optimizasyonu, otomatik sipariş
- OCR + AI hibrit belge okuma (düşük kaliteli belgeler için)
- Marketplace entegrasyonları (Trendyol, Hepsiburada)

---

## 16. Jüri İçin Kısa Sunum Metni

> Sayın jüri üyeleri, merhabalar.
>
> KOBİ AI Asistan'ı sunmak istiyoruz. Türkiye'de 3.5 milyonun üzerinde KOBİ var ve büyük çoğunluğu hala kağıt faturalar, Excel tabloları ve dağınık süreçlerle çalışıyor. Stok ne zaman bitecek bilmiyorlar, nakit akışlarını tahmin edemiyorlar, KDV tarihlerini kaçırıyorlar.
>
> Biz bu sorunu yapay zeka ile çözen bir platform geliştirdik. Sistemimiz bir fatura fotoğrafı yüklediğinizde onu otomatik okur, stoku günceller, KDV'yi hesaplar ve nakit akışına yansıtır — tek seferde. Ama asıl güçlü tarafımız AI asistanımız. İşletme sahibi, doğal Türkçe ile "Bu ay ne kadar kazandım?", "Hangi ürünüm bitecek?", "Nakit sıkışması riski var mı?" gibi sorular sorabiliyor. Arkada 7 uzman AI ajanı, 18 farklı araç kullanarak gerçek veritabanı verileri üzerinde analiz yapıyor.
>
> Üstelik sistem proaktif: stok kritik seviyeye düştüğünde otomatik uyarı ve sipariş taslağı hazırlıyor. Her sabah AI destekli işletme brifingi üretiyor. KDV beyanname tarihi yaklaştığında hatırlatıyor.
>
> Flutter ile cross-platform arayüz, FastAPI ile async backend, Gemini 2.5 Flash ile AI — tamamı modern teknolojilerle geliştirilmiş, genişletilebilir bir mimari. Amacımız KOBİ'lere muhasebeci, stokçu veya finans uzmanı olmadan kendi işletmelerini anlayabilecekleri bir dijital asistan sunmak.
>
> Teşekkür ederiz.

---

## 17. Sonuç

**KOBİ AI Asistan**, Türkiye'deki küçük ve orta ölçekli işletmelerin dijitalleşme ihtiyacına yapay zeka odaklı, bütünleşik bir çözüm sunar.

Proje, yalnızca bir stok takip veya muhasebe yazılımı değildir. **Farklı iş süreçlerini tek platformda birleştiren, belge okumadan nakit tahmine, stok analizinden puantaj yönetimine kadar geniş bir yelpazede AI destekli otomasyon sağlayan bir işletme zekası sistemidir.**

**Teknik açıdan:**
- Çok-ajanlı ReAct mimarisi ile otonom karar desteği
- Gemini 2.5 Flash ile belge anlama, doğal dil sorgusu ve proaktif analiz
- Event-driven, async-first, modüler backend tasarımı
- Responsive, cross-platform frontend

**Ürün açıdan:**
- KOBİ'lerin gerçek problemlerine odaklı, düşük bariyerli kullanım
- Proaktif uyarı ve brifing sistemi ile "sorun olmadan önce haberdar ol" yaklaşımı
- Tek belge yükleme ile çoklu modül güncellemesi

Bu proje, hackathon aşamasının ötesinde, üretime hazır bir temel sunar. Modüler mimarisi, yeni özellik ve entegrasyon eklemek için açık bir kapı bırakır. KOBİ'lerin dijital dönüşümüne gerçek değer katacak bir platform olma potansiyeline sahiptir.

---

*Bu doküman, KOBİ AI Asistan projesinin jüri değerlendirmesi için hazırlanmıştır.*
*Proje kaynak kodu: [github.com/1ahmetonay/BTK](https://github.com/1ahmetonay/BTK)*
