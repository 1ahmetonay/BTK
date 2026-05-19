"""
KOBİ AI Asistan — Auth Router
JWT Login endpoint'leri.
"""

import logging
import os
from datetime import timedelta

from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.security import OAuth2PasswordRequestForm

from services.security import create_access_token, ACCESS_TOKEN_EXPIRE_MINUTES

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/api/v1/auth", tags=["Auth"])

# Demo kullanici bilgileri — production'da env variable ile override edin
_DEMO_USER = os.getenv("AUTH_DEMO_USER", "demo")
_DEMO_PASS = os.getenv("AUTH_DEMO_PASS", "demo")


@router.post("/token")
async def login_for_access_token(form_data: OAuth2PasswordRequestForm = Depends()):
    """Kullanici girisi yapar ve JWT doner."""
    if form_data.username != _DEMO_USER or form_data.password != _DEMO_PASS:
        logger.warning("Basarisiz giris denemesi: %s", form_data.username)
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Yanlis kullanici adi veya sifre",
            headers={"WWW-Authenticate": "Bearer"},
        )

    access_token_expires = timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    access_token = create_access_token(
        data={"sub": form_data.username}, expires_delta=access_token_expires
    )
    return {"access_token": access_token, "token_type": "bearer"}
