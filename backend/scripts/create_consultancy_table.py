"""
Script para crear la tabla de consultoría
"""
import asyncio
import asyncpg
import sys
from pathlib import Path

# Agregar el directorio raíz al path
sys.path.insert(0, str(Path(__file__).parent.parent))

from app.config import settings


async def create_consultancy_table():
    """Crear tabla de consultoría en la base de datos"""
    try:
        # Conectar a la base de datos
        conn = await asyncpg.connect(settings.DATABASE_URL)
        print(f"✅ Conectado a la base de datos")

        # Leer el archivo SQL
        sql_file = Path(__file__).parent / "create_consultancy_table.sql"
        sql_content = sql_file.read_text()

        # Ejecutar el SQL
        await conn.execute(sql_content)
        print("✅ Tabla 'consultancy_requests' creada exitosamente")

        # Cerrar conexión
        await conn.close()
        print("✅ Conexión cerrada")

    except Exception as e:
        print(f"❌ Error al crear la tabla: {str(e)}")
        sys.exit(1)


if __name__ == "__main__":
    asyncio.run(create_consultancy_table())
