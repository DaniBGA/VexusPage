# Quick Start - Vexus Platform

## Para Desarrollo (Primera Vez)

### Opción A: Con Docker (Recomendado)

```bash
# 1. Clonar el repositorio
git clone <tu-repo-url>
cd VexusPage

# 2. Crear branch develop si no existe
git checkout -b develop

# 3. Levantar entorno de desarrollo
docker-compose -f docker-compose.dev.yml up

# 4. Acceder a:
# - Frontend: http://localhost:8080
# - Backend API: http://localhost:8000
# - API Docs: http://localhost:8000/docs
# - Adminer (DB GUI): http://localhost:8081 (user: postgres, pass: dev123)
```

### Opción B: Sin Docker (Setup Local)

```bash
# 1. Base de datos
# Opción 1: Docker solo para PostgreSQL
docker run --name vexus-dev-db \
  -e POSTGRES_PASSWORD=dev123 \
  -e POSTGRES_DB=vexus_db \
  -p 5432:5432 \
  -v vexus-dev-data:/var/lib/postgresql/data \
  -d postgres:17-alpine

# Importar schema
docker exec -i vexus-dev-db psql -U postgres vexus_db < vexus_db.sql

# 2. Backend
cd backend
python -m venv venv
# Windows:
venv\Scripts\activate
# Linux/Mac:
source venv/bin/activate

pip install -r requirements.txt
cp .env.example .env
uvicorn app.main:app --reload

# 3. Frontend (nueva terminal)
cd frontend
npx http-server -p 8080
# O usa Live Server extension en VS Code
```

## Para Desarrollo (Día a Día)

### Con Docker

```bash
# Levantar servicios
docker-compose -f docker-compose.dev.yml up

# O en background
docker-compose -f docker-compose.dev.yml up -d

# Ver logs
docker-compose -f docker-compose.dev.yml logs -f backend

# Detener
docker-compose -f docker-compose.dev.yml down
```

### Sin Docker

```bash
# Terminal 1 - Backend
cd backend
venv\Scripts\activate  # o source venv/bin/activate
uvicorn app.main:app --reload

# Terminal 2 - Frontend
cd frontend
npx http-server -p 8080
```

### Con Makefile (si tienes Make instalado)

```bash
make dev          # Levantar desarrollo
make logs-back    # Ver logs del backend
make shell-db     # Conectar a la base de datos
make stop         # Detener todo
make help         # Ver todos los comandos
```

## Para Producción (Deploy)

```bash
# 1. Generar SECRET_KEY
python generate_secret_key.py

# 2. Configurar variables de entorno
cp .env.production.example .env.production
# Editar .env.production con valores REALES

# 3. Deploy con Docker
docker-compose --env-file .env.production up -d --build

# 4. Verificar
curl http://localhost:8000/health
```

## Workflow de Git (Desarrollo)

```bash
# 1. Crear branch para tu feature
git checkout develop
git pull origin develop
git checkout -b feature/mi-nueva-funcionalidad

# 2. Trabajar en tu código...
# Los cambios se reflejan automáticamente con hot reload

# 3. Commit
git add .
git commit -m "feat: descripción de lo que hiciste"

# 4. Push
git push origin feature/mi-nueva-funcionalidad

# 5. Crear Pull Request en GitHub
# feature/mi-nueva-funcionalidad -> develop
```

## Comandos Útiles

### Git

```bash
git status                          # Ver estado
git log --oneline --graph           # Ver historial
git checkout develop                # Cambiar a develop
git pull origin develop             # Actualizar develop
git branch -a                       # Ver todas las branches
```

### Docker

```bash
docker ps                                                    # Ver contenedores
docker logs vexus-dev-backend -f                            # Ver logs
docker exec -it vexus-dev-backend bash                      # Shell en contenedor
docker exec -it vexus-dev-db psql -U postgres vexus_db     # Conectar a DB
docker-compose -f docker-compose.dev.yml restart backend    # Reiniciar servicio
```

### Base de Datos

```bash
# Conectar a PostgreSQL
docker exec -it vexus-dev-db psql -U postgres vexus_db

# Comandos en psql:
\dt           # Listar tablas
\d users      # Describir tabla users
SELECT * FROM users;
\q            # Salir

# Backup
docker exec vexus-dev-db pg_dump -U postgres vexus_db > backup.sql

# Restore
docker exec -i vexus-dev-db psql -U postgres vexus_db < backup.sql
```

## URLs Importantes

### Desarrollo
- Frontend: http://localhost:8080
- Backend API: http://localhost:8000
- API Docs (Swagger): http://localhost:8000/docs
- Health Check: http://localhost:8000/health
- Adminer (DB GUI): http://localhost:8081

### Producción
- Frontend: https://tu-dominio.com
- Backend API: https://tu-dominio.com/api/v1
- Health Check: https://tu-dominio.com/health

## Estructura de Branches

```
main          -> Producción (protegido)
develop       -> Desarrollo activo
feature/*     -> Nuevas funcionalidades
bugfix/*      -> Arreglos de bugs
hotfix/*      -> Fixes urgentes para producción
```

## Troubleshooting

### Puerto ya en uso

```bash
# Windows
netstat -ano | findstr :8000
taskkill /PID <PID> /F

# Linux/Mac
lsof -ti:8000 | xargs kill -9
```

### Base de datos no conecta

```bash
# Verificar que está corriendo
docker ps | grep postgres

# Ver logs
docker logs vexus-dev-db
```

### Cambios no se reflejan

```bash
# Docker: Rebuild
docker-compose -f docker-compose.dev.yml up --build

# Local: Verificar que uvicorn tiene --reload
```

## Documentación Completa

- [DEVELOPMENT_GUIDE.md](DEVELOPMENT_GUIDE.md) - Guía completa de desarrollo
- [DEPLOYMENT.md](DEPLOYMENT.md) - Guía de deployment a producción
- [SECURITY_CHECKLIST.md](SECURITY_CHECKLIST.md) - Checklist de seguridad
- [PRODUCTION_README.md](PRODUCTION_README.md) - Resumen de preparación para producción

## Ayuda

```bash
make help    # Ver comandos de Makefile
git --help   # Ayuda de git
```
