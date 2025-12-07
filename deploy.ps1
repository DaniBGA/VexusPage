# Script de despliegue para AWS Lightsail (PowerShell)
# Uso: .\deploy.ps1

Write-Host "🚀 Iniciando despliegue de Vexus Page..." -ForegroundColor Cyan

# Verificar que existe .env
if (-not (Test-Path .env)) {
    Write-Host "❌ Error: No se encontró el archivo .env" -ForegroundColor Red
    Write-Host "Por favor, copia .env.production.example a .env y configúralo" -ForegroundColor Yellow
    exit 1
}

# Verificar que Docker está corriendo
try {
    docker info | Out-Null
} catch {
    Write-Host "❌ Error: Docker no está corriendo" -ForegroundColor Red
    exit 1
}

Write-Host "✅ Verificaciones iniciales completadas" -ForegroundColor Green

# Detener contenedores actuales
Write-Host "🛑 Deteniendo contenedores actuales..." -ForegroundColor Yellow
docker-compose -f docker-compose.prod.yml down

# Limpiar caché de Docker
Write-Host "🧹 Limpiando caché de Docker..." -ForegroundColor Yellow
docker system prune -af --volumes

# Reconstruir imágenes sin caché
Write-Host "🔨 Reconstruyendo imágenes..." -ForegroundColor Yellow
docker-compose -f docker-compose.prod.yml build --no-cache

# Iniciar servicios
Write-Host "▶️  Iniciando servicios..." -ForegroundColor Yellow
docker-compose -f docker-compose.prod.yml up -d

# Esperar a que los servicios estén listos
Write-Host "⏳ Esperando que los servicios estén listos..." -ForegroundColor Yellow
Start-Sleep -Seconds 10

# Verificar que los contenedores están corriendo
Write-Host "🔍 Verificando contenedores..." -ForegroundColor Yellow
docker ps --filter "name=vexus"

# Verificar health checks
Write-Host "🏥 Verificando health checks..." -ForegroundColor Yellow

# Backend
try {
    $response = Invoke-WebRequest -Uri "https://www.grupovexus.com/health" -UseBasicParsing -TimeoutSec 5
    if ($response.StatusCode -eq 200) {
        Write-Host "✅ Backend respondiendo correctamente" -ForegroundColor Green
    }
} catch {
    Write-Host "❌ Backend no responde" -ForegroundColor Red
    Write-Host "Logs del backend:" -ForegroundColor Yellow
    docker logs vexus-backend --tail 20
}

# Frontend
try {
    $response = Invoke-WebRequest -Uri "https://www.grupovexus.com" -UseBasicParsing -TimeoutSec 5
    if ($response.StatusCode -eq 200) {
        Write-Host "✅ Frontend respondiendo correctamente" -ForegroundColor Green
    }
} catch {
    Write-Host "❌ Frontend no responde" -ForegroundColor Red
    Write-Host "Logs del frontend:" -ForegroundColor Yellow
    docker logs vexus-frontend --tail 20
}

# Mostrar logs en tiempo real
Write-Host "✅ Despliegue completado" -ForegroundColor Green
Write-Host "Mostrando logs en tiempo real (Ctrl+C para salir)..." -ForegroundColor Yellow
docker-compose -f docker-compose.prod.yml logs -f
