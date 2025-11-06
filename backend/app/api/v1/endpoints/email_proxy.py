"""
Endpoint proxy para envío de emails
Usa el sistema SMTP del backend (funciona con Gmail App Password o SendGrid)
"""
from fastapi import APIRouter, HTTPException, status
from pydantic import BaseModel, EmailStr
from app.services.email import send_verification_email, send_contact_email, send_consultancy_email

router = APIRouter()

class SendVerificationEmailRequest(BaseModel):
    email: EmailStr
    user_name: str
    verification_token: str

class SendContactEmailRequest(BaseModel):
    name: str
    email: EmailStr
    subject: str = None
    message: str

class SendConsultancyEmailRequest(BaseModel):
    name: str
    email: EmailStr
    query: str


@router.post("/send-verification")
async def send_verification_email_proxy(request: SendVerificationEmailRequest):
    """
    Endpoint proxy para enviar email de verificación
    Usa el servicio SMTP del backend (Gmail o SendGrid)

    Args:
        request: Datos del email (email, nombre, token)

    Returns:
        Confirmación de envío
    """
    try:
        print(f"📧 [Email Proxy] Recibida solicitud de verificación para: {request.email}")

        # Usar el servicio SMTP del backend
        email_sent = await send_verification_email(
            to_email=request.email,
            user_name=request.user_name,
            verification_token=request.verification_token
        )

        if email_sent:
            print(f"✅ Email enviado exitosamente a: {request.email}")
            return {
                "success": True,
                "message": "Verification email sent successfully"
            }
        else:
            print(f"❌ No se pudo enviar email a: {request.email}")
            raise HTTPException(
                status_code=500,
                detail="Failed to send verification email. Please check SMTP configuration."
            )

    except Exception as e:
        print(f"❌ Error en proxy de email: {str(e)}")
        raise HTTPException(
            status_code=500,
            detail=f"Error sending email: {str(e)}"
        )


@router.post("/send-contact")
async def send_contact_email_proxy(request: SendContactEmailRequest):
    """
    Endpoint proxy para enviar emails de contacto
    Usa el servicio SMTP del backend
    """
    try:
        print(f"📧 [Email Proxy] Email de contacto de: {request.name} ({request.email})")

        # Usar el servicio SMTP del backend
        email_sent = await send_contact_email(
            client_name=request.name,
            client_email=request.email,
            message=request.message,
            subject=request.subject
        )

        if email_sent:
            print(f"✅ Email de contacto enviado exitosamente")
            return {
                "success": True,
                "message": "Contact email sent successfully"
            }
        else:
            print(f"❌ No se pudo enviar email de contacto")
            raise HTTPException(
                status_code=500,
                detail="Failed to send contact email. Please check SMTP configuration."
            )

    except Exception as e:
        print(f"❌ Error: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))


@router.post("/send-consultancy")
async def send_consultancy_email_proxy(request: SendConsultancyEmailRequest):
    """
    Endpoint proxy para enviar emails de consultoría
    Usa el servicio SMTP del backend
    """
    try:
        print(f"📧 [Email Proxy] Consulta de: {request.name} ({request.email})")

        # Usar el servicio SMTP del backend
        email_sent = await send_consultancy_email(
            to_email="grupovexus@gmail.com",
            client_name=request.name,
            client_email=request.email,
            query=request.query,
            subject=f"Consulta de Consultoría de {request.name}"
        )

        if email_sent:
            print(f"✅ Email de consultoría enviado exitosamente")
            return {
                "success": True,
                "message": "Consultancy email sent successfully"
            }
        else:
            print(f"❌ No se pudo enviar email de consultoría")
            raise HTTPException(
                status_code=500,
                detail="Failed to send consultancy email. Please check SMTP configuration."
            )

    except Exception as e:
        print(f"❌ Error: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))
