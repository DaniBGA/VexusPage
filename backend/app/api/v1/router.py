"""
Router principal de la API v1
"""
from fastapi import APIRouter
from app.api.v1.endpoints import auth, users, services, courses, projects, tools, contact, dashboard, consultancy

api_router = APIRouter()

api_router.include_router(auth.router, prefix="/auth", tags=["authentication"])
api_router.include_router(users.router, prefix="/users", tags=["users"])
api_router.include_router(services.router, prefix="/services", tags=["services"])
api_router.include_router(courses.router, prefix="/courses", tags=["courses"])
api_router.include_router(projects.router, prefix="/projects", tags=["projects"])
api_router.include_router(tools.router, prefix="/tools", tags=["tools"])
api_router.include_router(contact.router, prefix="/contact", tags=["contact"])
api_router.include_router(consultancy.router, prefix="/consultancy", tags=["consultancy"])
api_router.include_router(dashboard.router, prefix="/dashboard", tags=["dashboard"])