"""
Endpoints de autenticación
"""
import uuid
from datetime import timedelta
from datetime import datetime
from fastapi import APIRouter, HTTPException, status, Depends
from fastapi.security import HTTPAuthorizationCredentials
from app.models.schemas import UserCreate, UserLogin, Token, User
from app.core.security import verify_password, get_password_hash, create_access_token
from app.core.database import db
from app.config import settings
from app.api.deps import get_current_user, security

router = APIRouter()

@router.post("/register", response_model=dict)
async def register_user(user: UserCreate):
    """Registrar nuevo usuario"""
    pool = await db.get_pool()
    
    async with pool.acquire() as connection:
        existing_user = await connection.fetchrow(
            "SELECT id FROM users WHERE email = $1", user.email
        )
        if existing_user:
            raise HTTPException(
                status_code=400,
                detail="Email already registered"
            )
        
        user_id = uuid.uuid4()
        hashed_password = get_password_hash(user.password)
        
        await connection.execute(
            """
            INSERT INTO users (id, name, email, password_hash)
            VALUES ($1, $2, $3, $4)
            """,
            user_id, user.name, user.email, hashed_password
        )
        
        return {"message": "User created successfully", "user_id": str(user_id)}

@router.post("/login", response_model=Token)
async def login_user(user_credentials: UserLogin):
    """Iniciar sesión"""
    pool = await db.get_pool()

    async with pool.acquire() as connection:
        user = await connection.fetchrow(
            "SELECT * FROM users WHERE email = $1 AND is_active = true",
            user_credentials.email
        )

        if not user or not verify_password(user_credentials.password, user['password_hash']):
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Incorrect email or password",
                headers={"WWW-Authenticate": "Bearer"},
            )

        await connection.execute(
            "UPDATE users SET last_login = CURRENT_TIMESTAMP WHERE id = $1",
            user['id']
        )

        access_token_expires = timedelta(minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES)
        access_token = create_access_token(
            data={"sub": str(user['id'])}, expires_delta=access_token_expires
        )

        session_id = uuid.uuid4()
        expires_at = datetime.utcnow() + access_token_expires
        await connection.execute(
            """
            INSERT INTO user_sessions (id, user_id, token, expires_at)
            VALUES ($1, $2, $3, $4)
            """,
            session_id, user['id'], access_token, expires_at
        )

        # Convertir a dict y verificar que role existe
        user_dict = dict(user)

        # Si role es None, asignar 'user' por defecto
        if user_dict.get('role') is None:
            user_dict['role'] = 'user'

        user_data = User(**user_dict)

        return {
            "access_token": access_token,
            "token_type": "bearer",
            "user": user_data
        }

@router.post("/logout")
async def logout_user(
    current_user: dict = Depends(get_current_user),
    credentials: HTTPAuthorizationCredentials = Depends(security)
):
    """Cerrar sesión"""
    pool = await db.get_pool()
    
    async with pool.acquire() as connection:
        await connection.execute(
            "DELETE FROM user_sessions WHERE user_id = $1 AND token = $2",
            current_user['id'], credentials.credentials
        )
    
    return {"message": "Logged out successfully"}