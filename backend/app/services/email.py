"""
Servicio de envío de emails
"""
import aiosmtplib
import secrets
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
from datetime import datetime, timedelta, timezone
from typing import Optional
from app.config import settings
import asyncio


def generate_verification_token() -> str:
    """Generar token de verificación único"""
    return secrets.token_urlsafe(32)


def get_token_expiration() -> datetime:
    """Obtener fecha de expiración del token (24 horas)"""
    return datetime.now(timezone.utc) + timedelta(hours=24)


def get_email_verification_template(user_name: str, verification_link: str) -> str:
    """
    Plantilla HTML para email de verificación
    Respeta la estética de la página web de Vexus
    """
    return f"""
    <!DOCTYPE html>
    <html lang="es">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Verificación de Email - Vexus</title>
        <style>
            * {{
                margin: 0;
                padding: 0;
                box-sizing: border-box;
            }}

            body {{
                font-family: 'Space Grotesk', -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
                background: linear-gradient(135deg, #0a0a0a 0%, #1a1a1a 100%);
                padding: 40px 20px;
                color: #e0e0e0;
            }}

            .email-container {{
                max-width: 600px;
                margin: 0 auto;
                background: #1a1a1a;
                border: 1px solid rgba(212, 175, 55, 0.2);
                border-radius: 16px;
                overflow: hidden;
                box-shadow: 0 10px 40px rgba(0, 0, 0, 0.5);
            }}

            .header {{
                background: linear-gradient(135deg, #0a0a0a 0%, #1a1a1a 100%);
                padding: 40px 30px;
                text-align: center;
                border-bottom: 2px solid #d4af37;
            }}

            .logo {{
                font-size: 36px;
                font-weight: 900;
                color: #d4af37;
                letter-spacing: 4px;
                text-transform: uppercase;
                margin-bottom: 10px;
            }}

            .subtitle {{
                color: #a0a0a0;
                font-size: 14px;
                letter-spacing: 2px;
            }}

            .content {{
                padding: 40px 30px;
            }}

            h1 {{
                color: #ffffff;
                font-size: 24px;
                margin-bottom: 20px;
                font-weight: 700;
            }}

            p {{
                color: #c0c0c0;
                line-height: 1.8;
                margin-bottom: 20px;
                font-size: 16px;
            }}

            .welcome-text {{
                font-size: 18px;
                color: #d4af37;
                margin-bottom: 30px;
            }}

            .verify-button {{
                display: inline-block;
                background: linear-gradient(135deg, #d4af37 0%, #c49a2f 100%);
                color: #0a0a0a;
                text-decoration: none;
                padding: 16px 40px;
                border-radius: 8px;
                font-weight: 700;
                font-size: 16px;
                letter-spacing: 1px;
                margin: 20px 0;
                transition: all 0.3s ease;
                text-align: center;
            }}

            .verify-button:hover {{
                background: linear-gradient(135deg, #c49a2f 0%, #b38a28 100%);
                transform: translateY(-2px);
                box-shadow: 0 5px 20px rgba(212, 175, 55, 0.4);
            }}

            .button-container {{
                text-align: center;
                margin: 30px 0;
            }}

            .info-box {{
                background: rgba(212, 175, 55, 0.1);
                border-left: 4px solid #d4af37;
                padding: 20px;
                margin: 25px 0;
                border-radius: 4px;
            }}

            .info-box p {{
                margin: 0;
                color: #e0e0e0;
                font-size: 14px;
            }}

            .footer {{
                background: #0a0a0a;
                padding: 30px;
                text-align: center;
                border-top: 1px solid rgba(212, 175, 55, 0.2);
            }}

            .footer p {{
                color: #808080;
                font-size: 12px;
                margin: 5px 0;
            }}

            .footer a {{
                color: #d4af37;
                text-decoration: none;
            }}

            .footer a:hover {{
                text-decoration: underline;
            }}

            .divider {{
                height: 1px;
                background: linear-gradient(to right, transparent, #d4af37, transparent);
                margin: 30px 0;
            }}

            @media (max-width: 600px) {{
                .email-container {{
                    margin: 0;
                    border-radius: 0;
                }}

                .content {{
                    padding: 30px 20px;
                }}

                .header {{
                    padding: 30px 20px;
                }}

                .logo {{
                    font-size: 28px;
                }}
            }}
        </style>
    </head>
    <body>
        <div class="email-container">
            <div class="header">
                <div class="logo">VEXUS</div>
                <div class="subtitle">DISEÑO ELEGANTE</div>
            </div>

            <div class="content">
                <p class="welcome-text">¡Hola {user_name}!</p>

                <h1>Bienvenido a Vexus</h1>

                <p>
                    Estamos emocionados de tenerte en nuestra comunidad. Para comenzar a disfrutar
                    de todos nuestros servicios y herramientas, necesitamos verificar tu dirección de email.
                </p>

                <div class="button-container">
                    <a href="{verification_link}" class="verify-button">
                        VERIFICAR MI EMAIL
                    </a>
                </div>

                <div class="info-box">
                    <p>
                        <strong>⏱️ Importante:</strong> Este enlace de verificación expirará en 24 horas.
                        Si no solicitaste esta cuenta, puedes ignorar este email de forma segura.
                    </p>
                </div>

                <div class="divider"></div>

                <p style="font-size: 14px; color: #a0a0a0;">
                    Si el botón no funciona, copia y pega este enlace en tu navegador:
                </p>
                <p style="font-size: 12px; color: #808080; word-break: break-all;">
                    {verification_link}
                </p>
            </div>

            <div class="footer">
                <p style="margin-bottom: 15px;">
                    <strong style="color: #d4af37;">VEXUS</strong> - Diseño Web Premium
                </p>
                <p>
                    Este es un email automático, por favor no respondas a este mensaje.
                </p>
                <p>
                    © 2025 Vexus. Todos los derechos reservados.
                </p>
            </div>
        </div>
    </body>
    </html>
    """


async def send_verification_email(
    to_email: str,
    user_name: str,
    verification_token: str,
    frontend_url: Optional[str] = None
) -> bool:
    """
    Enviar email de verificación al usuario

    Args:
        to_email: Email del destinatario
        user_name: Nombre del usuario
        verification_token: Token de verificación
        frontend_url: URL del frontend (opcional, se usa la configuración si no se proporciona)

    Returns:
        True si el email se envió correctamente, False en caso contrario
    """
    try:
        # Construir el enlace de verificación usando la configuración
        base_url = frontend_url or settings.FRONTEND_URL
        verification_link = f"{base_url}/pages/verify-email.html?token={verification_token}"

        # Crear mensaje
        msg = MIMEMultipart('alternative')
        msg['Subject'] = 'Verifica tu email - Vexus'
        msg['From'] = settings.EMAIL_FROM
        msg['To'] = to_email

        # Crear contenido HTML
        html_content = get_email_verification_template(user_name, verification_link)

        # Texto plano como alternativa
        text_content = f"""
        Hola {user_name},

        Bienvenido a Vexus!

        Para verificar tu email, por favor haz clic en el siguiente enlace:
        {verification_link}

        Este enlace expirará en 24 horas.

        Si no solicitaste esta cuenta, puedes ignorar este email de forma segura.

        © 2025 Vexus. Todos los derechos reservados.
        """

        # Adjuntar ambas partes
        part1 = MIMEText(text_content, 'plain')
        part2 = MIMEText(html_content, 'html')

        msg.attach(part1)
        msg.attach(part2)

        # Enviar email si las credenciales SMTP están configuradas
        smtp_issues = []
        if not settings.SMTP_HOST:
            smtp_issues.append("SMTP_HOST")
        if not settings.SMTP_USER:
            smtp_issues.append("SMTP_USER")
        if not settings.SMTP_PASSWORD:
            smtp_issues.append("SMTP_PASSWORD")
        
        if smtp_issues:
            missing = ", ".join(smtp_issues)
            print(f"⚠️ SMTP no configurado. Falta configurar: {missing}")
            print(f"📊 Valores actuales:")
            print(f"   SMTP_HOST={settings.SMTP_HOST or '(no configurado)'}")
            print(f"   SMTP_PORT={settings.SMTP_PORT}")
            print(f"   SMTP_USER={settings.SMTP_USER or '(no configurado)'}")
            print(f"   EMAIL_FROM={settings.EMAIL_FROM}")
            print(f"📧 Email pendiente para {to_email}: {verification_link}")
            # SMTP no configurado - no bloquear el registro
            return False

        # Conectar al servidor SMTP de forma ASÍNCRONA con timeout aumentado
        try:
            print(f"🔌 Conectando a SMTP: {settings.SMTP_HOST}:{settings.SMTP_PORT} para {to_email}")

            # Crear cliente SMTP asíncrono con timeout de 30 segundos
            # Render Free puede ser lento, especialmente en el primer request
            smtp_client = aiosmtplib.SMTP(
                hostname=settings.SMTP_HOST,
                port=settings.SMTP_PORT,
                timeout=30.0,  # Aumentado a 30 segundos para Render Free
                use_tls=False  # Usaremos STARTTLS manualmente
            )

            async with smtp_client:
                print(f"🔐 Conectando al servidor SMTP...")
                await smtp_client.connect()

                print(f"🔒 Iniciando STARTTLS...")
                await smtp_client.starttls()

                print(f"👤 Autenticando como {settings.SMTP_USER}...")
                await smtp_client.login(settings.SMTP_USER, settings.SMTP_PASSWORD)

                print(f"📨 Enviando mensaje a {to_email}...")
                await smtp_client.send_message(msg)

            print(f"✅ Email de verificación enviado exitosamente a {to_email}")
            return True

        except asyncio.TimeoutError:
            print(f"⏱️ TIMEOUT: El servidor SMTP no respondió en 30 segundos para {to_email}")
            print(f"💡 Esto puede ocurrir en Render Free por cold start o restricciones de red")
            print(f"💡 Considera usar SendGrid API en lugar de SMTP")
            return False
        except aiosmtplib.SMTPAuthenticationError as auth_error:
            print(f"🔐 ERROR DE AUTENTICACIÓN SMTP para {to_email}")
            print(f"   Código: {auth_error.code}")
            print(f"   Mensaje: {auth_error.message}")
            print(f"   Verifica que SMTP_PASSWORD sea un App Password válido de Gmail")
            return False
        except aiosmtplib.SMTPException as smtp_error:
            print(f"❌ ERROR SMTP al enviar email a {to_email}")
            print(f"   Tipo: {type(smtp_error).__name__}")
            print(f"   Detalles: {smtp_error}")
            return False
        except Exception as smtp_error:
            print(f"❌ ERROR INESPERADO al enviar email a {to_email}")
            print(f"   Tipo: {type(smtp_error).__name__}")
            print(f"   Mensaje: {str(smtp_error)}")
            import traceback
            traceback.print_exc()
            return False

    except Exception as e:
        print(f"❌ Error al enviar email de verificación: {str(e)}")
        return False


async def send_contact_email(
    client_name: str,
    client_email: str,
    message: str,
    subject: Optional[str] = None
) -> bool:
    """
    Enviar email de contacto general a grupovexus@gmail.com

    Args:
        client_name: Nombre del cliente
        client_email: Email del cliente
        message: Mensaje del cliente
        subject: Asunto del email (opcional)

    Returns:
        True si el email se envió correctamente, False en caso contrario
    """
    try:
        # Email destino (el de Vexus)
        to_email = settings.EMAIL_FROM
        email_subject = subject if subject else f"Nuevo mensaje de contacto de {client_name}"

        # Crear mensaje
        msg = MIMEMultipart('alternative')
        msg['Subject'] = email_subject
        msg['From'] = settings.EMAIL_FROM
        msg['To'] = to_email
        msg['Reply-To'] = client_email

        # Contenido HTML
        html_content = f"""
        <!DOCTYPE html>
        <html lang="es">
        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>{email_subject}</title>
            <style>
                body {{
                    font-family: 'Space Grotesk', -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
                    background: #f5f5f5;
                    padding: 20px;
                    margin: 0;
                }}
                .email-container {{
                    max-width: 600px;
                    margin: 0 auto;
                    background: white;
                    border-radius: 12px;
                    overflow: hidden;
                    box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
                }}
                .header {{
                    background: linear-gradient(135deg, #0a0a0a 0%, #1a1a1a 100%);
                    color: white;
                    padding: 30px;
                    text-align: center;
                }}
                .logo {{
                    font-size: 32px;
                    font-weight: 900;
                    color: #d4af37;
                    letter-spacing: 3px;
                    margin-bottom: 10px;
                }}
                .subtitle {{
                    color: #a0a0a0;
                    font-size: 12px;
                    letter-spacing: 2px;
                }}
                .content {{
                    padding: 30px;
                }}
                h2 {{
                    color: #0a0a0a;
                    margin-bottom: 20px;
                    font-size: 20px;
                }}
                .info-row {{
                    margin: 15px 0;
                    padding: 15px;
                    background: #f9f9f9;
                    border-left: 4px solid #d4af37;
                    border-radius: 4px;
                }}
                .info-label {{
                    font-weight: 700;
                    color: #333;
                    margin-bottom: 5px;
                }}
                .info-value {{
                    color: #666;
                    line-height: 1.6;
                }}
                .message-box {{
                    background: #fafafa;
                    padding: 20px;
                    border-radius: 8px;
                    border: 1px solid #e0e0e0;
                    margin: 20px 0;
                }}
                .footer {{
                    background: #f5f5f5;
                    padding: 20px;
                    text-align: center;
                    color: #999;
                    font-size: 12px;
                }}
            </style>
        </head>
        <body>
            <div class="email-container">
                <div class="header">
                    <div class="logo">VEXUS</div>
                    <div class="subtitle">NUEVO MENSAJE DE CONTACTO</div>
                </div>

                <div class="content">
                    <h2>📬 Nuevo Mensaje de Contacto</h2>

                    <div class="info-row">
                        <div class="info-label">👤 Nombre:</div>
                        <div class="info-value">{client_name}</div>
                    </div>

                    <div class="info-row">
                        <div class="info-label">📧 Email:</div>
                        <div class="info-value"><a href="mailto:{client_email}">{client_email}</a></div>
                    </div>

                    {f'''<div class="info-row">
                        <div class="info-label">📋 Asunto:</div>
                        <div class="info-value">{subject}</div>
                    </div>''' if subject else ''}

                    <div class="message-box">
                        <div class="info-label" style="margin-bottom: 10px;">💬 Mensaje:</div>
                        <div class="info-value">{message}</div>
                    </div>

                    <p style="color: #666; font-size: 14px; margin-top: 20px;">
                        Puedes responder directamente a este email para contactar al cliente.
                    </p>
                </div>

                <div class="footer">
                    <p><strong>VEXUS</strong> - Sistema de Gestión de Contactos</p>
                    <p>© 2025 Vexus. Todos los derechos reservados.</p>
                </div>
            </div>
        </body>
        </html>
        """

        # Texto plano como alternativa
        text_content = f"""
        NUEVO MENSAJE DE CONTACTO

        Nombre: {client_name}
        Email: {client_email}
        {f'Asunto: {subject}' if subject else ''}

        Mensaje:
        {message}

        ---
        Vexus - Sistema de Gestión de Contactos
        © 2025 Vexus. Todos los derechos reservados.
        """

        # Adjuntar ambas partes
        part1 = MIMEText(text_content, 'plain')
        part2 = MIMEText(html_content, 'html')

        msg.attach(part1)
        msg.attach(part2)

        # Enviar email si las credenciales SMTP están configuradas
        if not settings.SMTP_HOST or not settings.SMTP_USER:
            print(f"⚠️ SMTP no configurado. Email de contacto NO enviado.")
            print(f"📧 Mensaje de {client_name} ({client_email}):")
            print(f"📝 {message}")
            print(f"⚠️ Configura SMTP en el archivo .env para enviar emails reales")
            return False

        # Conectar al servidor SMTP de forma ASÍNCRONA
        try:
            smtp_client = aiosmtplib.SMTP(
                hostname=settings.SMTP_HOST,
                port=settings.SMTP_PORT,
                timeout=30.0,  # Aumentado para Render Free
                use_tls=False
            )

            async with smtp_client:
                await smtp_client.connect()
                await smtp_client.starttls()
                await smtp_client.login(settings.SMTP_USER, settings.SMTP_PASSWORD)
                await smtp_client.send_message(msg)

            print(f"✅ Email de contacto enviado a {to_email}")
            return True

        except asyncio.TimeoutError:
            print(f"⏱️ TIMEOUT al enviar email de contacto")
            return False
        except Exception as smtp_error:
            print(f"❌ Error SMTP al enviar email de contacto: {smtp_error}")
            return False

    except Exception as e:
        print(f"❌ Error al enviar email de contacto: {str(e)}")
        return False


async def send_consultancy_email(
    to_email: str,
    client_name: str,
    client_email: str,
    query: str,
    subject: str
) -> bool:
    """
    Enviar email de consultoría a grupovexus@gmail.com

    Args:
        to_email: Email destino (grupovexus@gmail.com)
        client_name: Nombre del cliente
        client_email: Email del cliente
        query: Consulta del cliente
        subject: Asunto del email

    Returns:
        True si el email se envió correctamente, False en caso contrario
    """
    try:
        # Crear mensaje
        msg = MIMEMultipart('alternative')
        msg['Subject'] = subject
        msg['From'] = settings.EMAIL_FROM
        msg['To'] = to_email
        msg['Reply-To'] = client_email

        # Contenido HTML
        html_content = f"""
        <!DOCTYPE html>
        <html lang="es">
        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>{subject}</title>
            <style>
                body {{
                    font-family: 'Space Grotesk', -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
                    background: #f5f5f5;
                    padding: 20px;
                    margin: 0;
                }}
                .email-container {{
                    max-width: 600px;
                    margin: 0 auto;
                    background: white;
                    border-radius: 12px;
                    overflow: hidden;
                    box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
                }}
                .header {{
                    background: linear-gradient(135deg, #0a0a0a 0%, #1a1a1a 100%);
                    color: white;
                    padding: 30px;
                    text-align: center;
                }}
                .logo {{
                    font-size: 32px;
                    font-weight: 900;
                    color: #d4af37;
                    letter-spacing: 3px;
                    margin-bottom: 10px;
                }}
                .subtitle {{
                    color: #a0a0a0;
                    font-size: 12px;
                    letter-spacing: 2px;
                }}
                .content {{
                    padding: 30px;
                }}
                h2 {{
                    color: #0a0a0a;
                    margin-bottom: 20px;
                    font-size: 20px;
                }}
                .info-row {{
                    margin: 15px 0;
                    padding: 15px;
                    background: #f9f9f9;
                    border-left: 4px solid #d4af37;
                    border-radius: 4px;
                }}
                .info-label {{
                    font-weight: 700;
                    color: #333;
                    margin-bottom: 5px;
                }}
                .info-value {{
                    color: #666;
                    line-height: 1.6;
                }}
                .query-box {{
                    background: #fafafa;
                    padding: 20px;
                    border-radius: 8px;
                    border: 1px solid #e0e0e0;
                    margin: 20px 0;
                }}
                .footer {{
                    background: #f5f5f5;
                    padding: 20px;
                    text-align: center;
                    color: #999;
                    font-size: 12px;
                }}
            </style>
        </head>
        <body>
            <div class="email-container">
                <div class="header">
                    <div class="logo">VEXUS</div>
                    <div class="subtitle">NUEVA CONSULTA DE CLIENTE</div>
                </div>

                <div class="content">
                    <h2>📨 Nueva Consulta de Consultoría/Desarrollo Web</h2>

                    <div class="info-row">
                        <div class="info-label">👤 Nombre del Cliente:</div>
                        <div class="info-value">{client_name}</div>
                    </div>

                    <div class="info-row">
                        <div class="info-label">📧 Email de Contacto:</div>
                        <div class="info-value"><a href="mailto:{client_email}">{client_email}</a></div>
                    </div>

                    <div class="query-box">
                        <div class="info-label" style="margin-bottom: 10px;">💬 Consulta:</div>
                        <div class="info-value">{query}</div>
                    </div>

                    <p style="color: #666; font-size: 14px; margin-top: 20px;">
                        Puedes responder directamente a este email para contactar al cliente.
                    </p>
                </div>

                <div class="footer">
                    <p><strong>VEXUS</strong> - Sistema de Gestión de Consultas</p>
                    <p>© 2025 Vexus. Todos los derechos reservados.</p>
                </div>
            </div>
        </body>
        </html>
        """

        # Texto plano como alternativa
        text_content = f"""
        NUEVA CONSULTA DE CONSULTORÍA/DESARROLLO WEB

        Nombre del Cliente: {client_name}
        Email: {client_email}

        Consulta:
        {query}

        ---
        Vexus - Sistema de Gestión de Consultas
        © 2025 Vexus. Todos los derechos reservados.
        """

        # Adjuntar ambas partes
        part1 = MIMEText(text_content, 'plain')
        part2 = MIMEText(html_content, 'html')

        msg.attach(part1)
        msg.attach(part2)

        # Enviar email si las credenciales SMTP están configuradas
        if not settings.SMTP_HOST or not settings.SMTP_USER:
            print(f"⚠️ SMTP no configurado. Email de consultoría NO enviado.")
            print(f"📧 Consulta de {client_name} ({client_email}):")
            print(f"📝 {query}")
            print(f"⚠️ Configura SMTP en el archivo .env para enviar emails reales")
            return False

        # Conectar al servidor SMTP de forma ASÍNCRONA
        try:
            smtp_client = aiosmtplib.SMTP(
                hostname=settings.SMTP_HOST,
                port=settings.SMTP_PORT,
                timeout=30.0,  # Aumentado para Render Free
                use_tls=False
            )

            async with smtp_client:
                await smtp_client.connect()
                await smtp_client.starttls()
                await smtp_client.login(settings.SMTP_USER, settings.SMTP_PASSWORD)
                await smtp_client.send_message(msg)

            print(f"✅ Email de consultoría enviado a {to_email}")
            return True

        except asyncio.TimeoutError:
            print(f"⏱️ TIMEOUT al enviar email de consultoría")
            return False
        except Exception as smtp_error:
            print(f"❌ Error SMTP al enviar email de consultoría: {smtp_error}")
            return False

    except Exception as e:
        print(f"❌ Error al enviar email de consultoría: {str(e)}")
        return False
