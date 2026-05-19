"""
KOBİ AI Asistan — Belge Router
Fatura tarama ve isleme.
"""

import logging

from fastapi import APIRouter, Depends, File, HTTPException, UploadFile
from sqlalchemy.ext.asyncio import AsyncSession

from database import get_db
from services.document_service import document_service

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/api/v1/document", tags=["Belge Isleme"])

_MAX_FILE_SIZE = 10 * 1024 * 1024  # 10 MB
_ALLOWED_MIMES = {
    "image/jpeg", "image/png", "image/tiff", "image/webp",
    "application/pdf",
}


@router.post("/process")
async def process_document(
    file: UploadFile = File(...),
    db: AsyncSession = Depends(get_db),
):
    """Fatura/fis belgesini yukle ve isle.

    Akis:
    1. Gemini Vision ile belgeyi oku
    2. Fatura kaydi olustur
    3. Stok guncelle (eslesen urunler)
    4. KDV kaydi olustur
    5. Nakit akisi guncelle
    6. Kritik stok uyarilari olustur
    """
    # Dosya tipi dogrulama
    mime_type = file.content_type or "image/jpeg"
    if mime_type not in _ALLOWED_MIMES:
        raise HTTPException(
            status_code=400,
            detail=f"Desteklenmeyen dosya tipi: {mime_type}. "
                   f"Desteklenen: {', '.join(sorted(_ALLOWED_MIMES))}",
        )

    content = await file.read()

    # Dosya boyutu dogrulama
    if len(content) > _MAX_FILE_SIZE:
        raise HTTPException(
            status_code=413,
            detail=f"Dosya boyutu cok buyuk ({len(content) / 1024 / 1024:.1f} MB). "
                   f"Maksimum: {_MAX_FILE_SIZE / 1024 / 1024:.0f} MB.",
        )

    if len(content) == 0:
        raise HTTPException(status_code=400, detail="Bos dosya yuklenemez.")

    result = await document_service.process_document(db, content, mime_type)
    return result


@router.post("/process-demo")
async def process_document_demo(db: AsyncSession = Depends(get_db)):
    """Demo modunda fatura isle (dosya yuklemeden).

    Gemini API key yoksa mock veriyle calisir.
    Hackathon demo'su icin idealdir.
    """
    result = await document_service.process_document(db, b"", "image/jpeg")
    return result
