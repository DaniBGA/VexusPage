# 📂 ESTRUCTURA DEL PROYECTO - Vexus Platform

## ✅ TODO REORGANIZADO Y SEPARADO

```
VexusPage/
│
├── 🛠️ DESARROLLO
│   └── deployment/development/
│       ├── docker-compose.yml      ← Configuración para desarrollo
│       ├── Dockerfile.dev          ← Docker backend con herramientas dev
│       └── README.md              ← 📖 LEE ESTO PARA DESARROLLO
│
├── 🚀 PRODUCCIÓN
│   └── deployment/production/
│       ├── docker-compose.yml      ← Configuración optimizada para producción
│       ├── .env.production.example ← Template de variables de entorno
│       └── README.md              ← 📖 LEE ESTO PARA DEPLOYMENT
│
├── 📚 DOCUMENTACIÓN
│   └── docs/guides/
│       ├── DEVELOPMENT_GUIDE.md    ← Guía completa de desarrollo
│       ├── DEPLOYMENT.md           ← Deploy paso a paso
│       ├── GIT_WORKFLOW.md         ← Branches, commits, PRs
│       ├── SECURITY_CHECKLIST.md   ← Checklist de seguridad
│       └── PRODUCTION_README.md    ← Resumen de cambios
│
├── 💻 CÓDIGO
│   ├── backend/                    ← API FastAPI
│   │   ├── app/
│   │   │   ├── api/               ← Endpoints
│   │   │   ├── core/              ← Database, security
│   │   │   ├── models/            ← Schemas
│   │   │   └── main.py
│   │   ├── requirements.txt
│   │   ├── .env.example
│   │   └── Dockerfile             ← Dockerfile de producción
│   │
│   └── frontend/                   ← Frontend HTML/CSS/JS
│       ├── Static/
│       │   ├── css/
│       │   └── js/
│       ├── pages/
│       ├── index.html
│       ├── Dockerfile             ← Dockerfile de producción
│       └── nginx.conf
│
├── 🔧 UTILIDADES
│   ├── .github/                    ← GitHub configs
│   │   ├── workflows/
│   │   │   └── ci.yml             ← CI/CD automático
│   │   └── PULL_REQUEST_TEMPLATE.md
│   │
│   ├── generate_secret_key.py     ← Generador de SECRET_KEY
│   ├── Makefile                   ← Comandos útiles
│   ├── vexus_db.sql               ← Schema de base de datos
│   │
│   └── Scripts de inicio:
│       ├── start-dev.bat          ← Windows: Inicio desarrollo
│       ├── start-dev.sh           ← Linux/Mac: Inicio desarrollo
│       └── start-prod.sh          ← Linux/Mac: Inicio producción
│
└── 📄 DOCUMENTOS RAÍZ
    ├── README.md                   ← 📖 EMPIEZA AQUÍ
    ├── QUICK_START.md              ← Guía rápida
    ├── ESTRUCTURA.md               ← Este archivo
    ├── .gitignore
    └── .dockerignore
```

---

## 🎯 ¿DÓNDE BUSCAR QUÉ?

### Para DESARROLLAR:

1. **Inicio:** `deployment/development/README.md`
2. **Levantar:** `cd deployment/development && docker-compose up`
3. **O ejecutar:** `start-dev.bat` (Windows) o `./start-dev.sh` (Linux/Mac)

**Todo lo de desarrollo está en:** `deployment/development/`

---

### Para DEPLOYAR:

1. **Inicio:** `deployment/production/README.md`
2. **Configurar:** `cp deployment/production/.env.production.example .env.production`
3. **Generar clave:** `python generate_secret_key.py`
4. **Levantar:** `cd deployment/production && docker-compose --env-file ../../.env.production up -d`
5. **O ejecutar:** `./start-prod.sh` (Linux/Mac)

**Todo lo de producción está en:** `deployment/production/`

---

### Para APRENDER:

**Rápido:**
- `README.md` - Overview general
- `QUICK_START.md` - Inicio rápido

**Detallado:**
- `docs/guides/DEVELOPMENT_GUIDE.md` - Desarrollo completo
- `docs/guides/GIT_WORKFLOW.md` - Cómo usar Git
- `docs/guides/DEPLOYMENT.md` - Deploy completo
- `docs/guides/SECURITY_CHECKLIST.md` - Seguridad

**Toda la documentación está en:** `docs/guides/`

---

## 🔄 FLUJO DE TRABAJO

### 1. DESARROLLO (Día a Día)

```bash
# En tu computadora local
deployment/development/
```

**Workflow:**
```bash
1. cd deployment/development
2. docker-compose up
3. Editar código en backend/ o frontend/
4. Cambios se reflejan automáticamente (hot reload)
5. git add . && git commit -m "feat: lo que hice"
6. git push
```

**URLs:**
- Frontend: http://localhost:8080
- Backend: http://localhost:8000
- Docs: http://localhost:8000/docs
- DB GUI: http://localhost:8081

---

### 2. PRODUCCIÓN (En servidor)

```bash
# En tu servidor (VPS, AWS, etc)
deployment/production/
```

**Workflow:**
```bash
1. Configurar .env.production
2. cd deployment/production
3. docker-compose --env-file ../../.env.production up -d
4. Configurar Nginx + SSL
5. Verificar: curl http://localhost:8000/health
```

**URLs:**
- Frontend: https://tu-dominio.com
- Backend: https://tu-dominio.com/api/v1
- Health: https://tu-dominio.com/health

---

## 📋 DIFERENCIAS CLAVE

| Aspecto | Desarrollo | Producción |
|---------|-----------|-----------|
| **Carpeta** | `deployment/development/` | `deployment/production/` |
| **Docker Compose** | `docker-compose.yml` | `docker-compose.yml` + `.env.production` |
| **DEBUG** | True | False |
| **Hot Reload** | ✅ Sí | ❌ No |
| **Adminer** | ✅ Incluido | ❌ No |
| **SECRET_KEY** | Simple | Criptográfica |
| **CORS** | `*` (todos) | Dominio específico |
| **Servidor** | Uvicorn --reload | Gunicorn + workers |
| **SSL** | No necesario | Obligatorio |
| **Para** | Programar | Usuarios finales |

---

## ⚡ COMANDOS RÁPIDOS

### Desarrollo:

```bash
# Inicio Windows
start-dev.bat

# Inicio Linux/Mac
./start-dev.sh

# O manual:
cd deployment/development
docker-compose up
```

### Producción:

```bash
# Inicio Linux/Mac
./start-prod.sh

# O manual:
cd deployment/production
docker-compose --env-file ../../.env.production up -d
```

---

## 🗂️ ARCHIVOS POR CATEGORÍA

### Configuración Docker:

| Archivo | Ubicación | Para |
|---------|-----------|------|
| `docker-compose.yml` | `deployment/development/` | Desarrollo |
| `Dockerfile.dev` | `deployment/development/` | Desarrollo |
| `docker-compose.yml` | `deployment/production/` | Producción |
| `Dockerfile` | `backend/` | Producción |
| `Dockerfile` | `frontend/` | Producción |

### Variables de Entorno:

| Archivo | Ubicación | Para |
|---------|-----------|------|
| `.env.example` | `backend/` | Template desarrollo |
| `.env.production.example` | `deployment/production/` | Template producción |
| `.env` | Raíz (crear) | Desarrollo local |
| `.env.production` | Raíz (crear) | Producción |

### Documentación:

| Archivo | Ubicación |
|---------|-----------|
| `README.md` | Raíz |
| `README.md` | `deployment/development/` |
| `README.md` | `deployment/production/` |
| `QUICK_START.md` | Raíz |
| Todas las guías | `docs/guides/` |

---

## 🚦 REGLAS SIMPLES

### ✅ HACER:

- **Desarrollar:** Usar solo `deployment/development/`
- **Deployar:** Usar solo `deployment/production/`
- **Git:** Trabajar en branches `feature/*` o `develop`
- **Secrets:** Usar variables de entorno, nunca hardcodear

### ❌ NO HACER:

- **NO** mezclar archivos de dev y prod
- **NO** usar `deployment/development/` en servidor
- **NO** usar `deployment/production/` en local
- **NO** commitear archivos `.env` o `.env.production`
- **NO** hacer commits directos a `main`

---

## 📖 GUÍA DE LECTURA SUGERIDA

### Primera Vez:

1. **README.md** (raíz) - Overview
2. **deployment/development/README.md** - Para empezar a desarrollar
3. **docs/guides/GIT_WORKFLOW.md** - Cómo usar Git

### Cuando vayas a deployar:

1. **deployment/production/README.md** - Setup básico
2. **docs/guides/DEPLOYMENT.md** - Paso a paso detallado
3. **docs/guides/SECURITY_CHECKLIST.md** - Antes de ir a producción

### Para profundizar:

- **docs/guides/DEVELOPMENT_GUIDE.md** - Desarrollo avanzado
- **docs/guides/PRODUCTION_README.md** - Cambios y optimizaciones

---

## 💡 TIPS

1. **Siempre lee el README de la carpeta donde estés trabajando**
   - En `deployment/development/`? → Lee su README.md
   - En `deployment/production/`? → Lee su README.md

2. **Usa los scripts de inicio**
   - Más fácil que recordar comandos
   - `start-dev.bat` o `./start-dev.sh` para desarrollo

3. **Mantén separado dev de prod**
   - Nunca uses mismo `.env` para ambos
   - Nunca mezcles configuraciones

4. **Git branches**
   - `main` = producción
   - `develop` = desarrollo
   - `feature/*` = tus cambios

---

**REGLA DE ORO:**

> **Desarrollo** → `deployment/development/`
> **Producción** → `deployment/production/`
> **Documentación** → `docs/guides/`

**Así de simple.**

---

Última actualización: 2025-10-25
