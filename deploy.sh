#!/bin/bash

# Script de despliegue para AWS Lightsail
# Uso: ./deploy.sh

echo "🚀 Iniciando despliegue de Vexus Page..."

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Verificar que existe .env
if [ ! -f .env ]; then
    echo -e "${RED}❌ Error: No se encontró el archivo .env${NC}"
    echo -e "${YELLOW}Por favor, copia .env.production.example a .env y configúralo${NC}"
    exit 1
fi

# Verificar que Docker está corriendo
if ! docker info > /dev/null 2>&1; then
    echo -e "${RED}❌ Error: Docker no está corriendo${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Verificaciones iniciales completadas${NC}"

# Detener contenedores actuales
echo -e "${YELLOW}🛑 Deteniendo contenedores actuales...${NC}"
docker-compose -f docker-compose.prod.yml down

# Limpiar caché de Docker
echo -e "${YELLOW}🧹 Limpiando caché de Docker...${NC}"
docker system prune -af --volumes

# Reconstruir imágenes sin caché
echo -e "${YELLOW}🔨 Reconstruyendo imágenes...${NC}"
docker-compose -f docker-compose.prod.yml build --no-cache

# Iniciar servicios
echo -e "${YELLOW}▶️  Iniciando servicios...${NC}"
docker-compose -f docker-compose.prod.yml up -d

# Esperar a que los servicios estén listos
echo -e "${YELLOW}⏳ Esperando que los servicios estén listos...${NC}"
sleep 10

# Verificar que los contenedores están corriendo
echo -e "${YELLOW}🔍 Verificando contenedores...${NC}"
docker ps --filter "name=vexus"

# Verificar health checks
echo -e "${YELLOW}🏥 Verificando health checks...${NC}"

# Backend
if curl -f -s https://www.grupovexus.com/health > /dev/null; then
    echo -e "${GREEN}✅ Backend respondiendo correctamente${NC}"
else
    echo -e "${RED}❌ Backend no responde${NC}"
    echo -e "${YELLOW}Logs del backend:${NC}"
    docker logs vexus-backend --tail 20
fi

# Frontend
if curl -f -s https://www.grupovexus.com > /dev/null; then
    echo -e "${GREEN}✅ Frontend respondiendo correctamente${NC}"
else
    echo -e "${RED}❌ Frontend no responde${NC}"
    echo -e "${YELLOW}Logs del frontend:${NC}"
    docker logs vexus-frontend --tail 20
fi

# Mostrar logs en tiempo real
echo -e "${GREEN}✅ Despliegue completado${NC}"
echo -e "${YELLOW}Mostrando logs en tiempo real (Ctrl+C para salir)...${NC}"
docker-compose -f docker-compose.prod.yml logs -f
