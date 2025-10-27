"""
Entry point para Vercel Serverless Functions
Wrapper ASGI personalizado sin Mangum
"""
import sys
import os
from pathlib import Path

# Configurar paths
current_dir = Path(__file__).parent
backend_dir = current_dir.parent / "backend"
sys.path.insert(0, str(backend_dir))

# Configurar para serverless
os.environ['SERVERLESS'] = 'true'

# Importar FastAPI app
from app.main import app

# Limpiar lifecycle events
app.router.on_startup.clear()
app.router.on_shutdown.clear()

# ASGI handler directo para Vercel
async def handler(scope, receive, send):
    """
    ASGI handler que Vercel puede llamar directamente
    sin necesidad de Mangum
    """
    await app(scope, receive, send)
