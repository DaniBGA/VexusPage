# Script para verificar usuarios en la base de datos
# Muestra los últimos usuarios registrados

$baseUrl = "https://vexuspage.onrender.com/api/v1"

Write-Host "Verificando usuarios registrados..." -ForegroundColor Cyan
Write-Host ""

# Para verificar usuarios necesitarías estar autenticado
# Este es un ejemplo de cómo verificar si un email está registrado

$email = Read-Host "Ingresa el email a verificar"

Write-Host ""
Write-Host "Intentando registrar el mismo email de nuevo (para verificar si existe)..." -ForegroundColor Yellow

$body = @{
    name = "Test User"
    email = $email
    password = "Test1234!"
} | ConvertTo-Json

try {
    $response = Invoke-RestMethod -Uri "$baseUrl/auth/register" `
        -Method Post `
        -Body $body `
        -ContentType "application/json"
    
    Write-Host ""
    Write-Host "Usuario NO existe en la DB (se creó nuevo)" -ForegroundColor Yellow
    Write-Host "User ID: $($response.user_id)" -ForegroundColor White
    
} catch {
    $statusCode = $_.Exception.Response.StatusCode.value__
    
    if ($statusCode -eq 400) {
        # Error 400 = Email ya registrado
        Write-Host ""
        Write-Host "Usuario EXISTE en la DB" -ForegroundColor Green
        Write-Host "El email '$email' ya está registrado" -ForegroundColor White
    } else {
        Write-Host ""
        Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "Nota: Para ver todos los datos del usuario necesitas iniciar sesion" -ForegroundColor Gray
