"""
Endpoint proxy para envío de emails
Oculta las credenciales de SendGrid del frontend
"""
from fastapi import APIRouter, HTTPException, status
from pydantic import BaseModel, EmailStr
from app.services.email_sendgrid import send_verification_email_http

router = APIRouter()

class SendVerificationEmailRequest(BaseModel):
    email: EmailStr
    user_name: str
    verification_token: str

@router.post("/send-verification")
async def send_verification_email_proxy(request: SendVerificationEmailRequest):
    """
    Endpoint proxy para enviar email de verificación desde el frontend
    Las credenciales de SendGrid están ocultas en el backend
    
    Args:
        request: Datos del email (email, nombre, token)
    
    Returns:
        Confirmación de envío
    """
    try:
        print(f"📧 Recibida solicitud de envío de email para: {request.email}")
        
        # Llamar al servicio de SendGrid (credenciales ocultas)
        success = await send_verification_email_http(
            to_email=request.email,
            user_name=request.user_name,
            verification_token=request.verification_token
        )
        
        if success:
            print(f"✅ Email enviado exitosamente a: {request.email}")
            return {
                "success": True,
                "message": "Verification email sent successfully"
            }
        else:
            print(f"❌ Error al enviar email a: {request.email}")
            raise HTTPException(
                status_code=500,
                detail="Failed to send verification email"
            )
            
    except Exception as e:
        print(f"❌ Error en proxy de email: {str(e)}")
        raise HTTPException(
            status_code=500,
            detail=f"Error sending email: {str(e)}"
        )
