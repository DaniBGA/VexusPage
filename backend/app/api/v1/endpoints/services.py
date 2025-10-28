"""
Endpoints de servicios
"""
import uuid
from typing import List
from fastapi import APIRouter, Depends
from app.models.schemas import Service, ServiceCreate
from app.api.deps import get_current_user
from app.core.database import db

router = APIRouter()

@router.get("/", response_model=List[Service])
async def get_services():
    """Obtener todos los servicios activos"""
    pool = await db.get_pool()
    
    async with pool.acquire() as connection:
        services = await connection.fetch(
            "SELECT * FROM services WHERE is_active = true ORDER BY created_at"
        )
        return [Service(**dict(service)) for service in services]

@router.post("/", response_model=Service)
async def create_service(
    service: ServiceCreate,
    current_user: dict = Depends(get_current_user)
):
    """Crear nuevo servicio"""
    pool = await db.get_pool()
    
    async with pool.acquire() as connection:
        service_id = uuid.uuid4()
        await connection.execute(
            """
            INSERT INTO services (id, name, description, category, icon_name)
            VALUES ($1, $2, $3, $4, $5)
            """,
            service_id, service.name, service.description, service.category, service.icon_name
        )
        
        created_service = await connection.fetchrow(
            "SELECT * FROM services WHERE id = $1", service_id
        )
        return Service(**dict(created_service))