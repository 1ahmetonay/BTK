"""
KOBİ AI Asistan — Belge Router
Fatura tarama ve işleme.
"""

from fastapi import APIRouter, Depends, File, UploadFile
from sqlalchemy.ext.asyncio import AsyncSession

import sys, os
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from database import get_db
from services.document_service import document_service

router = APIRouter(prefix="/api/v1/document", tags=["Belge İşleme"])


@router.post("/process")
async def process_document(
    file: UploadFile = File(...),
    db: AsyncSession = Depends(get_db),
):
    """Fatura/fiş belgesini yükle ve işle.
    
    Akış:
    1. Gemini Vision ile belgeyi oku
    2. Fatura kaydı oluştur
    3. Stok güncelle (eşleşen ürünler)
    4. KDV kaydı oluştur
    5. Nakit akışı güncelle
    6. Kritik stok uyarıları oluştur
    """
    content = await file.read()
    mime_type = file.content_type or "image/jpeg"

    result = await document_service.process_document(db, content, mime_type)
    return result


@router.post("/process-demo")
async def process_document_demo(db: AsyncSession = Depends(get_db)):
    """Demo modunda fatura işle (dosya yüklemeden).
    
    Gemini API key yoksa mock veriyle çalışır.
    Hackathon demo'su için idealdir.
    """
    # Mock image data — boş bytes gönder, gemini_service mock yanıt döner
    result = await document_service.process_document(db, b"", "image/jpeg")
    return result
