@echo off
echo Iniciando servidor frontend en http://localhost:5500
cd frontend
python -m http.server 5500
