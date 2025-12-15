"""
Endpoints de autenticación
"""
import uuid
from datetime import timedelta, datetime, timezone
from fastapi import APIRouter, HTTPException, status, Depends, Request, Response, BackgroundTasks
from fastapi.security import HTTPAuthorizationCredentials
from pydantic import BaseModel
from app.models.schemas import UserCreate, UserLogin, Token, User
from app.core.security import verify_password, get_password_hash, create_access_token
from app.core.database import db
from app.config import settings
from app.api.deps import get_current_user, security
from app.services.email import (
    generate_verification_token,
    get_token_expiration,
    send_verification_email
)
# SendGrid HTTP API (funciona en Render Free - no bloqueado)
from app.services.email import send_verification_email

router = APIRouter()

class ResendVerificationRequest(BaseModel):
    email: str

@router.post("/register", response_model=dict)
async def register_user(user: UserCreate, request: Request, background_tasks: BackgroundTasks):
    """Registrar nuevo usuario y enviar email de verificación en background"""
    pool = await db.get_pool()

    try:
        origin = request.headers.get("origin")
        print(f"🔔 Registration attempt for email: {user.email} method={request.method} origin={origin}")
    except Exception:
        pass

    async with pool.acquire() as connection:
        existing_user = await connection.fetchrow(
            "SELECT id FROM users WHERE email = $1", user.email
        )
        if existing_user:
            print(f"⚠️ Registration failed: email already registered -> {user.email}")
            raise HTTPException(
                status_code=400,
                detail="Email already registered"
            )

        user_id = uuid.uuid4()
        hashed_password = get_password_hash(user.password)

        # Generar token de verificación
        verification_token = generate_verification_token()
        token_expires = get_token_expiration()

        # Insertar usuario con token de verificación
        # Email verification habilitado - usuarios deben verificar su email
        auto_verify = False  # Email verification requerida

        try:
            await connection.execute(
                """
                INSERT INTO users (
                    id, full_name, email, hashed_password,
                    is_verified, verification_token,
                    verification_token_expires, is_active,
                    created_at, updated_at
                )
                VALUES ($1, $2, $3, $4, $5, $6, $7, $8, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
                """,
                user_id, user.name, user.email, hashed_password,
                auto_verify, verification_token, token_expires, True
            )
            print(f"✅ User created successfully: {user.email} (auto_verify={auto_verify})")
        except Exception as e:
            print(f"❌ Error creating user: {e}")
            raise HTTPException(status_code=500, detail="Error creating user")

        # Email de verificación enviado en background
        # Solo intentar enviar email si auto_verify es False
        # if not auto_verify:
        #     background_tasks.add_task(
        #         send_verification_email,  # ← Usando Gmail SMTP
        #         to_email=user.email,
        #         user_name=user.name,
        #         verification_token=verification_token
        #     )
        #     print(f"📧 Email de verificación agregado a cola en background (Gmail SMTP) para {user.email}")
        # else:
        #     print(f"ℹ️ Email verification skipped (auto_verify=True) for {user.email}")
        print(f"ℹ️ Email será enviado desde el frontend para {user.email}")

        # Mensaje personalizado según si el email fue verificado automáticamente
        message = "User created successfully. You can now log in." if auto_verify else \
                  "User created successfully. Please check your email to verify your account."

        return {
            "message": message,
            "user_id": str(user_id),
            "email_sent": "frontend",  # Email se enviará desde el frontend
            "verification_token": verification_token,  # Se envía al frontend para el email
            "user_name": user.name,  # Se envía al frontend para personalizar el email
            "auto_verified": auto_verify
        }

@router.post("/login", response_model=Token)
async def login_user(user_credentials: UserLogin):
    """Iniciar sesión"""
    pool = await db.get_pool()

    async with pool.acquire() as connection:
        user = await connection.fetchrow(
            "SELECT * FROM users WHERE email = $1 AND is_active = true",
            user_credentials.email
        )

        if not user or not verify_password(user_credentials.password, user['hashed_password']):
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Incorrect email or password",
                headers={"WWW-Authenticate": "Bearer"},
            )

        # Verificar si el email está verificado
        if not user['is_verified']:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Email not verified. Please check your email and verify your account before logging in.",
                headers={
                    "X-Email-Verified": "false",
                    "X-User-Email": user['email']
                }
            )

        # Nota: last_login no existe en el schema, removido
        # await connection.execute(
        #     "UPDATE users SET last_login = CURRENT_TIMESTAMP WHERE id = $1",
        #     user['id']
        # )

        access_token_expires = timedelta(minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES)
        access_token = create_access_token(
            data={"sub": str(user['id'])}, expires_delta=access_token_expires
        )

        session_id = uuid.uuid4()
        # Usar SQL para calcular la fecha de expiración directamente en la BD
        await connection.execute(
            f"""
            INSERT INTO user_sessions (id, user_id, session_token, expires_at)
            VALUES ($1, $2, $3, CURRENT_TIMESTAMP + INTERVAL '{settings.ACCESS_TOKEN_EXPIRE_MINUTES} minutes')
            """,
            session_id, user['id'], access_token
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
            "DELETE FROM user_sessions WHERE user_id = $1 AND session_token = $2",
            current_user['id'], credentials.credentials
        )

    return {"message": "Logged out successfully"}

@router.get("/verify-email")
async def verify_email(token: str):
    """
    Verificar email del usuario mediante token

    Args:
        token: Token de verificación enviado por email

    Returns:
        Mensaje de confirmación si la verificación fue exitosa
    """
    pool = await db.get_pool()

    async with pool.acquire() as connection:
        # Buscar usuario con el token
        user = await connection.fetchrow(
            """
            SELECT id, email, is_verified, verification_token_expires
            FROM users
            WHERE verification_token = $1
            """,
            token
        )

        if not user:
            raise HTTPException(
                status_code=400,
                detail="Invalid verification token"
            )

        # Verificar si el email ya fue verificado
        if user['is_verified']:
            return {
                "message": "Email already verified",
                "already_verified": True
            }

        # Verificar si el token expiró
        if user['verification_token_expires'] < datetime.now(timezone.utc):
            raise HTTPException(
                status_code=400,
                detail="Verification token has expired. Please request a new verification email."
            )

        # Marcar email como verificado y limpiar el token
        await connection.execute(
            """
            UPDATE users
            SET is_verified = true,
                verification_token = NULL,
                verification_token_expires = NULL,
                updated_at = CURRENT_TIMESTAMP
            WHERE id = $1
            """,
            user['id']
        )

        return {
            "message": "Email verified successfully. You can now log in.",
            "email": user['email']
        }

@router.post("/resend-verification")
async def resend_verification_email(request: ResendVerificationRequest):
    """
    Reenviar email de verificación

    Args:
        request: Objeto con el email del usuario que solicita un nuevo token

    Returns:
        Confirmación de que se envió el email
    """
    pool = await db.get_pool()

    async with pool.acquire() as connection:
        # Buscar usuario por email
        user = await connection.fetchrow(
            "SELECT id, full_name, email, is_verified FROM users WHERE email = $1",
            request.email
        )

        if not user:
            raise HTTPException(
                status_code=404,
                detail="User not found"
            )

        # Si ya está verificado
        if user['is_verified']:
            return {
                "message": "Email already verified",
                "already_verified": True
            }

        # Generar nuevo token
        verification_token = generate_verification_token()
        token_expires = get_token_expiration()

        # Actualizar token en la base de datos
        await connection.execute(
            """
            UPDATE users
            SET verification_token = $1,
                verification_token_expires = $2
            WHERE id = $3
            """,
            verification_token, token_expires, user['id']
        )

        # Enviar email
        email_sent = await send_verification_email(
            to_email=user['email'],
            user_name=user['full_name'],
            verification_token=verification_token
        )

        if not email_sent:
            raise HTTPException(
                status_code=500,
                detail="Failed to send verification email"
            )

        return {
            "message": "Verification email sent successfully. Please check your inbox.",
            "email_sent": email_sent
        }