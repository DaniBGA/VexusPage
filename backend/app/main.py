"""
Aplicación principal FastAPI
"""
from datetime import datetime, timezone
from fastapi import FastAPI, Request, HTTPException, status
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from fastapi.responses import JSONResponse
from fastapi.exceptions import RequestValidationError
from app.config import settings
from app.core.database import db
from app.api.v1.router import api_router
from pathlib import Path
import asyncpg

app = FastAPI(
    title=settings.PROJECT_NAME,
    version=settings.VERSION,
    description="API Backend para la plataforma Vexus"
)

# ===== EXCEPTION HANDLERS =====

def add_cors_headers(response: JSONResponse, request: Request) -> JSONResponse:
    """
    Agregar headers CORS a las respuestas de error usando la misma configuración que el middleware.
    Esto asegura que los errores (400, 401, 403, etc.) tengan las mismas cabeceras CORS que las 
    respuestas exitosas.
    """
    # Usar la misma lógica que CORSMiddleware para determinar si el origin está permitido
    origin = request.headers.get("origin")
    origin_allowed = (
        "*" in settings.ALLOWED_ORIGINS or 
        origin in settings.ALLOWED_ORIGINS
    )
    
    if origin_allowed:
        # Aplicar la misma configuración que el middleware global
        response.headers["Access-Control-Allow-Origin"] = origin or "*"
        response.headers["Access-Control-Allow-Credentials"] = "true"
        response.headers["Access-Control-Allow-Methods"] = "GET,HEAD,PUT,PATCH,POST,DELETE,OPTIONS"
        response.headers["Access-Control-Allow-Headers"] = "content-type,authorization"
        response.headers["Vary"] = "Origin"
    
    if settings.DEBUG and not origin_allowed and origin:
        # En debug, loguear origins no permitidos para ayudar a diagnosticar
        print(f"⚠️ Origin no permitido: {origin}")
        print(f"   Origins permitidos: {settings.ALLOWED_ORIGINS}")
    
    return response

@app.exception_handler(RequestValidationError)
async def validation_exception_handler(request: Request, exc: RequestValidationError):
    """Manejo de errores de validación de Pydantic"""
    response = JSONResponse(
        status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
        content={
            "detail": exc.errors(),
            "body": exc.body
        }
    )
    return add_cors_headers(response, request)

@app.exception_handler(HTTPException)
async def http_exception_handler(request: Request, exc: HTTPException):
    """Manejo de HTTPException incluyendo errores 400 de validación"""
    # Asegurar que todas las cabeceras necesarias están presentes, especialmente
    # para errores 400 que pueden venir de validaciones de negocio
    response = JSONResponse(
        status_code=exc.status_code,
        content={"detail": exc.detail, "code": "EMAIL_ALREADY_REGISTERED" if "already registered" in str(exc.detail) else None}
    )
    return add_cors_headers(response, request)

@app.exception_handler(asyncpg.PostgresError)
async def postgres_exception_handler(request: Request, exc: asyncpg.PostgresError):
    """Manejo de errores de PostgreSQL"""
    if settings.DEBUG:
        print(f"Database error: {exc}")
    response = JSONResponse(
        status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
        content={"detail": "Database temporarily unavailable"}
    )
    return add_cors_headers(response, request)


@app.exception_handler(ConnectionRefusedError)
async def connection_refused_handler(request: Request, exc: ConnectionRefusedError):
    """Manejo de errores de conexión TCP (p. ej. DB no accesible)"""
    if settings.DEBUG:
        print(f"Connection refused: {exc}")
    response = JSONResponse(
        status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
        content={"detail": "Service temporarily unavailable (connection refused)"}
    )
    return add_cors_headers(response, request)

@app.exception_handler(Exception)
async def general_exception_handler(request: Request, exc: Exception):
    """Manejo de excepciones generales"""
    if settings.DEBUG:
        print(f"Unexpected error: {exc}")
        import traceback
        traceback.print_exc()
    response = JSONResponse(
        status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
        content={"detail": "Internal server error"}
    )
    return add_cors_headers(response, request)

# Configurar CORS (orígenes desde .env)
# Debug: mostrar orígenes permitidos al iniciar
print(f"🌐 CORS Configuration:")
print(f"   Allowed Origins: {settings.ALLOWED_ORIGINS}")
print(f"   Environment: {settings.ENVIRONMENT}")
print(f"   Debug Mode: {settings.DEBUG}")

# Mostrar información enmascarada sobre la conexión a la base de datos
try:
    from urllib.parse import urlparse
    db_url = settings.DATABASE_URL
    if db_url:
        parsed = urlparse(db_url)
        db_host = parsed.hostname or 'unknown'
        db_port = parsed.port or 5432
        print(f"🔎 DB host: {db_host}:{db_port} (credentials masked)")
    else:
        print("🔎 DB host: none (DATABASE_URL not set)")
except Exception:
    # Nunca detener el arranque por un fallo de logging
    print("🔎 DB host: unable to parse DATABASE_URL")

# Crear una instancia de CORSMiddleware con nuestra configuración
cors_middleware = CORSMiddleware(
    app=app,
    allow_origins=settings.ALLOWED_ORIGINS,  # Lee desde .env
    allow_credentials=True,
    allow_methods=["GET", "POST", "PUT", "DELETE", "OPTIONS", "PATCH"],
    allow_headers=["*"],
    expose_headers=["*"],
    max_age=3600,
)

# Asignar el middleware y guardar una referencia para usarlo en los handlers de error
app.add_middleware(CORSMiddleware,
    allow_origins=settings.ALLOWED_ORIGINS,
    allow_credentials=True,
    allow_methods=["GET", "POST", "PUT", "DELETE", "OPTIONS", "PATCH"],
    allow_headers=["*"],
    expose_headers=["*"],
    max_age=3600,
)

# Incluir routers PRIMERO (antes de static files para que tengan prioridad)
app.include_router(api_router, prefix=settings.API_V1_PREFIX)

# Servir archivos estáticos (uploads)
# NOTA: Comentado para entornos serverless (Vercel/Lambda tienen filesystem read-only)
# En producción, los archivos deben subirse a almacenamiento externo (Supabase Storage, S3, etc.)
UPLOAD_DIR = Path("uploads")
# UPLOAD_DIR.mkdir(parents=True, exist_ok=True)  # ❌ No funciona en serverless (read-only filesystem)
# app.mount("/uploads", StaticFiles(directory="uploads"), name="uploads")  # ❌ Tampoco funciona en serverless

# Eventos de inicio y cierre
@app.on_event("startup")
async def startup_event():
    # Validar la configuración de la cadena de conexión antes de intentar conectar
    try:
        from urllib.parse import urlparse
        dsn = settings.DATABASE_URL
        if not dsn:
            print("❌ DATABASE_URL no está configurada. Revisa tus variables de entorno.")
        else:
            parsed = urlparse(dsn)
            scheme = (parsed.scheme or '').lower()
            if scheme not in ('postgresql', 'postgres'):
                print(f"❌ DATABASE_URL inválida. Se esperaba esquema 'postgresql' o 'postgres', se obtuvo '{scheme}'")
    except Exception:
        # No bloquear el arranque por la validación; db.connect mostrará errores si hay problemas
        pass

    # Intentar conectar a la base de datos pero NO fallar el arranque si no está disponible.
    # Esto evita que todos los workers mueran si el pooler remoto rechaza conexiones
    # temporalmente (por ejemplo límites de conexión del pooler). Las rutas que
    # dependen de la BD seguirán devolviendo 503 gracias a los handlers añadidos.
    try:
        # Intento rápido de conexión TCP al host:port para diagnóstico (más claro que
        # sólo confiar en asyncpg error stack traces cuando hay refusals)
        try:
            from urllib.parse import urlparse
            import asyncio

            dsn = settings.DATABASE_URL
            if dsn:
                parsed = urlparse(dsn)
                host = parsed.hostname
                port = parsed.port or 5432
                if host and 'sslmode=require' not in dsn.lower():
                    # Skip TCP check for SSL connections as they may block non-SSL attempts
                    if settings.DEBUG:
                        print(f"🔌 Checking TCP connectivity to DB {host}:{port} before pool create")
                    # Intento una conexión TCP simple con timeout corto
                    try:
                        await asyncio.wait_for(asyncio.open_connection(host, port), timeout=3.0)
                        if settings.DEBUG:
                            print(f"🔌 TCP connection to {host}:{port} succeeded")
                    except Exception as tcp_exc:
                        print(f"⚠️ TCP connectivity check failed for {host}:{port}: {tcp_exc}")

        except Exception:
            # No bloquear el arranque por fallos en la comprobación de conectividad
            pass

        await db.connect()
    except Exception as e:
        # Registrar el error pero permitir que la app siga arrancando. Las rutas
        # que necesiten BD deben manejar el error y devolver 503.
        print(f"❌ DB connect failed during startup: {e}")

@app.on_event("shutdown")
async def shutdown_event():
    await db.disconnect()

# Middleware de limpieza de sesiones
@app.middleware("http")
async def cleanup_expired_sessions(request: Request, call_next):
    if hasattr(request.state, 'cleanup_sessions'):
        pool = await db.get_pool()
        async with pool.acquire() as connection:
            await connection.execute(
                "DELETE FROM user_sessions WHERE expires_at < CURRENT_TIMESTAMP"
            )
    
    response = await call_next(request)
    return response

# Endpoint de salud
@app.get("/health")
async def health_check():
    try:
        pool = await db.get_pool()
        async with pool.acquire() as connection:
            await connection.fetchval("SELECT 1")
        return {
            "status": "healthy",
            "database": "connected",
            "timestamp": datetime.now(timezone.utc).isoformat()
        }
    except Exception as e:
        return {
            "status": "unhealthy",
            "database": "disconnected",
            "error": str(e),
            "timestamp": datetime.now(timezone.utc).isoformat()
        }

# Endpoint raíz
@app.get("/")
async def root():
    return {
        "name": settings.PROJECT_NAME,
        "version": settings.VERSION,
        "description": "Backend API para la plataforma Vexus",
        "docs": "/docs",
        "health": "/health"
    }

# Endpoint de debug CORS (temporal)
@app.get("/debug/cors")
async def debug_cors():
    return {
        "allowed_origins": settings.ALLOWED_ORIGINS,
        "environment": settings.ENVIRONMENT,
        "debug": settings.DEBUG
    }

if __name__ == "__main__":
    import uvicorn
    import os
    port = int(os.environ.get("PORT", 8000))
    uvicorn.run(app, host="0.0.0.0", port=port)