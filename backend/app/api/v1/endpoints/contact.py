"""
Endpoints de contacto
"""
import uuid
from fastapi import APIRouter, Request, HTTPException
from app.models.schemas import ContactMessage
from app.core.database import db
from app.services.email import send_contact_email

router = APIRouter()

@router.post("/")
async def send_contact_message(message: ContactMessage, request: Request):
    """Enviar mensaje de contacto"""
    pool = await db.get_pool()

    async with pool.acquire() as connection:
        message_id = uuid.uuid4()
        client_ip = request.client.host

        # Guardar en base de datos
        await connection.execute(
            """
            INSERT INTO contact_messages (id, name, email, subject, message, ip_address)
            VALUES ($1, $2, $3, $4, $5, $6)
            """,
            message_id, message.name, message.email, message.subject, message.message, client_ip
        )

        # Enviar email a grupovexus@gmail.com
        email_sent = await send_contact_email(
            client_name=message.name,
            client_email=message.email,
            message=message.message,
            subject=message.subject
        )

        if not email_sent:
            print(f"⚠️ El mensaje se guardó en la base de datos pero el email no se pudo enviar")

        return {
            "message": "Contact message sent successfully",
            "message_id": str(message_id),
            "email_sent": email_sent
        }