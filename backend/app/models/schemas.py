"""
Esquemas Pydantic para validación de datos
"""
from datetime import datetime
from typing import Optional
from pydantic import BaseModel, EmailStr, UUID4, Field, field_validator

# User Schemas
class UserBase(BaseModel):
    name: str
    email: EmailStr

class UserCreate(BaseModel):
    name: str = Field(..., min_length=2, max_length=100)
    email: EmailStr
    password: str = Field(..., min_length=8, max_length=72)

    @field_validator('password')
    @classmethod
    def validate_password(cls, v: str) -> str:
        """Validar que la contraseña cumpla requisitos mínimos"""
        if len(v) < 8:
            raise ValueError('Password must be at least 8 characters long')
        if len(v.encode('utf-8')) > 72:
            raise ValueError('Password is too long (max 72 bytes)')
        if not any(c.isdigit() for c in v):
            raise ValueError('Password must contain at least one number')
        if not any(c.isalpha() for c in v):
            raise ValueError('Password must contain at least one letter')
        return v

class UserLogin(BaseModel):
    email: EmailStr
    password: str

class User(BaseModel):
    id: UUID4
    full_name: str
    email: EmailStr
    avatar: Optional[str] = "👤"
    is_active: bool = True
    role: str = "user"
    created_at: datetime
    is_verified: bool = False

class Token(BaseModel):
    access_token: str
    token_type: str
    user: User

# Service Schemas
class ServiceCreate(BaseModel):
    name: str
    description: str
    category: str
    icon_name: Optional[str] = None

class Service(ServiceCreate):
    id: UUID4
    is_active: bool
    created_at: datetime

# Course Schemas
class CourseCreate(BaseModel):
    title: str
    description: str
    content: str
    difficulty_level: str = "beginner"
    duration_hours: int = 0

class Course(CourseCreate):
    id: UUID4
    is_published: bool
    created_at: datetime

class CourseProgress(BaseModel):
    course_id: UUID4
    progress_percentage: int
    started_at: Optional[datetime] = None
    completed_at: Optional[datetime] = None

# Course Unit Schemas
class CourseUnitCreate(BaseModel):
    title: str
    description: Optional[str] = None
    content: str
    order: int = 0

class CourseUnit(CourseUnitCreate):
    id: UUID4
    course_id: UUID4
    created_at: datetime

# Course Resource Schemas
class CourseResourceCreate(BaseModel):
    title: str
    resource_type: str  # 'document', 'video', 'link'
    url: str
    file_path: Optional[str] = None

class CourseResource(CourseResourceCreate):
    id: UUID4
    unit_id: UUID4
    created_at: datetime

# Project Schemas
class ProjectCreate(BaseModel):
    name: str
    description: Optional[str] = None
    status: str = "active"
    repository_url: Optional[str] = None
    demo_url: Optional[str] = None
    technologies: Optional[list] = None

class Project(ProjectCreate):
    id: UUID4
    user_id: UUID4
    created_at: datetime

# Contact Schema
class ContactMessage(BaseModel):
    name: str
    email: EmailStr
    subject: Optional[str] = None
    message: str