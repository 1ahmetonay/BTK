"""
KOBİ AI Asistan — Güvenlik Servisi (JWT)
Kimlik doğrulama, token oluşturma ve doğrulama işlemleri.
"""

import os
from datetime import datetime, timedelta
from typing import Optional
from jose import jwt, JWTError
from fastapi import Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer
from pydantic import BaseModel
from dotenv import load_dotenv

load_dotenv()

SECRET_KEY = os.getenv("JWT_SECRET", "super-secret-kobi-ai-key-change-in-production")
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = int(os.getenv("JWT_EXPIRE_MINUTES", str(60 * 24 * 7)))
APP_ENV = os.getenv("APP_ENV", "development")

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="/api/v1/auth/token", auto_error=False)


class TokenData(BaseModel):
    username: Optional[str] = None


def create_access_token(data: dict, expires_delta: Optional[timedelta] = None):
    to_encode = data.copy()
    expire = datetime.utcnow() + (expires_delta or timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES))
    to_encode.update({"exp": expire})
    return jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)


async def get_current_user(token: Optional[str] = Depends(oauth2_scheme)):
    """Mevcut kullanıcıyı token'dan doğrular.
    Development modda token yoksa demo kullanıcı döner.
    Production modda geçerli token zorunludur.
    """
    if APP_ENV == "development" and not token:
        return {"username": "demo_user"}

    if not token:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Kimlik dogrulama gerekli",
            headers={"WWW-Authenticate": "Bearer"},
        )

    # Development kolaylığı: dummy-token kabul et
    if APP_ENV == "development" and token == "dummy-token-for-demo":
        return {"username": "demo_user"}

    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        username: str = payload.get("sub")
        if username is None:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Gecersiz token",
                headers={"WWW-Authenticate": "Bearer"},
            )
        return {"username": username}
    except JWTError:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Token dogrulanamadi",
            headers={"WWW-Authenticate": "Bearer"},
        )
