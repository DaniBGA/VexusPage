"""
Endpoint de diagnóstico para verificar configuración SMTP
USAR SOLO EN DESARROLLO - ELIMINAR EN PRODUCCIÓN
"""
from fastapi import APIRouter, HTTPException
from pydantic import BaseModel, EmailStr
from app.config import settings
from app.services.email import send_verification_email, generate_verification_token
from app.services.email_sendgrid import send_verification_email_http

router = APIRouter()

class TestEmailRequest(BaseModel):
    email: EmailStr
    name: str = "Test User"
    use_http: bool = True  # Por defecto usar HTTP API

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
        "sendgrid_api_configured": bool(settings.SMTP_PASSWORD and settings.SMTP_PASSWORD.startswith('SG.')),
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
        "sendgrid_api_configured": smtp_config["sendgrid_api_configured"],
        "missing_variables": missing,
        "config": smtp_config,
        "message": "SendGrid HTTP API configurado ✅" if smtp_config["sendgrid_api_configured"] else f"Falta configurar: {', '.join(missing)} ⚠️",
        "note": "En Render Free, usa SendGrid HTTP API (use_http=true) ya que SMTP está bloqueado"
    }

@router.post("/test-email")
async def test_email_send(request: TestEmailRequest):
    """
    Enviar un email de prueba para verificar que el email funciona
    ⚠️ ENDPOINT DE DEBUGGING - ELIMINAR EN PRODUCCIÓN
    
    Ejemplo:
    POST /api/v1/debug/test-email
    {
        "email": "tu_email@gmail.com",
        "name": "Test User",
        "use_http": true  // true = HTTP API (Render Free), false = SMTP
    }
    """
    try:
        # Generar token de prueba
        test_token = generate_verification_token()
        
        method = "SendGrid HTTP API" if request.use_http else "SMTP"
        
        print(f"\n{'='*60}")
        print(f"🧪 TEST DE EMAIL INICIADO ({method})")
        print(f"📧 Destinatario: {request.email}")
        print(f"👤 Nombre: {request.name}")
        print(f"🔧 Método: {method}")
        print(f"{'='*60}\n")
        
        # Elegir método según el flag
        if request.use_http:
            # Usar SendGrid HTTP API (funciona en Render Free)
            result = await send_verification_email_http(
                to_email=request.email,
                user_name=request.name,
                verification_token=test_token
            )
        else:
            # Usar SMTP (bloqueado en Render Free)
            result = await send_verification_email(
                to_email=request.email,
                user_name=request.name,
                verification_token=test_token
            )
        
        print(f"\n{'='*60}")
        print(f"🧪 TEST DE EMAIL FINALIZADO")
        print(f"📊 Resultado: {'✅ ÉXITO' if result else '❌ FALLO'}")
        print(f"{'='*60}\n")
        
        if result:
            return {
                "success": True,
                "message": f"✅ Email de prueba enviado exitosamente a {request.email} usando {method}. Revisa tu bandeja (y spam).",
                "email_sent_to": request.email,
                "method": method
            }
        else:
            return {
                "success": False,
                "message": f"❌ Error al enviar email usando {method}. Revisa los logs del servidor.",
                "method": method,
                "recommendation": "En Render Free:\n1. Usa use_http=true (HTTP API funciona)\n2. SMTP está bloqueado (usa SendGrid HTTP API)\n3. Verifica que SMTP_PASSWORD sea tu API Key de SendGrid"
            }
            
    except Exception as e:
        print(f"❌ Excepción en test de email: {e}")
        import traceback
        traceback.print_exc()
        raise HTTPException(
            status_code=500,
            detail=f"Error al probar email: {str(e)}"
        )
