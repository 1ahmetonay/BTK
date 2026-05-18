"""Gemini API key'in çalışıp çalışmadığını test eder."""
import os
from dotenv import load_dotenv
load_dotenv()

key = os.getenv("GEMINI_API_KEY", "")
print(f"Key: {key[:10]}...{key[-4:]}" if len(key) > 14 else f"Key: {key or '(BOŞ)'}")

try:
    import google.generativeai as genai
    genai.configure(api_key=key)
    model = genai.GenerativeModel("gemini-2.5-flash")
    response = model.generate_content("Merhaba, 1+1 kaç?")
    print(f"\n✅ API KEY ÇALIŞIYOR!")
    print(f"Yanıt: {response.text[:200]}")
except Exception as e:
    print(f"\n❌ API KEY ÇALIŞMIYOR!")
    print(f"Hata: {e}")
    print(f"\nÇözüm: https://aistudio.google.com/apikey adresinden yeni key oluşturun")
    print(f"       ve backend/.env dosyasındaki GEMINI_API_KEY değerini güncelleyin.")
