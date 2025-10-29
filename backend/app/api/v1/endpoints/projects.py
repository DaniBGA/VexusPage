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
            SELECT up.*
            FROM user_projects up
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
            INSERT INTO user_projects (id, user_id, name, description, status, repository_url, demo_url, technologies)
            VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
            """,
            project_id, current_user['id'], project.name,
            project.description, project.status, project.repository_url, project.demo_url, project.technologies
        )
        
        created_project = await connection.fetchrow(
            "SELECT * FROM user_projects WHERE id = $1", project_id
        )
        return Project(**dict(created_project))