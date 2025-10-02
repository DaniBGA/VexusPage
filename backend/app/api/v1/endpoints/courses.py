"""
Endpoints de cursos
"""
from typing import List
from fastapi import APIRouter, Depends, HTTPException
from pydantic import UUID4
from app.models.schemas import Course, CourseProgress
from app.api.deps import get_current_user
from app.core.database import db

router = APIRouter()

@router.get("/", response_model=List[Course])
async def get_courses():
    """Obtener todos los cursos publicados"""
    pool = await db.get_pool()
    
    async with pool.acquire() as connection:
        courses = await connection.fetch(
            "SELECT * FROM learning_courses WHERE is_published = true ORDER BY created_at"
        )
        return [Course(**dict(course)) for course in courses]

@router.get("/{course_id}", response_model=Course)
async def get_course_by_id(course_id: UUID4):
    """Obtener curso por ID"""
    pool = await db.get_pool()
    
    async with pool.acquire() as connection:
        course = await connection.fetchrow(
            "SELECT * FROM learning_courses WHERE id = $1 AND is_published = true", 
            course_id
        )
        if not course:
            raise HTTPException(status_code=404, detail="Course not found")
        return Course(**dict(course))

@router.get("/user/progress")
async def get_user_course_progress(current_user: dict = Depends(get_current_user)):
    """Obtener progreso de cursos del usuario"""
    pool = await db.get_pool()
    
    async with pool.acquire() as connection:
        progress = await connection.fetch(
            """
            SELECT lc.*, COALESCE(ucp.progress_percentage, 0) as progress_percentage,
                   ucp.started_at, ucp.completed_at, ucp.last_accessed
            FROM learning_courses lc
            LEFT JOIN user_course_progress ucp ON lc.id = ucp.course_id AND ucp.user_id = $1
            WHERE lc.is_published = true
            ORDER BY lc.created_at
            """,
            current_user['id']
        )
        return [dict(p) for p in progress]

@router.post("/{course_id}/progress")
async def update_course_progress(
    course_id: UUID4,
    progress: CourseProgress,
    current_user: dict = Depends(get_current_user)
):
    """Actualizar progreso del curso"""
    pool = await db.get_pool()
    
    async with pool.acquire() as connection:
        course = await connection.fetchrow(
            "SELECT id FROM learning_courses WHERE id = $1 AND is_published = true",
            course_id
        )
        if not course:
            raise HTTPException(status_code=404, detail="Course not found")
        
        await connection.execute(
            """
            INSERT INTO user_course_progress (user_id, course_id, progress_percentage, last_accessed)
            VALUES ($1, $2, $3, CURRENT_TIMESTAMP)
            ON CONFLICT (user_id, course_id)
            DO UPDATE SET 
                progress_percentage = $3,
                last_accessed = CURRENT_TIMESTAMP,
                completed_at = CASE WHEN $3 = 100 THEN CURRENT_TIMESTAMP ELSE user_course_progress.completed_at END
            """,
            current_user['id'], course_id, progress.progress_percentage
        )
        
        return {"message": "Progress updated successfully"}
