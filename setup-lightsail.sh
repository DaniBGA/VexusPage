#!/bin/bash
# 🚀 Script de Inicio Rápido para AWS Lightsail
# Ejecuta este script después de conectarte por SSH a tu instancia

set -e  # Detener si hay error

echo "======================================"
echo "🚀 VEXUS - INSTALACIÓN AUTOMÁTICA"
echo "======================================"
echo ""

# Colores
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Paso 1: Actualizar sistema
echo -e "${YELLOW}[1/7]${NC} Actualizando sistema..."
sudo apt update -y
sudo apt upgrade -y

# Paso 2: Instalar Docker
echo -e "${YELLOW}[2/7]${NC} Instalando Docker..."
if ! command -v docker &> /dev/null; then
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh get-docker.sh
    sudo usermod -aG docker ubuntu
    echo -e "${GREEN}✓${NC} Docker instalado"
else
    echo -e "${GREEN}✓${NC} Docker ya está instalado"
fi

# Paso 3: Instalar Docker Compose
echo -e "${YELLOW}[3/7]${NC} Instalando Docker Compose..."
if ! command -v docker-compose &> /dev/null; then
    sudo apt install docker-compose -y
    echo -e "${GREEN}✓${NC} Docker Compose instalado"
else
    echo -e "${GREEN}✓${NC} Docker Compose ya está instalado"
fi

# Paso 4: Instalar Git
echo -e "${YELLOW}[4/7]${NC} Instalando Git..."
if ! command -v git &> /dev/null; then
    sudo apt install git -y
    echo -e "${GREEN}✓${NC} Git instalado"
else
    echo -e "${GREEN}✓${NC} Git ya está instalado"
fi

# Paso 5: Clonar repositorio
echo -e "${YELLOW}[5/7]${NC} Clonando repositorio..."
cd ~
if [ ! -d "VexusPage" ]; then
    git clone https://github.com/DaniBGA/VexusPage.git
    echo -e "${GREEN}✓${NC} Repositorio clonado"
else
    echo -e "${YELLOW}!${NC} Repositorio ya existe, actualizando..."
    cd VexusPage
    git pull
    cd ~
fi

# Paso 6: Configurar variables de entorno
echo -e "${YELLOW}[6/7]${NC} Configurando variables de entorno..."
cd ~/VexusPage
if [ ! -f ".env.production" ]; then
    cp .env.production.example .env.production
    echo -e "${GREEN}✓${NC} Archivo .env.production creado"
    echo -e "${YELLOW}⚠${NC}  IMPORTANTE: Edita el archivo .env.production con tus datos reales"
    echo ""
    echo "Ejecuta: nano .env.production"
    echo ""
else
    echo -e "${GREEN}✓${NC} Archivo .env.production ya existe"
fi

# Paso 7: Levantar servicios
echo -e "${YELLOW}[7/7]${NC} Levantando servicios con Docker..."
echo ""
echo -e "${YELLOW}⚠${NC}  Esto puede tomar 5-10 minutos la primera vez..."
echo ""

docker-compose -f docker-compose.prod.yml --env-file .env.production up -d --build

echo ""
echo "======================================"
echo -e "${GREEN}✅ INSTALACIÓN COMPLETADA!${NC}"
echo "======================================"
echo ""
echo "📊 Ver estado de los contenedores:"
echo "   docker-compose -f docker-compose.prod.yml ps"
echo ""
echo "📋 Ver logs:"
echo "   docker-compose -f docker-compose.prod.yml logs -f"
echo ""
echo "🌐 Acceder a tu sitio:"
echo "   http://$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)"
echo ""
echo "📝 Próximos pasos:"
echo "   1. Configura tu dominio grupovexus.com"
echo "   2. Instala certificado SSL (HTTPS)"
echo "   3. ¡Disfruta tu sitio en producción!"
echo ""
