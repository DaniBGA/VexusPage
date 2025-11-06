# Script PowerShell para probar el endpoint de email
# Ejecuta esto desde tu maquina local

$url = "https://vexuspage.onrender.com/api/v1/debug/test-email"
$body = @{
    email = "dgongorabanegas@alumnos.exa.unicen.edu.ar"
    name = "Daniel Test"
    use_http = $true  # true = HTTP API (funciona en Render Free), false = SMTP
} | ConvertTo-Json

Write-Host "[TEST] Enviando peticion de test de email (SendGrid HTTP API)..." -ForegroundColor Cyan
Write-Host "[URL] $url" -ForegroundColor Gray
Write-Host "[BODY] $body" -ForegroundColor Gray
Write-Host ""

try {
    $response = Invoke-RestMethod -Uri $url -Method Post -Body $body -ContentType "application/json"
    
    Write-Host "[OK] RESPUESTA RECIBIDA:" -ForegroundColor Green
    $response | ConvertTo-Json -Depth 10 | Write-Host -ForegroundColor Yellow
    
    if ($response.success -eq $true) {
        Write-Host ""
        Write-Host "[SUCCESS] EMAIL ENVIADO CON EXITO!" -ForegroundColor Green
        Write-Host "[INFO] Revisa tu bandeja de entrada y carpeta de Spam" -ForegroundColor Cyan
    } else {
        Write-Host ""
        Write-Host "[FAIL] FALLO AL ENVIAR EMAIL" -ForegroundColor Red
        Write-Host "[TIP] Recomendacion: $($response.recommendation)" -ForegroundColor Yellow
    }
    
} catch {
    Write-Host "[ERROR] ERROR EN LA PETICION:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    
    if ($_.Exception.Response) {
        $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
        $responseBody = $reader.ReadToEnd()
        Write-Host "Detalles: $responseBody" -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "[NEXT] Ahora ve a los LOGS de Render para ver detalles:" -ForegroundColor Cyan
Write-Host "https://dashboard.render.com" -ForegroundColor Blue
