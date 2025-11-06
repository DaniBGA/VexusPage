# Script de prueba para el endpoint proxy de email
# Prueba el endpoint /email/send-verification

$baseUrl = "https://vexuspage.onrender.com/api/v1"
$endpoint = "$baseUrl/email/send-verification"

Write-Host "🧪 TEST DEL PROXY DE EMAIL" -ForegroundColor Cyan
Write-Host "Endpoint: $endpoint" -ForegroundColor Gray
Write-Host ""

# Datos de prueba
$body = @{
    email = "tu_email@example.com"  # Cambiar por un email real para probar
    user_name = "Usuario de Prueba"
    verification_token = "test-token-12345"
} | ConvertTo-Json

Write-Host "📤 Enviando solicitud..." -ForegroundColor Yellow
Write-Host "Datos:" -ForegroundColor Gray
Write-Host $body -ForegroundColor DarkGray
Write-Host ""

try {
    $response = Invoke-RestMethod -Uri $endpoint `
        -Method Post `
        -Body $body `
        -ContentType "application/json" `
        -TimeoutSec 30
    
    Write-Host "✅ RESPUESTA EXITOSA" -ForegroundColor Green
    Write-Host ($response | ConvertTo-Json -Depth 3) -ForegroundColor White
    Write-Host ""
    
    if ($response.success) {
        Write-Host "✅ Email enviado correctamente" -ForegroundColor Green
    } else {
        Write-Host "⚠️ Respuesta recibida pero success=false" -ForegroundColor Yellow
    }
    
} catch {
    Write-Host "❌ ERROR EN LA SOLICITUD" -ForegroundColor Red
    Write-Host "Status Code: $($_.Exception.Response.StatusCode.value__)" -ForegroundColor Red
    Write-Host "Mensaje: $($_.Exception.Message)" -ForegroundColor Red
    
    # Intentar obtener detalles del error
    try {
        $errorDetails = $_.ErrorDetails.Message | ConvertFrom-Json
        Write-Host "Detalles del error:" -ForegroundColor Yellow
        Write-Host ($errorDetails | ConvertTo-Json -Depth 3) -ForegroundColor DarkYellow
    } catch {
        Write-Host "No se pudieron obtener detalles adicionales del error" -ForegroundColor DarkGray
    }
}

Write-Host ""
Write-Host "📝 Notas:" -ForegroundColor Cyan
Write-Host "- Cambiar 'tu_email@example.com' por un email real para probar" -ForegroundColor Gray
Write-Host "- El sender (EMAIL_FROM) debe estar verificado en SendGrid" -ForegroundColor Gray
Write-Host "- Verificar logs en Render para más detalles" -ForegroundColor Gray
