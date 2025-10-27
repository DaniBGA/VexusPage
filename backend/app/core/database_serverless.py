"""
Gestión de conexiones a la base de datos para entorno serverless
En serverless no usamos connection pools persistentes
"""
import asyncpg
from app.config import settings

class Database:
    def __init__(self):
        self.pool = None

    async def connect(self):
        """No-op para compatibilidad"""
        pass

    async def disconnect(self):
        """No-op para compatibilidad"""
        pass

    async def get_pool(self):
        """
        En serverless, creamos un pool ligero por request
        Vercel cierra la conexión automáticamente al final del request
        """
        if self.pool is None:
            self.pool = await asyncpg.create_pool(
                settings.DATABASE_URL,
                min_size=1,
                max_size=1,  # Solo 1 conexión en serverless
                command_timeout=60
            )
        return self.pool

db = Database()
