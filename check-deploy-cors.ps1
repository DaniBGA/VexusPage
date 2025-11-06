# Verificar si el deploy en Render está completo y CORS configurado
# Espera hasta que el servicio responda correctamente

$baseUrl = "https://vexuspage.onrender.com"
$testUrl = "$baseUrl/api/v1/auth/register"

Write-Host "Verificando estado del deploy en Render..." -ForegroundColor Cyan
Write-Host "URL: $baseUrl" -ForegroundColor Gray
Write-Host ""

$maxAttempts = 20
$attempt = 0
$deployed = $false

while ($attempt -lt $maxAttempts -and -not $deployed) {
    $attempt++
    Write-Host "Intento $attempt/$maxAttempts..." -ForegroundColor Yellow
    
    try {
        # Hacer una petición OPTIONS (preflight)
        $response = Invoke-WebRequest -Uri $testUrl `
            -Method Options `
            -Headers @{
                "Origin" = "http://localhost:8000"
                "Access-Control-Request-Method" = "POST"
                "Access-Control-Request-Headers" = "content-type"
            } `
            -TimeoutSec 10 `
            -UseBasicParsing `
            -ErrorAction Stop
        
        # Verificar headers CORS
        $corsHeader = $response.Headers["Access-Control-Allow-Origin"]
        
        if ($corsHeader) {
            Write-Host ""
            Write-Host "DEPLOY COMPLETO!" -ForegroundColor Green
            Write-Host "CORS configurado correctamente" -ForegroundColor Green
            Write-Host ""
            Write-Host "Headers CORS recibidos:" -ForegroundColor Cyan
            Write-Host "  Access-Control-Allow-Origin: $corsHeader" -ForegroundColor White
            
            $deployed = $true
            
            Write-Host ""
            Write-Host "Ahora puedes probar:" -ForegroundColor Green
            Write-Host "   http://localhost:8000/test-email-frontend.html" -ForegroundColor Yellow
            Write-Host ""
            
            # Abrir automáticamente
            $openBrowser = Read-Host "¿Abrir en navegador? (S/N)"
            if ($openBrowser -eq "S" -or $openBrowser -eq "s") {
                start http://localhost:8000/test-email-frontend.html
            }
            
        } else {
            Write-Host "Servicio responde pero sin CORS headers" -ForegroundColor Yellow
        }
        
    } catch {
        Write-Host "Esperando deploy... (Error: $($_.Exception.Message))" -ForegroundColor DarkGray
        Start-Sleep -Seconds 15
    }
}

if (-not $deployed) {
    Write-Host ""
    Write-Host "Timeout esperando deploy" -ForegroundColor Yellow
    Write-Host "Verifica manualmente en:" -ForegroundColor Gray
    Write-Host "https://dashboard.render.com" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "O prueba directamente:" -ForegroundColor Gray
    Write-Host "http://localhost:8000/test-email-frontend.html" -ForegroundColor Yellow
}
