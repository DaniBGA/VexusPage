"""
Esquemas Pydantic para validación de datos
"""
from datetime import datetime
from typing import Optional
from pydantic import BaseModel, EmailStr, UUID4

# User Schemas
class UserBase(BaseModel):
    name: str
    email: EmailStr

class UserCreate(UserBase):
    password: str

class UserLogin(BaseModel):
    email: EmailStr
    password: str

class User(UserBase):
    id: UUID4
    avatar: Optional[str] = "👤"
    is_active: bool = True
    role: str = "user"
    created_at: datetime
    last_login: Optional[datetime] = None
    email_verified: bool = False

class Token(BaseModel):
    access_token: str
    token_type: str
    user: User

# Service Schemas
class ServiceCreate(BaseModel):
    name: str
    description: str
    category: str
    icon: Optional[str] = None

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
    description: Optional[str] = None

class CourseResource(CourseResourceCreate):
    id: UUID4
    unit_id: UUID4
    created_at: datetime

# Project Schemas
class ProjectCreate(BaseModel):
    name: str
    description: Optional[str] = None
    service_id: Optional[UUID4] = None
    budget: Optional[float] = None
    start_date: Optional[datetime] = None
    end_date: Optional[datetime] = None

class Project(ProjectCreate):
    id: UUID4
    user_id: UUID4
    status: str = "pending"
    created_at: datetime

# Contact Schema
class ContactMessage(BaseModel):
    name: str
    email: EmailStr
    subject: Optional[str] = None
    message: str