"""
Endpoint proxy para envío de emails
Oculta las credenciales de EmailJS del frontend (solución para plan free sin dominios custom)
"""
from fastapi import APIRouter, HTTPException, status
from pydantic import BaseModel, EmailStr
import httpx
import os

router = APIRouter()

# Configuración de EmailJS (desde variables de entorno o hardcoded)
EMAILJS_SERVICE_ID = os.getenv("EMAILJS_SERVICE_ID", "service_80l1ykf")
EMAILJS_TEMPLATE_ID = os.getenv("EMAILJS_TEMPLATE_ID", "template_cwf419b")
EMAILJS_USER_ID = os.getenv("EMAILJS_USER_ID", "k1IUP2nR_rDmKZXcK")
EMAILJS_PRIVATE_KEY = os.getenv("EMAILJS_PRIVATE_KEY")  # Opcional: usar private key si la tienes

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
    Endpoint proxy para enviar email de verificación usando EmailJS desde el backend
    Solución para plan free de EmailJS que no permite dominios personalizados

    Args:
        request: Datos del email (email, nombre, token)

    Returns:
        Confirmación de envío
    """
    try:
        print(f"📧 [EmailJS Proxy] Recibida solicitud de email para: {request.email}")

        # Construir link de verificación
        frontend_url = os.getenv("FRONTEND_URL", "https://www.grupovexus.com")
        verification_link = f"{frontend_url}/pages/verify-email.html?token={request.verification_token}"

        # Parámetros del template de EmailJS
        template_params = {
            "user_name": request.user_name,
            "to_email": request.email,
            "verification_link": verification_link
        }

        # Payload para EmailJS API
        payload = {
            "service_id": EMAILJS_SERVICE_ID,
            "template_id": EMAILJS_TEMPLATE_ID,
            "user_id": EMAILJS_USER_ID,
            "template_params": template_params
        }

        # Si tienes private key, agrégala
        if EMAILJS_PRIVATE_KEY:
            payload["accessToken"] = EMAILJS_PRIVATE_KEY

        print(f"📤 Enviando a EmailJS API: {request.email}")

        # Hacer petición a EmailJS API
        async with httpx.AsyncClient(timeout=30.0) as client:
            response = await client.post(
                "https://api.emailjs.com/api/v1.0/email/send",
                json=payload,
                headers={"Content-Type": "application/json"}
            )

        if response.status_code == 200:
            print(f"✅ Email enviado exitosamente a: {request.email}")
            return {
                "success": True,
                "message": "Verification email sent successfully"
            }
        else:
            error_text = response.text
            print(f"❌ Error de EmailJS ({response.status_code}): {error_text}")
            raise HTTPException(
                status_code=500,
                detail=f"EmailJS error: {error_text}"
            )

    except httpx.TimeoutException:
        print(f"⏱️ Timeout al enviar email a: {request.email}")
        raise HTTPException(
            status_code=504,
            detail="Email service timeout"
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
    Endpoint proxy para enviar emails de contacto usando EmailJS
    """
    try:
        print(f"📧 [EmailJS Proxy] Email de contacto de: {request.name} ({request.email})")

        # Necesitarás crear un template diferente en EmailJS para contacto
        # Por ahora, usaremos el mismo endpoint pero con diferente template
        contact_template_id = os.getenv("EMAILJS_CONTACT_TEMPLATE_ID", "template_contact")

        template_params = {
            "from_name": request.name,
            "from_email": request.email,
            "subject": request.subject or f"Mensaje de contacto de {request.name}",
            "message": request.message,
            "to_email": "grupovexus@gmail.com"
        }

        payload = {
            "service_id": EMAILJS_SERVICE_ID,
            "template_id": contact_template_id,
            "user_id": EMAILJS_USER_ID,
            "template_params": template_params
        }

        async with httpx.AsyncClient(timeout=30.0) as client:
            response = await client.post(
                "https://api.emailjs.com/api/v1.0/email/send",
                json=payload,
                headers={"Content-Type": "application/json"}
            )

        if response.status_code == 200:
            print(f"✅ Email de contacto enviado exitosamente")
            return {
                "success": True,
                "message": "Contact email sent successfully"
            }
        else:
            print(f"❌ Error EmailJS: {response.text}")
            raise HTTPException(status_code=500, detail="Failed to send contact email")

    except Exception as e:
        print(f"❌ Error: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))
