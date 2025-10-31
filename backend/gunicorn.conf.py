"""
Configuración de Gunicorn para Vexus API
Optimizado para Render Free Tier (512MB RAM)
"""
import os

# === BINDING ===
# Render automáticamente asigna un puerto en la variable PORT
bind = f"0.0.0.0:{os.getenv('PORT', '8000')}"
backlog = 2048

# === WORKERS ===
# Para Render Free tier: usar 1 worker
# Para planes pagos con más RAM: workers = (2 * CPU_COUNT) + 1
workers = 1
worker_class = "uvicorn.workers.UvicornWorker"
worker_connections = 1000

# === TIMEOUTS ===
# Aumentar timeout para operaciones lentas de DB
timeout = 120  # 2 minutos - ajustar según necesidad
graceful_timeout = 30  # Tiempo para terminar requests existentes
keepalive = 5  # Mantener conexiones vivas

# === RESTART WORKERS ===
# Reiniciar workers automáticamente para prevenir memory leaks
max_requests = 1000  # Reiniciar después de 1000 requests
max_requests_jitter = 50  # Variabilidad aleatoria para evitar reinicios simultáneos

# === LOGGING ===
accesslog = "-"  # stdout
errorlog = "-"   # stderr
loglevel = "info"  # debug, info, warning, error, critical

# === PROCESS NAMING ===
proc_name = "vexus-api"

# === SERVER MECHANICS ===
daemon = False
pidfile = None
umask = 0
user = None
group = None

# === PERFORMANCE ===
# Usar memoria compartida para archivos temporales (más rápido que disco)
worker_tmp_dir = "/dev/shm"

# === PRELOAD APP ===
# No precargar la app para evitar problemas con conexiones de DB
preload_app = False

# === HOOKS ===
def on_starting(server):
    """Se ejecuta cuando Gunicorn inicia"""
    print("=" * 50)
    print("🚀 VEXUS API - Starting Gunicorn")
    print(f"   Workers: {workers}")
    print(f"   Worker Class: {worker_class}")
    print(f"   Timeout: {timeout}s")
    print(f"   Binding: {bind}")
    print("=" * 50)

def on_reload(server):
    """Se ejecuta cuando se recarga la configuración"""
    print("♻️ Reloading Gunicorn configuration...")

def worker_int(worker):
    """Se ejecuta cuando un worker recibe SIGINT o SIGQUIT"""
    print(f"⚠️ Worker {worker.pid} received interrupt signal")

def worker_abort(worker):
    """Se ejecuta cuando un worker muere por timeout"""
    print(f"❌ Worker {worker.pid} timeout - killing")