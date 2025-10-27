"""
Entry point para Vercel Serverless
"""
import sys
import os

# Agregar backend al path
backend_path = os.path.join(os.path.dirname(__file__), '..', 'backend')
sys.path.insert(0, backend_path)

# Configurar para serverless ANTES de importar
os.environ['SERVERLESS'] = 'true'

# Importar app
from app.main import app

# Eliminar eventos de startup/shutdown para serverless
app.router.on_startup.clear()
app.router.on_shutdown.clear()

# Importar Mangum y crear handler
from mangum import Mangum

# Configuración explícita de Mangum para Vercel
handler = Mangum(app, lifespan="off", api_gateway_base_path="/")
