#!/bin/bash
# Script para resetear PostgreSQL y reiniciar servicios con SendGrid

echo "🔄 RESETEAR Y DESPLEGAR CON SENDGRID"
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
docker-compose -f docker-compose.prod.yml --env-file .env.production down

echo ""
echo "2️⃣ Eliminando volumen de PostgreSQL (contraseña antigua)..."
docker volume rm vexuspage_postgres_data

echo ""
echo "3️⃣ Verificando que .env.production tiene las credenciales correctas..."
echo "📊 POSTGRES_PASSWORD:"
grep POSTGRES_PASSWORD .env.production
echo ""
echo "📧 SENDGRID_API_KEY:"
grep SENDGRID_API_KEY .env.production

echo ""
echo "4️⃣ Reconstruyendo backend..."
docker-compose -f docker-compose.prod.yml --env-file .env.production build backend

echo ""
echo "5️⃣ Iniciando servicios..."
docker-compose -f docker-compose.prod.yml --env-file .env.production up -d

echo ""
echo "6️⃣ Esperando que los servicios estén listos (40 segundos)..."
sleep 40

echo ""
echo "7️⃣ Verificando SENDGRID_API_KEY en el contenedor..."
docker exec vexus-backend env | grep SENDGRID

echo ""
echo "8️⃣ Logs del backend (últimas 30 líneas)..."
docker logs vexus-backend --tail 30

echo ""
echo "✅ Proceso completado"
echo ""
echo "🔍 Para verificar en tiempo real:"
echo "   docker logs -f vexus-backend"
echo ""
echo "🧪 Prueba el formulario en: https://www.grupovexus.com"
echo ""
echo "📧 Deberías ver en los logs:"
echo "   📧 Enviando email via SendGrid SDK a: grupovexus@gmail.com"
echo "   🔑 SendGrid API Key presente: SG.ZoZ_jx-W...w-10"
echo "   ✅ Email enviado exitosamente via SendGrid"
