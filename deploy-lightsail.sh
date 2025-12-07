#!/bin/bash
# Script para desplegar en AWS Lightsail
# Este script debe ejecutarse EN EL SERVIDOR, no en local

echo "🚀 Desplegando Vexus en Producción..."

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# 1. Actualizar código desde git
echo -e "${YELLOW}📥 Actualizando código desde Git...${NC}"
git pull origin main

# 2. Detener contenedores
echo -e "${YELLOW}🛑 Deteniendo contenedores...${NC}"
docker-compose -f docker-compose.prod.yml down

# 3. Eliminar volumen de postgres (si existe) para usar nueva contraseña
echo -e "${YELLOW}🗑️  Eliminando volumen de PostgreSQL viejo...${NC}"
docker volume rm vexuspage_postgres_data 2>/dev/null || true

# 4. Limpiar caché de Docker
echo -e "${YELLOW}🧹 Limpiando caché de Docker...${NC}"
docker system prune -f

# 5. Reconstruir imágenes sin caché
echo -e "${YELLOW}🔨 Reconstruyendo imágenes...${NC}"
docker-compose -f docker-compose.prod.yml build --no-cache

# 6. Levantar servicios
echo -e "${YELLOW}▶️  Levantando servicios...${NC}"
docker-compose -f docker-compose.prod.yml up -d

# 7. Esperar a que los servicios estén listos
echo -e "${YELLOW}⏳ Esperando a que los servicios inicien...${NC}"
sleep 15

# 8. Verificar que los contenedores están corriendo
echo -e "${GREEN}✅ Contenedores activos:${NC}"
docker ps --filter "name=vexus"

# 9. Verificar logs del backend
echo -e "${YELLOW}📋 Logs del backend (últimas 30 líneas):${NC}"
docker logs vexus-backend --tail 30

# 10. Verificar conexión a la base de datos
echo -e "${YELLOW}🔍 Verificando conexión a DB...${NC}"
docker exec vexus-backend curl -s http://localhost:8000/health | grep -q "ok" && echo -e "${GREEN}✅ Backend funcionando${NC}" || echo -e "${RED}❌ Backend no responde${NC}"

# 11. Verificar frontend
echo -e "${YELLOW}🔍 Verificando frontend...${NC}"
curl -s -o /dev/null -w "%{http_code}" http://localhost:80 | grep -q "200\|301\|302" && echo -e "${GREEN}✅ Frontend funcionando${NC}" || echo -e "${RED}❌ Frontend no responde${NC}"

echo ""
echo -e "${GREEN}✅ Despliegue completado${NC}"
echo ""
echo "Para ver logs en tiempo real:"
echo "  docker-compose -f docker-compose.prod.yml logs -f"
echo ""
echo "Para verificar el estado:"
echo "  docker-compose -f docker-compose.prod.yml ps"
