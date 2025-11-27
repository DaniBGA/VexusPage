# 🚀 Vexus Campus Platform

Plataforma educativa completa con backend FastAPI, frontend moderno, sistema de gestión de cursos y herramientas de desarrollo.

**Estado:** ✅ Listo para producción en AWS Lightsail con Docker

---

## 🎯 Inicio Rápido

### Para Desarrollo Local
```bash
# Backend
cd backend
python -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate
pip install -r requirements.txt
uvicorn app.main:app --reload

# Frontend
cd frontend
# Abrir index.html en navegador o usar Live Server
```

### Para Producción (AWS Lightsail)

**📖 Guía completa:** [QUICKSTART.md](QUICKSTART.md)

```bash
# En tu servidor
git clone https://github.com/TU_USUARIO/VexusPage.git
cd VexusPage
cp .env.production.example .env.production
nano .env.production  # Configurar variables
docker-compose -f docker-compose.prod.yml up -d
```

---

## 📚 Documentación

### Producción (AWS Lightsail + Docker)
- **[QUICKSTART.md](QUICKSTART.md)** - ⚡ Instalación en 5 minutos
- **[PRODUCTION_README.md](PRODUCTION_README.md)** - 📖 Guía completa de producción
- **[DEPLOYMENT_AWS_LIGHTSAIL.md](docs/DEPLOYMENT_AWS_LIGHTSAIL.md)** - 🌐 Despliegue detallado
- **[DEPLOYMENT_CHECKLIST.md](DEPLOYMENT_CHECKLIST.md)** - ✅ Checklist completo
- **[DEPLOYMENT_SUMMARY.md](DEPLOYMENT_SUMMARY.md)** - 📊 Resumen de archivos

### Alternativa (Neatech cPanel)
- **[docs/backend/DESPLIEGUE_NEATECH.md](docs/backend/DESPLIEGUE_NEATECH.md)** - Backend en Passenger
- **[docs/frontend/DESPLIEGUE_FRONTEND_NEATECH.md](docs/frontend/DESPLIEGUE_FRONTEND_NEATECH.md)** - Frontend en Apache

### General
- **[docs/README.md](docs/README.md)** - Índice de documentación
- **[docs/RESUMEN_ANALISIS_COMPLETO.md](docs/RESUMEN_ANALISIS_COMPLETO.md)** - Análisis técnico

---

## 🏗️ Arquitectura

```
┌─────────────────────────────────────────────────┐
│              CLIENTE (Browser)                   │
└─────────────────────────────────────────────────┘
                      ↓ HTTPS
┌─────────────────────────────────────────────────┐
│         NGINX (Frontend Container)               │
│  • Sirve archivos estáticos                      │
│  • Proxy reverso a /api/*                        │
│  • SSL/TLS                                       │
└─────────────────────────────────────────────────┘
                      ↓ HTTP
┌─────────────────────────────────────────────────┐
│        FASTAPI (Backend Container)               │
│  • API REST                                      │
│  • Autenticación JWT                             │
│  • Validación Pydantic                           │
└─────────────────────────────────────────────────┘
                      ↓ PostgreSQL
┌─────────────────────────────────────────────────┐
│      POSTGRESQL 15 (DB Container)                │
│  • Datos persistentes                            │
│  • 15 tablas relacionadas                        │
└─────────────────────────────────────────────────┘
```

---

## 📂 Estructura del Proyecto

```
VexusPage/
├── 📚 docs/                            # Documentación completa
│   ├── DEPLOYMENT_AWS_LIGHTSAIL.md     # Guía AWS Lightsail
│   ├── backend/                        # Docs backend
│   └── frontend/                       # Docs frontend
│
├── 🔥 backend/                         # Backend FastAPI
│   ├── app/
│   │   ├── api/v1/endpoints/           # 11 endpoints REST
│   │   ├── core/                       # Config y DB
│   │   ├── models/                     # Schemas Pydantic
│   │   └── services/                   # Email, etc.
│   ├── Dockerfile                      # Docker de producción
│   ├── requirements.txt                # Dependencias Python
│   └── gunicorn.conf.py               # Config Gunicorn
│
├── 🎨 frontend/                        # Frontend SPA
│   ├── index.html                      # Landing page
│   ├── pages/                          # Páginas
│   ├── Static/                         # Assets
│   │   ├── css/                        # Estilos
│   │   ├── js/                         # JavaScript
│   │   └── images/                     # Imágenes
│   ├── Dockerfile                      # Docker de producción
│   └── nginx.prod.conf                 # Config Nginx
│
├── 🗄️ deployment/production/
│   └── init_production_db.sql          # Schema + datos iniciales
│
├── 🐳 docker-compose.prod.yml          # Orquestación Docker
├── 📝 .env.production.example          # Template variables
├── 🚀 deploy.sh / deploy.ps1           # Scripts de deploy
├── 📖 PRODUCTION_README.md             # README de producción
├── ⚡ QUICKSTART.md                    # Quick start
└── ✅ DEPLOYMENT_CHECKLIST.md          # Checklist

---

## 📊 Características

### Backend (FastAPI + PostgreSQL)
- 🔐 **Autenticación JWT** - Sistema completo de registro y login
- ✉️ **Verificación de email** - Integración con Gmail SMTP
- 📚 **Sistema de cursos** - 3 cursos iniciales con unidades
- 🛠️ **Herramientas del campus** - 8 herramientas de desarrollo
- 📊 **Dashboard personalizado** - Estadísticas y progreso
- 🎯 **Proyectos de usuarios** - Gestión de portafolio
- 📬 **Contacto y consultoría** - Formularios integrados

### Frontend (Nginx + SPA)
- ⚡ **SPA optimizado** - Single Page Application con routing
- 🎨 **UI/UX moderno** - Interfaz intuitiva y responsive
- 📱 **Mobile-first** - Diseñado para todos los dispositivos
- 🔒 **Seguridad** - Headers de seguridad configurados
- 💨 **Performance** - Caché agresivo y compresión Gzip

### Base de Datos (PostgreSQL 15)
- 🗄️ **15 tablas relacionadas** - Schema completo
- 📊 **Datos iniciales** - 3 secciones, 3 cursos, 8 herramientas
- 🔄 **Triggers automáticos** - Actualización de timestamps
- 🔍 **Índices optimizados** - Consultas rápidas

---

## 🛠️ Stack Tecnológico

**Backend:**
- Python 3.11 + FastAPI
- PostgreSQL 15 (asyncpg)
- JWT Authentication
- Bcrypt password hashing
- Gmail SMTP Email
- Gunicorn + Uvicorn Workers

**Frontend:**
- Vanilla JavaScript (ES6 Modules)
- CSS3 con variables
- Fetch API
- Nginx Alpine

**DevOps:**
- Docker + Docker Compose
- Multi-stage builds
- Health checks
- Volume persistence

**Servidor:**
- AWS Lightsail (Ubuntu 22.04)
- Let's Encrypt SSL
- Certbot auto-renewal

---

## 🚀 Despliegue

### Opción 1: AWS Lightsail (Recomendado)

```bash
# 1. Instalar Docker
curl -fsSL https://get.docker.com | sh
sudo usermod -aG docker $USER

# 2. Clonar y configurar
git clone https://github.com/TU_USUARIO/VexusPage.git
cd VexusPage
cp .env.production.example .env.production
nano .env.production

# 3. Desplegar
docker-compose -f docker-compose.prod.yml up -d
```

📖 **Guía completa:** [QUICKSTART.md](QUICKSTART.md)

### Opción 2: Neatech cPanel

📖 **Guías:**
- Backend: [docs/backend/DESPLIEGUE_NEATECH.md](docs/backend/DESPLIEGUE_NEATECH.md)
- Frontend: [docs/frontend/DESPLIEGUE_FRONTEND_NEATECH.md](docs/frontend/DESPLIEGUE_FRONTEND_NEATECH.md)

---

## ✅ Estado del Proyecto

| Componente | Estado | Descripción |
|------------|--------|-------------|
| **Backend API** | ✅ Completo | 11 endpoints REST funcionando |
| **Frontend SPA** | ✅ Completo | 8 páginas + assets optimizados |
| **Base de Datos** | ✅ Completo | Schema + datos iniciales |
| **Docker** | ✅ Completo | Orquestación de 3 servicios |
| **Documentación** | ✅ Completo | Guías paso a paso |
| **Seguridad** | ✅ Completo | JWT, bcrypt, CORS, SSL |
| **Testing** | ⚠️ Pendiente | Unit tests por implementar |

---

## 🔒 Seguridad

### Implementado:
- ✅ Passwords hasheados con bcrypt (factor 12)
- ✅ JWT tokens seguros con expiración
- ✅ Verificación de email obligatoria
- ✅ Sesiones en base de datos
- ✅ CORS configurado correctamente
- ✅ Headers de seguridad en Nginx
- ✅ Variables sensibles en .env
- ✅ Usuario no-root en contenedores
- ✅ Multi-stage Docker builds

---

## 📝 Licencia

Este proyecto es propiedad de Vexus.

---

## 📞 Contacto

- **Email:** grupovexus@gmail.com
- **Web:** https://grupovexus.com

---

**¡Listo para producción! 🚀**

*Última actualización: Noviembre 2025*
*Versión: 1.0.0*
