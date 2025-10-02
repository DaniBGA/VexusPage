import asyncio
from app.core.database import db

async def list_users():
    pool = await db.get_pool()
    async with pool.acquire() as conn:
        rows = await conn.fetch("SELECT id, email, password_hash FROM users")
        for row in rows:
            print(dict(row))

if __name__ == "__main__":
    asyncio.run(list_users())