# Guía de Desarrollo - Vexus Platform

## Workflow Recomendado: Desarrollo vs Producción

### Estrategia de Branches (Git)

```
main (producción)
├── develop (desarrollo activo)
│   ├── feature/nueva-funcionalidad
│   ├── feature/otro-feature
│   └── bugfix/arreglar-algo
└── hotfix/fix-critico (para bugs urgentes en producción)
```

#### Branches Principales

**`main`** - Producción
- Solo código estable y testeado
- Cada commit debe ser deployable
- Protected branch (requiere pull request + revisión)
- Tags para versiones (`v1.0.0`, `v1.1.0`, etc.)

**`develop`** - Desarrollo
- Integración continua de features
- Puede tener bugs menores
- Base para nuevas features
- Se mergea a `main` cuando está listo para release

#### Branches de Trabajo

**`feature/nombre-feature`** - Nuevas funcionalidades
```bash
git checkout develop
git checkout -b feature/authentication-improvements
# ... trabajar ...
git push origin feature/authentication-improvements
# Crear PR hacia develop
```

**`bugfix/nombre-bug`** - Arreglos no urgentes
```bash
git checkout develop
git checkout -b bugfix/fix-login-validation
```

**`hotfix/nombre-fix`** - Arreglos urgentes en producción
```bash
git checkout main
git checkout -b hotfix/critical-security-fix
# ... arreglar ...
# Mergear a MAIN y DEVELOP
```

---

## Setup de Desarrollo Local

### Opción 1: Docker (Recomendado para desarrollo)

#### Crear docker-compose.dev.yml

Ya lo he creado más abajo ↓

```bash
# Levantar entorno de desarrollo
docker-compose -f docker-compose.dev.yml up

# Con rebuild automático
docker-compose -f docker-compose.dev.yml up --build

# Ver logs
docker-compose -f docker-compose.dev.yml logs -f backend
```

**Ventajas:**
- ✅ Consistencia entre desarrolladores
- ✅ No contamina tu sistema local
- ✅ Fácil de resetear
- ✅ Replica producción fielmente

### Opción 2: Setup Local Tradicional (Más rápido para cambios)

#### Backend

```bash
cd backend

# 1. Crear virtual environment
python -m venv venv

# 2. Activar venv
# Windows:
venv\Scripts\activate
# Linux/Mac:
source venv/bin/activate

# 3. Instalar dependencias
pip install -r requirements.txt

# 4. Usar .env para desarrollo
cp .env.example .env
# Editar .env con credenciales locales

# 5. Ejecutar en modo desarrollo (con hot reload)
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

#### Frontend

```bash
cd frontend

# Opción 1: Live Server (VS Code extension)
# Instalar "Live Server" extension
# Click derecho en index.html -> "Open with Live Server"

# Opción 2: Python simple server
python -m http.server 8080

# Opción 3: Node.js http-server
npx http-server -p 8080
```

#### Base de Datos

```bash
# Opción 1: Docker solo para PostgreSQL
docker run --name vexus-dev-db \
  -e POSTGRES_PASSWORD=dev123 \
  -e POSTGRES_DB=vexus_db \
  -p 5432:5432 \
  -v vexus-dev-data:/var/lib/postgresql/data \
  -d postgres:17-alpine

# Importar schema
docker exec -i vexus-dev-db psql -U postgres vexus_db < vexus_db.sql

# Opción 2: PostgreSQL instalado localmente
psql -U postgres
CREATE DATABASE vexus_db;
\q
psql -U postgres vexus_db < vexus_db.sql
```

---

## Archivos de Configuración por Entorno

### .env (Desarrollo Local)

```bash
# Usar valores de .env.example
cp backend/.env.example backend/.env
```

Características:
- `DEBUG=True`
- `ALLOWED_ORIGINS=*` (o localhost específicos)
- `SECRET_KEY` puede ser simple (no critica en dev)
- Database local

### .env.production (Producción)

```bash
# Usar valores de .env.production.example
cp .env.production.example .env.production
```

Características:
- `DEBUG=False`
- `ALLOWED_ORIGINS=https://tu-dominio.com`
- `SECRET_KEY` criptográficamente segura
- Database remota/containerizada

### Frontend Config

El frontend detecta automáticamente el entorno:

**Desarrollo** - [config.js](frontend/Static/js/config.js)
```javascript
API_BASE_URL: 'http://localhost:8000/api/v1'
```

**Producción** - [config.prod.js](frontend/Static/js/config.prod.js)
```javascript
API_BASE_URL: window.location.origin + '/api/v1'
```

---

## Workflow Diario de Desarrollo

### 1. Crear Nueva Feature

```bash
# 1. Asegurarte de estar en develop actualizado
git checkout develop
git pull origin develop

# 2. Crear branch para tu feature
git checkout -b feature/nombre-descriptivo

# 3. Levantar entorno de desarrollo
docker-compose -f docker-compose.dev.yml up
# O setup local:
# Terminal 1: cd backend && uvicorn app.main:app --reload
# Terminal 2: cd frontend && npx http-server

# 4. Trabajar en tu feature...
# Los cambios se reflejan automáticamente con hot reload
```

### 2. Durante el Desarrollo

```bash
# Ver logs en tiempo real
docker-compose -f docker-compose.dev.yml logs -f backend

# Reiniciar solo un servicio
docker-compose -f docker-compose.dev.yml restart backend

# Ejecutar comandos en el contenedor
docker-compose -f docker-compose.dev.yml exec backend python -c "print('test')"

# Acceder a la base de datos
docker-compose -f docker-compose.dev.yml exec db psql -U postgres vexus_db
```

### 3. Commits Frecuentes

```bash
# Commits pequeños y descriptivos
git add .
git commit -m "feat: add user profile photo upload"

# Convenciones de commit:
# feat: nueva funcionalidad
# fix: arreglo de bug
# refactor: refactorización de código
# docs: cambios en documentación
# style: formateo, punto y coma faltante, etc
# test: agregar tests
# chore: actualizar dependencias, build, etc
```

### 4. Push y Pull Request

```bash
# Push a tu branch
git push origin feature/nombre-descriptivo

# Crear Pull Request en GitHub:
# feature/nombre-descriptivo -> develop
```

### 5. Mergear a Develop

Una vez aprobado el PR:
```bash
# Merge en GitHub (o localmente)
git checkout develop
git merge feature/nombre-descriptivo
git push origin develop

# Opcional: Eliminar branch
git branch -d feature/nombre-descriptivo
git push origin --delete feature/nombre-descriptivo
```

### 6. Release a Producción

```bash
# Cuando develop está listo para producción
git checkout main
git merge develop
git tag -a v1.1.0 -m "Release version 1.1.0"
git push origin main --tags

# Deploy a producción
ssh tu-servidor
cd /ruta/a/vexus
git pull origin main
docker-compose --env-file .env.production up -d --build
```

---

## Tips y Mejores Prácticas

### 1. Never Commit to Main Directly

```bash
# Proteger branch main en GitHub:
# Settings -> Branches -> Add rule
# Branch name pattern: main
# ✅ Require pull request reviews before merging
# ✅ Require status checks to pass
```

### 2. Mantén Develop Actualizado

```bash
# Al inicio de cada día
git checkout develop
git pull origin develop
```

### 3. Usa .gitignore Correctamente

Ya configurado, pero verifica que nunca commits:
- `.env`
- `.env.production`
- `__pycache__/`
- `venv/`
- Archivos de IDE personales

### 4. Hot Reload en Desarrollo

**Backend (FastAPI):**
```bash
# --reload hace que los cambios se reflejen automáticamente
uvicorn app.main:app --reload
```

**Frontend:**
- Usa Live Server o http-server
- Cambios en HTML/CSS/JS se reflejan al refrescar el navegador

### 5. Debug en Desarrollo

```python
# En desarrollo, puedes usar prints y debugger
if settings.DEBUG:
    print(f"DEBUG: User data = {user_data}")
    import pdb; pdb.set_trace()  # Breakpoint
```

### 6. Testing Local Antes de Push

```bash
# Probar que todo funciona
curl http://localhost:8000/health
curl http://localhost:8000/api/v1/users/me

# Si tienes tests (recomendado):
pytest tests/
```

---

## Comandos Útiles de Desarrollo

### Git

```bash
# Ver estado
git status

# Ver branches
git branch -a

# Cambiar de branch
git checkout nombre-branch

# Crear y cambiar a branch nuevo
git checkout -b feature/nuevo

# Ver diferencias
git diff

# Ver historial
git log --oneline --graph --all

# Descartar cambios locales
git checkout -- archivo.py

# Stash (guardar cambios temporalmente)
git stash
git stash pop
```

### Docker

```bash
# Ver contenedores corriendo
docker ps

# Ver logs
docker logs vexus-backend -f

# Entrar a un contenedor
docker exec -it vexus-backend bash

# Limpiar todo
docker-compose -f docker-compose.dev.yml down -v
docker system prune -a
```

### Base de Datos

```bash
# Backup de desarrollo
docker exec vexus-dev-db pg_dump -U postgres vexus_db > dev_backup.sql

# Restaurar
docker exec -i vexus-dev-db psql -U postgres vexus_db < dev_backup.sql

# Conectar a psql
docker exec -it vexus-dev-db psql -U postgres vexus_db

# Ver tablas
\dt

# Describir tabla
\d users
```

---

## Estructura de Branches Recomendada

### Setup Inicial de Git Flow

```bash
# 1. Crear branch develop si no existe
git checkout -b develop
git push -u origin develop

# 2. Proteger branches en GitHub
# main: require PR + reviews
# develop: require PR (opcional)

# 3. Establecer develop como default branch (GitHub Settings)
```

### Ejemplo Completo de Feature

```bash
# Día 1: Comenzar feature
git checkout develop
git pull origin develop
git checkout -b feature/add-user-notifications

# Trabajar...
git add .
git commit -m "feat: add notification model"

# Día 2: Continuar
git add .
git commit -m "feat: add notification API endpoints"

# Día 3: Terminar
git add .
git commit -m "feat: add frontend notification UI"
git push origin feature/add-user-notifications

# Crear PR en GitHub: feature/add-user-notifications -> develop

# Después de aprobación y merge:
git checkout develop
git pull origin develop
git branch -d feature/add-user-notifications
```

---

## Troubleshooting Común

### "Port already in use"

```bash
# Windows
netstat -ano | findstr :8000
taskkill /PID <PID> /F

# Linux/Mac
lsof -ti:8000 | xargs kill -9
```

### "Database connection failed"

```bash
# Verificar que PostgreSQL está corriendo
docker ps | grep postgres

# Ver logs
docker logs vexus-dev-db

# Verificar .env
cat backend/.env | grep DATABASE_URL
```

### "Module not found"

```bash
# Reinstalar dependencias
pip install -r requirements.txt

# O con venv
deactivate
rm -rf venv
python -m venv venv
source venv/bin/activate  # o venv\Scripts\activate en Windows
pip install -r requirements.txt
```

---

## Checklist Antes de Crear PR

- [ ] Código compila sin errores
- [ ] Tests pasan (si los hay)
- [ ] No hay console.log / print() de debug innecesarios
- [ ] Commit messages son descriptivos
- [ ] Branch está actualizado con develop
- [ ] `.env` y archivos sensibles NO están incluidos
- [ ] Documentación actualizada (si aplica)

---

## Próximos Pasos Recomendados

1. **Setup CI/CD** - GitHub Actions para tests automáticos
2. **Pre-commit Hooks** - Validar código antes de commit
3. **Testing** - Agregar pytest para backend
4. **Linting** - Black, flake8, eslint
5. **Code Review** - Establecer proceso de revisión
6. **Staging Environment** - Entorno intermedio antes de producción

---

**Happy Coding! 🚀**
