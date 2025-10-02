import asyncio
import uuid
from app.core.database import db
from app.core.security import get_password_hash
from passlib.context import CryptContext

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

async def create_test_user():
    pool = await db.get_pool()
    async with pool.acquire() as conn:
        user_id = uuid.uuid4()
        password_hash = pwd_context.hash("123456")  # password plano
        await conn.execute(
            """
            INSERT INTO users (id, name, email, password_hash, is_active)
            VALUES ($1, $2, $3, $4, true)
            """,
            user_id, "Test User", "test@example.com", password_hash
        )
        print("✅ Usuario creado: test@example.com / 123456")

if __name__ == "__main__":
    asyncio.run(create_test_user())