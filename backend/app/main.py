"""
Aplicación principal FastAPI
"""
from datetime import datetime
from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from app.config import settings
from app.core.database import db
from app.api.v1.router import api_router

app = FastAPI(
    title=settings.PROJECT_NAME,
    version=settings.VERSION,
    description="API Backend para la plataforma Vexus"
)

# Configurar CORS (orígenes desde .env)
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.ALLOWED_ORIGINS,  # Lee desde .env
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Incluir routers
app.include_router(api_router, prefix=settings.API_V1_PREFIX)

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
            "timestamp": datetime.utcnow().isoformat()
        }
    except Exception as e:
        return {
            "status": "unhealthy",
            "database": "disconnected",
            "error": str(e),
            "timestamp": datetime.utcnow().isoformat()
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

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000, reload=True)