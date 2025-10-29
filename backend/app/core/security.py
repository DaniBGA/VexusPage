"""
Utilidades de seguridad y autenticación
"""
from datetime import datetime, timedelta, timezone
from typing import Optional
import bcrypt
import jwt
from jwt.exceptions import InvalidTokenError as JWTError
from app.config import settings

def verify_password(plain_password: str, hashed_password: str) -> bool:
    """Verificar contraseña"""
    # Truncar a 72 bytes para evitar error de bcrypt
    password_bytes = plain_password.encode('utf-8')[:72]
    hashed_bytes = hashed_password.encode('utf-8') if isinstance(hashed_password, str) else hashed_password
    return bcrypt.checkpw(password_bytes, hashed_bytes)

def get_password_hash(password: str) -> str:
    """Hashear contraseña"""
    # Truncar a 72 bytes para evitar error de bcrypt
    password_bytes = password.encode('utf-8')[:72]
    salt = bcrypt.gensalt()
    hashed = bcrypt.hashpw(password_bytes, salt)
    return hashed.decode('utf-8')

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