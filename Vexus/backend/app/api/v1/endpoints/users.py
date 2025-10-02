"""
Endpoints de usuarios
"""
from fastapi import APIRouter, Depends, HTTPException
from pydantic import UUID4
from app.models.schemas import User
from app.api.deps import get_current_user
from app.core.database import db

router = APIRouter()

@router.get("/me", response_model=User)
async def get_current_user_info(current_user: dict = Depends(get_current_user)):
    """Obtener información del usuario actual"""
    return User(**current_user)

@router.get("/{user_id}", response_model=User)
async def get_user_by_id(
    user_id: UUID4,
    current_user: dict = Depends(get_current_user)
):
    """Obtener usuario por ID"""
    pool = await db.get_pool()
    
    async with pool.acquire() as connection:
        user = await connection.fetchrow(
            "SELECT * FROM users WHERE id = $1", user_id
        )
        if not user:
            raise HTTPException(status_code=404, detail="User not found")
        return User(**dict(user))