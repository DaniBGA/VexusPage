"""
Utilidades de seguridad y autenticación
"""
from datetime import datetime, timedelta
from typing import Optional
from passlib.context import CryptContext
import jwt
from jwt.exceptions import InvalidTokenError as JWTError
from app.config import settings

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

def verify_password(plain_password: str, hashed_password: str) -> bool:
    """Verificar contraseña"""
    return pwd_context.verify(plain_password, hashed_password)

def get_password_hash(password: str) -> str:
    """Hashear contraseña"""
    return pwd_context.hash(password)

def create_access_token(data: dict, expires_delta: Optional[timedelta] = None) -> str:
    """Crear token JWT"""
    to_encode = data.copy()
    if expires_delta:
        expire = datetime.utcnow() + expires_delta
    else:
        expire = datetime.utcnow() + timedelta(minutes=15)
    to_encode.update({"exp": expire})
    return jwt.encode(to_encode, settings.SECRET_KEY, algorithm=settings.ALGORITHM)

def decode_token(token: str) -> dict:
    """Decodificar token JWT"""
    try:
        print(f"DEBUG DECODE - Attempting to decode token")
        print(f"DEBUG DECODE - SECRET_KEY: {settings.SECRET_KEY[:10]}...")
        print(f"DEBUG DECODE - ALGORITHM: {settings.ALGORITHM}")
        decoded = jwt.decode(token, settings.SECRET_KEY, algorithms=[settings.ALGORITHM])
        print(f"DEBUG DECODE - Successfully decoded: {decoded}")
        return decoded
    except JWTError as e:
        print(f"DEBUG DECODE - JWT Error: {str(e)}")
        print(f"DEBUG DECODE - Error type: {type(e).__name__}")
        return None
    except Exception as e:
        print(f"DEBUG DECODE - Unexpected error: {str(e)}")
        return None