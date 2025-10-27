"""
Entry point para Vercel Serverless Functions
Compatible con Vercel Python Runtime
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

# Limpiar lifecycle events que no funcionan en serverless
app.router.on_startup.clear()
app.router.on_shutdown.clear()

# Importar Mangum para AWS Lambda compatibility (Vercel usa Lambda)
from mangum import Mangum

# Crear handler - el nombre DEBE ser 'handler' para Vercel
handler = Mangum(app, lifespan="off")
