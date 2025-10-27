@echo off
echo ========================================
echo   VEXUS - Iniciando Backend
echo ========================================
echo.
echo Backend corriendo en: http://localhost:8000
echo Documentacion API: http://localhost:8000/docs
echo.
echo Presiona Ctrl+C para detener
echo ========================================
echo.

cd backend
python -m uvicorn app.main:app --reload
