"""
Servicio de envío de emails usando SendGrid HTTP API
Funciona en Render Free (no usa SMTP bloqueado)
"""
from sendgrid import SendGridAPIClient
from sendgrid.helpers.mail import Mail, Email, To, Content
from app.config import settings
from typing import Optional


async def send_verification_email_http(
    to_email: str,
    user_name: str,
    verification_token: str,
    frontend_url: Optional[str] = None
) -> bool:
    """
    Enviar email de verificación usando SendGrid HTTP API
    
    Args:
        to_email: Email del destinatario
        user_name: Nombre del usuario
        verification_token: Token de verificación
        frontend_url: URL del frontend (opcional)
        
    Returns:
        True si el email se envió correctamente, False en caso contrario
    """
    try:
        # Verificar que tengamos la API Key
        if not settings.SMTP_PASSWORD or not settings.SMTP_PASSWORD.startswith('SG.'):
            print(f"⚠️ SendGrid API Key no configurada")
            print(f"📊 SMTP_PASSWORD debe empezar con 'SG.'")
            return False
        
        # Construir el enlace de verificación
        base_url = frontend_url or settings.FRONTEND_URL
        verification_link = f"{base_url}/pages/verify-email.html?token={verification_token}"
        
        print(f"📧 Preparando email con SendGrid HTTP API para {to_email}")
        
        # Contenido del email (versión simplificada HTML)
        html_content = f"""
        <!DOCTYPE html>
        <html lang="es">
        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>Verificación de Email - Vexus</title>
        </head>
        <body style="font-family: Arial, sans-serif; background: #f5f5f5; padding: 20px;">
            <div style="max-width: 600px; margin: 0 auto; background: white; border-radius: 8px; padding: 40px; box-shadow: 0 2px 8px rgba(0,0,0,0.1);">
                <h1 style="color: #d4af37; text-align: center; font-size: 32px; margin-bottom: 10px;">VEXUS</h1>
                <p style="text-align: center; color: #666; margin-bottom: 30px;">Diseño Elegante</p>
                
                <h2 style="color: #333;">¡Hola {user_name}!</h2>
                
                <p style="color: #666; line-height: 1.6;">
                    Bienvenido a Vexus. Para comenzar a disfrutar de todos nuestros servicios, 
                    necesitamos verificar tu dirección de email.
                </p>
                
                <div style="text-align: center; margin: 30px 0;">
                    <a href="{verification_link}" 
                       style="background: linear-gradient(135deg, #d4af37 0%, #c49a2f 100%); 
                              color: #0a0a0a; 
                              text-decoration: none; 
                              padding: 16px 40px; 
                              border-radius: 8px; 
                              font-weight: bold; 
                              display: inline-block;">
                        VERIFICAR MI EMAIL
                    </a>
                </div>
                
                <div style="background: rgba(212, 175, 55, 0.1); 
                            border-left: 4px solid #d4af37; 
                            padding: 15px; 
                            margin: 25px 0;">
                    <p style="margin: 0; color: #333; font-size: 14px;">
                        <strong>⏱️ Importante:</strong> Este enlace expirará en 24 horas.
                    </p>
                </div>
                
                <p style="font-size: 14px; color: #999; margin-top: 30px;">
                    Si el botón no funciona, copia y pega este enlace en tu navegador:
                </p>
                <p style="font-size: 12px; color: #666; word-break: break-all;">
                    {verification_link}
                </p>
                
                <hr style="border: none; border-top: 1px solid #eee; margin: 30px 0;">
                
                <p style="text-align: center; color: #999; font-size: 12px;">
                    © 2025 Vexus. Todos los derechos reservados.
                </p>
            </div>
        </body>
        </html>
        """
        
        # Crear el mensaje
        message = Mail(
            from_email=Email(settings.EMAIL_FROM, "Vexus"),
            to_emails=To(to_email),
            subject="Verifica tu email - Vexus",
            html_content=Content("text/html", html_content)
        )
        
        # Enviar usando la API de SendGrid
        print(f"🔌 Enviando email via SendGrid HTTP API...")
        sg = SendGridAPIClient(api_key=settings.SMTP_PASSWORD)
        response = sg.send(message)
        
        print(f"✅ Email enviado exitosamente a {to_email}")
        print(f"📊 Status Code: {response.status_code}")
        
        return True
        
    except Exception as e:
        print(f"❌ Error al enviar email via SendGrid API: {str(e)}")
        import traceback
        traceback.print_exc()
        return False


async def send_contact_email_http(
    client_name: str,
    client_email: str,
    message: str,
    subject: Optional[str] = None
) -> bool:
    """
    Enviar email de contacto usando SendGrid HTTP API
    
    Args:
        client_name: Nombre del cliente
        client_email: Email del cliente
        message: Mensaje del cliente
        subject: Asunto del email (opcional)
        
    Returns:
        True si el email se envió correctamente
    """
    try:
        if not settings.SMTP_PASSWORD or not settings.SMTP_PASSWORD.startswith('SG.'):
            print(f"⚠️ SendGrid API Key no configurada")
            return False
        
        email_subject = subject or f"Nuevo mensaje de contacto de {client_name}"
        
        html_content = f"""
        <!DOCTYPE html>
        <html>
        <body style="font-family: Arial, sans-serif; padding: 20px;">
            <h2 style="color: #d4af37;">Nuevo Mensaje de Contacto</h2>
            <p><strong>Nombre:</strong> {client_name}</p>
            <p><strong>Email:</strong> {client_email}</p>
            <p><strong>Mensaje:</strong></p>
            <div style="background: #f5f5f5; padding: 15px; border-radius: 4px;">
                {message}
            </div>
        </body>
        </html>
        """
        
        mail_message = Mail(
            from_email=Email(settings.EMAIL_FROM, "Vexus Contact Form"),
            to_emails=To(settings.EMAIL_FROM),
            subject=email_subject,
            html_content=Content("text/html", html_content)
        )
        
        # Set Reply-To
        mail_message.reply_to = Email(client_email, client_name)
        
        sg = SendGridAPIClient(api_key=settings.SMTP_PASSWORD)
        response = sg.send(mail_message)
        
        print(f"✅ Email de contacto enviado (Status: {response.status_code})")
        return True
        
    except Exception as e:
        print(f"❌ Error enviando email de contacto: {e}")
        return False
