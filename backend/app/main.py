"""
Aplicación principal FastAPI - Versión corregida
"""
from datetime import datetime, timezone
from fastapi import FastAPI, Request, HTTPException, status
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from fastapi.exceptions import RequestValidationError
from app.config import settings
from app.core.database import db
from app.api.v1.router import api_router
import asyncpg
import asyncio

app = FastAPI(
    title=settings.PROJECT_NAME,
    version=settings.VERSION,
    description="API Backend para la plataforma Vexus"
)

# ===== CONFIGURAR CORS PRIMERO (ANTES DE TODO) =====
print(f"🌐 CORS Configuration:")
print(f"   Allowed Origins: {settings.ALLOWED_ORIGINS}")
print(f"   Environment: {settings.ENVIRONMENT}")
print(f"   Debug Mode: {settings.DEBUG}")

# IMPORTANTE: Agregar middleware CORS antes que nada
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.ALLOWED_ORIGINS,
    allow_credentials=True,
    allow_methods=["GET", "POST", "PUT", "DELETE", "OPTIONS", "PATCH"],
    allow_headers=["*"],
    expose_headers=["*"],
    max_age=3600,
)

# ===== EXCEPTION HANDLERS =====

def add_cors_headers(response: JSONResponse, request: Request) -> JSONResponse:
    """Agregar headers CORS a las respuestas de error"""
    origin = request.headers.get("origin")
    origin_allowed = (
        "*" in settings.ALLOWED_ORIGINS or 
        origin in settings.ALLOWED_ORIGINS
    )
    
    if origin_allowed and origin:
        response.headers["Access-Control-Allow-Origin"] = origin
        response.headers["Access-Control-Allow-Credentials"] = "true"
        response.headers["Access-Control-Allow-Methods"] = "GET,HEAD,PUT,PATCH,POST,DELETE,OPTIONS"
        response.headers["Access-Control-Allow-Headers"] = "*"
        response.headers["Vary"] = "Origin"
    
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
    response = JSONResponse(
        status_code=exc.status_code,
        content={
            "detail": exc.detail,
            "code": "EMAIL_ALREADY_REGISTERED" if "already registered" in str(exc.detail).lower() else None
        }
    )
    return add_cors_headers(response, request)

@app.exception_handler(asyncpg.PostgresError)
async def postgres_exception_handler(request: Request, exc: asyncpg.PostgresError):
    """Manejo de errores de PostgreSQL"""
    if settings.DEBUG:
        print(f"❌ Database error: {exc}")
    response = JSONResponse(
        status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
        content={"detail": "Database temporarily unavailable"}
    )
    return add_cors_headers(response, request)

@app.exception_handler(ConnectionRefusedError)
async def connection_refused_handler(request: Request, exc: ConnectionRefusedError):
    """Manejo de errores de conexión TCP"""
    if settings.DEBUG:
        print(f"❌ Connection refused: {exc}")
    response = JSONResponse(
        status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
        content={"detail": "Service temporarily unavailable - database connection failed"}
    )
    return add_cors_headers(response, request)

@app.exception_handler(Exception)
async def general_exception_handler(request: Request, exc: Exception):
    """Manejo de excepciones generales"""
    if settings.DEBUG:
        print(f"❌ Unexpected error: {exc}")
        import traceback
        traceback.print_exc()
    response = JSONResponse(
        status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
        content={"detail": "Internal server error"}
    )
    return add_cors_headers(response, request)

# Incluir routers
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

# Eventos de inicio y cierre
@app.on_event("startup")
async def startup_event():
    """Inicializar conexión a base de datos con reintentos"""
    print("🚀 Starting application...")
    
    # Validar DATABASE_URL
    if not settings.DATABASE_URL:
        print("❌ ERROR: DATABASE_URL no configurada")
        return
    
    print(f"📊 Connecting to database...")
    max_retries = 3
    retry_delay = 2
    
    for attempt in range(1, max_retries + 1):
        try:
            print(f"🔌 Attempt {attempt}/{max_retries} to connect to database...")
            await asyncio.wait_for(db.connect(), timeout=10.0)
            print("✅ Database connected successfully")
            return
        except asyncio.TimeoutError:
            print(f"⏱️ Connection attempt {attempt} timed out")
        except Exception as e:
            print(f"❌ Connection attempt {attempt} failed: {e}")
        
        if attempt < max_retries:
            print(f"⏳ Waiting {retry_delay}s before retry...")
            await asyncio.sleep(retry_delay)
            retry_delay *= 2
    
    print("❌ All database connection attempts failed")
    print("⚠️ Application will start but database operations will fail")

@app.on_event("shutdown")
async def shutdown_event():
    """Cerrar conexión a base de datos"""
    print("🛑 Shutting down application...")
    try:
        await db.disconnect()
        print("✅ Database disconnected")
    except Exception as e:
        print(f"⚠️ Error disconnecting database: {e}")

# Middleware de limpieza de sesiones
@app.middleware("http")
async def cleanup_expired_sessions(request: Request, call_next):
    """Limpiar sesiones expiradas periódicamente"""
    if hasattr(request.state, 'cleanup_sessions'):
        try:
            pool = await db.get_pool()
            async with pool.acquire() as connection:
                await connection.execute(
                    "DELETE FROM user_sessions WHERE expires_at < CURRENT_TIMESTAMP"
                )
        except Exception as e:
            if settings.DEBUG:
                print(f"⚠️ Session cleanup failed: {e}")
    
    response = await call_next(request)
    return response

# Endpoint de salud
@app.get("/health")
async def health_check():
    """Verificar estado de la aplicación y base de datos"""
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
        return JSONResponse(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            content={
                "status": "unhealthy",
                "database": "disconnected",
                "error": str(e),
                "timestamp": datetime.now(timezone.utc).isoformat()
            }
        )

# Endpoint raíz
@app.get("/")
async def root():
    """Información de la API"""
    return {
        "name": settings.PROJECT_NAME,
        "version": settings.VERSION,
        "description": "Backend API para la plataforma Vexus",
        "docs": "/docs",
        "health": "/health"
    }

# Endpoint de debug CORS
@app.get("/debug/cors")
async def debug_cors(request: Request):
    """Debug de configuración CORS"""
    return {
        "allowed_origins": settings.ALLOWED_ORIGINS,
        "environment": settings.ENVIRONMENT,
        "debug": settings.DEBUG,
        "request_origin": request.headers.get("origin"),
        "request_headers": dict(request.headers)
    }

if __name__ == "__main__":
    import uvicorn
    import os
    port = int(os.environ.get("PORT", 8000))
    uvicorn.run(
        app, 
        host="0.0.0.0", 
        port=port,
        log_level="info"
    )