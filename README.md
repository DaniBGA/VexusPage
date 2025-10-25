# Vexus Platform

Plataforma web completa con backend FastAPI y frontend moderno.

---

## 📂 ESTRUCTURA ORGANIZADA

```
VexusPage/
│
├── 🛠️ deployment/
│   ├── development/     ← TODO PARA DESARROLLO
│   │   ├── docker-compose.yml
│   │   ├── Dockerfile.dev
│   │   └── README.md (LEE ESTO PARA DESARROLLO)
│   │
│   └── production/      ← TODO PARA PRODUCCIÓN
│       ├── docker-compose.yml
│       ├── .env.production.example
│       └── README.md (LEE ESTO PARA DEPLOYMENT)
│
├── 📚 docs/
│   └── guides/          ← GUÍAS DETALLADAS
│       ├── DEVELOPMENT_GUIDE.md
│       ├── DEPLOYMENT.md
│       ├── SECURITY_CHECKLIST.md
│       ├── GIT_WORKFLOW.md
│       └── PRODUCTION_README.md
│
├── backend/             ← Código del backend
├── frontend/            ← Código del frontend
│
└── Scripts de inicio:
    ├── start-dev.bat    ← Inicio rápido desarrollo (Windows)
    ├── start-dev.sh     ← Inicio rápido desarrollo (Linux/Mac)
    └── start-prod.sh    ← Inicio rápido producción (Linux/Mac)
```

---

## 🚀 INICIO RÁPIDO

### Para DESARROLLO:

#### Opción 1: Scripts automáticos

**Windows:**
```bash
start-dev.bat
```

**Linux/Mac:**
```bash
chmod +x start-dev.sh
./start-dev.sh
```

#### Opción 2: Manual

```bash
cd deployment/development
docker-compose up
```

**Acceder a:**
- 🌐 Frontend: http://localhost:8080
- 🔌 Backend API: http://localhost:8000
- 📚 API Docs: http://localhost:8000/docs
- 🗄️ Adminer (DB): http://localhost:8081

**📖 Leer:** [deployment/development/README.md](deployment/development/README.md)

---

### Para PRODUCCIÓN:

#### 1. Configurar variables

```bash
# Copiar template
cp deployment/production/.env.production.example .env.production

# Generar SECRET_KEY
python generate_secret_key.py

# Editar con valores REALES
nano .env.production
```

#### 2. Iniciar

**Linux/Mac:**
```bash
chmod +x start-prod.sh
./start-prod.sh
```

**Manual:**
```bash
cd deployment/production
docker-compose --env-file ../../.env.production up -d
```

**📖 Leer:** [deployment/production/README.md](deployment/production/README.md)

---

## 📚 DOCUMENTACIÓN

### Empezar Aquí:

| Documento | Para Qué |
|-----------|----------|
| **[deployment/development/README.md](deployment/development/README.md)** | 🛠️ Trabajar en desarrollo |
| **[deployment/production/README.md](deployment/production/README.md)** | 🚀 Deployar a producción |
| **[QUICK_START.md](QUICK_START.md)** | ⚡ Guía rápida general |

### Guías Detalladas:

| Guía | Descripción |
|------|-------------|
| [docs/guides/DEVELOPMENT_GUIDE.md](docs/guides/DEVELOPMENT_GUIDE.md) | Desarrollo completo + workflow |
| [docs/guides/GIT_WORKFLOW.md](docs/guides/GIT_WORKFLOW.md) | Branches, commits, PRs |
| [docs/guides/DEPLOYMENT.md](docs/guides/DEPLOYMENT.md) | Deployment paso a paso |
| [docs/guides/SECURITY_CHECKLIST.md](docs/guides/SECURITY_CHECKLIST.md) | Checklist de seguridad |

---

## 🎯 ¿QUÉ USAR CUANDO?

### DESARROLLO (Día a Día):

```bash
# Usar:
deployment/development/

# Características:
✅ Hot reload automático
✅ Adminer (DB GUI)
✅ DEBUG=True
✅ Logs verbosos
✅ Password simple
✅ CORS permisivo (*)

# Para:
- Programar nuevas features
- Arreglar bugs
- Probar cambios
- Desarrollo local
```

### PRODUCCIÓN (Deployment):

```bash
# Usar:
deployment/production/

# Características:
✅ Optimizado para performance
✅ DEBUG=False
✅ SECRET_KEY fuerte
✅ Gunicorn + workers
✅ Sin herramientas de dev
✅ CORS restrictivo

# Para:
- Servidor real
- Usuarios finales
- Dominio público
```

---

## 🌳 GIT WORKFLOW

### Branches:

```
main          ← Producción (código estable)
  ↓
develop       ← Desarrollo activo
  ↓
feature/*     ← Tus nuevas funcionalidades
```

### Trabajar en una Feature:

```bash
# 1. Crear branch
git checkout develop
git checkout -b feature/mi-funcionalidad

# 2. Desarrollar (con hot reload)
cd deployment/development
docker-compose up

# 3. Commit y push
git add .
git commit -m "feat: descripción"
git push origin feature/mi-funcionalidad

# 4. Crear Pull Request en GitHub
# feature/mi-funcionalidad → develop
```

Ver guía completa: [docs/guides/GIT_WORKFLOW.md](docs/guides/GIT_WORKFLOW.md)

---

## 🛠️ STACK TECNOLÓGICO

**Backend:**
- Python 3.12
- FastAPI
- PostgreSQL 17
- AsyncPG
- JWT Auth
- Bcrypt

**Frontend:**
- HTML5 / CSS3
- JavaScript ES6+
- Nginx (producción)

**DevOps:**
- Docker & Docker Compose
- Gunicorn + Uvicorn
- GitHub Actions (CI/CD)

---

## ⚙️ COMANDOS ÚTILES

### Desarrollo:

```bash
# Levantar
cd deployment/development
docker-compose up

# Ver logs
docker-compose logs -f backend

# Shell en backend
docker-compose exec backend bash

# Conectar a DB
docker-compose exec db psql -U postgres vexus_db

# Detener
docker-compose down
```

### Producción:

```bash
# Levantar
cd deployment/production
docker-compose --env-file ../../.env.production up -d

# Ver logs
docker-compose logs -f

# Health check
curl http://localhost:8000/health

# Actualizar
git pull origin main
docker-compose --env-file ../../.env.production up -d --build
```

---

## 🔒 SEGURIDAD

### Checklist Pre-Producción:

- [ ] `DEBUG=False`
- [ ] `SECRET_KEY` aleatoria (64+ caracteres)
- [ ] `POSTGRES_PASSWORD` fuerte
- [ ] `ALLOWED_ORIGINS` con tu dominio específico
- [ ] SSL/HTTPS configurado
- [ ] Firewall configurado
- [ ] Backups automatizados
- [ ] `.env.production` NO en git

Ver: [docs/guides/SECURITY_CHECKLIST.md](docs/guides/SECURITY_CHECKLIST.md)

---

## 🆘 AYUDA RÁPIDA

### No sé qué hacer:
1. **Para desarrollar:** Lee [deployment/development/README.md](deployment/development/README.md)
2. **Para deployar:** Lee [deployment/production/README.md](deployment/production/README.md)

### Errores comunes:

**"Port already in use"**
```bash
# Windows
netstat -ano | findstr :8000
taskkill /PID <PID> /F

# Linux/Mac
lsof -ti:8000 | xargs kill -9
```

**"Database connection failed"**
```bash
# Ver logs de la base de datos
docker-compose logs db
```

**"Changes not reflecting" (desarrollo)**
```bash
# Verificar hot reload en logs
docker-compose logs -f backend
# Debe decir "Detected file change, reloading..."
```

---

## 📞 SOPORTE

- Desarrollo: Ver [deployment/development/README.md](deployment/development/README.md)
- Producción: Ver [deployment/production/README.md](deployment/production/README.md)
- Git: Ver [docs/guides/GIT_WORKFLOW.md](docs/guides/GIT_WORKFLOW.md)

---

## 📝 RESUMEN

**REGLA SIMPLE:**

- 🛠️ **Desarrollo:** Todo está en `deployment/development/`
- 🚀 **Producción:** Todo está en `deployment/production/`
- 📚 **Documentación:** Todo está en `docs/guides/`

**NUNCA** mezcles archivos de desarrollo con producción.

---

**Última actualización:** 2025-10-25
