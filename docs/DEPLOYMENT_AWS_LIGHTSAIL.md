# ====================================
# VEXUS - GUÍA DE DESPLIEGUE EN AWS LIGHTSAIL
# ====================================

Este documento contiene instrucciones completas para desplegar Vexus en AWS Lightsail usando Docker.

## 📋 Tabla de Contenidos

1. [Prerrequisitos](#prerrequisitos)
2. [Configuración Inicial](#configuración-inicial)
3. [Despliegue con Docker](#despliegue-con-docker)
4. [Configuración de Dominio y SSL](#configuración-de-dominio-y-ssl)
5. [Mantenimiento](#mantenimiento)
6. [Troubleshooting](#troubleshooting)

---

## 1. Prerrequisitos

### En tu máquina local:
- Git instalado
- Docker y Docker Compose (opcional, para pruebas locales)
- Acceso SSH configurado

### En AWS:
- Cuenta de AWS activa
- Instancia de Lightsail creada (recomendado: Ubuntu 22.04 LTS, 2GB RAM mínimo)
- IP estática asignada a la instancia

### Servicios externos:
- Cuenta de Gmail con App Password (para envío de emails)
- Dominio configurado (opcional pero recomendado)

---

## 2. Configuración Inicial

### 2.1. Crear instancia de Lightsail

1. Ve a AWS Lightsail Console
2. Crea una nueva instancia:
   - Plataforma: Linux/Unix
   - Blueprint: OS Only → Ubuntu 22.04 LTS
   - Plan: $10/mes (2GB RAM, 1 vCPU) o superior
   - Nombre: `vexus-production`

3. Espera a que la instancia esté en estado "Running"

4. Asigna una IP estática:
   - Networking → Create static IP
   - Asocia la IP a tu instancia

### 2.2. Conectar a la instancia

```bash
# Opción 1: SSH desde la consola de Lightsail (browser)
# Opción 2: SSH local
ssh -i /path/to/lightsail-key.pem ubuntu@YOUR_STATIC_IP
```

### 2.3. Instalar Docker y Docker Compose

```bash
# Actualizar sistema
sudo apt update && sudo apt upgrade -y

# Instalar dependencias
sudo apt install -y apt-transport-https ca-certificates curl software-properties-common

# Agregar repositorio de Docker
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Instalar Docker
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io

# Instalar Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Agregar usuario al grupo docker
sudo usermod -aG docker ${USER}

# Aplicar cambios (relogin necesario)
newgrp docker

# Verificar instalación
docker --version
docker-compose --version
```

---

## 3. Despliegue con Docker

### 3.1. Clonar el repositorio

```bash
# Crear directorio de aplicaciones
cd ~
mkdir -p apps
cd apps

# Clonar repositorio
git clone https://github.com/TU_USUARIO/VexusPage.git
cd VexusPage
```

### 3.2. Configurar variables de entorno

```bash
# Copiar archivo de ejemplo
cp .env.production.example .env.production

# Editar archivo
nano .env.production
```

**Configurar estas variables:**

```bash
# === BASE DE DATOS ===
POSTGRES_DB=vexus_db
POSTGRES_USER=vexus_admin
POSTGRES_PASSWORD=TU_CONTRASEÑA_SEGURA_AQUI  # ⚠️ CAMBIAR

# === BACKEND ===
SECRET_KEY=TU_CLAVE_SECRETA_AQUI  # Generar con: python -c "import secrets; print(secrets.token_urlsafe(32))"

# === CORS ===
ALLOWED_ORIGINS=https://tudominio.com,https://www.tudominio.com

# === EMAIL (Gmail SMTP) ===
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USER=tu-email@gmail.com
SMTP_PASSWORD=tu-app-password-aqui
EMAIL_FROM=noreply@tudominio.com

# === FRONTEND ===
FRONTEND_URL=https://tudominio.com
API_URL=https://tudominio.com
```

### 3.3. Generar SECRET_KEY

```bash
python3 -c "import secrets; print(secrets.token_urlsafe(32))"
```

### 3.4. Construir y levantar contenedores

```bash
# Construir imágenes
docker-compose -f docker-compose.prod.yml build

# Levantar servicios
docker-compose -f docker-compose.prod.yml up -d

# Ver logs
docker-compose -f docker-compose.prod.yml logs -f
```

### 3.5. Verificar que todo funciona

```bash
# Ver contenedores corriendo
docker ps

# Deberías ver 3 contenedores:
# - vexus-postgres
# - vexus-backend
# - vexus-frontend

# Verificar salud de la base de datos
docker exec vexus-postgres pg_isready -U vexus_admin

# Verificar backend
curl http://localhost:8000/health

# Verificar frontend
curl http://localhost
```

### 3.6. Abrir puertos en Lightsail

1. Ve a tu instancia en Lightsail Console
2. Networking → Firewall
3. Agrega reglas:
   - HTTP: TCP 80
   - HTTPS: TCP 443 (para SSL)
   - Custom: TCP 8000 (backend - opcional, solo para debugging)

---

## 4. Configuración de Dominio y SSL

### 4.1. Configurar DNS

En tu proveedor de dominio (ej: GoDaddy, Namecheap):

```
Tipo    Nombre    Valor
A       @         TU_IP_ESTATICA_LIGHTSAIL
A       www       TU_IP_ESTATICA_LIGHTSAIL
```

### 4.2. Instalar Certbot para SSL (Let's Encrypt)

```bash
# Instalar Certbot
sudo apt install -y certbot python3-certbot-nginx

# Detener nginx temporalmente
docker-compose -f docker-compose.prod.yml stop frontend

# Obtener certificado
sudo certbot certonly --standalone -d tudominio.com -d www.tudominio.com

# Los certificados se guardan en:
# /etc/letsencrypt/live/tudominio.com/fullchain.pem
# /etc/letsencrypt/live/tudominio.com/privkey.pem
```

### 4.3. Copiar certificados al proyecto

```bash
# Crear directorio SSL
mkdir -p ~/apps/VexusPage/ssl

# Copiar certificados
sudo cp /etc/letsencrypt/live/tudominio.com/fullchain.pem ~/apps/VexusPage/ssl/
sudo cp /etc/letsencrypt/live/tudominio.com/privkey.pem ~/apps/VexusPage/ssl/
sudo chown -R $USER:$USER ~/apps/VexusPage/ssl
```

### 4.4. Habilitar SSL en nginx

Edita `frontend/nginx.prod.conf` y descomenta las líneas SSL:

```bash
nano ~/apps/VexusPage/frontend/nginx.prod.conf
```

Descomenta:
- `listen 443 ssl http2;`
- Toda la configuración SSL
- El redirect HTTP → HTTPS

### 4.5. Reiniciar servicios

```bash
cd ~/apps/VexusPage
docker-compose -f docker-compose.prod.yml down
docker-compose -f docker-compose.prod.yml up -d
```

### 4.6. Auto-renovación de certificados

```bash
# Crear script de renovación
sudo nano /etc/cron.d/certbot-renew

# Agregar:
0 3 * * * root certbot renew --quiet --post-hook "cd /home/ubuntu/apps/VexusPage && docker-compose -f docker-compose.prod.yml restart frontend"
```

---

## 5. Mantenimiento

### 5.1. Ver logs

```bash
cd ~/apps/VexusPage

# Todos los servicios
docker-compose -f docker-compose.prod.yml logs -f

# Solo backend
docker-compose -f docker-compose.prod.yml logs -f backend

# Solo frontend
docker-compose -f docker-compose.prod.yml logs -f frontend

# Solo database
docker-compose -f docker-compose.prod.yml logs -f postgres
```

### 5.2. Actualizar la aplicación

```bash
cd ~/apps/VexusPage

# Pull cambios del repositorio
git pull origin main

# Reconstruir y reiniciar
docker-compose -f docker-compose.prod.yml down
docker-compose -f docker-compose.prod.yml build
docker-compose -f docker-compose.prod.yml up -d
```

### 5.3. Backup de la base de datos

```bash
# Crear backup
docker exec vexus-postgres pg_dump -U vexus_admin vexus_db > backup_$(date +%Y%m%d_%H%M%S).sql

# Restaurar backup
cat backup_20231120_150000.sql | docker exec -i vexus-postgres psql -U vexus_admin vexus_db
```

### 5.4. Monitoreo de recursos

```bash
# Ver uso de recursos de contenedores
docker stats

# Ver espacio en disco
df -h

# Ver memoria
free -h
```

---

## 6. Troubleshooting

### Backend no se conecta a la base de datos

```bash
# Verificar que postgres está corriendo
docker ps | grep postgres

# Ver logs de postgres
docker logs vexus-postgres

# Verificar conectividad desde backend
docker exec vexus-backend ping postgres
```

### Frontend no puede acceder al backend

1. Verificar que `API_URL` en `.env.production` es correcto
2. Verificar configuración CORS en backend
3. Ver logs del backend: `docker logs vexus-backend`

### Certificado SSL no funciona

```bash
# Verificar certificados
sudo certbot certificates

# Renovar manualmente
sudo certbot renew

# Verificar configuración nginx
docker exec vexus-frontend nginx -t
```

### Contenedores se reinician constantemente

```bash
# Ver por qué falla
docker logs vexus-backend
docker logs vexus-frontend
docker logs vexus-postgres

# Ver health checks
docker inspect vexus-backend | grep -A 10 Health
```

### Liberar espacio en disco

```bash
# Limpiar imágenes no usadas
docker system prune -a

# Limpiar volúmenes no usados
docker volume prune
```

---

## 📞 Soporte

Si encuentras problemas:
1. Revisa los logs: `docker-compose logs -f`
2. Verifica las variables de entorno en `.env.production`
3. Confirma que los puertos están abiertos en Lightsail Firewall
4. Revisa la documentación de AWS Lightsail

---

## 🎉 ¡Listo!

Tu aplicación Vexus debería estar corriendo en:
- Frontend: https://tudominio.com
- Backend API: https://tudominio.com/api
- Health Check: https://tudominio.com/api/health
