"""
Endpoints de consultoría
"""
import uuid
from fastapi import APIRouter, Request, HTTPException
from pydantic import BaseModel, EmailStr
from app.core.database import db
from app.services.email import send_consultancy_email

router = APIRouter()

class ConsultancyRequest(BaseModel):
    name: str
    email: EmailStr
    query: str
    to: EmailStr
    subject: str

@router.post("/email")
async def send_consultancy(consultancy: ConsultancyRequest, request: Request):
    """Enviar consulta de consultoría por email"""
    try:
        # Guardar en base de datos
        pool = await db.get_pool()

        async with pool.acquire() as connection:
            consultancy_id = uuid.uuid4()
            client_ip = request.client.host

            await connection.execute(
                """
                INSERT INTO consultancy_requests (id, name, email, description, ip_address)
                VALUES ($1, $2, $3, $4, $5)
                """,
                consultancy_id, consultancy.name, consultancy.email, consultancy.query, client_ip
            )

        # Enviar email a grupovexus@gmail.com
        email_sent = await send_consultancy_email(
            to_email=consultancy.to,
            client_name=consultancy.name,
            client_email=consultancy.email,
            query=consultancy.query,
            subject=consultancy.subject
        )

        if not email_sent:
            # Si el servicio de email falla, considerarlo Service Unavailable (503)
            print(f"⚠️ Consultancy email NOT sent, service unavailable for {consultancy.email}")
            raise HTTPException(status_code=503, detail="Email service temporarily unavailable")

        return {
            "message": "Consulta enviada exitosamente",
            "consultancy_id": str(consultancy_id)
        }

    except Exception as e:
        print(f"Error en consultoría: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))
