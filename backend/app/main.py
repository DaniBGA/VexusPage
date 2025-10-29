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
    """Agregar headers CORS a las respuestas de error"""
    origin = request.headers.get("origin")
    if origin in settings.ALLOWED_ORIGINS or "*" in settings.ALLOWED_ORIGINS:
        response.headers["Access-Control-Allow-Origin"] = origin if origin else "*"
        response.headers["Access-Control-Allow-Credentials"] = "true"
        response.headers["Access-Control-Allow-Methods"] = "*"
        response.headers["Access-Control-Allow-Headers"] = "*"
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
    """Manejo de HTTPException"""
    response = JSONResponse(
        status_code=exc.status_code,
        content={"detail": exc.detail}
    )
    return add_cors_headers(response, request)

@app.exception_handler(asyncpg.PostgresError)
async def postgres_exception_handler(request: Request, exc: asyncpg.PostgresError):
    """Manejo de errores de PostgreSQL"""
    if settings.DEBUG:
        print(f"Database error: {exc}")
    response = JSONResponse(
        status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
        content={"detail": "Database error occurred"}
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

app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.ALLOWED_ORIGINS,  # Lee desde .env
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
    await db.connect()

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