# Servidor HTTP simple para servir el test de email
# Esto soluciona el problema de CORS al usar file://

Write-Host "Iniciando servidor HTTP local..." -ForegroundColor Cyan
Write-Host "Sirviendo archivos desde: frontend/" -ForegroundColor Gray
Write-Host ""
Write-Host "Abre en tu navegador:" -ForegroundColor Green
Write-Host "   http://localhost:8000/test-email-frontend.html" -ForegroundColor Yellow
Write-Host ""
Write-Host "Presiona Ctrl+C para detener el servidor" -ForegroundColor DarkGray
Write-Host ""

# Cambiar al directorio frontend
Set-Location -Path "e:\Vexus\VexusPage\frontend"

# Iniciar servidor HTTP en puerto 8000
python -m http.server 8000
