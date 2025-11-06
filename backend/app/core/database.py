"""
Gestión de conexiones a la base de datos
"""
import asyncpg
import asyncio
import time
from app.config import settings


class Database:
    def __init__(self):
        self.pool = None

    async def connect(self, retries: int = 3, backoff: float = 2.0):
        """Crear pool de conexiones con reintentos y timeout configurable.

        This helps in environments where the DB may be temporarily unreachable
        (cold start, network blips). It is not a substitute for correct network
        or credentials configuration.
        """
        attempt = 0
        last_exc = None

        while attempt < retries:
            try:
                if settings.DEBUG:
                    print(f"Attempting to create DB pool (attempt {attempt + 1}/{retries})...")

                # asyncpg.create_pool accepts a timeout parameter which applies to
                # establishing each new connection.
                # SSL is required for Supabase connections
                # IMPORTANT: statement_cache_size=0 for Supabase Connection Pooler (pgbouncer)
                self.pool = await asyncpg.create_pool(
                    settings.DATABASE_URL,
                    min_size=settings.DB_POOL_MIN_SIZE,
                    max_size=settings.DB_POOL_MAX_SIZE,
                    timeout=settings.DB_CONNECT_TIMEOUT,
                    ssl='require',  # Ensure SSL is always enabled
                    statement_cache_size=0  # Required for pgbouncer compatibility
                )

                if settings.DEBUG:
                    print("✅ Database connection pool created successfully")
                return

            except Exception as e:
                last_exc = e
                # Log concise info; the caller will still get the exception if all retries fail
                print(f"❌ Error creating database pool (attempt {attempt + 1}): {e}")
                attempt += 1
                if attempt < retries:
                    sleep_for = backoff * attempt
                    if settings.DEBUG:
                        print(f"Waiting {sleep_for}s before next DB connect attempt...")
                    await asyncio.sleep(sleep_for)

        # All retries exhausted
        print(f"❌ All attempts to create DB pool failed. Last error: {last_exc}")
        raise last_exc

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