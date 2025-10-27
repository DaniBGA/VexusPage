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

try:
    from mangum import Mangum

    # Importar app
    from app.main import app

    # Eliminar eventos de startup/shutdown para serverless
    app.router.on_startup.clear()
    app.router.on_shutdown.clear()

    # Wrapper para serverless (Vercel usa AWS Lambda)
    handler = Mangum(app, lifespan="off")

except Exception as e:
    print(f"❌ Error importing modules: {e}")
    import traceback
    traceback.print_exc()
    raise
