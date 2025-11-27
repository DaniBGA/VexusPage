# ====================================
# VEXUS - Script de Despliegue para Windows
# ====================================
# Ejecuta con: .\deploy.ps1

$ErrorActionPreference = "Stop"

Write-Host "======================================" -ForegroundColor Cyan
Write-Host "🚀 VEXUS - Deployment Script" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan
Write-Host ""

function Print-Status {
    param($Message)
    Write-Host "✓ $Message" -ForegroundColor Green
}

function Print-Error {
    param($Message)
    Write-Host "✗ $Message" -ForegroundColor Red
}

function Print-Warning {
    param($Message)
    Write-Host "⚠ $Message" -ForegroundColor Yellow
}

# Verificar que estamos en el directorio correcto
if (-not (Test-Path "docker-compose.prod.yml")) {
    Print-Error "No se encontró docker-compose.prod.yml. Asegúrate de estar en el directorio raíz del proyecto."
    exit 1
}

# Verificar que existe .env.production
if (-not (Test-Path ".env.production")) {
    Print-Error "No se encontró .env.production. Copia .env.production.example y configúralo."
    Write-Host ""
    Write-Host "Ejecuta:"
    Write-Host "  Copy-Item .env.production.example .env.production"
    Write-Host "  notepad .env.production"
    exit 1
}

# Verificar Docker
if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
    Print-Error "Docker no está instalado. Instálalo primero."
    exit 1
}

# Verificar Docker Compose
if (-not (Get-Command docker-compose -ErrorAction SilentlyContinue)) {
    Print-Error "Docker Compose no está instalado. Instálalo primero."
    exit 1
}

Write-Host "1️⃣  Verificando configuración..." -ForegroundColor Yellow
$dockerVersion = docker --version
$composeVersion = docker-compose --version
Print-Status "Docker encontrado: $dockerVersion"
Print-Status "Docker Compose encontrado: $composeVersion"
Print-Status "Archivo .env.production encontrado"

# Preguntar por backup
Write-Host ""
$backup = Read-Host "¿Deseas hacer backup de la base de datos antes de continuar? (s/n)"
if ($backup -eq "s" -or $backup -eq "S") {
    Write-Host "2️⃣  Creando backup de la base de datos..." -ForegroundColor Yellow
    $backupFile = "backup_$(Get-Date -Format 'yyyyMMdd_HHmmss').sql"
    
    if (docker ps | Select-String "vexus-postgres") {
        docker exec vexus-postgres pg_dump -U vexus_admin vexus_db > $backupFile
        Print-Status "Backup creado: $backupFile"
    } else {
        Print-Warning "Contenedor de postgres no está corriendo. Saltando backup."
    }
}

# Pull latest changes
Write-Host ""
Write-Host "3️⃣  Actualizando código desde Git..." -ForegroundColor Yellow
if (Test-Path ".git") {
    git pull origin main
    Print-Status "Código actualizado"
} else {
    Print-Warning "No es un repositorio Git. Saltando pull."
}

# Detener servicios existentes
Write-Host ""
Write-Host "4️⃣  Deteniendo servicios existentes..." -ForegroundColor Yellow
docker-compose -f docker-compose.prod.yml down
Print-Status "Servicios detenidos"

# Construir imágenes
Write-Host ""
Write-Host "5️⃣  Construyendo imágenes Docker..." -ForegroundColor Yellow
docker-compose -f docker-compose.prod.yml build --no-cache
Print-Status "Imágenes construidas"

# Levantar servicios
Write-Host ""
Write-Host "6️⃣  Levantando servicios..." -ForegroundColor Yellow
docker-compose -f docker-compose.prod.yml up -d
Print-Status "Servicios iniciados"

# Esperar
Write-Host ""
Write-Host "7️⃣  Esperando a que los servicios estén listos..." -ForegroundColor Yellow
Start-Sleep -Seconds 10

# Verificar salud
Write-Host ""
Write-Host "8️⃣  Verificando salud de los servicios..." -ForegroundColor Yellow

# Check Postgres
try {
    docker exec vexus-postgres pg_isready -U vexus_admin | Out-Null
    Print-Status "PostgreSQL está listo"
} catch {
    Print-Error "PostgreSQL no responde"
}

# Check Backend
try {
    $response = Invoke-WebRequest -Uri "http://localhost:8000/health" -UseBasicParsing -TimeoutSec 5
    Print-Status "Backend está listo"
} catch {
    Print-Error "Backend no responde"
}

# Check Frontend
try {
    $response = Invoke-WebRequest -Uri "http://localhost" -UseBasicParsing -TimeoutSec 5
    Print-Status "Frontend está listo"
} catch {
    Print-Error "Frontend no responde"
}

# Mostrar status
Write-Host ""
Write-Host "9️⃣  Estado de los contenedores:" -ForegroundColor Yellow
docker-compose -f docker-compose.prod.yml ps

# Mostrar logs
Write-Host ""
Write-Host "📋 Últimos logs:" -ForegroundColor Yellow
docker-compose -f docker-compose.prod.yml logs --tail=20

Write-Host ""
Write-Host "======================================" -ForegroundColor Green
Write-Host "✅ Despliegue completado" -ForegroundColor Green
Write-Host "======================================" -ForegroundColor Green
Write-Host ""
Write-Host "📊 Para ver logs en tiempo real:"
Write-Host "   docker-compose -f docker-compose.prod.yml logs -f"
Write-Host ""
Write-Host "🔍 Para verificar el estado:"
Write-Host "   docker-compose -f docker-compose.prod.yml ps"
Write-Host ""
Write-Host "🛑 Para detener los servicios:"
Write-Host "   docker-compose -f docker-compose.prod.yml down"
Write-Host ""
Write-Host "🔄 Para reiniciar un servicio:"
Write-Host "   docker-compose -f docker-compose.prod.yml restart [backend|frontend|postgres]"
Write-Host ""
