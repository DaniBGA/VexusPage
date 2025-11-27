# 🚀 Vexus Campus - Despliegue en Producción

Sistema completo de campus educativo con backend FastAPI, frontend Nginx y PostgreSQL, listo para desplegar en AWS Lightsail con Docker.

## 📋 Contenido

- [Características](#características)
- [Arquitectura](#arquitectura)
- [Prerequisitos](#prerequisitos)
- [Instalación Rápida](#instalación-rápida)
- [Configuración](#configuración)
- [Despliegue](#despliegue)
- [Mantenimiento](#mantenimiento)

---

## ✨ Características

### Backend (FastAPI + PostgreSQL)
- 🔐 **Autenticación JWT** - Sistema completo de registro y login
- ✉️ **Verificación de email** - Integración con Gmail SMTP
- 📚 **Sistema de cursos** - Gestión completa de cursos y progreso
- 🛠️ **Herramientas del campus** - Acceso a herramientas de desarrollo
- 📊 **Dashboard personalizado** - Estadísticas y progreso del usuario
- 🎯 **Proyectos** - Gestión de proyectos de usuarios
- 📬 **Contacto y consultoría** - Formularios de contacto

### Frontend (Nginx + SPA)
- ⚡ **SPA optimizado** - Single Page Application con routing
- 🎨 **UI/UX moderno** - Interfaz intuitiva y responsive
- 📱 **Mobile-first** - Diseñado para todos los dispositivos
- 🔒 **Seguridad** - Headers de seguridad configurados
- 💨 **Performance** - Caché agresivo y compresión Gzip

### Base de Datos (PostgreSQL 15)
- 🗄️ **Esquema completo** - 15+ tablas relacionadas
- 📊 **Datos iniciales** - 3 secciones, 3 cursos, 8 herramientas
- 🔄 **Triggers automáticos** - Actualización de timestamps
- 🔍 **Índices optimizados** - Consultas rápidas
- 💾 **Backups automáticos** - Scripts incluidos

---

## 🏗️ Arquitectura

```
┌─────────────────────────────────────────────────────────────┐
│                         CLIENTE                              │
│                    (Navegador Web)                           │
└─────────────────────────────────────────────────────────────┘
                            │
                            │ HTTPS (443)
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                    NGINX (Frontend)                          │
│  • Sirve archivos estáticos                                  │
│  • Proxy reverso a /api/*                                    │
│  • SSL/TLS terminación                                       │
│  • Compresión Gzip                                           │
└─────────────────────────────────────────────────────────────┘
                            │
                            │ HTTP (8000)
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                 FASTAPI (Backend)                            │
│  • API REST                                                  │
│  • Autenticación JWT                                         │
│  • Validación Pydantic                                       │
│  • Pool de conexiones                                        │
└─────────────────────────────────────────────────────────────┘
                            │
                            │ PostgreSQL (5432)
                            ▼
┌─────────────────────────────────────────────────────────────┐
│               POSTGRESQL 15                                  │
│  • Base de datos principal                                   │
│  • Datos persistentes                                        │
│  • Backups automáticos                                       │
└─────────────────────────────────────────────────────────────┘
```

---

## 📦 Prerequisitos

### Local (Desarrollo)
- Docker 20.10+
- Docker Compose 2.0+
- Git
- Python 3.11+ (opcional, para testing)

### Producción (AWS Lightsail)
- Instancia Ubuntu 22.04 LTS
- 2GB RAM mínimo (recomendado 4GB)
- 1 vCPU mínimo (recomendado 2 vCPU)
- 40GB SSD mínimo
- IP estática asignada

### Servicios Externos
- Cuenta de Gmail con App Password (para envío de emails)
- Dominio registrado (opcional pero recomendado)
- Certificado SSL (Let's Encrypt - gratis)

---

## 🚀 Instalación Rápida

### 1. Clonar el repositorio

```bash
git clone https://github.com/TU_USUARIO/VexusPage.git
cd VexusPage
```

### 2. Configurar variables de entorno

```bash
# Copiar archivo de ejemplo
cp .env.production.example .env.production

# Editar y configurar
nano .env.production
```

**Variables obligatorias a cambiar:**

```bash
# Contraseña de PostgreSQL
POSTGRES_PASSWORD=tu_contraseña_segura_aqui

# Clave secreta (generar nueva)
SECRET_KEY=genera_una_clave_secreta_con_python

# Gmail SMTP Configuration
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USER=tu-email@gmail.com
SMTP_PASSWORD=tu-app-password-aqui

# URLs de tu dominio
FRONTEND_URL=https://tudominio.com
ALLOWED_ORIGINS=https://tudominio.com,https://www.tudominio.com
```

### 3. Generar SECRET_KEY

```bash
python3 -c "import secrets; print(secrets.token_urlsafe(32))"
```

### 4. Desplegar con Docker Compose

```bash
# Construir y levantar servicios
docker-compose -f docker-compose.prod.yml up -d

# Ver logs
docker-compose -f docker-compose.prod.yml logs -f
```

---

## ⚙️ Configuración

### Estructura de Archivos

```
VexusPage/
├── backend/
│   ├── app/
│   │   ├── api/v1/endpoints/  # Endpoints de la API
│   │   ├── core/              # Configuración core
│   │   ├── models/            # Schemas Pydantic
│   │   └── services/          # Servicios (email.py, etc)
│   ├── Dockerfile             # Dockerfile de producción
│   └── requirements.txt       # Dependencias Python
│
├── frontend/
│   ├── pages/                 # Páginas HTML
│   ├── Static/                # CSS, JS, imágenes
│   ├── Dockerfile             # Dockerfile de producción
│   └── nginx.prod.conf        # Configuración Nginx
│
├── deployment/production/
│   └── init_production_db.sql # Script de inicialización DB
│
├── docker-compose.prod.yml    # Compose de producción
├── .env.production.example    # Ejemplo de variables
├── deploy.sh                  # Script de deploy (Linux)
└── deploy.ps1                 # Script de deploy (Windows)
```

### Variables de Entorno

| Variable | Descripción | Ejemplo |
|----------|-------------|---------|
| `POSTGRES_DB` | Nombre de la base de datos | `vexus_db` |
| `POSTGRES_USER` | Usuario de PostgreSQL | `vexus_admin` |
| `POSTGRES_PASSWORD` | **⚠️ CAMBIAR** Contraseña PostgreSQL | `contraseña_segura` |
| `SECRET_KEY` | **⚠️ CAMBIAR** Clave para JWT | `token_aleatorio_32bytes` |
| `SMTP_HOST` | Host del servidor SMTP | `smtp.gmail.com` |
| `SMTP_PORT` | Puerto SMTP | `587` |
| `SMTP_USER` | **⚠️ CAMBIAR** Email Gmail | `tu-email@gmail.com` |
| `SMTP_PASSWORD` | **⚠️ CAMBIAR** App Password Gmail | `tu-app-password` |
| `FRONTEND_URL` | URL del frontend | `https://tudominio.com` |
| `ALLOWED_ORIGINS` | Orígenes CORS permitidos | `https://tudominio.com` |

---

## 🌐 Despliegue

### Opción 1: Script Automático (Recomendado)

**Linux/Mac:**
```bash
chmod +x deploy.sh
./deploy.sh
```

**Windows (PowerShell):**
```powershell
.\deploy.ps1
```

### Opción 2: Manual

```bash
# 1. Detener servicios (si existen)
docker-compose -f docker-compose.prod.yml down

# 2. Construir imágenes
docker-compose -f docker-compose.prod.yml build --no-cache

# 3. Levantar servicios
docker-compose -f docker-compose.prod.yml up -d

# 4. Ver logs
docker-compose -f docker-compose.prod.yml logs -f

# 5. Verificar estado
docker-compose -f docker-compose.prod.yml ps
```

### Verificar Despliegue

```bash
# Backend health check
curl http://localhost:8000/health

# Frontend
curl http://localhost

# PostgreSQL
docker exec vexus-postgres pg_isready -U vexus_admin
```

---

## 🔒 SSL/HTTPS con Let's Encrypt

### 1. Instalar Certbot

```bash
sudo apt update
sudo apt install -y certbot
```

### 2. Obtener Certificado

```bash
# Detener frontend temporalmente
docker-compose -f docker-compose.prod.yml stop frontend

# Obtener certificado
sudo certbot certonly --standalone \
  -d tudominio.com \
  -d www.tudominio.com

# Iniciar frontend nuevamente
docker-compose -f docker-compose.prod.yml start frontend
```

### 3. Copiar Certificados

```bash
# Crear directorio SSL
mkdir -p ssl

# Copiar certificados
sudo cp /etc/letsencrypt/live/tudominio.com/fullchain.pem ssl/
sudo cp /etc/letsencrypt/live/tudominio.com/privkey.pem ssl/
sudo chown $USER:$USER ssl/*
```

### 4. Habilitar SSL en Nginx

Edita `frontend/nginx.prod.conf` y descomenta:
- `listen 443 ssl http2;`
- Configuración SSL completa
- Redirect HTTP → HTTPS

```bash
# Reiniciar frontend
docker-compose -f docker-compose.prod.yml restart frontend
```

### 5. Auto-renovación

```bash
# Crear cron job
sudo crontab -e

# Agregar línea:
0 3 * * * certbot renew --quiet --post-hook "cd /home/ubuntu/apps/VexusPage && docker-compose -f docker-compose.prod.yml restart frontend"
```

---

## 🛠️ Mantenimiento

### Ver Logs

```bash
# Todos los servicios
docker-compose -f docker-compose.prod.yml logs -f

# Solo backend
docker-compose -f docker-compose.prod.yml logs -f backend

# Solo frontend
docker-compose -f docker-compose.prod.yml logs -f frontend

# Solo database
docker-compose -f docker-compose.prod.yml logs -f postgres
```

### Backup de Base de Datos

```bash
# Crear backup
docker exec vexus-postgres pg_dump -U vexus_admin vexus_db > backup_$(date +%Y%m%d_%H%M%S).sql

# Restaurar backup
cat backup_20231120_150000.sql | docker exec -i vexus-postgres psql -U vexus_admin vexus_db
```

### Actualizar Aplicación

```bash
# Pull cambios
git pull origin main

# Ejecutar script de deploy
./deploy.sh

# O manual:
docker-compose -f docker-compose.prod.yml down
docker-compose -f docker-compose.prod.yml build
docker-compose -f docker-compose.prod.yml up -d
```

### Monitoreo

```bash
# Uso de recursos
docker stats

# Estado de contenedores
docker-compose -f docker-compose.prod.yml ps

# Health checks
docker inspect vexus-backend | grep -A 10 Health
```

### Limpieza

```bash
# Limpiar imágenes no usadas
docker system prune -a

# Limpiar volúmenes no usados
docker volume prune

# Limpiar todo (⚠️ cuidado)
docker system prune -a --volumes
```

---

## 📊 Base de Datos

### Esquema Incluido

El script `deployment/production/init_production_db.sql` crea:

- ✅ 15+ tablas relacionadas
- ✅ Extensiones necesarias (uuid-ossp, pgcrypto)
- ✅ Índices optimizados
- ✅ Triggers automáticos
- ✅ Funciones auxiliares

### Datos Iniciales

- **3 Secciones del Campus:** Dashboard, Cursos, Herramientas
- **3 Cursos:** Desarrollo Web, Python, Git & GitHub
- **8 Herramientas:** Code Editor, Terminal, Python Playground, etc.
- **4 Servicios:** Desarrollo Web, Apps Móviles, Consultoría, UI/UX

### Conectar a la Base de Datos

```bash
# Desde el host
docker exec -it vexus-postgres psql -U vexus_admin -d vexus_db

# Consultas útiles
\dt                          # Listar tablas
SELECT * FROM users;         # Ver usuarios
SELECT * FROM learning_courses;  # Ver cursos
```

---

## 🔧 Troubleshooting

### Backend no se conecta a PostgreSQL

```bash
# Verificar que postgres está corriendo
docker ps | grep postgres

# Ver logs de postgres
docker logs vexus-postgres

# Verificar conectividad
docker exec vexus-backend ping postgres
```

### Frontend no accede al backend

1. Verifica `API_URL` en `.env.production`
2. Verifica CORS en `backend/app/config.py`
3. Revisa logs: `docker logs vexus-backend`

### Certificado SSL no funciona

```bash
# Verificar certificados
sudo certbot certificates

# Renovar manualmente
sudo certbot renew --dry-run

# Verificar nginx config
docker exec vexus-frontend nginx -t
```

### Contenedores se reinician

```bash
# Ver por qué fallan
docker logs vexus-backend
docker logs vexus-frontend
docker logs vexus-postgres

# Ver health check status
docker inspect vexus-backend | grep -A 10 Health
```

---

## 📚 Documentación Adicional

- [Guía Completa de AWS Lightsail](docs/DEPLOYMENT_AWS_LIGHTSAIL.md)
- [Configuración de Email](docs/EMAIL_VERIFICATION_SETUP.md)
- [Análisis Frontend-Backend](docs/ANALISIS_INTEGRACION_FRONTEND_BACKEND.md)

---

## 🤝 Contribuir

1. Fork el proyecto
2. Crea una rama (`git checkout -b feature/AmazingFeature`)
3. Commit cambios (`git commit -m 'Add: AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abre un Pull Request

---

## 📄 Licencia

Este proyecto es privado y propiedad de Vexus.

---

## 📞 Soporte

- 📧 Email: support@vexus.com
- 🌐 Website: https://vexus.com
- 📱 GitHub Issues: https://github.com/TU_USUARIO/VexusPage/issues

---

## ✅ Checklist de Despliegue

- [ ] Variables de entorno configuradas en `.env.production`
- [ ] SECRET_KEY generada y configurada
- [ ] Gmail SMTP configurado con App Password
- [ ] Dominio apuntando a IP de Lightsail
- [ ] Docker y Docker Compose instalados
- [ ] Puertos abiertos en firewall (80, 443)
- [ ] Certificado SSL obtenido y configurado
- [ ] Base de datos inicializada con datos
- [ ] Backup configurado
- [ ] Monitoreo configurado
- [ ] Logs funcionando correctamente

---

**¡Listo para producción! 🚀**
