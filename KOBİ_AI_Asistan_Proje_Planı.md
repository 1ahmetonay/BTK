# KOBİ AI Asistan — Tam Proje Planı

**Hazırlık Tarihi:** Mayıs 2026  
**Versiyon:** 1.0  
**Hedef:** Finans & E-Ticaret Odaklı AI Hackathon  
**Ekip Kullanımı İçin Hazırlanmıştır**

---

## İçindekiler

1. Proje Vizyonu ve Özeti
2. Problem Tanımı ve Pazar Analizi
3. Çözüm: Ne Yapıyoruz, Neden Özgün
4. Kesinlikle Olması Gereken Özellikler
5. Fark Yaratan Özellikler
6. Teknik Mimari
7. Gemini API Kullanım Planı
8. Agentic Yapı — ReAct ve Olay Zinciri
9. Stok Modülü — Tam Derinlik
10. Fatura İşleme ve E-Fatura
11. Puantaj Sistemi
12. Maliyet-Verim Analizi (20 Puan)
13. Mimari Tasarım Detayları (20 Puan)
14. Veritabanı Şeması
15. Platform ve Tech Stack
16. Neleri Ekleme
17. Hackathon Demo Stratejisi
18. Geliştirme Öncelik Sırası
19. Risk ve Dikkat Edilecekler

---

## 1. Proje Vizyonu ve Özeti

**Proje Adı:** KOBİ AI Asistan  
**Alt Başlık:** Türk KOBİ'leri için Çok-Ajanlı Otonom Finansal Zeka Sistemi

### Tek Cümle Özet
Fatura fotoğrafı çekip yükle — yapay zeka stoku günceller, KDV'yi hesaplar, nakit açığını önceden görür ve tedarikçiye otomatik teklif talebi gönderir.

### Temel Yaklaşım
Piyasadaki muhasebe yazılımlarının tamamı **reaktif**dir: kullanıcı veri girer, sistem kaydeder, kullanıcı rapor ister, sistem gösterir.

KOBİ AI Asistan **proaktif ve özerk**tir:
- Kullanıcı sormadan stok kritikleştiğinde uyarı verir ve çözüm sunar
- Fatura gelince tüm modülleri otomatik günceller
- Her sabah kendi kendine tüm verileri tarar, brifingi hazırlar
- Doğal Türkçe soru sorar, ajan veritabanından çekerek analiz yapar

---

## 2. Problem Tanımı ve Pazar Analizi

### Türkiye'deki KOBİ Gerçekleri

- Türkiye'de yaklaşık **3,2 milyon KOBİ** faaliyet gösteriyor
- Bu işletmelerin büyük çoğunluğu muhasebe yazılımı **kullanmıyor**
- Faturalar elle işleniyor, stok defterle veya kafadan takip ediliyor
- Vergi hesabı manuel yapılıyor veya muhasebeciye bırakılıyor
- Puantaj kağıda dolduruluyor, sonra elle bilgisayara aktarılıyor

### E-Fatura Zorunluluğu Baskısı

Türkiye Gelir İdaresi Başkanlığı (GİB) e-fatura kullanımını sürekli genişletiyor:
- Yıllık ciro **3 milyon TL üzeri** işletmeler B2B için e-Fatura kullanmak zorunda
- B2C işlemlerde **3.000 TL üzeri** faturalar e-Arşiv olarak kesilmeli
- E-ticaret yapan işletmeler için ciro eşiği **500.000 TL**
- Tüm faturalarda QR kod zorunlu (Eylül 2023'ten itibaren)
- Uyumsuzluk cezası: fatura değerinin **%10'u, minimum 2.200 TL**

### Kişisel Enflasyon Baskısı

2025 yılı boyunca Türkiye'de enflasyon %28,5 seviyesinde seyretti. Bu ortamda:
- Stok maliyetleri sürekli değişiyor, marjlar hızla eriyor
- Ne zaman stok yapmalı, ne zaman beklemelisin belli değil
- Aynı ürünü farklı tedarikçilerden farklı fiyatlarla alan KOBİ'ler maliyet kontrolü yapamıyor

### Pazar Büyüklüğü

- Türkiye fintech pazarı 2024'te 1,9 milyar dolar → 2033'te 7,2 milyar dolar hedefi
- KOBİ odaklı finansal yazılım segmenti bu büyümenin en hızlı komponenti
- Trendyol'da 300.000+ aktif satıcı, büyük çoğunluğu bu araçlara ihtiyaç duyuyor

---

## 3. Çözüm: Ne Yapıyoruz, Neden Özgün

### Ne Yapıyoruz

KOBİ AI Asistan, Google Gemini API üzerine kurulu, Google ADK ile orkestre edilen çok-ajanlı bir yapay zeka sistemidir. Sistemin merkezi Gemini Vision API'sidir — bu API sayesinde **herhangi bir formattaki belge** (buruşuk fiş, el yazılı irsaliye, PDF, WhatsApp ekran görüntüsü) anında yapılandırılmış veriye dönüşür.

### Rakiplerden Farkı

| Özellik | Geleneksel Muhasebe Yazılımı | KOBİ AI Asistan |
|---|---|---|
| Veri girişi | Manuel form | Fotoğraf çek → otomatik |
| Puantaj | Kağıt → elle giriş | Kağıt fotoğrafla → otomatik |
| Analiz | Statik rapor | Türkçe doğal dil sorgusu |
| Uyarı | Kullanıcı sorgu yapınca | Kullanıcı sormadan, sabah |
| Aksiyon | Sadece bilgi gösterir | Taslak hazırlar, onay ister |
| Stok zekası | Sayı takibi | Mevsimsellik, anomali, tahmin |
| Gemini entegrasyonu | Yok | Vision + Function Calling + ADK |

### Özgünlük Noktaları

**Çok-modlu belge zekası:** Gemini Vision hem fatura hem puantaj hem irsaliye hem de serbest format fişleri okur. Piyasadaki hiçbir KOBİ yazılımı bunu yapmıyor.

**ReAct agentic döngüsü:** Kullanıcı "bu ayın X ürünü analizini getir" dediğinde ajan sadece veri döndürmez. Önce hangi araçlara ihtiyacı olduğunu planlar, araçları sırayla çağırır, sonuçları gözlemler, eksik veri varsa başka araç çağırır, sonunda Türkçe analiz raporu üretir.

**Olay tetikleme zinciri:** Fatura yüklenir → Gemini okur → aynı anda 3 ajan tetiklenir (stok, KDV, nakit akışı) → stok kritikse tedarik ajanı devreye girer → tedarikçiye teklif taslağı hazırlanır → kullanıcıya onay için sunar.

**Sabah brifingi döngüsü:** Her sabah arka planda çalışır. Stok, nakit, gecikmiş ödemeler, vergi tarihleri — hepsi taranır, özetlenir, kullanıcı açtığında hazır bulur.

**Kağıt puantaj dijitalleştirme:** Devlet kurumları ve çoğu KOBİ puantajı hâlâ kağıtta tutuyor. Gemini Vision el yazısı puantaj tablolarını okur, çalışan adlarını, günleri, saatleri çıkarır, maaş hesabını yapar, gider kaydına düşürür.

---

## 4. Kesinlikle Olması Gereken Özellikler

### 4.1 Gemini Vision ile Belge Okuma

Her formattan yapılandırılmış veri çıkarımı:

```python
# Örnek API çağrısı
response = gemini_client.generate_content([
    image_part,  # fatura fotoğrafı
    """Bu faturayı analiz et ve şu JSON formatında döndür:
    {
      "satici_adi": "",
      "tarih": "",
      "kalemler": [{"urun": "", "miktar": 0, "birim_fiyat": 0, "kdv_orani": 0}],
      "toplam_kdv": 0,
      "genel_toplam": 0,
      "para_birimi": "TRY"
    }"""
])
```

Desteklenen belge türleri:
- Satın alma faturaları (her format)
- Satış fişleri
- İrsaliyeler
- Kargo/teslimat belgeleri
- Kağıt puantaj tabloları
- El yazılı notlar ve serbest format belgeler
- PDF, JPG, PNG, WebP

### 4.2 Stok Yönetimi

Ayrıntılar Bölüm 9'da. Özet:
- Fatura girince stok otomatik artar
- Satış faturasında otomatik düşüm
- Kritik eşik uyarıları
- ABC analizi
- Mevsimsellik takibi

### 4.3 Elektronik Fatura Üretimi

Sistemden e-fatura kesilebilir:
- Müşteri bilgileri ve ürün kalemleri girilir
- KDV otomatik hesaplanır
- UBL-TR XML formatında üretilir
- QR kod eklenir (GİB standardı)
- PDF olarak indirilir veya e-posta ile gönderilir

> **Not:** GİB'e gerçek-zamanlı gönderim hackathon kapsamı dışında tutulur. Teknik uyumluluk (UBL-TR format + QR kod) gösterilir.

### 4.4 Gelir-Gider ve KDV Takibi

- Her faturadan KDV otomatik ayrıştırılır
- Aylık KDV beyanname özeti çıkarılır
- P&L (kâr-zarar) tablosu otomatik oluşur
- Kategori bazlı gider analizi

### 4.5 Nakit Akışı Tahmini

- Geçmiş ödeme pattern'larından 30/60/90 günlük projeksiyon
- "X gün sonra Y TL açık oluşacak" uyarısı
- Gecikmiş ödemelerin nakit etkisi hesabı

### 4.6 Puantaj Sistemi

Ayrıntılar Bölüm 11'de. Özet:
- Kağıt puantaj fotoğrafı → Gemini Vision → dijital kayıt
- Mesai hesabı, izin takibi
- Maaş hesabı → gider kaydına otomatik düşüm
- Çalışan performans skoru (devamsızlık + mesai düzeni)

### 4.7 Türkçe Doğal Dil Analizi

Kullanıcı chat arayüzünde soru sorar:
- "Bu ayın en kârlı 5 ürününü listele"
- "Geçen Ramazan'a kıyasla bu Ramazan'da satışlar nasıl?"
- "Tedarikçi X ile Tedarikçi Y'nin fiyat karşılaştırmasını yap"
- "Önümüzdeki ay nakit sıkışması yaşar mıyım?"

Ajan ReAct döngüsüyle yanıtlar.

### 4.8 Proaktif Uyarı Sistemi

Kullanıcı sormadan gelen bildirimler:
- Stok kritik seviyeye düştü
- Gecikmiş ödeme tespit edildi
- Nakit açığı tahmini
- KDV beyanname tarihi yaklaşıyor
- Beklenden hızlı stok azalması (kayıp riski)

---

## 5. Fark Yaratan Özellikler

### 5.1 Sabah Brifingi Ajanı

Her sabah 03:00'te çalışan background agent:

```python
async def morning_briefing_agent():
    # Stok taraması
    critical_stock = await stock_agent.get_critical_items()
    # Nakit durumu
    cash_warnings = await finance_agent.check_30day_forecast()
    # Gecikmiş ödemeler
    overdue = await finance_agent.get_overdue_payments()
    # Vergi tarihleri
    tax_alerts = await tax_agent.get_upcoming_deadlines()
    # Orkestratör sentezler
    brief = await orchestrator.synthesize_morning_brief(
        critical_stock, cash_warnings, overdue, tax_alerts
    )
    await notification_service.push(brief)
```

Kullanıcı sabah uygulamayı açtığında hazır bir özet bulur.

### 5.2 Stok Analiz Anlatısı (Narrative Analysis)

Geleneksel yazılım sayı gösterir. Bu sistem hikaye anlatır:

> "Mart ayında X ürününde 340 adet hareket izlendi, Şubat'a göre %23 artış. Ancak ortalama satın alma maliyeti Ocak'tan bu yana %31 yükseldi — brüt marjın %18'den %12'ye gerilediğini gösteriyor. Mevsimsel veriler bu ürünün her yıl Nisan-Mayıs'ta talep artışı yaşadığını gösteriyor; stok düzeyini şimdiden güçlendirmek önerilir."

Hiçbir custom model eğitimi gerekmez. Gemini'nin domain bilgisi + iyi hazırlanmış araçlar yeterli.

### 5.3 What-If Simülasyonu

"Bu ürünü %15 indirim yaparsam stok kaç günde erir?"

Ajan geçmiş fiyat-talep elastikiyetini hesaplar, tahmini cevap verir.

### 5.4 Anomali Açıklaması

Stok beklenden hızlı azalırsa salt uyarı değil, 3 olası neden:
1. Dönemsel talep artışı (mevsimsel pattern eşleşiyor)
2. Veri girişi hatası (son sayımda tutarsızlık var)
3. Kayıp riski (son 2 haftada açıklanamayan düşüş)

### 5.5 Tedarikçi Performans Skoru

Her tedarikçi için:
- Ortalama teslim süresi
- Fiyat tutarlılığı (ne kadar sık fiyat değiştiriyor)
- Kalite skoru (o tedarikçiden gelen ürünlerin iade oranıyla ters korelasyon)

### 5.6 Toplu Belge İşleme

20 fatura fotoğrafını aynı anda yükle → Gemini hepsini paralel işler → 5 dakikada ay sonu kapanışı.

### 5.7 Enflasyon Maliyet Takibi

Her ürün için birim maliyet tarihçesi tutulur. Dashboard'da:
- "Bu ürünün maliyeti son 6 ayda %34 arttı"
- Enflasyona karşı optimal stok zamanlaması önerisi

---

## 6. Teknik Mimari

### 6.1 Genel Katman Yapısı

```
┌─────────────────────────────────────────┐
│         KULLANICI ARAYÜZÜ              │
│    Flutter Web (PWA) — Dashboard        │
│    Chat arayüzü + Belge yükleme         │
└──────────────┬──────────────────────────┘
               │ REST API
┌──────────────▼──────────────────────────┐
│           BACKEND                       │
│         FastAPI (Python)                │
│   Endpoint routing + Auth + Events      │
└──────────────┬──────────────────────────┘
               │
┌──────────────▼──────────────────────────┐
│         GEMINI API KATMANI              │
│  Gemini 2.5 Flash — Vision + FC + ADK  │
│  (Belge anlama · Ajan kararları · NLU)  │
└──────────────┬──────────────────────────┘
               │
┌──────────────▼──────────────────────────┐
│         AJAN KATMANI (Google ADK)       │
│  Orkestratör · Stok · Finans · KDV     │
│  HR/Puantaj · Tedarik · Uyarı · Tahmin │
└──────────────┬──────────────────────────┘
               │
┌──────────────▼──────────────────────────┐
│           VERİ KATMANI                  │
│      SQLite (hackathon)                 │
│     PostgreSQL (production)             │
└─────────────────────────────────────────┘
```

### 6.2 Ajan Listesi ve Sorumlulukları

| Ajan | Görevi | Tetiklenme |
|---|---|---|
| Orkestratör | Görev dağıtımı, ReAct yönetimi, sentez | Her istek |
| Belge Ajanı | Gemini Vision ile belge okuma, JSON çıkarımı | Belge yükleme |
| Stok Ajanı | Stok güncelleme, kritik tespiti, ABC analizi | Fatura + periyodik |
| Finans Ajanı | P&L, nakit akışı, ödeme takibi | Fatura + günlük |
| KDV Ajanı | KDV hesabı, beyanname özeti, uyarılar | Fatura + aylık |
| HR/Puantaj Ajanı | Puantaj okuma, maaş hesabı, performans | Puantaj yükleme |
| Tedarik Ajanı | Stok kritikse devreye girer, teklif hazırlar | Stok ajanı tetikler |
| Uyarı Ajanı | Push notification, öncelik sıralaması | Diğer ajanların çıktısı |
| Tahmin Ajanı | 30/60/90 günlük nakit + stok tahmini | Günlük background |

---

## 7. Gemini API Kullanım Planı

### 7.1 Hangi API'ler, Neden

**`gemini-2.5-flash` — Ana Model**
- Hızlı, ucuz, function calling desteğiyle ajan kararları için ideal
- Tüm ReAct döngüsü bu model üzerinde çalışır
- Türkçe doğal dil anlama yeteneği güçlü

**Gemini Vision (`inline_data`)**
- Fatura, fiş, puantaj, irsaliye okuma için
- Görüntü + metin prompt birlikte gönderilir
- Her türlü görsel formatta belge işleme

**File API**
- Büyük PDF'ler ve çok sayfalı belgeler için
- Dosya bir kez yüklenir, birden fazla sorguda kullanılır
- Toplu işlemde paralel sorgular için

### 7.2 Function Calling Tool Listesi

Gemini'nin çağırabileceği araçlar:

```python
tools = [
    # Stok araçları
    {
        "name": "get_product_movements",
        "description": "Belirtilen ürünün stok giriş/çıkış geçmişini döndürür",
        "parameters": {"sku": str, "start_date": str, "end_date": str}
    },
    {
        "name": "get_stock_levels",
        "description": "Tüm ürünlerin güncel stok seviyelerini döndürür",
        "parameters": {"category": str, "critical_only": bool}
    },
    {
        "name": "get_abc_analysis",
        "description": "ABC stok analizini döndürür",
        "parameters": {"period_months": int}
    },
    # Finans araçları
    {
        "name": "get_pl_summary",
        "description": "Gelir-gider özeti döndürür",
        "parameters": {"month": int, "year": int}
    },
    {
        "name": "get_cash_forecast",
        "description": "30/60/90 günlük nakit akışı tahmini",
        "parameters": {"days": int}
    },
    {
        "name": "get_overdue_payments",
        "description": "Gecikmiş ödemeleri döndürür",
        "parameters": {"days_overdue_min": int}
    },
    # KDV araçları
    {
        "name": "get_kdv_summary",
        "description": "Aylık KDV beyanname özeti",
        "parameters": {"month": int, "year": int}
    },
    # Stok analiz araçları
    {
        "name": "get_seasonality_pattern",
        "description": "Ürünün mevsimsel satış pattern'ını analiz eder",
        "parameters": {"sku": str, "years": int}
    },
    {
        "name": "compare_suppliers",
        "description": "Aynı ürün için tedarikçi karşılaştırması",
        "parameters": {"sku": str}
    },
    {
        "name": "simulate_price_change",
        "description": "Fiyat değişikliğinin stok eritme hızına etkisini simüle eder",
        "parameters": {"sku": str, "price_change_pct": float}
    },
    # Puantaj araçları
    {
        "name": "get_employee_attendance",
        "description": "Çalışan devam/devamsızlık kaydını döndürür",
        "parameters": {"employee_id": str, "month": int, "year": int}
    },
    {
        "name": "calculate_salary",
        "description": "Puantaj verisinden maaş hesaplar",
        "parameters": {"employee_id": str, "month": int, "year": int}
    },
]
```

### 7.3 Gemini API Maliyet Hesabı

Tipik kullanım senaryosu (5 kişilik KOBİ, aylık):

| İşlem | Miktar | Token Tahmini | Maliyet |
|---|---|---|---|
| Fatura/fiş görsel okuma | 330 belge | ~1.000 token/belge | ~$0.33 |
| Doğal dil sorguları | 200 sorgu | ~2.000 token/sorgu | ~$0.20 |
| Arka plan ajan döngüleri | 30 çalışma | ~3.000 token/çalışma | ~$0.09 |
| Sabah brifingleri | 22 gün | ~4.000 token/gün | ~$0.04 |
| **Toplam** | | | **~$0.66 ≈ 22 TL/ay** |

**Gemini 2.5 Flash fiyatı:** ~$0.075/1M input token, ~$0.30/1M output token  
Bu maliyet rakamı, sağladığı tasarrufla kıyaslandığında önemsizdir (bkz. Bölüm 12).

---

## 8. Agentic Yapı — ReAct ve Olay Zinciri

### 8.1 ReAct Pattern Nedir ve Neden Önemli

Standart LLM kullanımı: soru gel → cevap ver → biter.

ReAct (Reason + Act) pattern:

```
Girdi → [DÜŞÜN] Hangi araçlara ihtiyacım var, plan yap
      → [AKSIYON] Araç 1'i çağır
      → [GÖZLEMLE] Sonuç yeterli mi?
           → Hayır: [DÜŞÜN] Başka araç lazım
                  → [AKSIYON] Araç 2'yi çağır
                  → [GÖZLEMLE] Şimdi yeterli mi?
           → Evet: [YANIT] Türkçe rapor üret + aksiyonlar
```

Bu döngü, sistemin "akıllı" davranmasının temelidir. Kullanıcı "bu ayın X ürünü analizini getir" dediğinde:

1. Gemini planlar: "Hareket geçmişi lazım, fiyat trendi lazım, mevsimsel kıyaslama lazım"
2. `get_product_movements()` → data alır
3. `get_price_history()` → data alır  
4. `compare_same_period_last_year()` → data alır
5. Gözlemler: "Fiyat artışı dikkate değer, mevsimsel data tutarsız, bir de tedarikçi karşılaştırması çekeyim"
6. `compare_suppliers()` → data alır
7. Yeterli: Türkçe analiz raporu üretir

### 8.2 Olay Tetikleme Zinciri

Fatura yüklendiğinde:

```
Fatura yüklendi
     │
     ▼
Gemini Vision — JSON çıkarımı
     │
     ├──► Stok Ajanı → stok güncellenir
     │         │
     │         └──► Kritik seviye kontrolü
     │                   │
     │                   └──► Kritikse: Tedarik Ajanı tetiklenir
     │                              │
     │                              └──► Tedarikçiye teklif taslağı hazırla
     │                                         │
     │                                         └──► Kullanıcı onayı bekle
     │
     ├──► KDV Ajanı → beyanname güncellenir
     │
     └──► Nakit Ajanı → projeksiyon güncellenir
```

Bu zincir **kullanıcı müdahalesi olmadan** çalışır. Her adım bir öncekinin çıktısını alır.

### 8.3 Sabah Brifingi (Background Loop)

Her sabah 03:00'te çalışan `APScheduler` job:

```python
@scheduler.scheduled_job('cron', hour=3, minute=0)
async def morning_briefing():
    results = await asyncio.gather(
        stock_agent.scan_critical_items(),
        finance_agent.check_30day_cash_forecast(),
        finance_agent.get_overdue_payments(),
        tax_agent.get_upcoming_deadlines(),
        hr_agent.check_late_timesheets()
    )
    brief = await orchestrator.synthesize_brief(results)
    await push_notification(brief)
```

Örnek sabah brifingi çıktısı:

> "Günaydın. Bu sabah 3 öncelikli konu: **Stok** — Ürün X kritik seviyeye indi (12 adet kaldı, 4 günlük stok), Tedarikçi A'ya teklif talebi taslağı hazırladım. **Nakit** — 14 gün sonra 42.000 TL açık tahmini, Ahmet Usta'nın 9 günlük geciken ödemesi için hatırlatma gönderdim. **KDV** — Bu ay beyanname tutarı 18.400 TL, son gün 26 Mayıs."

### 8.4 Google ADK Entegrasyonu

```python
from google.adk import Agent, Orchestrator, ToolRegistry

# Araçları kaydet
registry = ToolRegistry()
registry.register_all(tools)  # Bölüm 7.2'deki tool listesi

# Ajanları tanımla
stock_agent = Agent(
    name="stok_ajani",
    model="gemini-2.5-flash",
    tools=registry.get_subset(["stok", "tedarik"]),
    system_prompt=STOCK_AGENT_PROMPT
)

finance_agent = Agent(
    name="finans_ajani",
    model="gemini-2.5-flash",
    tools=registry.get_subset(["finans", "kdv"]),
    system_prompt=FINANCE_AGENT_PROMPT
)

# Orkestratör
orchestrator = Orchestrator(
    agents=[stock_agent, finance_agent, hr_agent, tax_agent, supply_agent],
    model="gemini-2.5-flash",
    react_loop=True,  # ReAct pattern aktif
    max_iterations=5
)
```

---

## 9. Stok Modülü — Tam Derinlik

### 9.1 Veri Girişi (5 Kanal)

**Kanal 1 — Fatura Tarama (Birincil):**
Satın alma faturası yüklenir → Gemini Vision her kalemi okur → stok otomatik artar. Kullanıcı hiçbir şey yazmaz.

**Kanal 2 — Satış Otomasyonu:**
E-fatura kesildiğinde ilgili ürünlerin stoğu otomatik düşer. Ayrıca Trendyol/Hepsiburada satışları mock API ile sync edilebilir.

**Kanal 3 — Manuel Giriş:**
Ürün adı veya barkod ile hızlı giriş. Kamera ile barkod okuma tarayıcı üzerinden çalışır.

**Kanal 4 — Toplu Import:**
Excel/CSV upload. Başlangıç sayımı veya sistem göçü için.

**Kanal 5 — Fiziksel Sayım Modu:**
Ürün ürün sayım yapılır, sistem beklenen ile karşılaştırır. Fark varsa anomali kaydı açılır.

### 9.2 Stok Veri Modeli

```sql
-- Ürün master tablosu
CREATE TABLE urunler (
    id INTEGER PRIMARY KEY,
    sku TEXT UNIQUE NOT NULL,
    isim TEXT NOT NULL,
    kategori TEXT,
    birim TEXT DEFAULT 'adet',
    min_stok INTEGER DEFAULT 0,
    max_stok INTEGER,
    varsayilan_tedarikci_id INTEGER,
    son_satis_fiyati REAL,
    son_alis_maliyeti REAL,
    aktif BOOLEAN DEFAULT TRUE,
    olusturma_tarihi TIMESTAMP DEFAULT NOW()
);

-- Stok hareket tablosu (tüm giriş/çıkışlar)
CREATE TABLE stok_hareketleri (
    id INTEGER PRIMARY KEY,
    urun_id INTEGER REFERENCES urunler(id),
    tarih TIMESTAMP DEFAULT NOW(),
    miktar REAL NOT NULL,           -- pozitif=giriş, negatif=çıkış
    hareket_tipi TEXT,              -- 'satin_alma', 'satis', 'iade', 'sayim', 'duzeltme'
    kaynak_belge_id INTEGER,        -- fatura veya puantaj id
    birim_fiyat REAL,               -- o andaki birim fiyat
    aciklama TEXT
);

-- Fiyat geçmişi (enflasyon takibi için kritik)
CREATE TABLE fiyat_gecmisi (
    id INTEGER PRIMARY KEY,
    urun_id INTEGER REFERENCES urunler(id),
    tedarikci_id INTEGER,
    tarih DATE,
    birim_fiyat REAL,
    para_birimi TEXT DEFAULT 'TRY'
);

-- Periyodik sayım kayıtları
CREATE TABLE stok_sayimlari (
    id INTEGER PRIMARY KEY,
    urun_id INTEGER REFERENCES urunler(id),
    sayim_tarihi DATE,
    beklenen_miktar REAL,
    fiili_miktar REAL,
    fark REAL,
    sayim_yapan TEXT
);
```

### 9.3 Stok Görselleştirme

Dashboard bileşenleri:

1. **Stok Durum Özeti:** Her ürün için renk kodlu bar (kırmızı = kritik, sarı = uyarı, yeşil = normal)
2. **Hareket Grafiği:** Seçilen ürünün zaman serisi (giriş mavi, çıkış kırmızı)
3. **ABC Analizi:** Donut chart — A grubu ürünler cironun %80'ini oluşturuyor
4. **Enflasyon Etkisi:** Her ürünün 6 aylık maliyet değişimi grafiği
5. **Tedarikçi Karşılaştırma:** Aynı ürün için farklı tedarikçilerin yan yana fiyat tablosu

### 9.4 LLM Analiz — Custom Model Gerekmez

Gemini zaten finans ve stok yönetimi bilgisine sahip. İhtiyacı olan sadece işletmenin kendi verisi. Bu veri function calling araçlarıyla sağlanır.

Örnek sorgu akışı:

```
Kullanıcı: "Bu ayın X ürünü analizini getir"

Gemini düşünür:
  → Plan: hareket geçmişi + fiyat trendi + mevsimsel kıyaslama + tedarikçi analizi

Adım 1: get_product_movements(sku='X', months=1) → çağır
Adım 2: get_price_history(sku='X', months=6) → çağır
Adım 3: compare_same_period_last_year(sku='X') → çağır
Adım 4: Gözlem: "Fiyat artışı dikkat çekici, tedarikçi de kontrol edilmeli"
Adım 5: compare_suppliers(sku='X') → çağır
Adım 6: Yeterli veri var → Türkçe analiz raporu üret
```

Çıktı: Detaylı, hikaye biçiminde Türkçe analiz.

---

## 10. Fatura İşleme ve E-Fatura

### 10.1 Fatura Okuma Pipeline

```
Belge Yüklendi (görüntü/PDF)
     │
     ▼
Gemini Vision API
     │
     ▼
JSON Çıktısı:
{
  "belge_tipi": "satin_alma_faturasi",
  "satici_adi": "...",
  "satici_vkn": "...",
  "fatura_no": "...",
  "tarih": "YYYY-MM-DD",
  "kalemler": [
    {
      "urun_adi": "...",
      "sku": "...",  // eşleştirilebilirse
      "miktar": 50,
      "birim": "adet",
      "birim_fiyat": 125.00,
      "kdv_orani": 20,
      "kdv_tutari": 1250.00,
      "satir_toplam": 7500.00
    }
  ],
  "toplam_kdv": 1250.00,
  "genel_toplam": 7500.00,
  "para_birimi": "TRY",
  "guven_skoru": 0.94  // Gemini'nin okuma güveni
}
     │
     ▼
Stok güncellemesi
KDV kaydı
Nakit akışı güncellemesi
Tedarikçi kaydı güncelleme
```

### 10.2 E-Fatura Üretimi

Türk vergi mevzuatı gereksinimleri:
- Format: UBL-TR 1.2 (XML)
- Dijital imza zorunlu (production'da mali mühür gerekir)
- QR kod zorunlu (Eylül 2023'ten)
- 10 yıl arşivleme zorunluluğu
- B2B için GİB platformuna gönderim

Hackathon implementasyonu:
- UBL-TR formatında doğru XML üretimi gösterilir
- QR kod eklenir
- PDF render edilir
- "GİB'e gönder" butonu UI'da mock olarak gösterilir

```python
def generate_efatura_xml(invoice_data: dict) -> str:
    """UBL-TR 1.2 formatında e-fatura üretir"""
    template = load_template('ubl_tr_template.xml')
    qr_code = generate_qr_code(invoice_data)
    xml = template.render(
        invoice=invoice_data,
        qr_code=qr_code,
        uuid=str(uuid4()),
        issue_date=datetime.now()
    )
    return xml
```

---

## 11. Puantaj Sistemi

### 11.1 Neden Puantaj

Türkiye'deki devlet kurumları ve KOBİ'lerin büyük çoğunluğu puantajı kağıda tutar. Kağıt puantaj sonra elle sisteme girilir — bu ciddi zaman kaybı ve hata kaynağı.

Gemini Vision bu kağıtları okur. Bu, sistemin ikinci büyük "wow moment"i.

### 11.2 Kağıt Puantaj Okuma

```
Kağıt puantaj fotoğrafı yüklendi
     │
     ▼
Gemini Vision:
"Bu puantaj tablosunu analiz et ve şu JSON formatında döndür:
{
  'donem': {'ay': 5, 'yil': 2026},
  'calısanlar': [
    {
      'isim': 'Ahmet Yılmaz',
      'gunler': {'1': 'X', '2': 'X', '3': '-', ...},  // X=çalıştı, -=izin/tatil
      'toplam_calısma_gunu': 20,
      'mesai_saatleri': 8,
      'izin_gunu': 2
    }
  ]
}"
     │
     ▼
Dijital kayıt oluşturulur
Maaş otomatik hesaplanır
Gider kaydına düşürülür
```

### 11.3 Maaş Hesaplama

```python
def calculate_monthly_salary(employee_id: int, month: int, year: int) -> dict:
    attendance = get_attendance_record(employee_id, month, year)
    
    base_salary = get_employee_base_salary(employee_id)
    daily_rate = base_salary / 30
    
    net_salary = (
        attendance['working_days'] * daily_rate
        + attendance['overtime_hours'] * (daily_rate / 8) * 1.5
        - attendance['unpaid_leave_days'] * daily_rate
    )
    
    # SGK ve gelir vergisi kesintileri
    deductions = calculate_deductions(net_salary)
    
    return {
        'brut_maas': net_salary,
        'net_maas': net_salary - deductions['total'],
        'sgk_isci': deductions['sgk'],
        'gelir_vergisi': deductions['income_tax'],
        'kesintiler': deductions
    }
```

### 11.4 Performans Skoru

Her çalışan için aylık performans skoru:

```python
def calculate_performance_score(employee_id: int) -> float:
    # Devam/devamsızlık skoru (%40 ağırlık)
    attendance_score = get_attendance_rate(employee_id, months=3)
    
    # Mesai düzeni skoru (%30 ağırlık)  
    punctuality_score = get_punctuality_rate(employee_id, months=3)
    
    # Satış/üretim verisi varsa (%30 ağırlık)
    productivity_score = get_productivity_metric(employee_id, months=3)
    
    return (
        attendance_score * 0.4
        + punctuality_score * 0.3
        + productivity_score * 0.3
    )
```

---

## 12. Maliyet-Verim Analizi (20 Puan)

### 12.1 Referans KOBİ Profili

- 5 çalışan
- Günde 15 fatura/fiş işleme
- Aylık 5 müşteri faturası kesme
- 30 ürün SKU takibi
- Aylık muhasebeci maliyeti: 5.000–8.000 TL

### 12.2 Zaman Tasarrufu Hesabı

| Görev | Önceki Süre | Sistemle | Aylık Tasarruf |
|---|---|---|---|
| Fatura/fiş okuma ve girişi | 12 dk/belge × 330 = 66 saat | 30 dk (toplu) | 65,5 saat |
| Puantaj girişi | 30 dk/çalışan × 5 = 2,5 saat | 10 dk (scan) | 2,3 saat |
| Aylık mali rapor | 4 saat | Otomatik | 4 saat |
| KDV hesabı | 2 saat | Otomatik | 2 saat |
| Stok kontrol | 3 saat/hafta = 12 saat | Dashboard | 10 saat |
| **Toplam** | | | **~83,8 saat/ay** |

Saatlik değer hesabı (asgari ücret: 22.104 TL/ay ÷ 180 saat = 123 TL/saat):

**Tasarruf edilen işgücü:** 83,8 saat × 123 TL = **10.307 TL/ay**

### 12.3 Muhasebeci Maliyeti Azalması

Sistemin otomatize ettiği işler muhasebeci iş yükünü %60–70 oranında düşürür:
- Ortalama muhasebeci maliyeti: 6.000 TL/ay
- Azalma: 4.200 TL/ay

### 12.4 Hata Maliyeti Önleme

| Risk | Olasılık (önceki) | Maliyet | Yıllık Beklenen Kayıp |
|---|---|---|---|
| KDV yanlış hesap cezası | %30/yıl | 5.000 TL+ | 1.500 TL |
| Stok sayım hatası | %50/yıl | 2.000 TL | 1.000 TL |
| Geciken fatura kaçırılan indirim | %40/yıl | 3.000 TL | 1.200 TL |
| **Toplam** | | | **3.700 TL/yıl** |

### 12.5 Toplam ROI

| Kalem | Aylık Tutar |
|---|---|
| İşgücü tasarrufu | +10.307 TL |
| Muhasebeci azalması | +4.200 TL |
| Hata maliyeti önleme | +308 TL |
| **Toplam aylık fayda** | **+14.815 TL** |
| Gemini API maliyeti | -22 TL |
| **Net aylık fayda** | **+14.793 TL** |

**Yatırım Geri Dönüşü (ROI): %67.241**

---

## 13. Mimari Tasarım Detayları (20 Puan)

### 13.1 Neden Bu Mimari Güçlü

Jüriye şu 5 mimari kararı açıkla:

**Karar 1 — Event-Driven Architecture**  
Modüller birbirini doğrudan çağırmaz. Event bus üzerinden iletişim kurar. Stok ajanı bir event fırlatır, KDV ajanı bunu dinler. Bu ayrışım (decoupling) üretim kalitesi kod göstergesidir.

**Karar 2 — ReAct Pattern**  
Basit prompt-response yerine döngüsel akıl yürütme. Jüriye "bu sıradan bir chatbot değil, gerçek bir ajan" mesajını verir.

**Karar 3 — Tool Registry**  
Her ajanın kullanabileceği araçlar merkezi bir registry'de tanımlı. Yeni araç eklemek sistemi bozmaz.

**Karar 4 — Gemini Multimodal**  
Tek API çağrısında hem görüntüyü hem metni işleme. Ayrı OCR servisi gerektirmez.

**Karar 5 — Stateless Agents**  
Her ajan çağrısı bağımsız. State sadece veritabanında. Bu ölçeklenebilirlik sağlar.

### 13.2 API Endpoint Tasarımı

```
POST /api/v1/document/process       # Belge yükle ve işle
POST /api/v1/invoice/generate       # E-fatura üret
GET  /api/v1/stock/overview         # Stok durumu
GET  /api/v1/stock/{sku}/analysis   # Ürün analizi
POST /api/v1/chat                   # Doğal dil sorgusu
GET  /api/v1/finance/pl             # P&L raporu
GET  /api/v1/finance/cashflow       # Nakit akışı
POST /api/v1/hr/timesheet/process   # Puantaj işle
GET  /api/v1/alerts                 # Aktif uyarılar
GET  /api/v1/morning-brief          # Sabah brifingi
```

### 13.3 Background Job Mimarisi

```python
from apscheduler.schedulers.asyncio import AsyncIOScheduler

scheduler = AsyncIOScheduler()

# Sabah brifingi
scheduler.add_job(morning_briefing, 'cron', hour=3)

# Nakit akışı projeksiyonu güncelleme
scheduler.add_job(update_cash_forecast, 'cron', hour='*/6')

# Stok kritik kontrol
scheduler.add_job(check_critical_stock, 'interval', hours=2)

# KDV takvim uyarıları
scheduler.add_job(check_tax_deadlines, 'cron', day=1)
```

---

## 14. Veritabanı Şeması (Tam)

Bölüm 9'daki stok tablolarına ek olarak:

```sql
-- Tedarikçiler
CREATE TABLE tedarikciler (
    id INTEGER PRIMARY KEY,
    isim TEXT NOT NULL,
    vkn TEXT,
    email TEXT,
    telefon TEXT,
    ortalama_teslim_suresi_gun INTEGER,
    guvenilirlik_skoru REAL DEFAULT 5.0
);

-- Faturalar (hem gelen hem giden)
CREATE TABLE faturalar (
    id INTEGER PRIMARY KEY,
    fatura_no TEXT,
    tarih DATE,
    tur TEXT,                       -- 'satin_alma', 'satis', 'efatura', 'arsiv'
    karsı_taraf_isim TEXT,
    karsı_taraf_vkn TEXT,
    toplam_tutar REAL,
    kdv_tutari REAL,
    net_tutar REAL,
    odeme_durumu TEXT DEFAULT 'bekliyor',
    odeme_tarihi DATE,
    belge_url TEXT,                 -- yüklenen dosya yolu
    gemini_raw_json TEXT,           -- Gemini'nin ham çıktısı
    islendi BOOLEAN DEFAULT FALSE
);

-- Çalışanlar
CREATE TABLE calısanlar (
    id INTEGER PRIMARY KEY,
    ad_soyad TEXT NOT NULL,
    pozisyon TEXT,
    brut_maas REAL,
    ise_giris_tarihi DATE,
    aktif BOOLEAN DEFAULT TRUE
);

-- Puantaj kayıtları
CREATE TABLE puantaj (
    id INTEGER PRIMARY KEY,
    calıskan_id INTEGER REFERENCES calısanlar(id),
    yil INTEGER,
    ay INTEGER,
    calısma_gunleri INTEGER,
    mesai_saat REAL DEFAULT 0,
    izin_gunu INTEGER DEFAULT 0,
    rapor_gunu INTEGER DEFAULT 0,
    gemini_ham_veri TEXT,           -- Gemini'nin puantaj tablosundan çıkardığı raw JSON
    olusturma_tarihi TIMESTAMP DEFAULT NOW()
);

-- Uyarı geçmişi
CREATE TABLE uyarılar (
    id INTEGER PRIMARY KEY,
    tur TEXT,                       -- 'stok_kritik', 'nakit_acik', 'gecikmiş_odeme', 'kdv_tarihi'
    mesaj TEXT,
    oncelik TEXT DEFAULT 'normal',  -- 'dusuk', 'normal', 'yuksek', 'kritik'
    olusturma_tarihi TIMESTAMP DEFAULT NOW(),
    okundu BOOLEAN DEFAULT FALSE,
    aksiyon_alındı BOOLEAN DEFAULT FALSE
);

-- Nakit akışı kayıtları
CREATE TABLE nakit_akisi (
    id INTEGER PRIMARY KEY,
    tarih DATE,
    giris REAL DEFAULT 0,
    cikis REAL DEFAULT 0,
    bakiye REAL,
    aciklama TEXT,
    kaynak_belge_id INTEGER
);
```

---

## 15. Platform ve Tech Stack

### 15.1 Platform Kararı: Web PWA

**Neden Web:**
- Hackathon'da kurulum/deployment yok
- Her cihazda demo edilebilir
- Kamera erişimi tarayıcıdan çalışır (fatura tarama)
- Tek codebase, tüm ekranlar
- Flutter Web zaten tanıdık

**Mobil uygulama:** PWA manifest eklenirse telefonda app gibi yüklenebilir. Ayrı Flutter mobil build hackathon için gereksiz.

### 15.2 Tam Tech Stack

| Katman | Teknoloji | Neden |
|---|---|---|
| Frontend | Flutter Web | Ekip biliyor, hızlı geliştirme |
| Backend | FastAPI (Python) | Gemini API ile en uyumlu, async desteği |
| Veritabanı | SQLite → PostgreSQL | SQLite hackathon, production'da Postgres |
| AI — LLM | Gemini 2.5 Flash | Hızlı, ucuz, function calling |
| AI — Vision | Gemini 2.5 Flash (inline_data) | Native multimodal |
| Ajan Orchestration | Google ADK | Google ekosistemi, A2A desteği |
| Background Jobs | APScheduler | Python native, kolay kurulum |
| Fatura Template | Jinja2 + reportlab | UBL-TR XML + PDF üretimi |
| Auth | JWT (fastapi-jwt) | Basit, yeterli |
| Deployment | Vercel (frontend) + Railway/Render (backend) | Ücretsiz tier, hızlı |

### 15.3 Klasör Yapısı

```
kobi-ai-asistan/
├── backend/
│   ├── main.py                    # FastAPI app
│   ├── agents/
│   │   ├── orchestrator.py        # Ana orkestratör
│   │   ├── stock_agent.py
│   │   ├── finance_agent.py
│   │   ├── kdv_agent.py
│   │   ├── hr_agent.py
│   │   ├── supply_agent.py
│   │   ├── alert_agent.py
│   │   └── forecast_agent.py
│   ├── tools/
│   │   ├── stock_tools.py         # DB sorgu fonksiyonları
│   │   ├── finance_tools.py
│   │   ├── hr_tools.py
│   │   └── tool_registry.py
│   ├── services/
│   │   ├── gemini_service.py      # Gemini API wrapper
│   │   ├── document_service.py    # Belge işleme
│   │   ├── invoice_service.py     # E-fatura üretim
│   │   └── scheduler_service.py  # Background jobs
│   ├── models/
│   │   └── database.py            # SQLAlchemy modelleri
│   ├── routers/
│   │   ├── document.py
│   │   ├── stock.py
│   │   ├── finance.py
│   │   ├── chat.py
│   │   └── hr.py
│   └── prompts/
│       ├── orchestrator_prompt.py
│       ├── stock_agent_prompt.py
│       └── ...
├── frontend/
│   ├── lib/
│   │   ├── screens/
│   │   │   ├── dashboard.dart
│   │   │   ├── document_upload.dart
│   │   │   ├── stock_view.dart
│   │   │   ├── finance_view.dart
│   │   │   ├── chat_view.dart
│   │   │   └── hr_view.dart
│   │   ├── widgets/
│   │   └── services/
│   └── pubspec.yaml
├── templates/
│   └── ubl_tr_invoice.xml         # E-fatura şablonu
└── README.md
```

---

## 16. Neleri Ekleme

| Şey | Neden Eklenmemeli |
|---|---|
| GİB gerçek API entegrasyonu | Hackathon'da imkânsız, mock yeterli |
| Banka API bağlantısı | Regülasyon ve güvenlik karmaşıklığı |
| Blockchain | Hiçbir değer katmıyor bu kullanım durumunda |
| Ayrı mobil uygulama | Web PWA yeterli |
| ML model eğitimi | Gemini function calling bunu halleder |
| Gerçek e-posta gönderimi | Mock buton yeterli, demo sırasında gereksiz |
| Çoklu dil desteği | Türkçe odaklanmak daha güçlü |
| Gerçek ödeme işlemi | Kapsam dışı |

---

## 17. Hackathon Demo Stratejisi

### Demo Akışı (4 Dakika)

**Dakika 1 — Fatura Tarama "Wow Moment":**
Buruşuk, düzensiz bir fişin fotoğrafını uygulamaya yükle. Gemini 3 saniyede tüm kalemleri, KDV'yi, tutarı okuyor. Stok otomatik güncellendi, KDV beyannamesi güncellendi, nakit projeksiyonu güncellendi. Kullanıcı hiçbir şey yazmadı.

**Dakika 2 — Olay Zinciri:**
Stok "Ürün X"in kritik seviyeye düştüğünü göster. Ekranda görünür: "Stok Ajanı tetiklendi → Tedarik Ajanı devreye girdi → Tedarikçi A'ya teklif taslağı hazır." Onay ver → taslak gösterilir.

**Dakika 3 — Puantaj:**
10 kişilik el yazılı kağıt puantaj fotoğrafı tara. Gemini tüm isimleri, günleri okuyor, maaş otomatik hesaplandı, gider kaydına düştü.

**Dakika 4 — ReAct Analizi:**
Chat'e yaz: "Bu ayın en kârlı ürününü bul ve neden kârlı olduğunu açıkla." Ekranda Gemini'nin adım adım araç çağrıları görünüyor (get_stock, get_sales, get_margins, compare_period), sonunda Türkçe analiz raporu geliyor.

### Jüriye Söylenecek Anahtar Cümleler

- "Gemini Vision API'nin native multimodal özelliğini her formattaki belge için kullandık — sadece fatura değil, el yazısı dahil."
- "ReAct pattern sayesinde sistem sadece veri göstermiyor, planlama yapıp araçları kendisi seçiyor."
- "ROI: 22 TL/ay maliyet, 14.800 TL/ay tasarruf — %67.000 geri dönüş."
- "Türkiye'de 3,2 milyon KOBİ bu aracı kullanabilir."

---

## 18. Geliştirme Öncelik Sırası

Hackathon süresine göre sıralama:

### Faz 1 — Temel (İlk 4 Saat)
- [ ] Veritabanı şeması (SQLite)
- [ ] Gemini Vision fatura okuma endpoint'i
- [ ] Stok güncelleme servisi
- [ ] Temel Flutter Web dashboard

### Faz 2 — Ajan Altyapısı (Sonraki 3 Saat)
- [ ] Google ADK orchestrator kurulumu
- [ ] Tool registry (get_stock, get_movements, get_pl)
- [ ] ReAct döngüsü (orchestrator.py)
- [ ] Chat endpoint

### Faz 3 — Olay Zinciri (Sonraki 3 Saat)
- [ ] Event bus (fatura yüklendi → ajanlar tetiklensin)
- [ ] Stok kritik kontrol + Tedarik ajanı
- [ ] Sabah brifingi background job
- [ ] Push notification (UI'da badge)

### Faz 4 — Özellikler (Son 2 Saat)
- [ ] Puantaj tarama (Gemini Vision)
- [ ] E-fatura üretimi (UBL-TR mock)
- [ ] Dashboard grafikler
- [ ] Demo verisi hazırlama

---

## 19. Risk ve Dikkat Edilecekler

### Teknik Riskler

**Gemini API Rate Limit:**  
Free tier: 15 req/dk. Toplu belge işlemde limit aşılabilir. Çözüm: basit rate limiter ekle, toplu işlemde 1 saniyelik delay.

**Gemini Vision Okuma Hataları:**  
Çok düşük kaliteli fotoğraflarda yanlış okuma. Çözüm: güven skoru döndür, %80 altında kullanıcıdan teyit iste.

**SQLite Concurrent Access:**  
Background job + API aynı anda yazarsa conflict. Çözüm: WAL mode aktif et veya PostgreSQL kullan.

**Flutter Web Kamera:**  
Safari'de kamera izni farklı davranıyor. Çözüm: Chrome'da demo yap.

### Demo Riskleri

**İnternet bağlantısı:** Gemini API internet gerektirir. Hackathon mekanında WiFi yavaşsa sorun olabilir. Çözüm: en az 2-3 örnek sonucu önceden cache'le.

**Demo verisi:** Gerçekçi fatura ve puantaj örnekleri önceden hazırla. Demo sırasında anlık fotoğraf çekmek yerine hazır dosya kullan.

**Süre yönetimi:** Demo 4 dakikayı geçmemeli. Her akışı önceden 5 kez prova et.

---

## Ek: Gemini API Başlangıç Kodu

```python
import google.generativeai as genai
from google.generativeai.types import HarmCategory, HarmBlockThreshold
import json
import base64
from pathlib import Path

genai.configure(api_key="YOUR_GEMINI_API_KEY")

def read_invoice(image_path: str) -> dict:
    """Fatura görselinden yapılandırılmış veri çıkarır"""
    
    model = genai.GenerativeModel('gemini-2.5-flash')
    
    with open(image_path, 'rb') as f:
        image_data = base64.b64encode(f.read()).decode('utf-8')
    
    image_part = {
        "inline_data": {
            "mime_type": "image/jpeg",
            "data": image_data
        }
    }
    
    prompt = """Bu fatura/fişi analiz et. Sadece JSON döndür, başka metin ekleme:
    {
      "belge_tipi": "satin_alma_faturasi veya satis_fisi veya irsaliye",
      "satici_adi": "",
      "tarih": "YYYY-MM-DD",
      "fatura_no": "",
      "kalemler": [
        {
          "urun_adi": "",
          "miktar": 0,
          "birim": "adet",
          "birim_fiyat": 0.0,
          "kdv_orani": 18,
          "satir_toplam": 0.0
        }
      ],
      "toplam_kdv": 0.0,
      "genel_toplam": 0.0,
      "guven_skoru": 0.95
    }"""
    
    response = model.generate_content([image_part, prompt])
    
    # JSON parse
    raw = response.text.strip()
    if raw.startswith('```'):
        raw = raw.split('```')[1]
        if raw.startswith('json'):
            raw = raw[4:]
    
    return json.loads(raw.strip())


def chat_with_agent(user_message: str, db_tools: list) -> str:
    """ReAct döngüsüyle kullanıcı sorusunu yanıtlar"""
    
    model = genai.GenerativeModel(
        model_name='gemini-2.5-flash',
        tools=db_tools  # function calling araçları
    )
    
    system_prompt = """Sen bir KOBİ finansal asistanısın. 
    Türkçe yanıt ver. Gerekli verileri araçlarla topla, 
    sonra net ve faydalı bir analiz sun."""
    
    chat = model.start_chat()
    response = chat.send_message(
        f"{system_prompt}\n\nKullanıcı: {user_message}"
    )
    
    # Function calling döngüsü
    while response.candidates[0].content.parts[0].function_call:
        fc = response.candidates[0].content.parts[0].function_call
        tool_result = execute_tool(fc.name, fc.args)
        
        response = chat.send_message(
            genai.protos.Content(parts=[
                genai.protos.Part(
                    function_response=genai.protos.FunctionResponse(
                        name=fc.name,
                        response={"result": tool_result}
                    )
                )
            ])
        )
    
    return response.text
```

---

*Bu belge hackathon ekibi için hazırlanmıştır. Tüm teknik kararlar, maliyet hesapları ve demo stratejisi bu plana göre yürütülecektir.*

**Son Güncelleme:** Mayıs 2026
