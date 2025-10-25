# 🛠️ DESARROLLO - Vexus Platform

Esta carpeta contiene TODO lo necesario para trabajar en **DESARROLLO**.

## 🚀 Inicio Rápido

### Opción 1: Docker (Recomendado)

```bash
# Desde la raíz del proyecto ejecutar:
cd deployment/development
docker-compose up
```

**Listo!** Accede a:
- 🌐 Frontend: http://localhost:8080
- 🔌 Backend API: http://localhost:8000
- 📚 API Docs: http://localhost:8000/docs
- 🗄️ Adminer (DB): http://localhost:8081 (user: `postgres`, pass: `dev123`)

### Opción 2: Sin Docker

```bash
# 1. Base de datos (Docker solo para PostgreSQL)
docker run --name vexus-dev-db \
  -e POSTGRES_PASSWORD=dev123 \
  -e POSTGRES_DB=vexus_db \
  -p 5432:5432 \
  -d postgres:17-alpine

# Importar schema
docker exec -i vexus-dev-db psql -U postgres vexus_db < ../../vexus_db.sql

# 2. Backend (Terminal 1)
cd ../../backend
python -m venv venv
venv\Scripts\activate  # Windows
# source venv/bin/activate  # Linux/Mac
pip install -r requirements.txt
cp .env.example .env
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000

# 3. Frontend (Terminal 2)
cd ../../frontend
npx http-server -p 8080
```

---

## 📁 Archivos en esta Carpeta

### `docker-compose.yml`
Configuración de Docker Compose para desarrollo:
- ✅ Hot reload automático (cambios se reflejan sin reiniciar)
- ✅ Adminer (GUI para base de datos)
- ✅ Volúmenes montados (código se edita directamente)
- ✅ Variables de entorno configuradas para desarrollo

### `Dockerfile.dev`
Dockerfile del backend con herramientas de desarrollo:
- iPython, ipdb (debugging)
- pytest (testing)
- black, flake8 (code quality)

### `.env.development` (crear si no existe)
Variables de entorno para desarrollo:
```bash
DATABASE_URL=postgresql://postgres:dev123@localhost:5432/vexus_db
SECRET_KEY=dev-secret-key-not-for-production
ALLOWED_ORIGINS=*
DEBUG=True
ENVIRONMENT=development
```

---

## 🔄 Hot Reload

Con Docker Compose, tus cambios se reflejan **automáticamente**:

- ✅ **Backend**: Uvicorn con `--reload` detecta cambios en archivos `.py`
- ✅ **Frontend**: Refrescar el navegador muestra los cambios en HTML/CSS/JS
- ✅ **Base de Datos**: Cambios persisten en volumen Docker

---

## 🎯 Workflow Diario

### 1. Levantar Entorno
```bash
cd deployment/development
docker-compose up
```

### 2. Trabajar en tu Código
- Edita archivos en `backend/app/` o `frontend/`
- Los cambios se reflejan automáticamente
- No necesitas reiniciar nada

### 3. Ver Logs
```bash
# En otra terminal
docker-compose logs -f backend
```

### 4. Acceder a la Base de Datos
```bash
# Con Adminer (navegador)
http://localhost:8081

# O con psql (terminal)
docker-compose exec db psql -U postgres vexus_db
```

### 5. Detener Todo
```bash
# Ctrl+C en la terminal donde corre docker-compose
# O:
docker-compose down
```

---

## 🐛 Debug y Testing

### Ver Logs del Backend
```bash
docker-compose logs -f backend
```

### Ejecutar Comandos en el Contenedor
```bash
# Shell interactivo
docker-compose exec backend bash

# Ejecutar Python
docker-compose exec backend python -c "print('test')"

# IPython (si está instalado)
docker-compose exec backend ipython
```

### Conectar a la Base de Datos
```bash
# PostgreSQL CLI
docker-compose exec db psql -U postgres vexus_db

# Comandos útiles en psql:
\dt              # Listar tablas
\d users         # Describir tabla
SELECT * FROM users;
\q               # Salir
```

### Ejecutar Tests (cuando los agregues)
```bash
docker-compose exec backend pytest tests/ -v
```

---

## 🔧 Comandos Útiles

### Docker Compose
```bash
# Levantar
docker-compose up

# Levantar en background
docker-compose up -d

# Ver logs
docker-compose logs -f

# Logs de un servicio
docker-compose logs -f backend

# Reiniciar servicio
docker-compose restart backend

# Rebuild
docker-compose up --build

# Detener
docker-compose down

# Detener y eliminar volúmenes
docker-compose down -v
```

### Git (Desarrollo)
```bash
# Crear feature branch
git checkout develop
git checkout -b feature/mi-funcionalidad

# Commits frecuentes
git add .
git commit -m "feat: descripción"

# Push
git push origin feature/mi-funcionalidad
```

---

## ⚙️ Configuración

### Cambiar Puertos
Edita `docker-compose.yml`:
```yaml
ports:
  - "8001:8000"  # Backend en puerto 8001
  - "8081:8080"  # Frontend en puerto 8081
```

### Agregar Dependencias Python
```bash
# 1. Agregar a backend/requirements.txt
# 2. Rebuild
docker-compose up --build
```

### Resetear Base de Datos
```bash
# Detener y eliminar volumen
docker-compose down -v

# Volver a levantar (se crea nueva DB desde vexus_db.sql)
docker-compose up
```

---

## 📝 Notas Importantes

### Hot Reload NO funciona para:
- Cambios en `requirements.txt` → Necesitas rebuild: `docker-compose up --build`
- Cambios en `Dockerfile.dev` → Necesitas rebuild
- Cambios en variables de entorno → Reinicia: `docker-compose restart backend`

### Datos de la Base de Datos
- Se guardan en volumen Docker: `vexus-dev-postgres-data`
- Persisten aunque detengas los contenedores
- Para resetear: `docker-compose down -v`

### Performance
- Primera vez tarda más (descarga imágenes)
- Siguientes veces es rápido (usa caché)

---

## 🆘 Troubleshooting

### "Port already in use"
```bash
# Ver qué usa el puerto
netstat -ano | findstr :8000  # Windows
lsof -ti:8000                 # Linux/Mac

# Matar proceso
taskkill /PID <PID> /F        # Windows
kill -9 <PID>                 # Linux/Mac

# O cambiar puerto en docker-compose.yml
```

### "Cannot connect to database"
```bash
# Ver logs de la base de datos
docker-compose logs db

# Verificar que está corriendo
docker-compose ps
```

### "Changes not reflecting"
```bash
# Para backend: verificar logs
docker-compose logs -f backend
# Debe decir "Detected file change, reloading..."

# Para frontend: hacer hard refresh
Ctrl+Shift+R  # Windows/Linux
Cmd+Shift+R   # Mac
```

---

## 📚 Más Información

Ver documentación completa en `docs/guides/`:
- `DEVELOPMENT_GUIDE.md` - Guía completa de desarrollo
- `GIT_WORKFLOW.md` - Workflow de Git con branches

---

**Solo para desarrollo - NO usar en producción**
