#!/bin/bash

################################################################################
# Script de Instalación Automatizada del Sistema - VexusPage VPS
# Versión: 1.0
# Descripción: Instala todas las dependencias necesarias en Ubuntu 22.04 LTS
# Uso: sudo ./01-install-system.sh
################################################################################

set -e  # Salir si hay errores

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Función de logging
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
log "  INSTALACIÓN VPS - VEXUSPAGE"
log "=========================================="

# Crear directorio de logs
LOG_FILE="/var/log/vexus-install.log"
exec > >(tee -a "$LOG_FILE")
exec 2>&1

log "Inicio de instalación: $(date)"

################################################################################
# PASO 1: Actualizar sistema
################################################################################
log "PASO 1: Actualizando sistema operativo..."

apt update -y
apt upgrade -y
apt autoremove -y

info "Sistema actualizado correctamente"

################################################################################
# PASO 2: Instalar dependencias básicas
################################################################################
log "PASO 2: Instalando dependencias básicas..."

apt install -y \
    software-properties-common \
    build-essential \
    curl \
    wget \
    git \
    vim \
    nano \
    htop \
    net-tools \
    ufw \
    fail2ban \
    unzip \
    tar \
    ca-certificates \
    gnupg \
    lsb-release

info "Dependencias básicas instaladas"

################################################################################
# PASO 3: Instalar Python 3.12
################################################################################
log "PASO 3: Instalando Python 3.12..."

# Agregar repositorio deadsnakes
add-apt-repository ppa:deadsnakes/ppa -y
apt update -y

# Instalar Python 3.12 y dependencias
apt install -y \
    python3.12 \
    python3.12-venv \
    python3.12-dev \
    python3-pip \
    python3.12-distutils

# Verificar instalación
PYTHON_VERSION=$(python3.12 --version)
log "Python instalado: $PYTHON_VERSION"

# Actualizar pip
python3.12 -m pip install --upgrade pip setuptools wheel

info "Python 3.12 instalado correctamente"

################################################################################
# PASO 4: Instalar PostgreSQL
################################################################################
log "PASO 4: Instalando PostgreSQL..."

# Instalar PostgreSQL 15 (o 16 si prefieres)
apt install -y postgresql postgresql-contrib postgresql-client libpq-dev

# Iniciar y habilitar PostgreSQL
systemctl start postgresql
systemctl enable postgresql

# Verificar instalación
PG_VERSION=$(psql --version)
log "PostgreSQL instalado: $PG_VERSION"

info "PostgreSQL instalado correctamente"

################################################################################
# PASO 5: Instalar Nginx
################################################################################
log "PASO 5: Instalando Nginx..."

apt install -y nginx

# Iniciar y habilitar Nginx
systemctl start nginx
systemctl enable nginx

# Verificar instalación
NGINX_VERSION=$(nginx -v 2>&1)
log "Nginx instalado: $NGINX_VERSION"

info "Nginx instalado correctamente"

################################################################################
# PASO 6: Configurar Firewall (UFW)
################################################################################
log "PASO 6: Configurando firewall..."

# Configurar reglas básicas
ufw default deny incoming
ufw default allow outgoing

# Permitir SSH (IMPORTANTE: antes de habilitar UFW)
ufw allow ssh
ufw allow 22/tcp

# Permitir HTTP y HTTPS
ufw allow 'Nginx Full'
ufw allow 80/tcp
ufw allow 443/tcp

# Habilitar firewall (con confirmación automática)
echo "y" | ufw enable

# Verificar estado
ufw status verbose

info "Firewall configurado correctamente"

################################################################################
# PASO 7: Configurar Fail2Ban
################################################################################
log "PASO 7: Configurando Fail2Ban..."

# Copiar configuración por defecto
cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local

# Crear configuración personalizada
cat > /etc/fail2ban/jail.local << 'EOF'
[DEFAULT]
bantime = 3600
findtime = 600
maxretry = 5

[sshd]
enabled = true
port = ssh
logpath = %(sshd_log)s
backend = %(sshd_backend)s

[nginx-http-auth]
enabled = true
port = http,https
logpath = /var/log/nginx/error.log

[nginx-botsearch]
enabled = true
port = http,https
logpath = /var/log/nginx/access.log
maxretry = 2
EOF

# Iniciar y habilitar Fail2Ban
systemctl start fail2ban
systemctl enable fail2ban

info "Fail2Ban configurado correctamente"

################################################################################
# PASO 8: Crear estructura de directorios
################################################################################
log "PASO 8: Creando estructura de directorios..."

# Directorios principales
mkdir -p /var/www/vexus-api
mkdir -p /var/www/vexus-frontend
mkdir -p /var/backups/vexus
mkdir -p /var/log/vexus

# Establecer permisos
chown -R www-data:www-data /var/www
chmod -R 755 /var/www

chown -R root:root /var/backups/vexus
chmod -R 700 /var/backups/vexus

chown -R www-data:www-data /var/log/vexus
chmod -R 755 /var/log/vexus

info "Estructura de directorios creada"

################################################################################
# PASO 9: Instalar Certbot (para SSL)
################################################################################
log "PASO 9: Instalando Certbot..."

apt install -y certbot python3-certbot-nginx

info "Certbot instalado correctamente"

################################################################################
# PASO 10: Optimizaciones del sistema
################################################################################
log "PASO 10: Aplicando optimizaciones del sistema..."

# Aumentar límites de archivos abiertos
cat >> /etc/security/limits.conf << 'EOF'
* soft nofile 65536
* hard nofile 65536
root soft nofile 65536
root hard nofile 65536
EOF

# Optimizaciones de red
cat >> /etc/sysctl.conf << 'EOF'

# Optimizaciones para servidor web
net.core.somaxconn = 65536
net.ipv4.tcp_max_syn_backlog = 8192
net.ipv4.tcp_tw_reuse = 1
net.ipv4.ip_local_port_range = 1024 65000
net.ipv4.tcp_fin_timeout = 30
EOF

# Aplicar cambios
sysctl -p

info "Optimizaciones aplicadas"

################################################################################
# PASO 11: Configurar zona horaria
################################################################################
log "PASO 11: Configurando zona horaria..."

# Configurar a UTC (o cambia a tu zona horaria)
timedatectl set-timezone UTC

# Si prefieres hora de Argentina/Buenos Aires:
# timedatectl set-timezone America/Argentina/Buenos_Aires

TIMEZONE=$(timedatectl | grep "Time zone")
log "Zona horaria: $TIMEZONE"

info "Zona horaria configurada"

################################################################################
# PASO 12: Instalar herramientas de monitoreo
################################################################################
log "PASO 12: Instalando herramientas de monitoreo..."

apt install -y \
    htop \
    iotop \
    nethogs \
    ncdu \
    tmux

info "Herramientas de monitoreo instaladas"

################################################################################
# PASO 13: Configurar logs rotation
################################################################################
log "PASO 13: Configurando rotación de logs..."

cat > /etc/logrotate.d/vexus << 'EOF'
/var/log/vexus/*.log {
    daily
    rotate 14
    compress
    delaycompress
    notifempty
    create 0640 www-data www-data
    sharedscripts
    postrotate
        systemctl reload vexus-api > /dev/null 2>&1 || true
    endscript
}

/var/log/nginx/*.log {
    daily
    rotate 14
    compress
    delaycompress
    notifempty
    create 0640 www-data adm
    sharedscripts
    postrotate
        systemctl reload nginx > /dev/null 2>&1 || true
    endscript
}
EOF

info "Rotación de logs configurada"

################################################################################
# PASO 14: Crear usuario de deployment (opcional pero recomendado)
################################################################################
log "PASO 14: Creando usuario de deployment..."

# Crear usuario 'deploy' si no existe
if ! id -u deploy > /dev/null 2>&1; then
    adduser --disabled-password --gecos "" deploy
    usermod -aG sudo deploy
    usermod -aG www-data deploy

    # Permitir sudo sin password (opcional)
    echo "deploy ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/deploy
    chmod 440 /etc/sudoers.d/deploy

    info "Usuario 'deploy' creado"
else
    warning "Usuario 'deploy' ya existe"
fi

################################################################################
# PASO 15: Configurar SSH (seguridad adicional)
################################################################################
log "PASO 15: Configurando SSH..."

# Backup de configuración original
cp /etc/ssh/sshd_config /etc/ssh/sshd_config.backup

# Aplicar configuraciones de seguridad
sed -i 's/#PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config
sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config
sed -i 's/X11Forwarding yes/X11Forwarding no/' /etc/ssh/sshd_config

# Reiniciar SSH
systemctl restart sshd

warning "IMPORTANTE: PermitRootLogin está deshabilitado. Usa el usuario 'deploy' para conectarte."
warning "Si necesitas root, usa: ssh deploy@server y luego 'sudo su -'"

################################################################################
# PASO 16: Crear script de información del sistema
################################################################################
log "PASO 16: Creando script de información del sistema..."

cat > /usr/local/bin/vexus-info << 'EOF'
#!/bin/bash

echo "=========================================="
echo "  INFORMACIÓN DEL SISTEMA - VEXUS"
echo "=========================================="
echo ""

echo "=== Sistema ==="
echo "OS: $(lsb_release -d | cut -f2)"
echo "Kernel: $(uname -r)"
echo "Uptime: $(uptime -p)"
echo ""

echo "=== Recursos ==="
echo "CPU: $(nproc) cores"
echo "RAM: $(free -h | awk '/^Mem:/ {print $2}')"
echo "Disk: $(df -h / | awk 'NR==2 {print $4 " free of " $2}')"
echo ""

echo "=== Servicios ==="
systemctl is-active --quiet postgresql && echo "PostgreSQL: ✓ Running" || echo "PostgreSQL: ✗ Stopped"
systemctl is-active --quiet nginx && echo "Nginx: ✓ Running" || echo "Nginx: ✗ Stopped"
systemctl is-active --quiet vexus-api && echo "Vexus API: ✓ Running" || echo "Vexus API: ✗ Stopped"
systemctl is-active --quiet fail2ban && echo "Fail2Ban: ✓ Running" || echo "Fail2Ban: ✗ Stopped"
echo ""

echo "=== Versiones ==="
echo "Python: $(python3.12 --version 2>&1)"
echo "PostgreSQL: $(psql --version 2>&1)"
echo "Nginx: $(nginx -v 2>&1)"
echo ""

echo "=== Red ==="
echo "IP Pública: $(curl -s ifconfig.me)"
echo "Puertos abiertos:"
ss -tlnp | grep -E ':(80|443|22|5432|8000) '
echo ""

echo "=== Backups ==="
echo "Últimos backups:"
ls -lht /var/backups/vexus/ 2>/dev/null | head -5 || echo "No hay backups aún"
echo ""

echo "=========================================="
EOF

chmod +x /usr/local/bin/vexus-info

info "Script de información creado: /usr/local/bin/vexus-info"

################################################################################
# VERIFICACIÓN FINAL
################################################################################
log "=========================================="
log "  VERIFICACIÓN FINAL"
log "=========================================="

# Verificar servicios críticos
log "Verificando servicios..."

services=("postgresql" "nginx" "fail2ban")
for service in "${services[@]}"; do
    if systemctl is-active --quiet "$service"; then
        log "✓ $service está corriendo"
    else
        error "✗ $service NO está corriendo"
    fi
done

# Verificar versiones
log ""
log "Versiones instaladas:"
log "  - $(python3.12 --version)"
log "  - $(psql --version)"
log "  - $(nginx -v 2>&1)"

# Mostrar información del sistema
log ""
log "Información del sistema:"
log "  - Hostname: $(hostname)"
log "  - IP Local: $(hostname -I | awk '{print $1}')"
log "  - IP Pública: $(curl -s ifconfig.me || echo 'No disponible')"

################################################################################
# RESUMEN FINAL
################################################################################
log ""
log "=========================================="
log "  INSTALACIÓN COMPLETADA"
log "=========================================="
log ""
log "✅ Todos los componentes han sido instalados"
log ""
log "Siguientes pasos:"
log "  1. Ejecutar: ./02-setup-database.sh"
log "  2. Ejecutar: ./03-deploy-backend.sh"
log "  3. Ejecutar: ./04-deploy-frontend.sh"
log "  4. Configurar SSL: ./05-nginx-config.conf"
log ""
log "Para ver información del sistema: vexus-info"
log "Logs guardados en: $LOG_FILE"
log ""
log "=========================================="

exit 0
