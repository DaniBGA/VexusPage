"""
Endpoint de diagnóstico para verificar configuración SMTP
USAR SOLO EN DESARROLLO - ELIMINAR EN PRODUCCIÓN
"""
from fastapi import APIRouter, HTTPException
from app.config import settings

router = APIRouter()

@router.get("/smtp-status")
async def check_smtp_status():
    """
    Verificar si las variables SMTP están configuradas
    ⚠️ ENDPOINT DE DEBUGGING - ELIMINAR EN PRODUCCIÓN
    """
    
    smtp_config = {
        "smtp_host": settings.SMTP_HOST or None,
        "smtp_port": settings.SMTP_PORT,
        "smtp_user": settings.SMTP_USER or None,
        "smtp_password_set": bool(settings.SMTP_PASSWORD),
        "email_from": settings.EMAIL_FROM,
        "frontend_url": settings.FRONTEND_URL,
    }
    
    # Verificar qué falta
    missing = []
    if not settings.SMTP_HOST:
        missing.append("SMTP_HOST")
    if not settings.SMTP_USER:
        missing.append("SMTP_USER")
    if not settings.SMTP_PASSWORD:
        missing.append("SMTP_PASSWORD")
    
    is_configured = len(missing) == 0
    
    return {
        "smtp_configured": is_configured,
        "missing_variables": missing,
        "config": smtp_config,
        "message": "SMTP está correctamente configurado ✅" if is_configured else f"Falta configurar: {', '.join(missing)} ⚠️"
    }
