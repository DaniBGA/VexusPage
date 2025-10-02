"""
Endpoints de herramientas
"""
from fastapi import APIRouter, Depends
from app.api.deps import get_current_user
from app.core.database import db

router = APIRouter()

@router.get("/")
async def get_campus_tools(current_user: dict = Depends(get_current_user)):
    """Obtener herramientas del campus"""
    pool = await db.get_pool()
    
    async with pool.acquire() as connection:
        tools = await connection.fetch(
            """
            SELECT ct.*, 
                   CASE WHEN uta.user_id IS NOT NULL THEN true ELSE false END as has_access
            FROM campus_tools ct
            LEFT JOIN user_tool_access uta ON ct.id = uta.tool_id 
                AND uta.user_id = $1 
                AND uta.is_active = true
                AND (uta.expires_at IS NULL OR uta.expires_at > CURRENT_TIMESTAMP)
            WHERE ct.is_active = true
            ORDER BY ct.created_at
            """,
            current_user['id']
        )
        return [dict(tool) for tool in tools]