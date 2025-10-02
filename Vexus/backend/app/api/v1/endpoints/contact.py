"""
Endpoints de contacto
"""
import uuid
from fastapi import APIRouter, Request
from app.models.schemas import ContactMessage
from app.core.database import db

router = APIRouter()

@router.post("/")
async def send_contact_message(message: ContactMessage, request: Request):
    """Enviar mensaje de contacto"""
    pool = await db.get_pool()
    
    async with pool.acquire() as connection:
        message_id = uuid.uuid4()
        client_ip = request.client.host
        
        await connection.execute(
            """
            INSERT INTO contact_messages (id, name, email, subject, message, ip_address)
            VALUES ($1, $2, $3, $4, $5, $6)
            """,
            message_id, message.name, message.email, message.subject, message.message, client_ip
        )
        
        return {"message": "Contact message sent successfully", "message_id": str(message_id)}