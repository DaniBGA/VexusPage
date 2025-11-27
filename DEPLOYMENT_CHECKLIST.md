# ✅ Checklist de Despliegue en AWS Lightsail

## 📋 Pre-Despliegue

### Preparación Local
- [ ] Repositorio clonado localmente
- [ ] Git configurado con SSH keys
- [ ] Archivo `.env.production` creado y configurado
- [ ] SECRET_KEY generada (32+ caracteres aleatorios)
- [ ] Gmail App Password obtenida
- [ ] Dominio registrado (opcional pero recomendado)

### Verificación de Archivos
- [ ] `docker-compose.prod.yml` existe
- [ ] `backend/Dockerfile` existe
- [ ] `frontend/Dockerfile` existe
- [ ] `frontend/nginx.prod.conf` existe
- [ ] `deployment/production/init_production_db.sql` existe
- [ ] `.env.production` configurado (NO subir a Git)

---

## 🌐 AWS Lightsail Setup

### 1. Crear Instancia
- [ ] Cuenta AWS activa
- [ ] Instancia creada en Lightsail
  - [ ] Sistema: Ubuntu 22.04 LTS
  - [ ] Plan: $10/mes (2GB RAM) o superior
  - [ ] Región seleccionada
- [ ] IP estática asignada
- [ ] Nombre de instancia: `vexus-production`

### 2. Configurar Firewall
- [ ] Puerto 22 (SSH) - Abierto por defecto
- [ ] Puerto 80 (HTTP) - Agregar regla
- [ ] Puerto 443 (HTTPS) - Agregar regla
- [ ] Puerto 8000 (Backend) - Opcional para debug

### 3. Configurar DNS (Si tienes dominio)
- [ ] Registro A: `@` → IP estática de Lightsail
- [ ] Registro A: `www` → IP estática de Lightsail
- [ ] Propagación DNS verificada (usar `nslookup tudominio.com`)

---

## 🔧 Configuración del Servidor

### 1. Conectar por SSH
```bash
ssh -i /path/to/lightsail-key.pem ubuntu@YOUR_STATIC_IP
```
- [ ] Conexión SSH exitosa
- [ ] Usuario: `ubuntu`

### 2. Actualizar Sistema
```bash
sudo apt update && sudo apt upgrade -y
```
- [ ] Sistema actualizado
- [ ] Reiniciar si es necesario

### 3. Instalar Docker
```bash
# Agregar repositorio de Docker
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Instalar Docker
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io

# Verificar instalación
docker --version
```
- [ ] Docker instalado
- [ ] Versión: 20.10+

### 4. Instalar Docker Compose
```bash
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

sudo chmod +x /usr/local/bin/docker-compose

# Verificar
docker-compose --version
```
- [ ] Docker Compose instalado
- [ ] Versión: 2.0+

### 5. Configurar Permisos Docker
```bash
sudo usermod -aG docker ${USER}
newgrp docker

# Verificar
docker ps
```
- [ ] Usuario agregado al grupo docker
- [ ] Puede ejecutar docker sin sudo

---

## 📦 Despliegue de la Aplicación

### 1. Clonar Repositorio
```bash
cd ~
mkdir -p apps
cd apps
git clone https://github.com/TU_USUARIO/VexusPage.git
cd VexusPage
```
- [ ] Repositorio clonado en `/home/ubuntu/apps/VexusPage`

### 2. Configurar Variables de Entorno
```bash
cp .env.production.example .env.production
nano .env.production
```

**Variables a configurar:**
- [ ] `POSTGRES_PASSWORD` - Contraseña segura para PostgreSQL
- [ ] `SECRET_KEY` - Token aleatorio de 32+ caracteres
- [ ] `SMTP_HOST` - smtp.gmail.com
- [ ] `SMTP_PORT` - 587
- [ ] `SMTP_USER` - Tu email de Gmail
- [ ] `SMTP_PASSWORD` - App Password de Gmail
- [ ] `EMAIL_FROM` - Email para envíos
- [ ] `FRONTEND_URL` - URL de tu dominio
- [ ] `ALLOWED_ORIGINS` - Orígenes CORS permitidos

### 3. Construir Imágenes
```bash
docker-compose -f docker-compose.prod.yml build
```
- [ ] Backend image construida
- [ ] Frontend image construida
- [ ] No hay errores de build

### 4. Levantar Servicios
```bash
docker-compose -f docker-compose.prod.yml up -d
```
- [ ] Contenedor `vexus-postgres` corriendo
- [ ] Contenedor `vexus-backend` corriendo
- [ ] Contenedor `vexus-frontend` corriendo

### 5. Verificar Salud
```bash
# PostgreSQL
docker exec vexus-postgres pg_isready -U vexus_admin

# Backend
curl http://localhost:8000/health

# Frontend
curl http://localhost
```
- [ ] PostgreSQL responde
- [ ] Backend responde con status 200
- [ ] Frontend sirve HTML

---

## 🔒 Configurar SSL/HTTPS

### 1. Instalar Certbot
```bash
sudo apt install -y certbot
```
- [ ] Certbot instalado

### 2. Detener Frontend Temporalmente
```bash
docker-compose -f docker-compose.prod.yml stop frontend
```
- [ ] Frontend detenido

### 3. Obtener Certificado
```bash
sudo certbot certonly --standalone \
  -d tudominio.com \
  -d www.tudominio.com \
  --email tu@email.com \
  --agree-tos
```
- [ ] Certificado obtenido exitosamente
- [ ] Ubicación: `/etc/letsencrypt/live/tudominio.com/`

### 4. Copiar Certificados
```bash
mkdir -p ~/apps/VexusPage/ssl

sudo cp /etc/letsencrypt/live/tudominio.com/fullchain.pem ~/apps/VexusPage/ssl/
sudo cp /etc/letsencrypt/live/tudominio.com/privkey.pem ~/apps/VexusPage/ssl/

sudo chown $USER:$USER ~/apps/VexusPage/ssl/*
```
- [ ] Certificados copiados a `ssl/`
- [ ] Permisos correctos

### 5. Habilitar SSL en Nginx
```bash
nano ~/apps/VexusPage/frontend/nginx.prod.conf
```

Descomentar:
- [ ] `listen 443 ssl http2;`
- [ ] Bloque de configuración SSL
- [ ] Redirect HTTP → HTTPS

### 6. Reiniciar Frontend
```bash
cd ~/apps/VexusPage
docker-compose -f docker-compose.prod.yml up -d
```
- [ ] Frontend reiniciado con SSL

### 7. Verificar HTTPS
```bash
curl https://tudominio.com
```
- [ ] HTTPS funciona
- [ ] Certificado válido

### 8. Configurar Auto-renovación
```bash
sudo crontab -e

# Agregar línea:
0 3 * * * certbot renew --quiet --post-hook "cd /home/ubuntu/apps/VexusPage && docker-compose -f docker-compose.prod.yml restart frontend"
```
- [ ] Cron job configurado
- [ ] Renovación automática a las 3 AM

---

## 🧪 Pruebas Post-Despliegue

### 1. Endpoints Backend
- [ ] `GET https://tudominio.com/api/health` → 200 OK
- [ ] `GET https://tudominio.com/api` → Información de la API
- [ ] `POST https://tudominio.com/api/v1/auth/register` → 200/400
- [ ] `POST https://tudominio.com/api/v1/auth/login` → 200/401

### 2. Frontend
- [ ] `https://tudominio.com` → Carga correctamente
- [ ] `https://tudominio.com/pages/dashboard.html` → Carga
- [ ] `https://tudominio.com/pages/courses.html` → Carga
- [ ] Assets (CSS/JS/imágenes) cargan correctamente

### 3. Base de Datos
```bash
docker exec -it vexus-postgres psql -U vexus_admin -d vexus_db

# Consultas de verificación
SELECT COUNT(*) FROM campus_sections;  -- Debe ser 3
SELECT COUNT(*) FROM learning_courses;  -- Debe ser 3
SELECT COUNT(*) FROM campus_tools;      -- Debe ser 8
```
- [ ] 3 secciones en `campus_sections`
- [ ] 3 cursos en `learning_courses`
- [ ] 8 herramientas en `campus_tools`

### 4. Funcionalidad Completa
- [ ] Registro de usuario funciona
- [ ] Login funciona
- [ ] Email de verificación se envía
- [ ] Dashboard muestra información
- [ ] Cursos se listan correctamente
- [ ] Herramientas se muestran

---

## 📊 Monitoreo

### 1. Ver Logs
```bash
# Todos los servicios
docker-compose -f docker-compose.prod.yml logs -f

# Solo backend
docker-compose -f docker-compose.prod.yml logs -f backend
```
- [ ] Logs accesibles
- [ ] No hay errores críticos

### 2. Verificar Recursos
```bash
# Uso de contenedores
docker stats

# Disco
df -h

# Memoria
free -h
```
- [ ] Contenedores usando recursos normales
- [ ] Disco tiene espacio suficiente (>10GB libre)
- [ ] Memoria disponible (>500MB libre)

### 3. Health Checks
```bash
docker inspect vexus-backend | grep -A 10 Health
docker inspect vexus-frontend | grep -A 10 Health
docker inspect vexus-postgres | grep -A 10 Health
```
- [ ] Backend health check: healthy
- [ ] Frontend health check: healthy
- [ ] Postgres health check: healthy

---

## 💾 Configurar Backups

### 1. Script de Backup Manual
```bash
#!/bin/bash
BACKUP_DIR="/home/ubuntu/backups"
mkdir -p $BACKUP_DIR
docker exec vexus-postgres pg_dump -U vexus_admin vexus_db > $BACKUP_DIR/vexus_db_$(date +%Y%m%d_%H%M%S).sql
```
- [ ] Script creado en `/home/ubuntu/backup_db.sh`
- [ ] Permisos de ejecución: `chmod +x backup_db.sh`

### 2. Backup Automático (Cron)
```bash
sudo crontab -e

# Agregar:
0 2 * * * /home/ubuntu/backup_db.sh
```
- [ ] Backup diario a las 2 AM configurado

### 3. Retention Policy
```bash
# Agregar al final de backup_db.sh
find $BACKUP_DIR -name "vexus_db_*.sql" -mtime +7 -delete
```
- [ ] Backups antiguos (>7 días) se eliminan automáticamente

---

## 🔐 Seguridad Final

- [ ] Contraseñas seguras en `.env.production`
- [ ] `.env.production` NO está en Git
- [ ] SSH con key authentication (desactivar password)
- [ ] Firewall solo con puertos necesarios
- [ ] SSL/HTTPS activo
- [ ] Headers de seguridad en Nginx
- [ ] Usuarios no-root en contenedores
- [ ] Secrets no expuestos en logs

---

## 📝 Documentación

- [ ] URLs de la aplicación documentadas
- [ ] Credenciales guardadas en lugar seguro
- [ ] Equipo notificado del deploy
- [ ] Documentación actualizada

---

## 🎉 Deploy Completado

### URLs Finales:
- **Frontend:** https://tudominio.com
- **Backend API:** https://tudominio.com/api
- **Health Check:** https://tudominio.com/api/health
- **API Docs:** https://tudominio.com/api/docs

### Próximos Pasos:
- [ ] Monitorear logs las primeras 24 horas
- [ ] Configurar alertas (opcional)
- [ ] Setup CI/CD (opcional)
- [ ] Configurar CDN (opcional)

---

**¡Deployment exitoso! 🚀**

Fecha de deploy: _______________
Deployed por: _______________
Versión: v1.0.0
