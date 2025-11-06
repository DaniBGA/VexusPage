"""
Router principal de la API v1
"""
from fastapi import APIRouter
from app.api.v1.endpoints import auth, users, services, courses, projects, tools, contact, dashboard, consultancy, debug_smtp, email_proxy

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

# Proxy para envío de emails desde frontend (oculta credenciales)
api_router.include_router(email_proxy.router, prefix="/email", tags=["email"])

# DEBUG - Endpoint temporal para verificar configuración SMTP
api_router.include_router(debug_smtp.router, prefix="/debug", tags=["debug"])