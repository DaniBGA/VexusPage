"""
Configuración central de la aplicación
"""
import os
from dotenv import load_dotenv

load_dotenv()

class Settings:
    # Base
    PROJECT_NAME: str = "Vexus API"
    VERSION: str = "1.0.0"
    API_V1_PREFIX: str = "/api/v1"
    
    # Database
    DATABASE_URL: str = os.getenv(
        "DATABASE_URL", 
        "postgresql://postgres:Danuus22@localhost:5432/vexus_db"
    )
    
    # Security
    SECRET_KEY: str = os.getenv(
        "SECRET_KEY", 
        "your-secret-key-here-change-in-production"
    )
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 30
    
    # CORS
    ALLOWED_ORIGINS: list = ["*"]  # En producción, especificar dominios
    
    # Database Pool
    DB_POOL_MIN_SIZE: int = 5
    DB_POOL_MAX_SIZE: int = 20

settings = Settings()