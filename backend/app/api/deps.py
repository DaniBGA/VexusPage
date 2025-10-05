"""
Dependencias reutilizables para endpoints
"""
import uuid
from typing import AsyncGenerator
from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from app.core.security import decode_token
from app.core.database import db
import asyncpg

security = HTTPBearer()

# ===== Database Connection Dependency =====
async def get_db_connection() -> AsyncGenerator[asyncpg.Connection, None]:
    """Obtener conexión a la base de datos"""
    pool = await db.get_pool()
    async with pool.acquire() as connection:
        yield connection

async def get_current_user(
    credentials: HTTPAuthorizationCredentials = Depends(security)
):
    """Obtener usuario actual desde el token"""
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Could not validate credentials",
        headers={"WWW-Authenticate": "Bearer"},
    )

    token = credentials.credentials
    print(f"DEBUG - Received token: {token[:20]}...")

    payload = decode_token(token)
    print(f"DEBUG - Decoded payload: {payload}")

    if payload is None:
        print("DEBUG - Payload is None, token invalid")
        raise credentials_exception

    user_id: str = payload.get("sub")
    print(f"DEBUG - User ID from token: {user_id}")

    if user_id is None:
        print("DEBUG - User ID is None")
        raise credentials_exception

    pool = await db.get_pool()
    async with pool.acquire() as connection:
        user = await connection.fetchrow(
            "SELECT * FROM users WHERE id = $1 AND is_active = true",
            uuid.UUID(user_id)
        )
        print(f"DEBUG - User from DB: {dict(user) if user else None}")

        if user is None:
            print("DEBUG - User not found in DB")
            raise credentials_exception

        user_dict = dict(user)
        # Asegurar que role existe
        if user_dict.get('role') is None:
            user_dict['role'] = 'user'

        print(f"DEBUG - Returning user: {user_dict.get('email')} with role: {user_dict.get('role')}")
        return user_dict

# ===== Admin Role Dependency =====
async def require_admin(current_user: dict = Depends(get_current_user)) -> dict:
    """Verificar que el usuario actual sea administrador"""
    if current_user.get('role') != 'admin':
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Not authorized. Admin role required."
        )
    return current_user