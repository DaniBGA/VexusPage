"""
Entry point para Vercel Serverless
"""
import sys
import os

# Agregar backend al path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', 'backend'))

# Importar la app
from app.main import app

# Esta es la variable que Vercel busca
handler = app
