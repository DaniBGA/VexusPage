import asyncio
import asyncpg
import sys

async def test_connection():
    print("Testing database connection...")
    try:
        conn = await asyncpg.connect(
            "postgresql://postgres.fjfucvwpstrujpqsvuvr:KxvKgM8iUnJJBVgE@aws-1-sa-east-1.pooler.supabase.com:5432/postgres?sslmode=require",
            timeout=10
        )
        await conn.fetch('SELECT 1')
        print("✅ Connection successful!")
        await conn.close()
        return True
    except Exception as e:
        print(f"❌ Connection failed: {str(e)}")
        return False

if __name__ == "__main__":
    success = asyncio.run(test_connection())
    sys.exit(0 if success else 1)