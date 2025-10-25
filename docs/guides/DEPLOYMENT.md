# Guía de Deployment - Vexus Platform

## Tabla de Contenidos
1. [Preparación para Producción](#preparación-para-producción)
2. [Deployment con Docker](#deployment-con-docker)
3. [Deployment Manual](#deployment-manual)
4. [Configuración de Servidor](#configuración-de-servidor)
5. [Seguridad](#seguridad)
6. [Monitoreo y Mantenimiento](#monitoreo-y-mantenimiento)

---

## Preparación para Producción

### 1. Generar SECRET_KEY Segura

```bash
python generate_secret_key.py
```

Copia la clave generada para usarla en el siguiente paso.

### 2. Configurar Variables de Entorno

```bash
# Copiar el template de producción
cp .env.production.example .env.production

# Editar y configurar TODAS las variables
nano .env.production  # o usa tu editor preferido
```

**IMPORTANTE:** Configura estos valores críticos:
- `SECRET_KEY`: Usa la clave generada en el paso 1
- `POSTGRES_PASSWORD`: Contraseña fuerte para PostgreSQL
- `ALLOWED_ORIGINS`: Dominios permitidos (ej: `https://vexus.com,https://www.vexus.com`)
- `SMTP_*`: Credenciales de email si vas a usar notificaciones

### 3. Configurar Frontend para Producción

Edita [frontend/Static/js/config.prod.js](frontend/Static/js/config.prod.js) y asegúrate de que `API_BASE_URL` apunte a tu dominio de producción.

Si usas un proxy inverso (Nginx), puedes dejarlo como está para usar rutas relativas.

---

## Deployment con Docker (Recomendado)

### Prerequisitos
- Docker 20.10+
- Docker Compose 2.0+

### 1. Iniciar la Aplicación

```bash
# Usando el archivo .env.production
docker-compose --env-file .env.production up -d
```

### 2. Verificar que todo está funcionando

```bash
# Ver logs
docker-compose logs -f

# Verificar health checks
docker ps

# Probar la API
curl http://localhost:8000/health

# Probar el frontend
curl http://localhost
```

### 3. Inicializar Base de Datos

La base de datos se inicializa automáticamente con el archivo `vexus_db.sql` al crear el contenedor.

Si necesitas reinicializar:

```bash
# Detener y eliminar contenedores
docker-compose down

# Eliminar el volumen de datos
docker volume rm vexus-postgres-data

# Volver a iniciar
docker-compose --env-file .env.production up -d
```

### 4. Comandos Útiles

```bash
# Ver logs del backend
docker-compose logs -f backend

# Ver logs de la base de datos
docker-compose logs -f db

# Reiniciar un servicio específico
docker-compose restart backend

# Detener todo
docker-compose down

# Detener y eliminar volúmenes
docker-compose down -v
```

---

## Deployment Manual

### Backend

#### 1. Instalar Python 3.12+

```bash
python --version  # Verificar versión
```

#### 2. Crear entorno virtual e instalar dependencias

```bash
cd backend
python -m venv venv
source venv/bin/activate  # En Windows: venv\Scripts\activate
pip install -r requirements.txt
```

#### 3. Configurar variables de entorno

```bash
cp .env.example .env
# Editar .env con las configuraciones de producción
```

#### 4. Ejecutar con Gunicorn

```bash
gunicorn app.main:app \
  --workers 4 \
  --worker-class uvicorn.workers.UvicornWorker \
  --bind 0.0.0.0:8000 \
  --timeout 120 \
  --access-logfile - \
  --error-logfile - \
  --log-level info
```

### Frontend

#### Opción 1: Nginx (Recomendado)

```bash
# Copiar archivos al directorio de nginx
sudo cp -r frontend/* /var/www/vexus/

# Copiar configuración de nginx
sudo cp frontend/nginx.conf /etc/nginx/sites-available/vexus

# Habilitar el sitio
sudo ln -s /etc/nginx/sites-available/vexus /etc/nginx/sites-enabled/

# Probar configuración
sudo nginx -t

# Reiniciar nginx
sudo systemctl restart nginx
```

#### Opción 2: Servidor estático simple

```bash
cd frontend
python -m http.server 8080
```

---

## Configuración de Servidor

### Nginx como Proxy Inverso (Recomendado)

Crea `/etc/nginx/sites-available/vexus`:

```nginx
# Redirigir HTTP a HTTPS
server {
    listen 80;
    server_name tu-dominio.com www.tu-dominio.com;
    return 301 https://$server_name$request_uri;
}

# HTTPS
server {
    listen 443 ssl http2;
    server_name tu-dominio.com www.tu-dominio.com;

    # SSL Certificates (usar Let's Encrypt)
    ssl_certificate /etc/letsencrypt/live/tu-dominio.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/tu-dominio.com/privkey.pem;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;

    # Security headers
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;

    # Frontend (archivos estáticos)
    location / {
        root /var/www/vexus;
        try_files $uri $uri/ /index.html;

        # Cache para archivos estáticos
        location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ {
            expires 1y;
            add_header Cache-Control "public, immutable";
        }
    }

    # Backend API
    location /api/ {
        proxy_pass http://localhost:8000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    # Health check endpoint
    location /health {
        proxy_pass http://localhost:8000/health;
        access_log off;
    }
}
```

### Configurar SSL con Let's Encrypt

```bash
# Instalar certbot
sudo apt install certbot python3-certbot-nginx

# Obtener certificado
sudo certbot --nginx -d tu-dominio.com -d www.tu-dominio.com

# Auto-renovación (ya configurado por certbot)
sudo certbot renew --dry-run
```

---

## Seguridad

### Checklist de Seguridad

- [ ] **SECRET_KEY** generada aleatoriamente y segura (mínimo 32 caracteres)
- [ ] **DEBUG=False** en producción
- [ ] **ALLOWED_ORIGINS** configurado con dominios específicos (no usar `*`)
- [ ] **HTTPS/SSL** configurado con certificados válidos
- [ ] **Firewall** configurado (solo puertos 80, 443, y 22 abiertos)
- [ ] **PostgreSQL** con contraseña fuerte
- [ ] **Backups** automatizados de la base de datos
- [ ] **Rate limiting** configurado (Nginx o a nivel de aplicación)
- [ ] Archivos **.env** NO están en el repositorio git
- [ ] **Logs** configurados y monitoreados
- [ ] **Updates** del sistema operativo aplicados

### Configurar Firewall (UFW)

```bash
# Habilitar UFW
sudo ufw enable

# Permitir SSH
sudo ufw allow 22

# Permitir HTTP y HTTPS
sudo ufw allow 80
sudo ufw allow 443

# Ver status
sudo ufw status
```

### Backups de Base de Datos

```bash
# Backup manual
docker exec vexus-db pg_dump -U postgres vexus_db > backup_$(date +%Y%m%d_%H%M%S).sql

# Script de backup automático (crontab -e)
0 2 * * * /usr/local/bin/backup-vexus-db.sh
```

Crear `/usr/local/bin/backup-vexus-db.sh`:

```bash
#!/bin/bash
BACKUP_DIR="/var/backups/vexus"
mkdir -p $BACKUP_DIR
docker exec vexus-db pg_dump -U postgres vexus_db | gzip > $BACKUP_DIR/backup_$(date +\%Y\%m\%d_\%H\%M\%S).sql.gz

# Mantener solo últimos 7 días
find $BACKUP_DIR -name "backup_*.sql.gz" -mtime +7 -delete
```

---

## Monitoreo y Mantenimiento

### Health Checks

```bash
# API Health
curl https://tu-dominio.com/health

# Respuesta esperada:
# {
#   "status": "healthy",
#   "database": "connected",
#   "timestamp": "..."
# }
```

### Logs

```bash
# Logs del backend (Docker)
docker-compose logs -f backend

# Logs de Nginx
sudo tail -f /var/log/nginx/access.log
sudo tail -f /var/log/nginx/error.log

# Logs del sistema
sudo journalctl -u nginx -f
```

### Actualizar la Aplicación

```bash
# 1. Hacer pull del código actualizado
git pull origin main

# 2. Reconstruir contenedores
docker-compose --env-file .env.production build

# 3. Reiniciar servicios
docker-compose --env-file .env.production up -d

# 4. Verificar que todo funciona
docker-compose ps
curl https://tu-dominio.com/health
```

### Escalamiento

Para manejar más tráfico, ajusta el número de workers en [docker-compose.yml](docker-compose.yml):

```yaml
backend:
  environment:
    - WORKERS=8  # Ajusta según CPU disponible
```

O en deployment manual:

```bash
gunicorn app.main:app --workers 8 --worker-class uvicorn.workers.UvicornWorker ...
```

**Regla general**: `workers = (2 x CPU_cores) + 1`

---

## Solución de Problemas

### Base de datos no conecta

```bash
# Verificar que el contenedor está corriendo
docker ps | grep vexus-db

# Ver logs de la base de datos
docker-compose logs db

# Verificar conexión manual
docker exec -it vexus-db psql -U postgres -d vexus_db
```

### Backend no responde

```bash
# Ver logs
docker-compose logs backend

# Verificar variables de entorno
docker exec vexus-backend env | grep DATABASE_URL

# Reiniciar backend
docker-compose restart backend
```

### CORS errors en el frontend

Verificar que `ALLOWED_ORIGINS` en `.env.production` incluye tu dominio:

```bash
ALLOWED_ORIGINS=https://tu-dominio.com,https://www.tu-dominio.com
```

---

## Contacto y Soporte

Para reportar problemas o sugerencias, contacta al equipo de desarrollo.

---

**Última actualización:** 2025-10-25
