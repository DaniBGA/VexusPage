"""
Endpoints de cursos
"""
from typing import List
from fastapi import APIRouter, Depends, HTTPException, UploadFile, File
from fastapi.responses import FileResponse
from pydantic import UUID4
from app.models.schemas import (
    Course, CourseProgress, CourseCreate,
    CourseUnit, CourseUnitCreate,
    CourseResource, CourseResourceCreate
)
from app.api.deps import get_current_user, require_admin, get_db_connection
from app.core.database import db
import uuid
import os
import shutil
from pathlib import Path
from datetime import datetime

router = APIRouter()

# Configuración de uploads
UPLOAD_DIR = Path("uploads/course_resources")
UPLOAD_DIR.mkdir(parents=True, exist_ok=True)
ALLOWED_EXTENSIONS = {'.pdf', '.doc', '.docx', '.ppt', '.pptx', '.xls', '.xlsx', '.txt', '.zip', '.mp4', '.mp3', '.jpg', '.jpeg', '.png', '.gif', '.webm', '.avi', '.mov'}
MAX_FILE_SIZE = 100 * 1024 * 1024  # 100MB

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

# Admin endpoints
@router.post("/admin/create", response_model=Course)
async def create_course(
    course: CourseCreate,
    admin: dict = Depends(require_admin),
    connection = Depends(get_db_connection)
):
    """Crear un nuevo curso (solo administradores)"""
    async with connection.transaction():
        course_id = uuid.uuid4()
        new_course = await connection.fetchrow(
            """
            INSERT INTO learning_courses (id, title, description, content, difficulty_level, duration_hours, is_published)
            VALUES ($1, $2, $3, $4, $5, $6, true)
            RETURNING *
            """,
            course_id, course.title, course.description, course.content,
            course.difficulty_level, course.duration_hours
        )

    return Course(**dict(new_course))

@router.put("/admin/{course_id}", response_model=Course)
async def update_course(
    course_id: UUID4,
    course: CourseCreate,
    admin: dict = Depends(require_admin),
    connection = Depends(get_db_connection)
):
    """Actualizar un curso (solo administradores)"""
    existing_course = await connection.fetchrow(
        "SELECT id FROM learning_courses WHERE id = $1", course_id
    )
    if not existing_course:
        raise HTTPException(status_code=404, detail="Course not found")

    updated_course = await connection.fetchrow(
        """
        UPDATE learning_courses
        SET title = $2, description = $3, content = $4,
            difficulty_level = $5, duration_hours = $6
        WHERE id = $1
        RETURNING *
        """,
        course_id, course.title, course.description, course.content,
        course.difficulty_level, course.duration_hours
    )

    return Course(**dict(updated_course))

@router.delete("/admin/{course_id}")
async def delete_course(
    course_id: UUID4,
    admin: dict = Depends(require_admin),
    connection = Depends(get_db_connection)
):
    """Eliminar un curso (solo administradores)"""
    course = await connection.fetchrow(
        "SELECT id FROM learning_courses WHERE id = $1", course_id
    )
    if not course:
        raise HTTPException(status_code=404, detail="Course not found")

    await connection.execute(
        "DELETE FROM learning_courses WHERE id = $1", course_id
    )

    return {"message": "Course deleted successfully"}

@router.get("/admin/all", response_model=List[Course])
async def get_all_courses_admin(
    admin: dict = Depends(require_admin),
    connection = Depends(get_db_connection)
):
    """Obtener todos los cursos incluyendo no publicados (solo administradores)"""
    courses = await connection.fetch(
        "SELECT * FROM learning_courses ORDER BY created_at DESC"
    )
    return [Course(**dict(course)) for course in courses]

# ===== COURSE UNITS ENDPOINTS =====

@router.get("/{course_id}/units", response_model=List[CourseUnit])
async def get_course_units(course_id: UUID4):
    """Obtener todas las unidades de un curso"""
    pool = await db.get_pool()

    async with pool.acquire() as connection:
        units = await connection.fetch(
            'SELECT * FROM course_units WHERE course_id = $1 ORDER BY "order"',
            course_id
        )
        return [CourseUnit(**dict(unit)) for unit in units]

@router.post("/{course_id}/units", response_model=CourseUnit)
async def create_course_unit(
    course_id: UUID4,
    unit: CourseUnitCreate,
    admin: dict = Depends(require_admin),
    connection = Depends(get_db_connection)
):
    """Crear una nueva unidad en un curso (solo administradores)"""
    # Verificar que el curso existe
    course = await connection.fetchrow(
        "SELECT id FROM learning_courses WHERE id = $1", course_id
    )
    if not course:
        raise HTTPException(status_code=404, detail="Course not found")

    unit_id = uuid.uuid4()
    new_unit = await connection.fetchrow(
        """
        INSERT INTO course_units (id, course_id, title, description, content, "order")
        VALUES ($1, $2, $3, $4, $5, $6)
        RETURNING *
        """,
        unit_id, course_id, unit.title, unit.description, unit.content, unit.order
    )

    return CourseUnit(**dict(new_unit))

@router.put("/units/{unit_id}", response_model=CourseUnit)
async def update_course_unit(
    unit_id: UUID4,
    unit: CourseUnitCreate,
    admin: dict = Depends(require_admin),
    connection = Depends(get_db_connection)
):
    """Actualizar una unidad de curso (solo administradores)"""
    updated_unit = await connection.fetchrow(
        """
        UPDATE course_units
        SET title = $2, description = $3, content = $4, "order" = $5
        WHERE id = $1
        RETURNING *
        """,
        unit_id, unit.title, unit.description, unit.content, unit.order
    )

    if not updated_unit:
        raise HTTPException(status_code=404, detail="Unit not found")

    return CourseUnit(**dict(updated_unit))

@router.delete("/units/{unit_id}")
async def delete_course_unit(
    unit_id: UUID4,
    admin: dict = Depends(require_admin),
    connection = Depends(get_db_connection)
):
    """Eliminar una unidad de curso (solo administradores)"""
    await connection.execute(
        "DELETE FROM course_units WHERE id = $1", unit_id
    )

    return {"message": "Unit deleted successfully"}

# ===== COURSE RESOURCES ENDPOINTS =====

@router.get("/units/{unit_id}/resources", response_model=List[CourseResource])
async def get_unit_resources(unit_id: UUID4):
    """Obtener todos los recursos de una unidad"""
    pool = await db.get_pool()

    async with pool.acquire() as connection:
        resources = await connection.fetch(
            "SELECT * FROM course_resources WHERE unit_id = $1 ORDER BY created_at",
            unit_id
        )
        return [CourseResource(**dict(resource)) for resource in resources]

@router.post("/units/{unit_id}/resources", response_model=CourseResource)
async def create_resource(
    unit_id: UUID4,
    resource: CourseResourceCreate,
    admin: dict = Depends(require_admin),
    connection = Depends(get_db_connection)
):
    """Crear un nuevo recurso en una unidad (solo administradores)"""
    # Verificar que la unidad existe
    unit = await connection.fetchrow(
        "SELECT id FROM course_units WHERE id = $1", unit_id
    )
    if not unit:
        raise HTTPException(status_code=404, detail="Unit not found")

    resource_id = uuid.uuid4()
    new_resource = await connection.fetchrow(
        """
        INSERT INTO course_resources (id, unit_id, title, resource_type, url, description)
        VALUES ($1, $2, $3, $4, $5, $6)
        RETURNING *
        """,
        resource_id, unit_id, resource.title, resource.resource_type,
        resource.url, resource.description
    )

    return CourseResource(**dict(new_resource))

@router.delete("/resources/{resource_id}")
async def delete_resource(
    resource_id: UUID4,
    admin: dict = Depends(require_admin),
    connection = Depends(get_db_connection)
):
    """Eliminar un recurso (solo administradores)"""
    await connection.execute(
        "DELETE FROM course_resources WHERE id = $1", resource_id
    )

    return {"message": "Resource deleted successfully"}

# ===== COURSE ENROLLMENT & VIEWING ENDPOINTS =====

@router.post("/{course_id}/enroll")
async def enroll_in_course(
    course_id: UUID4,
    current_user: dict = Depends(get_current_user),
    connection = Depends(get_db_connection)
):
    """Inscribir al usuario en un curso"""
    # Verificar que el curso existe y está publicado
    course = await connection.fetchrow(
        "SELECT id FROM learning_courses WHERE id = $1 AND is_published = true",
        course_id
    )
    if not course:
        raise HTTPException(status_code=404, detail="Course not found")

    # Verificar si ya está inscrito
    existing = await connection.fetchrow(
        "SELECT id FROM course_enrollments WHERE user_id = $1 AND course_id = $2",
        current_user['id'], course_id
    )

    if existing:
        return {"message": "Already enrolled", "enrollment_id": str(existing['id'])}

    # Usar transacción para asegurar que ambas inserciones se completen
    async with connection.transaction():
        # Inscribir al usuario
        enrollment_id = uuid.uuid4()
        await connection.execute(
            """
            INSERT INTO course_enrollments (id, user_id, course_id)
            VALUES ($1, $2, $3)
            """,
            enrollment_id, current_user['id'], course_id
        )

        # También crear registro en user_course_progress
        await connection.execute(
            """
            INSERT INTO user_course_progress (user_id, course_id, progress_percentage)
            VALUES ($1, $2, 0)
            ON CONFLICT (user_id, course_id) DO NOTHING
            """,
            current_user['id'], course_id
        )

    return {"message": "Enrolled successfully", "enrollment_id": str(enrollment_id)}

@router.get("/{course_id}/view")
async def get_course_with_units(
    course_id: UUID4,
    current_user: dict = Depends(get_current_user)
):
    """Obtener curso completo con unidades y recursos (requiere inscripción)"""
    pool = await db.get_pool()

    async with pool.acquire() as connection:
        # Verificar que el curso existe
        course = await connection.fetchrow(
            "SELECT * FROM learning_courses WHERE id = $1 AND is_published = true",
            course_id
        )
        if not course:
            raise HTTPException(status_code=404, detail="Course not found")

        # Verificar si el usuario está inscrito o es admin
        if current_user.get('role') != 'admin':
            enrollment = await connection.fetchrow(
                "SELECT id FROM course_enrollments WHERE user_id = $1 AND course_id = $2",
                current_user['id'], course_id
            )
            if not enrollment:
                # Auto-inscribir al usuario
                enrollment_id = uuid.uuid4()
                await connection.execute(
                    "INSERT INTO course_enrollments (id, user_id, course_id) VALUES ($1, $2, $3)",
                    enrollment_id, current_user['id'], course_id
                )

        # Actualizar last_accessed
        await connection.execute(
            """
            UPDATE course_enrollments
            SET last_accessed = CURRENT_TIMESTAMP
            WHERE user_id = $1 AND course_id = $2
            """,
            current_user['id'], course_id
        )

        # Crear o actualizar registro de progreso inicial
        await connection.execute(
            """
            INSERT INTO user_course_progress (user_id, course_id, progress_percentage, last_accessed)
            VALUES ($1, $2, 0, CURRENT_TIMESTAMP)
            ON CONFLICT (user_id, course_id)
            DO UPDATE SET last_accessed = CURRENT_TIMESTAMP
            """,
            current_user['id'], course_id
        )

        # Obtener unidades del curso
        units = await connection.fetch(
            'SELECT * FROM course_units WHERE course_id = $1 ORDER BY "order"',
            course_id
        )

        # Para cada unidad, obtener recursos y progreso del usuario
        units_with_resources = []
        for unit in units:
            resources = await connection.fetch(
                "SELECT * FROM course_resources WHERE unit_id = $1 ORDER BY created_at",
                unit['id']
            )

            unit_progress = await connection.fetchrow(
                "SELECT completed FROM user_unit_progress WHERE user_id = $1 AND unit_id = $2",
                current_user['id'], unit['id']
            )

            units_with_resources.append({
                **dict(unit),
                'resources': [dict(r) for r in resources],
                'completed': unit_progress['completed'] if unit_progress else False
            })

        # Obtener progreso general del usuario
        progress = await connection.fetchrow(
            "SELECT progress_percentage FROM user_course_progress WHERE user_id = $1 AND course_id = $2",
            current_user['id'], course_id
        )

        return {
            'course': dict(course),
            'units': units_with_resources,
            'progress': progress['progress_percentage'] if progress else 0
        }

@router.post("/units/{unit_id}/complete")
async def mark_unit_complete(
    unit_id: UUID4,
    current_user: dict = Depends(get_current_user)
):
    """Marcar una unidad como completada"""
    pool = await db.get_pool()

    async with pool.acquire() as connection:
        # Verificar que la unidad existe y obtener el course_id
        unit = await connection.fetchrow(
            "SELECT course_id FROM course_units WHERE id = $1", unit_id
        )
        if not unit:
            raise HTTPException(status_code=404, detail="Unit not found")

        # Marcar unidad como completada
        await connection.execute(
            """
            INSERT INTO user_unit_progress (user_id, unit_id, completed, completed_at)
            VALUES ($1, $2, true, CURRENT_TIMESTAMP)
            ON CONFLICT (user_id, unit_id)
            DO UPDATE SET completed = true, completed_at = CURRENT_TIMESTAMP
            """,
            current_user['id'], unit_id
        )

        # Calcular progreso del curso
        total_units = await connection.fetchval(
            "SELECT COUNT(*) FROM course_units WHERE course_id = $1",
            unit['course_id']
        )

        completed_units = await connection.fetchval(
            """
            SELECT COUNT(*)
            FROM user_unit_progress uup
            JOIN course_units cu ON uup.unit_id = cu.id
            WHERE uup.user_id = $1 AND cu.course_id = $2 AND uup.completed = true
            """,
            current_user['id'], unit['course_id']
        )

        progress = int((completed_units / total_units * 100)) if total_units > 0 else 0

        # Actualizar o crear progreso del curso
        await connection.execute(
            """
            INSERT INTO user_course_progress (user_id, course_id, progress_percentage, last_accessed, completed_at)
            VALUES ($1, $2, $3, CURRENT_TIMESTAMP, CASE WHEN $3 = 100 THEN CURRENT_TIMESTAMP ELSE NULL END)
            ON CONFLICT (user_id, course_id)
            DO UPDATE SET
                progress_percentage = $3,
                last_accessed = CURRENT_TIMESTAMP,
                completed_at = CASE WHEN $3 = 100 THEN CURRENT_TIMESTAMP ELSE user_course_progress.completed_at END
            """,
            current_user['id'], unit['course_id'], progress
        )

        return {"message": "Unit marked as complete", "course_progress": progress}

# ===== FILE UPLOAD ENDPOINT =====

@router.post("/upload-file")
async def upload_file(
    file: UploadFile = File(...),
    admin: dict = Depends(require_admin)
):
    """Subir archivo para recursos del curso (solo administradores)"""

    # Validar nombre de archivo
    if not file.filename or file.filename.strip() == "":
        raise HTTPException(status_code=400, detail="Nombre de archivo inválido")

    # Verificar extensión
    file_ext = Path(file.filename).suffix.lower()
    if file_ext not in ALLOWED_EXTENSIONS:
        raise HTTPException(
            status_code=400,
            detail=f"Tipo de archivo no permitido. Permitidos: {', '.join(ALLOWED_EXTENSIONS)}"
        )

    # Leer archivo y verificar tamaño
    file_content = await file.read()
    file_size = len(file_content)

    if file_size > MAX_FILE_SIZE:
        raise HTTPException(
            status_code=413,
            detail=f"Archivo demasiado grande. Máximo: {MAX_FILE_SIZE / (1024*1024)}MB"
        )

    # Generar nombre único y seguro (prevenir path traversal)
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    unique_id = str(uuid.uuid4())[:8]
    # Sanitizar nombre de archivo original
    safe_original_name = "".join(c for c in file.filename if c.isalnum() or c in '._- ')
    safe_filename = f"{timestamp}_{unique_id}_{safe_original_name}"
    file_path = UPLOAD_DIR / safe_filename

    # Guardar archivo
    try:
        with file_path.open("wb") as buffer:
            buffer.write(file_content)
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error al guardar archivo: {str(e)}")

    # Retornar URL relativa
    file_url = f"/uploads/course_resources/{safe_filename}"

    return {
        "filename": file.filename,
        "url": file_url,
        "size": file_path.stat().st_size,
        "type": file_ext
    }

@router.get("/download/{filename}")
async def download_file(filename: str):
    """Descargar archivo de recurso"""
    file_path = UPLOAD_DIR / filename

    if not file_path.exists():
        raise HTTPException(status_code=404, detail="Archivo no encontrado")

    return FileResponse(
        path=file_path,
        filename=filename,
        media_type='application/octet-stream'
    )
