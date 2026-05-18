"""
KOBİ AI Asistan — API Test Script
Tüm endpoint'leri test verileriyle çalıştırır.

Kullanım:
  1. Backend'i başlat: uvicorn main:app --reload --port 8000
  2. Testi çalıştır:   python test_api.py
"""

import json
import time
import sys
from urllib.request import Request, urlopen
from urllib.error import HTTPError, URLError
from urllib.parse import urlencode

BASE_URL = "http://localhost:8000"
PASSED = 0
FAILED = 0
ERRORS = []


# ─── Yardımcı Fonksiyonlar ──────────────────────────────────────────

def api_get(path):
    """GET isteği gönderir."""
    req = Request(f"{BASE_URL}{path}")
    req.add_header("Content-Type", "application/json")
    with urlopen(req, timeout=15) as resp:
        return json.loads(resp.read().decode()), resp.status

def api_post(path, data=None):
    """POST isteği gönderir (JSON body)."""
    body = json.dumps(data or {}).encode()
    req = Request(f"{BASE_URL}{path}", data=body, method="POST")
    req.add_header("Content-Type", "application/json")
    with urlopen(req, timeout=30) as resp:
        return json.loads(resp.read().decode()), resp.status

def api_post_form(path, data):
    """POST isteği gönderir (form body)."""
    body = urlencode(data).encode()
    req = Request(f"{BASE_URL}{path}", data=body, method="POST")
    req.add_header("Content-Type", "application/x-www-form-urlencoded")
    with urlopen(req, timeout=15) as resp:
        return json.loads(resp.read().decode()), resp.status

def api_put(path):
    """PUT isteği gönderir."""
    req = Request(f"{BASE_URL}{path}", data=b"{}", method="PUT")
    req.add_header("Content-Type", "application/json")
    with urlopen(req, timeout=15) as resp:
        return json.loads(resp.read().decode()), resp.status

def run_test(name, fn):
    """Tek bir test senaryosu çalıştırır."""
    global PASSED, FAILED
    try:
        fn()
        PASSED += 1
        print(f"  ✅ {name}")
    except AssertionError as e:
        FAILED += 1
        msg = f"  ❌ {name} → {e}"
        print(msg)
        ERRORS.append(msg)
    except (HTTPError, URLError, Exception) as e:
        FAILED += 1
        msg = f"  ❌ {name} → {type(e).__name__}: {e}"
        print(msg)
        ERRORS.append(msg)


# ═══════════════════════════════════════════════════════════════════════
#  TEST SENARYOLARI
# ═══════════════════════════════════════════════════════════════════════

# ─── 1. Sağlık & Root ────────────────────────────────────────────────

def test_health():
    data, status = api_get("/health")
    assert status == 200, f"Status {status}"
    assert data["status"] == "healthy", f"Status: {data['status']}"

def test_api_root():
    data, status = api_get("/api")
    assert status == 200
    assert "endpoints" in data
    assert data["name"] == "KOBİ AI Asistan API"

def test_docs_accessible():
    req = Request(f"{BASE_URL}/docs")
    with urlopen(req, timeout=10) as resp:
        assert resp.status == 200


# ─── 2. Auth ─────────────────────────────────────────────────────────

def test_auth_valid_login():
    data, status = api_post_form("/api/v1/auth/token", {"username": "demo", "password": "demo"})
    assert status == 200
    assert "access_token" in data
    assert data["token_type"] == "bearer"

def test_auth_invalid_login():
    try:
        api_post_form("/api/v1/auth/token", {"username": "demo", "password": "wrong"})
        assert False, "401 beklendi"
    except HTTPError as e:
        assert e.code == 401, f"Beklenen 401, gelen {e.code}"

def test_auth_empty_credentials():
    try:
        api_post_form("/api/v1/auth/token", {"username": "", "password": ""})
        assert False, "401 beklendi"
    except HTTPError as e:
        assert e.code in (401, 422), f"Beklenen 401/422, gelen {e.code}"


# ─── 3. Dashboard ────────────────────────────────────────────────────

def test_dashboard_summary():
    data, status = api_get("/api/v1/dashboard/summary")
    assert status == 200
    assert "stats" in data
    for key in ["toplam_sku", "kritik_stok", "stok_degeri", "mevcut_bakiye"]:
        assert key in data["stats"], f"stats.{key} eksik"
    assert "kritik_stoklar" in data
    assert "kdv_ozet" in data

def test_dashboard_morning_brief():
    data, status = api_get("/api/v1/dashboard/morning-brief")
    assert status == 200
    assert "brief" in data
    assert "source" in data
    assert data["source"] in ("cache", "live")


# ─── 4. Stok ─────────────────────────────────────────────────────────

def test_stock_overview():
    data, status = api_get("/api/v1/stock/overview")
    assert status == 200
    assert "toplam_sku" in data
    assert isinstance(data["toplam_sku"], int)
    assert data["toplam_sku"] > 0

def test_stock_critical():
    data, status = api_get("/api/v1/stock/critical")
    assert status == 200
    assert isinstance(data, list)
    if data:
        assert "isim" in data[0]
        assert "mevcut_stok" in data[0]

def test_stock_movements_default():
    data, status = api_get("/api/v1/stock/movements")
    assert status == 200
    assert isinstance(data, list)

def test_stock_movements_limit():
    data, status = api_get("/api/v1/stock/movements?limit=3")
    assert status == 200
    assert len(data) <= 3

def test_stock_abc_analysis():
    data, status = api_get("/api/v1/stock/abc-analysis")
    assert status == 200

def test_stock_product_analysis_valid():
    data, status = api_get("/api/v1/stock/KHV-250/analysis")
    assert status == 200

def test_stock_product_analysis_invalid():
    data, status = api_get("/api/v1/stock/INVALID-999/analysis")
    assert status == 200  # 200 ile error mesajı döner
    assert "error" in data or "urun" in data

def test_stock_suppliers():
    data, status = api_get("/api/v1/stock/KHV-250/suppliers")
    assert status == 200

def test_stock_seasonality():
    data, status = api_get("/api/v1/stock/KHV-250/seasonality")
    assert status == 200

def test_stock_simulate_discount():
    data, status = api_post("/api/v1/stock/KHV-250/simulate", {"price_change_pct": -15})
    assert status == 200

def test_stock_simulate_increase():
    data, status = api_post("/api/v1/stock/KHV-250/simulate", {"price_change_pct": 20})
    assert status == 200


# ─── 5. Finans ────────────────────────────────────────────────────────

def test_finance_pl():
    data, status = api_get("/api/v1/finance/pl")
    assert status == 200
    assert "gelir" in data
    assert "net_kar" in data

def test_finance_pl_specific_month():
    data, status = api_get("/api/v1/finance/pl?ay=5&yil=2026")
    assert status == 200
    assert data["donem"] == "5/2026"

def test_finance_cashflow_30():
    data, status = api_get("/api/v1/finance/cashflow?gun=30")
    assert status == 200
    assert "mevcut_bakiye" in data
    assert "projeksiyonlar" in data
    assert isinstance(data["projeksiyonlar"], list)

def test_finance_cashflow_7():
    data, status = api_get("/api/v1/finance/cashflow?gun=7")
    assert status == 200

def test_finance_kdv():
    data, status = api_get("/api/v1/finance/kdv")
    assert status == 200
    assert "odenecek_kdv" in data
    assert "beyanname_son_tarihi" in data

def test_finance_kdv_specific():
    data, status = api_get("/api/v1/finance/kdv?ay=5&yil=2026")
    assert status == 200

def test_finance_overdue():
    data, status = api_get("/api/v1/finance/overdue")
    assert status == 200
    assert isinstance(data, list)

def test_finance_invoices():
    data, status = api_get("/api/v1/finance/invoices")
    assert status == 200
    assert isinstance(data, list)

def test_finance_invoices_limit():
    data, status = api_get("/api/v1/finance/invoices?limit=2")
    assert status == 200
    assert len(data) <= 2


# ─── 6. Belge İşleme ─────────────────────────────────────────────────

def test_document_process_demo():
    data, status = api_post("/api/v1/document/process-demo")
    assert status == 200
    assert data.get("success") == True
    assert "fatura_id" in data
    assert "toplam_tutar" in data


# ─── 7. E-Fatura ─────────────────────────────────────────────────────

def test_invoice_generate_demo():
    data, status = api_post("/api/v1/invoice/generate-demo")
    assert status == 200
    assert data.get("success") == True
    assert "fatura_no" in data
    assert "pdf_base64" in data
    assert "xml" in data

def test_invoice_generate_custom():
    payload = {
        "musteri_adi": "Test Müşteri A.Ş.",
        "musteri_vkn": "1112223334",
        "kalemler": [
            {
                "urun_adi": "Espresso Çekirdeği 1kg",
                "miktar": 10,
                "birim": "adet",
                "birim_fiyat": 420.0,
                "kdv_orani": 20
            },
            {
                "urun_adi": "Karton Bardak 8oz",
                "miktar": 200,
                "birim": "adet",
                "birim_fiyat": 1.80,
                "kdv_orani": 20
            }
        ]
    }
    data, status = api_post("/api/v1/invoice/generate", payload)
    assert status == 200
    assert data.get("success") == True
    assert data["kalem_sayisi"] == 2
    assert data["genel_toplam"] > 0

def test_invoice_generate_single_item():
    payload = {
        "musteri_adi": "Tek Kalem Test",
        "musteri_vkn": "9998887776",
        "kalemler": [
            {
                "urun_adi": "Süt 1L",
                "miktar": 50,
                "birim": "litre",
                "birim_fiyat": 45.0,
                "kdv_orani": 10
            }
        ]
    }
    data, status = api_post("/api/v1/invoice/generate", payload)
    assert status == 200
    assert data["kalem_sayisi"] == 1
    # KDV: 50 * 45 * 0.10 = 225, Toplam: 2250 + 225 = 2475
    assert data["genel_toplam"] == 2475.0, f"Beklenen 2475, gelen {data['genel_toplam']}"

def test_invoice_list():
    data, status = api_get("/api/v1/invoice/list")
    assert status == 200
    assert isinstance(data, list)

def test_invoice_list_filter():
    data, status = api_get("/api/v1/invoice/list?tur=satis&limit=5")
    assert status == 200
    for f in data:
        assert f["tur"] == "satis"


# ─── 8. İK / Puantaj ─────────────────────────────────────────────────

def test_hr_employees():
    data, status = api_get("/api/v1/hr/employees")
    assert status == 200
    assert isinstance(data, list)
    assert len(data) > 0
    assert "ad_soyad" in data[0]
    assert "pozisyon" in data[0]

def test_hr_payroll_current():
    data, status = api_get("/api/v1/hr/payroll")
    assert status == 200
    assert "bordro" in data

def test_hr_payroll_specific():
    data, status = api_get("/api/v1/hr/payroll?ay=4&yil=2026")
    assert status == 200
    assert data["donem"] == "4/2026"
    assert data["calisan_sayisi"] > 0

def test_hr_timesheet_demo():
    data, status = api_post("/api/v1/hr/timesheet/process-demo")
    assert status == 200
    assert data.get("success") == True
    assert "sonuclar" in data


# ─── 9. AI Chat ──────────────────────────────────────────────────────

def test_chat_basic():
    data, status = api_post("/api/v1/chat", {"message": "Stok durumum nasıl?"})
    assert status == 200
    assert "response" in data
    assert len(data["response"]) > 10

def test_chat_finance_query():
    data, status = api_post("/api/v1/chat", {"message": "Bu ayın kâr-zarar durumu ne?"})
    assert status == 200
    assert "response" in data

def test_chat_careful_mode():
    data, status = api_post("/api/v1/chat", {"message": "Nakit durumum nasıl?", "ai_mode": "careful"})
    assert status == 200
    assert "response" in data

def test_chat_proactive_mode():
    data, status = api_post("/api/v1/chat", {"message": "Genel değerlendirme yap", "ai_mode": "proactive"})
    assert status == 200
    assert "response" in data

def test_chat_suggestions():
    data, status = api_get("/api/v1/chat/suggestions")
    assert status == 200
    assert "suggestions" in data
    assert isinstance(data["suggestions"], list)
    if data["suggestions"]:
        s = data["suggestions"][0]
        assert "tip" in s
        assert "mesaj" in s


# ─── 10. Uyarılar ────────────────────────────────────────────────────

def test_alerts_list():
    data, status = api_get("/api/v1/alerts")
    assert status == 200
    assert isinstance(data, list)
    if data:
        a = data[0]
        assert "baslik" in a
        assert "oncelik" in a

def test_alerts_filter_priority():
    data, status = api_get("/api/v1/alerts?oncelik=kritik")
    assert status == 200
    for a in data:
        assert a["oncelik"] == "kritik"

def test_alerts_unread_only():
    data, status = api_get("/api/v1/alerts?okunmamis=true")
    assert status == 200
    for a in data:
        assert a["okundu"] == False

def test_alerts_count():
    data, status = api_get("/api/v1/alerts/count")
    assert status == 200
    assert "count" in data
    assert isinstance(data["count"], int)

def test_alerts_mark_read():
    # Önce uyarı listesinden bir ID al
    alerts, _ = api_get("/api/v1/alerts")
    if alerts:
        alert_id = alerts[0]["id"]
        data, status = api_put(f"/api/v1/alerts/{alert_id}/read")
        assert status == 200
        assert data.get("success") == True

def test_alerts_mark_action():
    alerts, _ = api_get("/api/v1/alerts")
    if alerts:
        alert_id = alerts[-1]["id"]
        data, status = api_put(f"/api/v1/alerts/{alert_id}/action")
        assert status == 200
        assert data.get("success") == True


# ═══════════════════════════════════════════════════════════════════════
#  TEST ÇALIŞTIRICI
# ═══════════════════════════════════════════════════════════════════════

def main():
    print("=" * 60)
    print("  KOBİ AI Asistan — API Test Suite")
    print("=" * 60)
    start = time.time()

    sections = [
        ("1. SAĞLIK & ROOT", [
            ("Health endpoint", test_health),
            ("API root", test_api_root),
            ("Swagger docs", test_docs_accessible),
        ]),
        ("2. KİMLİK DOĞRULAMA", [
            ("Geçerli login", test_auth_valid_login),
            ("Geçersiz şifre", test_auth_invalid_login),
            ("Boş credentials", test_auth_empty_credentials),
        ]),
        ("3. DASHBOARD", [
            ("Dashboard özet", test_dashboard_summary),
            ("Sabah brifingi", test_dashboard_morning_brief),
        ]),
        ("4. STOK YÖNETİMİ", [
            ("Stok genel durum", test_stock_overview),
            ("Kritik stoklar", test_stock_critical),
            ("Hareketler (varsayılan)", test_stock_movements_default),
            ("Hareketler (limit=3)", test_stock_movements_limit),
            ("ABC analizi", test_stock_abc_analysis),
            ("Ürün analizi (geçerli)", test_stock_product_analysis_valid),
            ("Ürün analizi (geçersiz)", test_stock_product_analysis_invalid),
            ("Tedarikçi karşılaştırma", test_stock_suppliers),
            ("Mevsimsellik", test_stock_seasonality),
            ("Fiyat simülasyonu (indirim)", test_stock_simulate_discount),
            ("Fiyat simülasyonu (zam)", test_stock_simulate_increase),
        ]),
        ("5. FİNANS", [
            ("P&L özeti", test_finance_pl),
            ("P&L belirli ay", test_finance_pl_specific_month),
            ("Nakit akışı (30 gün)", test_finance_cashflow_30),
            ("Nakit akışı (7 gün)", test_finance_cashflow_7),
            ("KDV özeti", test_finance_kdv),
            ("KDV belirli dönem", test_finance_kdv_specific),
            ("Gecikmiş ödemeler", test_finance_overdue),
            ("Son faturalar", test_finance_invoices),
            ("Son faturalar (limit)", test_finance_invoices_limit),
        ]),
        ("6. BELGE İŞLEME", [
            ("Demo belge işleme", test_document_process_demo),
        ]),
        ("7. E-FATURA", [
            ("Demo e-fatura", test_invoice_generate_demo),
            ("Özel fatura (2 kalem)", test_invoice_generate_custom),
            ("Tek kalemli fatura", test_invoice_generate_single_item),
            ("Fatura listesi", test_invoice_list),
            ("Fatura filtresi (satış)", test_invoice_list_filter),
        ]),
        ("8. İK / PUANTAJ", [
            ("Çalışan listesi", test_hr_employees),
            ("Maaş bordrosu (güncel)", test_hr_payroll_current),
            ("Maaş bordrosu (Nisan)", test_hr_payroll_specific),
            ("Demo puantaj işleme", test_hr_timesheet_demo),
        ]),
        ("9. AI CHAT", [
            ("Basit stok sorusu", test_chat_basic),
            ("Finans sorusu", test_chat_finance_query),
            ("Dikkatli mod", test_chat_careful_mode),
            ("Proaktif mod", test_chat_proactive_mode),
            ("AI öneriler", test_chat_suggestions),
        ]),
        ("10. UYARILAR", [
            ("Uyarı listesi", test_alerts_list),
            ("Öncelik filtresi", test_alerts_filter_priority),
            ("Okunmamış filtresi", test_alerts_unread_only),
            ("Okunmamış sayısı", test_alerts_count),
            ("Okundu işaretle", test_alerts_mark_read),
            ("Aksiyon alındı", test_alerts_mark_action),
        ]),
    ]

    for section_name, tests in sections:
        print(f"\n{'─' * 50}")
        print(f"  {section_name}")
        print(f"{'─' * 50}")
        for test_name, test_fn in tests:
            run_test(test_name, test_fn)

    elapsed = time.time() - start

    print(f"\n{'=' * 60}")
    print(f"  SONUÇLAR")
    print(f"{'=' * 60}")
    print(f"  ✅ Başarılı : {PASSED}")
    print(f"  ❌ Başarısız: {FAILED}")
    print(f"  ⏱  Süre     : {elapsed:.1f} saniye")
    print(f"{'=' * 60}")

    if ERRORS:
        print(f"\n  HATALAR:")
        for e in ERRORS:
            print(f"  {e}")

    sys.exit(1 if FAILED > 0 else 0)


if __name__ == "__main__":
    main()
