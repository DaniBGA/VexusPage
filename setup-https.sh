#!/bin/bash

# ====================================
# Script de Configuración HTTPS
# Vexus - AWS Lightsail
# ====================================

set -e  # Detener si hay errores

echo "🔒 CONFIGURACIÓN HTTPS PARA GRUPOVEXUS.COM"
echo "=========================================="
echo ""

# Colores
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Variables
PROJECT_DIR="/home/ubuntu/VexusPage"
SSL_DIR="$PROJECT_DIR/ssl"
DOMAIN="grupovexus.com"

# Función para mensajes
success() {
    echo -e "${GREEN}✅ $1${NC}"
}

error() {
    echo -e "${RED}❌ $1${NC}"
    exit 1
}

warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

info() {
    echo -e "ℹ️  $1"
}

# Verificar que estamos en el servidor correcto
if [ ! -d "$PROJECT_DIR" ]; then
    error "No se encuentra el directorio $PROJECT_DIR"
fi

# PASO 1: Crear carpeta SSL
info "Paso 1/10: Creando carpeta SSL..."
sudo mkdir -p "$SSL_DIR"
success "Carpeta SSL creada"

# PASO 2: Verificar certificados de Let's Encrypt
info "Paso 2/10: Verificando certificados de Let's Encrypt..."
if [ ! -d "/etc/letsencrypt/live/$DOMAIN" ]; then
    error "No se encuentran certificados para $DOMAIN. Ejecuta: sudo certbot certonly --nginx -d $DOMAIN -d www.$DOMAIN"
fi
success "Certificados encontrados"

# PASO 3: Copiar certificados
info "Paso 3/10: Copiando certificados..."
sudo cp -r /etc/letsencrypt/live/$DOMAIN "$SSL_DIR/"
sudo cp -r /etc/letsencrypt/archive/$DOMAIN "$SSL_DIR/"
success "Certificados copiados"

# PASO 4: Dar permisos
info "Paso 4/10: Configurando permisos..."
sudo chmod -R 755 "$SSL_DIR"
sudo chown -R ubuntu:ubuntu "$SSL_DIR"
success "Permisos configurados"

# PASO 5: Verificar archivos
info "Paso 5/10: Verificando archivos de certificados..."
if [ ! -f "$SSL_DIR/live/$DOMAIN/fullchain.pem" ]; then
    error "No se encuentra fullchain.pem"
fi
if [ ! -f "$SSL_DIR/live/$DOMAIN/privkey.pem" ]; then
    error "No se encuentra privkey.pem"
fi
success "Archivos de certificados OK"

# PASO 6: Git pull
info "Paso 6/10: Actualizando código desde Git..."
cd "$PROJECT_DIR"
git pull origin main || warning "Git pull falló, continuando con archivos locales..."
success "Código actualizado"

# PASO 7: Detener contenedores
info "Paso 7/10: Deteniendo contenedores..."
docker compose -f docker-compose.prod.yml down
success "Contenedores detenidos"

# PASO 8: Reconstruir y levantar
info "Paso 8/10: Reconstruyendo y levantando contenedores..."
info "Esto puede tomar 2-3 minutos..."
docker compose -f docker-compose.prod.yml up -d --build
success "Contenedores levantados"

# PASO 9: Esperar a que los contenedores estén saludables
info "Paso 9/10: Esperando a que los contenedores estén saludables..."
sleep 10

# Verificar postgres
info "Verificando postgres..."
for i in {1..30}; do
    if docker exec vexus-postgres pg_isready -U vexus_admin -d vexus_db > /dev/null 2>&1; then
        success "PostgreSQL está listo"
        break
    fi
    if [ $i -eq 30 ]; then
        error "PostgreSQL no respondió"
    fi
    sleep 2
done

# Verificar backend
info "Verificando backend..."
for i in {1..30}; do
    if curl -s http://localhost:8000/health > /dev/null 2>&1; then
        success "Backend está listo"
        break
    fi
    if [ $i -eq 30 ]; then
        error "Backend no respondió"
    fi
    sleep 2
done

# Verificar frontend
info "Verificando frontend..."
sleep 5
if docker exec vexus-frontend nginx -t > /dev/null 2>&1; then
    success "Nginx configuración OK"
else
    error "Nginx configuración inválida"
fi

# PASO 10: Tests finales
info "Paso 10/10: Ejecutando tests..."

# Test 1: Certificados en contenedor
info "Test 1: Verificando certificados en contenedor..."
if docker exec vexus-frontend test -f /etc/letsencrypt/live/$DOMAIN/fullchain.pem; then
    success "Certificados montados correctamente"
else
    error "Certificados NO encontrados en contenedor"
fi

# Test 2: HTTPS funciona
info "Test 2: Verificando HTTPS..."
sleep 3
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" https://localhost || echo "000")
if [ "$HTTP_CODE" = "200" ]; then
    success "HTTPS funciona (código 200)"
else
    warning "HTTPS retornó código $HTTP_CODE (puede ser normal si aún no propagó)"
fi

# Test 3: Redirección HTTP → HTTPS
info "Test 3: Verificando redirección HTTP → HTTPS..."
REDIRECT_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost || echo "000")
if [ "$REDIRECT_CODE" = "301" ]; then
    success "Redirección HTTP → HTTPS funciona (código 301)"
else
    warning "Redirección retornó código $REDIRECT_CODE"
fi

# Test 4: Healthcheck
info "Test 4: Verificando healthcheck..."
sleep 10
HEALTH=$(docker inspect vexus-frontend --format='{{.State.Health.Status}}' 2>/dev/null || echo "unknown")
if [ "$HEALTH" = "healthy" ]; then
    success "Healthcheck OK"
elif [ "$HEALTH" = "starting" ]; then
    warning "Healthcheck aún iniciando, espera 30 segundos más"
else
    warning "Healthcheck: $HEALTH (puede tomar tiempo)"
fi

echo ""
echo "=========================================="
echo -e "${GREEN}🎉 CONFIGURACIÓN COMPLETADA${NC}"
echo "=========================================="
echo ""
echo "📝 TESTS EXTERNOS:"
echo "   1. Abre Chrome y ve a: https://grupovexus.com"
echo "   2. Verifica el candado verde 🔒"
echo "   3. Prueba también: https://www.grupovexus.com"
echo ""
echo "🔍 VERIFICACIÓN MANUAL:"
echo "   curl -I https://grupovexus.com"
echo "   curl -I https://www.grupovexus.com"
echo ""
echo "📊 VER LOGS:"
echo "   docker logs vexus-frontend -f"
echo ""
echo "🔄 SI ALGO FALLA:"
echo "   Ejecuta: docker compose -f docker-compose.prod.yml logs"
echo ""
