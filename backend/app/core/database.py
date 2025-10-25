"""
Gestión de conexiones a la base de datos
"""
import asyncpg
from app.config import settings

class Database:
    def __init__(self):
        self.pool = None
    
    async def connect(self):
        """Crear pool de conexiones"""
        try:
            self.pool = await asyncpg.create_pool(
                settings.DATABASE_URL,
                min_size=settings.DB_POOL_MIN_SIZE,
                max_size=settings.DB_POOL_MAX_SIZE
            )
            if settings.DEBUG:
                print("✅ Database connection pool created successfully")
        except Exception as e:
            print(f"❌ Error creating database pool: {e}")
            raise

    async def disconnect(self):
        """Cerrar pool de conexiones"""
        if self.pool:
            await self.pool.close()
            if settings.DEBUG:
                print("✅ Database connection pool closed")
    
    async def get_pool(self):
        """Obtener pool de conexiones"""
        if self.pool is None:
            await self.connect()
        return self.pool

db = Database()