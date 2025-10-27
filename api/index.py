"""
Entry point para Vercel Serverless
"""
import sys
import os
from mangum import Mangum

# Agregar backend al path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', 'backend'))

# Importar la app
from app.main import app

# Wrapper para serverless (Vercel usa AWS Lambda)
handler = Mangum(app, lifespan="off")
