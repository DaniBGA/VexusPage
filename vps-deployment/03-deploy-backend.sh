#!/bin/bash

################################################################################
# Script de Deployment del Backend - VexusPage VPS
# Versión: 1.0
# Descripción: Despliega la API FastAPI en producción
# Uso: sudo ./03-deploy-backend.sh
################################################################################

set -e  # Salir si hay errores

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

# Verificar que se ejecuta como root
if [ "$EUID" -ne 0 ]; then
    error "Este script debe ejecutarse como root (use sudo)"
    exit 1
fi

log "=========================================="
log "  DEPLOYMENT BACKEND - VEXUSPAGE"
log "=========================================="

################################################################################
# CONFIGURACIÓN
################################################################################

APP_DIR="/var/www/vexus-api"
REPO_URL="https://github.com/TU_USUARIO/VexusPage.git"  # ⚠️ CAMBIAR ESTO
BRANCH="main"

################################################################################
# PASO 1: Verificar que el archivo .env existe
################################################################################
log "PASO 1: Verificando archivo .env..."

if [ ! -f "$APP_DIR/.env" ]; then
    warning "El archivo .env NO existe"
    info "Copiando plantilla de ejemplo..."

    # Verificar si existe el archivo de ejemplo
    if [ -f "../vps-deployment/08-production.env.example" ]; then
        cp ../vps-deployment/08-production.env.example $APP_DIR/.env
    elif [ -f "./08-production.env.example" ]; then
        cp ./08-production.env.example $APP_DIR/.env
    else
        # Crear .env básico
        cat > $APP_DIR/.env << 'ENVFILE'
# CONFIGURACIÓN DE PRODUCCIÓN - VEXUS API
# ⚠️ COMPLETA TODOS LOS VALORES ANTES DE CONTINUAR

# Base de datos (usar credenciales de 02-setup-database.sh)
DATABASE_URL=postgresql://vexus_admin:TU_PASSWORD@localhost:5432/vexus_db

# Seguridad
SECRET_KEY=GENERAR_SECRET_KEY_AQUI
ALLOWED_ORIGINS=https://grupovexus.com,https://www.grupovexus.com

# Email - SMTP (Gmail)
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USER=tu-email@gmail.com
SMTP_PASSWORD=tu-app-password-de-gmail
EMAIL_FROM=noreply@grupovexus.com

# Email - SendGrid (alternativa recomendada)
SENDGRID_API_KEY=tu-sendgrid-api-key

# Frontend
FRONTEND_URL=https://grupovexus.com

# Aplicación
PROJECT_NAME=Vexus API
VERSION=1.0.0
API_V1_PREFIX=/api/v1
ENVIRONMENT=production
DEBUG=False
ENVFILE
    fi

    error "ARCHIVO .env CREADO PERO NO CONFIGURADO"
    error "Edita $APP_DIR/.env con tus credenciales y vuelve a ejecutar este script"
    error "Usa: nano $APP_DIR/.env"
    exit 1
fi

info "Archivo .env encontrado"

# Verificar que no tenga valores de ejemplo
if grep -q "CAMBIAR\|GENERAR\|TU_PASSWORD\|tu-email" $APP_DIR/.env 2>/dev/null; then
    error "El archivo .env contiene valores de ejemplo sin configurar"
    error "Edita $APP_DIR/.env y completa todas las credenciales"
    error "Usa: nano $APP_DIR/.env"
    exit 1
fi

info "✓ Archivo .env configurado correctamente"

################################################################################
# PASO 2: Clonar o actualizar repositorio
################################################################################
log "PASO 2: Obteniendo código fuente..."

if [ -d "$APP_DIR/backend" ]; then
    info "Directorio backend ya existe, actualizando..."
    cd $APP_DIR

    # Si es un repositorio git
    if [ -d ".git" ]; then
        git pull origin $BRANCH
    else
        warning "No es un repositorio git, saltando actualización"
    fi
else
    info "Clonando repositorio..."

    # Crear directorio si no existe
    mkdir -p $APP_DIR

    # Opción A: Clonar desde Git
    # git clone -b $BRANCH $REPO_URL $APP_DIR/temp
    # mv $APP_DIR/temp/backend/* $APP_DIR/
    # rm -rf $APP_DIR/temp

    # Opción B: Copiar desde local (para este momento)
    warning "Deberás copiar manualmente los archivos del backend"
    warning "Ejecuta desde tu máquina local:"
    warning "  cd VexusPage/backend"
    warning "  tar -czf backend.tar.gz app/ requirements.txt"
    warning "  scp backend.tar.gz root@[IP_VPS]:$APP_DIR/"
    warning "  ssh root@[IP_VPS]"
    warning "  cd $APP_DIR && tar -xzf backend.tar.gz"
    warning ""
    warning "Presiona ENTER cuando hayas copiado los archivos..."
    read
fi

################################################################################
# PASO 3: Crear y activar entorno virtual
################################################################################
log "PASO 3: Configurando entorno virtual de Python..."

cd $APP_DIR

# Crear venv si no existe
if [ ! -d "venv" ]; then
    info "Creando entorno virtual..."
    python3.12 -m venv venv
else
    info "Entorno virtual ya existe"
fi

# Activar venv
source venv/bin/activate

# Actualizar pip
pip install --upgrade pip setuptools wheel

info "✓ Entorno virtual configurado"

################################################################################
# PASO 4: Instalar dependencias
################################################################################
log "PASO 4: Instalando dependencias de Python..."

if [ -f "requirements.txt" ]; then
    pip install -r requirements.txt
    info "✓ Dependencias instaladas"
else
    error "No se encontró requirements.txt"
    error "Asegúrate de que los archivos del backend estén en $APP_DIR"
    exit 1
fi

################################################################################
# PASO 5: Verificar estructura de archivos
################################################################################
log "PASO 5: Verificando estructura de archivos..."

REQUIRED_FILES=(
    "app/main.py"
    "app/config.py"
    "app/core/database.py"
    "requirements.txt"
)

MISSING_FILES=()

for file in "${REQUIRED_FILES[@]}"; do
    if [ ! -f "$file" ]; then
        MISSING_FILES+=("$file")
    fi
done

if [ ${#MISSING_FILES[@]} -ne 0 ]; then
    error "Faltan archivos requeridos:"
    for file in "${MISSING_FILES[@]}"; do
        error "  - $file"
    done
    error "Asegúrate de copiar todos los archivos del backend"
    exit 1
fi

info "✓ Estructura de archivos correcta"

################################################################################
# PASO 6: Probar conexión a base de datos
################################################################################
log "PASO 6: Verificando conexión a base de datos..."

# Crear script temporal de prueba
cat > /tmp/test_db.py << 'TESTDB'
import asyncio
import asyncpg
import os
from dotenv import load_dotenv

async def test_connection():
    load_dotenv()
    db_url = os.getenv("DATABASE_URL")

    if not db_url:
        print("ERROR: DATABASE_URL no configurada")
        return False

    try:
        conn = await asyncpg.connect(db_url)
        result = await conn.fetchval("SELECT 1")
        await conn.close()
        print(f"✓ Conexión exitosa: {result}")
        return True
    except Exception as e:
        print(f"✗ Error de conexión: {e}")
        return False

if __name__ == "__main__":
    result = asyncio.run(test_connection())
    exit(0 if result else 1)
TESTDB

# Ejecutar prueba
if python /tmp/test_db.py; then
    info "✓ Conexión a base de datos exitosa"
else
    error "✗ Error de conexión a base de datos"
    error "Verifica las credenciales en $APP_DIR/.env"
    exit 1
fi

rm /tmp/test_db.py

################################################################################
# PASO 7: Crear servicio systemd
################################################################################
log "PASO 7: Creando servicio systemd..."

cat > /etc/systemd/system/vexus-api.service << SYSTEMD
[Unit]
Description=Vexus API - FastAPI Application
After=network.target postgresql.service
Requires=postgresql.service

[Service]
Type=simple
User=www-data
Group=www-data
WorkingDirectory=$APP_DIR
Environment="PATH=$APP_DIR/venv/bin"
EnvironmentFile=$APP_DIR/.env
ExecStart=$APP_DIR/venv/bin/uvicorn app.main:app \\
    --host 0.0.0.0 \\
    --port 8000 \\
    --workers 2 \\
    --log-level info \\
    --access-log \\
    --proxy-headers \\
    --forwarded-allow-ips='*'

# Restart
Restart=always
RestartSec=10
StartLimitInterval=60
StartLimitBurst=3

# Seguridad
NoNewPrivileges=true
PrivateTmp=true

# Logs
StandardOutput=journal
StandardError=journal
SyslogIdentifier=vexus-api

[Install]
WantedBy=multi-user.target
SYSTEMD

info "✓ Servicio systemd creado"

################################################################################
# PASO 8: Ajustar permisos
################################################################################
log "PASO 8: Ajustando permisos..."

chown -R www-data:www-data $APP_DIR
chmod -R 755 $APP_DIR
chmod 600 $APP_DIR/.env  # Archivo .env solo lectura para www-data

info "✓ Permisos ajustados"

################################################################################
# PASO 9: Habilitar e iniciar servicio
################################################################################
log "PASO 9: Iniciando servicio..."

# Recargar systemd
systemctl daemon-reload

# Habilitar servicio (auto-inicio)
systemctl enable vexus-api

# Iniciar servicio
systemctl start vexus-api

# Esperar a que inicie
sleep 5

# Verificar estado
if systemctl is-active --quiet vexus-api; then
    info "✓ Servicio iniciado correctamente"
else
    error "✗ Error al iniciar el servicio"
    error "Ver logs: journalctl -u vexus-api -n 50"
    exit 1
fi

################################################################################
# PASO 10: Verificar que la API responde
################################################################################
log "PASO 10: Verificando que la API responde..."

sleep 3

# Probar endpoint de health
if curl -f http://localhost:8000/health > /dev/null 2>&1; then
    info "✓ API responde correctamente"

    # Mostrar respuesta
    log ""
    log "Respuesta del health check:"
    curl -s http://localhost:8000/health | python3 -m json.tool
else
    error "✗ La API no responde"
    error "Ver logs: journalctl -u vexus-api -n 50"
    exit 1
fi

################################################################################
# PASO 11: Crear scripts de utilidad
################################################################################
log "PASO 11: Creando scripts de utilidad..."

# Script para ver logs
cat > /usr/local/bin/vexus-api-logs << 'LOGS'
#!/bin/bash
journalctl -u vexus-api -f
LOGS
chmod +x /usr/local/bin/vexus-api-logs

# Script para reiniciar API
cat > /usr/local/bin/vexus-api-restart << 'RESTART'
#!/bin/bash
echo "Reiniciando Vexus API..."
systemctl restart vexus-api
sleep 3
systemctl status vexus-api
RESTART
chmod +x /usr/local/bin/vexus-api-restart

# Script para actualizar código
cat > /usr/local/bin/vexus-api-update << 'UPDATE'
#!/bin/bash
echo "Actualizando Vexus API..."
cd /var/www/vexus-api

# Backup del .env actual
cp .env .env.backup

# Actualizar código (git pull o manual)
if [ -d ".git" ]; then
    git pull origin main
else
    echo "⚠️ No es un repositorio git, actualiza manualmente"
    exit 1
fi

# Activar venv e instalar dependencias
source venv/bin/activate
pip install -r requirements.txt

# Reiniciar servicio
systemctl restart vexus-api

echo "✅ Actualización completada"
systemctl status vexus-api
UPDATE
chmod +x /usr/local/bin/vexus-api-update

info "✓ Scripts de utilidad creados:"
info "  - vexus-api-logs: Ver logs en tiempo real"
info "  - vexus-api-restart: Reiniciar la API"
info "  - vexus-api-update: Actualizar código y reiniciar"

################################################################################
# VERIFICACIÓN FINAL
################################################################################
log ""
log "=========================================="
log "  VERIFICACIÓN FINAL"
log "=========================================="

# Estado del servicio
log ""
log "Estado del servicio:"
systemctl status vexus-api --no-pager -l

# Endpoints disponibles
log ""
log "Probando endpoints..."

echo -n "  - Health check: "
curl -s http://localhost:8000/health | grep -q "healthy" && echo "✓" || echo "✗"

echo -n "  - Root endpoint: "
curl -s http://localhost:8000/ | grep -q "Vexus" && echo "✓" || echo "✗"

echo -n "  - API docs: "
curl -s http://localhost:8000/docs | grep -q "swagger" && echo "✓" || echo "✗"

# Información de procesos
log ""
log "Procesos corriendo:"
ps aux | grep uvicorn | grep -v grep

# Puertos escuchando
log ""
log "Puertos en escucha:"
netstat -tlnp | grep 8000

################################################################################
# RESUMEN
################################################################################
log ""
log "=========================================="
log "  DEPLOYMENT COMPLETADO"
log "=========================================="
log ""
log "✅ Backend desplegado correctamente"
log ""
log "Información:"
log "  - Directorio: $APP_DIR"
log "  - Puerto: 8000"
log "  - Workers: 2"
log "  - Usuario: www-data"
log ""
log "Endpoints locales:"
log "  - Health: http://localhost:8000/health"
log "  - API Root: http://localhost:8000/"
log "  - Docs: http://localhost:8000/docs"
log "  - OpenAPI: http://localhost:8000/openapi.json"
log ""
log "Comandos útiles:"
log "  - Ver logs: vexus-api-logs"
log "  - Reiniciar: vexus-api-restart"
log "  - Actualizar: vexus-api-update"
log "  - Estado: systemctl status vexus-api"
log ""
log "Siguiente paso:"
log "  1. Ejecutar: ./04-deploy-frontend.sh"
log "  2. Configurar Nginx: ./05-nginx-config.conf"
log ""
log "=========================================="

exit 0
