"""
Configuración central de la aplicación
Todas las configuraciones sensibles se cargan desde el archivo .env
"""
import os
from typing import List
from dotenv import load_dotenv

# Cargar variables de entorno desde .env
load_dotenv()

class Settings:
    """
    Configuración centralizada de la aplicación.
    Todas las credenciales y configuraciones sensibles se obtienen del archivo .env
    """

    # === BASE ===
    PROJECT_NAME: str = os.getenv("PROJECT_NAME", "Vexus API")
    VERSION: str = os.getenv("VERSION", "1.0.0")
    API_V1_PREFIX: str = os.getenv("API_V1_PREFIX", "/api/v1")
    ENVIRONMENT: str = os.getenv("ENVIRONMENT", "development")
    DEBUG: bool = os.getenv("DEBUG", "True").lower() == "true"

    # === DATABASE ===
    DATABASE_URL: str = os.getenv(
    "DATABASE_URL",
    "postgresql://postgres.fjfucvwpstrujpqsvuvr:KxvKgM8iUnJJBVgE@aws-1-sa-east-1.pooler.supabase.com:6543/grupovex_db?sslmode=require"
    )
    DB_POOL_MIN_SIZE: int = int(os.getenv("DB_POOL_MIN_SIZE", "5"))
    DB_POOL_MAX_SIZE: int = int(os.getenv("DB_POOL_MAX_SIZE", "20"))

    # === SECURITY ===
    SECRET_KEY: str = os.getenv(
        "SECRET_KEY",
        "default-secret-key-CHANGE-THIS"
    )
    ALGORITHM: str = os.getenv("ALGORITHM", "HS256")
    ACCESS_TOKEN_EXPIRE_MINUTES: int = int(os.getenv("ACCESS_TOKEN_EXPIRE_MINUTES", "30"))

    # === CORS ===
    @property
    def ALLOWED_ORIGINS(self) -> List[str]:
        origins = os.getenv("ALLOWED_ORIGINS", "*")
        if origins == "*":
            return ["*"]
        
        # Parsear orígenes de la variable de entorno
        origins_list = [origin.strip() for origin in origins.split(",")]
        
        # En producción, siempre agregar localhost para testing
        # (esto permite probar con test-email-frontend.html)
        localhost_origins = [
            "http://localhost:8000",
            "http://localhost:5500",
            "http://127.0.0.1:8000",
            "http://127.0.0.1:5500"
        ]
        
        # Agregar localhost si no está ya en la lista
        for localhost in localhost_origins:
            if localhost not in origins_list:
                origins_list.append(localhost)
        
        return origins_list

    # === DATABASE CONNECT ===
    # Timeout (seconds) used when creating the asyncpg pool. Increase if your DB
    # may take longer to accept connections (cold starts, network latency).
    DB_CONNECT_TIMEOUT: int = int(os.getenv("DB_CONNECT_TIMEOUT", "10"))

    # === EMAIL (para verificación de email) ===
    SMTP_HOST: str = os.getenv("SMTP_HOST", "")
    SMTP_PORT: int = int(os.getenv("SMTP_PORT", "587"))
    SMTP_USER: str = os.getenv("SMTP_USER", "")
    SMTP_PASSWORD: str = os.getenv("SMTP_PASSWORD", "")
    EMAIL_FROM: str = os.getenv("EMAIL_FROM", "noreply@vexus.com")

    # === FRONTEND ===
    FRONTEND_URL: str = os.getenv("FRONTEND_URL", "http://localhost:5500")

# Instancia única de configuración
settings = Settings()