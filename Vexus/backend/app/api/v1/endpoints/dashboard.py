"""
Endpoints del dashboard
"""
from fastapi import APIRouter, Depends
from app.api.deps import get_current_user
from app.core.database import db

router = APIRouter()

@router.get("/stats")
async def get_dashboard_stats(current_user: dict = Depends(get_current_user)):
    """Obtener estadísticas del dashboard"""
    pool = await db.get_pool()
    
    async with pool.acquire() as connection:
        projects_count = await connection.fetchval(
            "SELECT COUNT(*) FROM user_projects WHERE user_id = $1",
            current_user['id']
        )
        
        completed_courses = await connection.fetchval(
            """
            SELECT COUNT(*) FROM user_course_progress 
            WHERE user_id = $1 AND progress_percentage = 100
            """,
            current_user['id']
        )
        
        total_courses = await connection.fetchval(
            "SELECT COUNT(*) FROM learning_courses WHERE is_published = true"
        )
        
        active_projects = await connection.fetchval(
            "SELECT COUNT(*) FROM user_projects WHERE user_id = $1 AND status = 'in_progress'",
            current_user['id']
        )
        
        return {
            "projects_count": projects_count,
            "completed_courses": completed_courses,
            "total_courses": total_courses,
            "active_projects": active_projects,
            "completion_rate": (completed_courses / total_courses * 100) if total_courses > 0 else 0
        }

@router.get("/campus/sections")
async def get_campus_sections():
    """Obtener secciones del campus"""
    pool = await db.get_pool()
    
    async with pool.acquire() as connection:
        sections = await connection.fetch(
            "SELECT * FROM campus_sections WHERE is_active = true ORDER BY created_at"
        )
        return [dict(section) for section in sections]