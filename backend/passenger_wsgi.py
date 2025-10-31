"""
Passenger WSGI para Neatech
Backend en public_html/api/ (sin symlink)
"""
import sys
import os

# Añadir el directorio actual al path
current_dir = os.path.dirname(__file__)
sys.path.insert(0, current_dir)

# Cargar variables de entorno
from dotenv import load_dotenv
load_dotenv(os.path.join(current_dir, '.env'))

# Importar la aplicación FastAPI
try:
    from app.main import app as application
    print("✅ FastAPI app loaded successfully from public_html/api/")
except Exception as e:
    print(f"❌ Error loading FastAPI app: {e}")
    import traceback
    traceback.print_exc()
    raise