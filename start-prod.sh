#!/bin/bash
echo "========================================"
echo " VEXUS - INICIO PRODUCCIÓN"
echo "========================================"
echo ""

# Verificar que existe .env.production
if [ ! -f ".env.production" ]; then
    echo "ERROR: Archivo .env.production no encontrado!"
    echo ""
    echo "Por favor:"
    echo "1. cp deployment/production/.env.production.example .env.production"
    echo "2. python3 generate_secret_key.py"
    echo "3. Editar .env.production con valores reales"
    echo ""
    exit 1
fi

echo "Iniciando en modo producción..."
echo ""

cd deployment/production
docker-compose --env-file ../../.env.production up -d

echo ""
echo "Aplicación iniciada en background"
echo "Ver logs: docker-compose logs -f"
echo "Health check: curl http://localhost:8000/health"
