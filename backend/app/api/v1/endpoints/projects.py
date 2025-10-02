"""
Endpoints de proyectos
"""
import uuid
from fastapi import APIRouter, Depends
from app.models.schemas import Project, ProjectCreate
from app.api.deps import get_current_user
from app.core.database import db

router = APIRouter()

@router.get("/")
async def get_user_projects(current_user: dict = Depends(get_current_user)):
    """Obtener proyectos del usuario"""
    pool = await db.get_pool()
    
    async with pool.acquire() as connection:
        projects = await connection.fetch(
            """
            SELECT up.*, s.name as service_name
            FROM user_projects up
            LEFT JOIN services s ON up.service_id = s.id
            WHERE up.user_id = $1
            ORDER BY up.created_at DESC
            """,
            current_user['id']
        )
        return [dict(project) for project in projects]

@router.post("/", response_model=Project)
async def create_project(
    project: ProjectCreate,
    current_user: dict = Depends(get_current_user)
):
    """Crear nuevo proyecto"""
    pool = await db.get_pool()
    
    async with pool.acquire() as connection:
        project_id = uuid.uuid4()
        await connection.execute(
            """
            INSERT INTO user_projects (id, user_id, service_id, name, description, budget, start_date, end_date)
            VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
            """,
            project_id, current_user['id'], project.service_id, project.name,
            project.description, project.budget, project.start_date, project.end_date
        )
        
        created_project = await connection.fetchrow(
            "SELECT * FROM user_projects WHERE id = $1", project_id
        )
        return Project(**dict(created_project))