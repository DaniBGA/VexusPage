"""
Passenger WSGI para Neatech/cPanel - SIN acceso SSH
Este archivo permite ejecutar FastAPI automáticamente con Passenger
"""
import sys
import os

# Añadir el directorio actual al path de Python
sys.path.insert(0, os.path.dirname(__file__))

# Cargar variables de entorno desde .env
from dotenv import load_dotenv
load_dotenv(os.path.join(os.path.dirname(__file__), '.env'))

# Importar la aplicación FastAPI
try:
    from app.main import app as application
    print("✅ FastAPI app loaded successfully")
except Exception as e:
    print(f"❌ Error loading FastAPI app: {e}")
    raise

# Configuración adicional para Passenger
if __name__ == "__main__":
    import uvicorn
    uvicorn.run(application, host="0.0.0.0", port=8000)
