#!/bin/bash
# Script para resetear PostgreSQL con la nueva contraseña

echo "🔄 RESETEAR BASE DE DATOS POSTGRESQL"
echo "======================================"
echo ""
echo "⚠️  ADVERTENCIA: Esto borrará TODOS los datos de la base de datos"
echo "⚠️  Asegúrate de tener un backup si necesitas conservar datos"
echo ""
read -p "¿Continuar? (escribe 'SI' en mayúsculas): " confirm

if [ "$confirm" != "SI" ]; then
    echo "❌ Operación cancelada"
    exit 1
fi

echo ""
echo "1️⃣ Parando contenedores..."
docker-compose -f docker-compose.prod.yml down

echo ""
echo "2️⃣ Eliminando volumen de PostgreSQL (contraseña antigua)..."
docker volume rm vexuspage_postgres_data

echo ""
echo "3️⃣ Verificando que .env.production tiene la contraseña correcta..."
grep POSTGRES_PASSWORD .env.production

echo ""
echo "4️⃣ Reconstruyendo backend..."
docker-compose -f docker-compose.prod.yml build backend

echo ""
echo "5️⃣ Iniciando servicios (PostgreSQL se creará con contraseña nueva)..."
docker-compose -f docker-compose.prod.yml up -d

echo ""
echo "6️⃣ Esperando que PostgreSQL esté listo (30 segundos)..."
sleep 30

echo ""
echo "7️⃣ Verificando logs del backend..."
docker logs vexus-backend | tail -20

echo ""
echo "✅ Proceso completado"
echo ""
echo "🔍 Para verificar:"
echo "   docker logs -f vexus-backend"
echo "   docker logs -f vexus-postgres"
echo ""
echo "🧪 Para probar SendGrid:"
echo "   export SENDGRID_API_KEY=\"TU_API_KEY_AQUI\""
echo "   python3 test_sendgrid.py"
