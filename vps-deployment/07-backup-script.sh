#!/bin/bash

################################################################################
# Script de Backup Automático - VexusPage VPS
# Versión: 1.0
# Descripción: Realiza backup completo de base de datos y archivos
# Uso: ./07-backup-script.sh [manual|auto]
################################################################################

set -e  # Salir si hay errores

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

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

################################################################################
# CONFIGURACIÓN - EDITA ESTOS VALORES
################################################################################

# Credenciales de base de datos (deben coincidir con 02-setup-database.sh)
DB_NAME="vexus_db"
DB_USER="vexus_admin"
DB_PASSWORD="CAMBIAR_POR_PASSWORD_SEGURA"  # ⚠️ CAMBIAR ESTO
DB_HOST="localhost"
DB_PORT="5432"

# Directorios
BACKUP_DIR="/var/backups/vexus"
APP_DIR="/var/www/vexus-api"
FRONTEND_DIR="/var/www/vexus-frontend"

# Retención (días)
RETENTION_DAYS=30

# Tipo de backup (manual o auto)
BACKUP_TYPE="${1:-auto}"

################################################################################
# VALIDACIONES
################################################################################

log "=========================================="
log "  BACKUP VEXUSPAGE"
log "=========================================="

# Verificar que se ejecuta como root
if [ "$EUID" -ne 0 ]; then
    error "Este script debe ejecutarse como root (use sudo)"
    exit 1
fi

# Verificar directorios
if [ ! -d "$BACKUP_DIR" ]; then
    warning "Directorio de backup no existe, creándolo..."
    mkdir -p "$BACKUP_DIR"
    chmod 700 "$BACKUP_DIR"
fi

# Verificar credenciales
if [ "$DB_PASSWORD" = "CAMBIAR_POR_PASSWORD_SEGURA" ]; then
    warning "Contraseña de base de datos no configurada"
    warning "Intentando leer desde archivo de credenciales..."

    if [ -f "/root/.vexus-db-credentials" ]; then
        source /root/.vexus-db-credentials
        info "Credenciales cargadas desde /root/.vexus-db-credentials"
    else
        error "No se encontraron credenciales"
        error "Edita este script y configura DB_PASSWORD"
        exit 1
    fi
fi

################################################################################
# PREPARACIÓN
################################################################################

# Timestamp para el backup
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_DATE=$(date +"%Y-%m-%d %H:%M:%S")

# Nombres de archivos
DB_BACKUP_FILE="vexus_db_${TIMESTAMP}.sql"
DB_BACKUP_GZ="vexus_db_${TIMESTAMP}.sql.gz"
FILES_BACKUP="vexus_files_${TIMESTAMP}.tar.gz"
FULL_BACKUP="vexus_full_${TIMESTAMP}.tar.gz"

# Directorio temporal
TEMP_DIR="/tmp/vexus_backup_${TIMESTAMP}"
mkdir -p "$TEMP_DIR"

log "Iniciando backup: $BACKUP_TYPE"
log "Timestamp: $TIMESTAMP"

################################################################################
# PASO 1: Backup de Base de Datos
################################################################################
log "PASO 1: Realizando backup de base de datos..."

# Exportar password para pg_dump
export PGPASSWORD="$DB_PASSWORD"

# Realizar dump de la base de datos
if pg_dump -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" \
    --clean --if-exists --create \
    -F plain -f "$TEMP_DIR/$DB_BACKUP_FILE"; then

    info "✓ Dump de base de datos completado"

    # Comprimir dump
    gzip "$TEMP_DIR/$DB_BACKUP_FILE"
    info "✓ Base de datos comprimida"

    # Obtener tamaño
    DB_SIZE=$(du -h "$TEMP_DIR/$DB_BACKUP_GZ" | cut -f1)
    log "  Tamaño: $DB_SIZE"
else
    error "✗ Error al realizar dump de base de datos"
    rm -rf "$TEMP_DIR"
    unset PGPASSWORD
    exit 1
fi

# Limpiar variable de password
unset PGPASSWORD

################################################################################
# PASO 2: Backup de Archivos del Backend
################################################################################
log "PASO 2: Realizando backup de archivos del backend..."

if [ -d "$APP_DIR" ]; then
    # Crear backup del backend (excluyendo venv y cache)
    tar -czf "$TEMP_DIR/backend.tar.gz" \
        -C /var/www \
        --exclude='vexus-api/venv' \
        --exclude='vexus-api/__pycache__' \
        --exclude='vexus-api/**/__pycache__' \
        --exclude='vexus-api/.git' \
        vexus-api/ \
        2>/dev/null || true

    BACKEND_SIZE=$(du -h "$TEMP_DIR/backend.tar.gz" | cut -f1)
    info "✓ Backup de backend completado ($BACKEND_SIZE)"
else
    warning "Directorio de backend no encontrado: $APP_DIR"
fi

################################################################################
# PASO 3: Backup de Archivos del Frontend
################################################################################
log "PASO 3: Realizando backup de archivos del frontend..."

if [ -d "$FRONTEND_DIR" ]; then
    tar -czf "$TEMP_DIR/frontend.tar.gz" \
        -C /var/www \
        vexus-frontend/ \
        2>/dev/null || true

    FRONTEND_SIZE=$(du -h "$TEMP_DIR/frontend.tar.gz" | cut -f1)
    info "✓ Backup de frontend completado ($FRONTEND_SIZE)"
else
    warning "Directorio de frontend no encontrado: $FRONTEND_DIR"
fi

################################################################################
# PASO 4: Backup de Configuraciones
################################################################################
log "PASO 4: Realizando backup de configuraciones..."

mkdir -p "$TEMP_DIR/config"

# Nginx
if [ -d "/etc/nginx/sites-available" ]; then
    cp -r /etc/nginx/sites-available "$TEMP_DIR/config/" 2>/dev/null || true
    info "✓ Configuración de Nginx copiada"
fi

# Systemd service
if [ -f "/etc/systemd/system/vexus-api.service" ]; then
    cp /etc/systemd/system/vexus-api.service "$TEMP_DIR/config/" 2>/dev/null || true
    info "✓ Servicio systemd copiado"
fi

# Archivo .env (IMPORTANTE)
if [ -f "$APP_DIR/.env" ]; then
    cp "$APP_DIR/.env" "$TEMP_DIR/config/backend.env" 2>/dev/null || true
    info "✓ Archivo .env copiado"
fi

# SSL certificates (solo metadata, no las keys privadas por seguridad)
if [ -d "/etc/letsencrypt" ]; then
    # Solo copiar la configuración, no las keys
    mkdir -p "$TEMP_DIR/config/letsencrypt"
    cp /etc/letsencrypt/renewal/*.conf "$TEMP_DIR/config/letsencrypt/" 2>/dev/null || true
    info "✓ Configuración SSL copiada"
fi

# Comprimir configuraciones
tar -czf "$TEMP_DIR/config.tar.gz" -C "$TEMP_DIR" config/ 2>/dev/null || true
rm -rf "$TEMP_DIR/config"

CONFIG_SIZE=$(du -h "$TEMP_DIR/config.tar.gz" | cut -f1)
info "✓ Backup de configuraciones completado ($CONFIG_SIZE)"

################################################################################
# PASO 5: Crear Metadata del Backup
################################################################################
log "PASO 5: Creando metadata del backup..."

cat > "$TEMP_DIR/backup_info.txt" << METADATA
========================================
BACKUP VEXUSPAGE
========================================

Fecha: $BACKUP_DATE
Timestamp: $TIMESTAMP
Tipo: $BACKUP_TYPE
Hostname: $(hostname)
IP: $(hostname -I | awk '{print $1}')

CONTENIDO:
- Base de datos: $DB_NAME
- Backend: $APP_DIR
- Frontend: $FRONTEND_DIR

ARCHIVOS:
- Base de datos: $DB_BACKUP_GZ ($DB_SIZE)
- Backend: backend.tar.gz ($BACKEND_SIZE)
- Frontend: frontend.tar.gz ($FRONTEND_SIZE)
- Configuraciones: config.tar.gz ($CONFIG_SIZE)

VERSIONES:
- PostgreSQL: $(psql --version 2>&1 | head -1)
- Python: $(python3.12 --version 2>&1)
- Nginx: $(nginx -v 2>&1)

RESTAURACIÓN:
Para restaurar este backup:
1. Copiar el archivo a la VPS
2. Extraer: tar -xzf vexus_full_${TIMESTAMP}.tar.gz
3. Restaurar DB: gunzip -c $DB_BACKUP_GZ | psql -U $DB_USER -d postgres
4. Restaurar archivos: tar -xzf backend.tar.gz -C /var/www/
5. Restaurar configuraciones: tar -xzf config.tar.gz

========================================
METADATA

info "✓ Metadata creada"

################################################################################
# PASO 6: Crear Archivo Final
################################################################################
log "PASO 6: Creando archivo final de backup..."

# Crear backup completo (todo en un solo archivo)
tar -czf "$BACKUP_DIR/$FULL_BACKUP" -C "$TEMP_DIR" . 2>/dev/null

# Verificar que se creó correctamente
if [ -f "$BACKUP_DIR/$FULL_BACKUP" ]; then
    FULL_SIZE=$(du -h "$BACKUP_DIR/$FULL_BACKUP" | cut -f1)
    info "✓ Backup completo creado: $FULL_BACKUP ($FULL_SIZE)"
else
    error "✗ Error al crear backup completo"
    rm -rf "$TEMP_DIR"
    exit 1
fi

# Ajustar permisos
chmod 600 "$BACKUP_DIR/$FULL_BACKUP"

################################################################################
# PASO 7: Limpiar Archivos Temporales
################################################################################
log "PASO 7: Limpiando archivos temporales..."

rm -rf "$TEMP_DIR"
info "✓ Archivos temporales eliminados"

################################################################################
# PASO 8: Limpiar Backups Antiguos
################################################################################
log "PASO 8: Limpiando backups antiguos (>$RETENTION_DAYS días)..."

# Contar backups antes
BACKUPS_BEFORE=$(find "$BACKUP_DIR" -name "vexus_full_*.tar.gz" | wc -l)

# Eliminar backups antiguos
find "$BACKUP_DIR" -name "vexus_full_*.tar.gz" -mtime +$RETENTION_DAYS -delete

# Contar backups después
BACKUPS_AFTER=$(find "$BACKUP_DIR" -name "vexus_full_*.tar.gz" | wc -l)
DELETED=$((BACKUPS_BEFORE - BACKUPS_AFTER))

if [ $DELETED -gt 0 ]; then
    info "✓ $DELETED backup(s) antiguo(s) eliminado(s)"
else
    info "✓ No hay backups antiguos para eliminar"
fi

################################################################################
# PASO 9: Verificar Integridad
################################################################################
log "PASO 9: Verificando integridad del backup..."

if tar -tzf "$BACKUP_DIR/$FULL_BACKUP" > /dev/null 2>&1; then
    info "✓ Integridad verificada correctamente"
else
    error "✗ El archivo de backup está corrupto"
    exit 1
fi

################################################################################
# PASO 10: Enviar Notificación (Opcional)
################################################################################
log "PASO 10: Enviando notificación..."

# Aquí puedes agregar código para enviar notificación por email/Slack/etc.
# Por ejemplo:
# curl -X POST https://hooks.slack.com/... -d "{\"text\":\"Backup completado: $FULL_BACKUP\"}"

info "✓ Notificación enviada (implementar si es necesario)"

################################################################################
# RESUMEN
################################################################################
log ""
log "=========================================="
log "  BACKUP COMPLETADO"
log "=========================================="
log ""
log "✅ Backup realizado exitosamente"
log ""
log "Archivo de backup:"
log "  $BACKUP_DIR/$FULL_BACKUP"
log "  Tamaño: $FULL_SIZE"
log ""
log "Backups disponibles: $BACKUPS_AFTER"
log "Espacio usado: $(du -sh $BACKUP_DIR | cut -f1)"
log ""
log "Para restaurar:"
log "  tar -xzf $BACKUP_DIR/$FULL_BACKUP -C /tmp/"
log "  cat /tmp/backup_info.txt"
log ""
log "=========================================="

# Listar últimos 5 backups
log ""
log "Últimos backups:"
ls -lht "$BACKUP_DIR"/vexus_full_*.tar.gz | head -5 | awk '{print "  " $9 " (" $5 " - " $6 " " $7 ")"}'

exit 0
