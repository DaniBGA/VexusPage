#!/bin/bash

# ====================================
# VEXUS - SCRIPT DE DESPLIEGUE RÁPIDO
# ====================================
# Este script automatiza el despliegue en AWS Lightsail

set -e  # Exit on error

echo "======================================"
echo "🚀 VEXUS - Deployment Script"
echo "======================================"
echo ""

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Función para imprimir mensajes
print_status() {
    echo -e "${GREEN}✓${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

# Verificar que estamos en el directorio correcto
if [ ! -f "docker-compose.prod.yml" ]; then
    print_error "No se encontró docker-compose.prod.yml. Asegúrate de estar en el directorio raíz del proyecto."
    exit 1
fi

# Verificar que existe .env.production
if [ ! -f ".env.production" ]; then
    print_error "No se encontró .env.production. Copia .env.production.example y configúralo."
    echo ""
    echo "Ejecuta:"
    echo "  cp .env.production.example .env.production"
    echo "  nano .env.production"
    exit 1
fi

# Verificar que Docker está instalado
if ! command -v docker &> /dev/null; then
    print_error "Docker no está instalado. Instálalo primero."
    exit 1
fi

# Verificar que Docker Compose está instalado
if ! command -v docker-compose &> /dev/null; then
    print_error "Docker Compose no está instalado. Instálalo primero."
    exit 1
fi

echo "1️⃣  Verificando configuración..."
print_status "Docker encontrado: $(docker --version)"
print_status "Docker Compose encontrado: $(docker-compose --version)"
print_status "Archivo .env.production encontrado"

# Preguntar si queremos hacer backup
echo ""
read -p "¿Deseas hacer backup de la base de datos antes de continuar? (s/n) " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Ss]$ ]]; then
    echo "2️⃣  Creando backup de la base de datos..."
    BACKUP_FILE="backup_$(date +%Y%m%d_%H%M%S).sql"
    if docker ps | grep -q vexus-postgres; then
        docker exec vexus-postgres pg_dump -U vexus_admin vexus_db > "$BACKUP_FILE"
        print_status "Backup creado: $BACKUP_FILE"
    else
        print_warning "Contenedor de postgres no está corriendo. Saltando backup."
    fi
fi

# Pull latest changes
echo ""
echo "3️⃣  Actualizando código desde Git..."
if [ -d ".git" ]; then
    git pull origin main
    print_status "Código actualizado"
else
    print_warning "No es un repositorio Git. Saltando pull."
fi

# Detener servicios existentes
echo ""
echo "4️⃣  Deteniendo servicios existentes..."
docker-compose -f docker-compose.prod.yml down
print_status "Servicios detenidos"

# Construir imágenes
echo ""
echo "5️⃣  Construyendo imágenes Docker..."
docker-compose -f docker-compose.prod.yml build --no-cache
print_status "Imágenes construidas"

# Levantar servicios
echo ""
echo "6️⃣  Levantando servicios..."
docker-compose -f docker-compose.prod.yml up -d
print_status "Servicios iniciados"

# Esperar a que los servicios estén listos
echo ""
echo "7️⃣  Esperando a que los servicios estén listos..."
sleep 10

# Verificar salud de los servicios
echo ""
echo "8️⃣  Verificando salud de los servicios..."

# Check Postgres
if docker exec vexus-postgres pg_isready -U vexus_admin &> /dev/null; then
    print_status "PostgreSQL está listo"
else
    print_error "PostgreSQL no responde"
fi

# Check Backend
if curl -f http://localhost:8000/health &> /dev/null; then
    print_status "Backend está listo"
else
    print_error "Backend no responde"
fi

# Check Frontend
if curl -f http://localhost &> /dev/null; then
    print_status "Frontend está listo"
else
    print_error "Frontend no responde"
fi

# Mostrar status
echo ""
echo "9️⃣  Estado de los contenedores:"
docker-compose -f docker-compose.prod.yml ps

# Mostrar logs recientes
echo ""
echo "📋 Últimos logs:"
docker-compose -f docker-compose.prod.yml logs --tail=20

echo ""
echo "======================================"
echo -e "${GREEN}✅ Despliegue completado${NC}"
echo "======================================"
echo ""
echo "📊 Para ver logs en tiempo real:"
echo "   docker-compose -f docker-compose.prod.yml logs -f"
echo ""
echo "🔍 Para verificar el estado:"
echo "   docker-compose -f docker-compose.prod.yml ps"
echo ""
echo "🛑 Para detener los servicios:"
echo "   docker-compose -f docker-compose.prod.yml down"
echo ""
echo "🔄 Para reiniciar un servicio:"
echo "   docker-compose -f docker-compose.prod.yml restart [backend|frontend|postgres]"
echo ""
