"""
Utilidades de seguridad y autenticación
"""
from datetime import datetime, timedelta, timezone
from typing import Optional
from passlib.context import CryptContext
import jwt
from jwt.exceptions import InvalidTokenError as JWTError
from app.config import settings

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

def verify_password(plain_password: str, hashed_password: str) -> bool:
    """Verificar contraseña"""
    # Truncar a 72 bytes para evitar error de bcrypt
    password_bytes = plain_password.encode('utf-8')[:72]
    return pwd_context.verify(password_bytes, hashed_password)

def get_password_hash(password: str) -> str:
    """Hashear contraseña"""
    # Truncar a 72 bytes para evitar error de bcrypt
    password_bytes = password.encode('utf-8')[:72]
    return pwd_context.hash(password_bytes)

def create_access_token(data: dict, expires_delta: Optional[timedelta] = None) -> str:
    """Crear token JWT"""
    to_encode = data.copy()
    if expires_delta:
        expire = datetime.now(timezone.utc) + expires_delta
    else:
        expire = datetime.now(timezone.utc) + timedelta(minutes=15)
    to_encode.update({"exp": expire})
    return jwt.encode(to_encode, settings.SECRET_KEY, algorithm=settings.ALGORITHM)

def decode_token(token: str) -> dict:
    """Decodificar token JWT"""
    try:
        decoded = jwt.decode(token, settings.SECRET_KEY, algorithms=[settings.ALGORITHM])
        return decoded
    except JWTError:
        return None
    except Exception:
        return None