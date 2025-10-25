# 🚀 PRODUCCIÓN - Vexus Platform

Esta carpeta contiene TODO lo necesario para **DEPLOYMENT A PRODUCCIÓN**.

## ⚠️ IMPORTANTE - Antes de Empezar

**NUNCA uses archivos de desarrollo en producción.**

Checklist pre-deployment:
- [ ] Has terminado de desarrollar y testeado en `develop` branch
- [ ] El código está en `main` branch
- [ ] Tienes un servidor/VPS con Ubuntu/Debian
- [ ] Tienes un dominio apuntando a tu servidor
- [ ] Has leído esta guía completa

---

## 🚀 Deploy Rápido (Servidor Nuevo)

### 1. Preparar Servidor

```bash
# Conectar a tu servidor
ssh usuario@tu-servidor.com

# Actualizar sistema
sudo apt update && sudo apt upgrade -y

# Instalar Docker y Docker Compose
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER

# Instalar Docker Compose
sudo apt install docker-compose-plugin -y

# Verificar instalación
docker --version
docker compose version
```

### 2. Clonar Repositorio

```bash
# Clonar proyecto
git clone https://github.com/tu-usuario/VexusPage.git
cd VexusPage

# Cambiar a branch main
git checkout main
```

### 3. Configurar Variables de Entorno

```bash
# Copiar template
cp deployment/production/.env.production.example .env.production

# Generar SECRET_KEY
python3 generate_secret_key.py

# Editar .env.production con valores REALES
nano .env.production
```

**IMPORTANTE:** Configura TODOS estos valores:

```bash
# Base de datos
POSTGRES_PASSWORD=UNA_CONTRASEÑA_MUY_SEGURA_Y_LARGA

# Seguridad (usa la clave generada en paso anterior)
SECRET_KEY=LA_CLAVE_SUPER_SEGURA_QUE_GENERASTE

# CORS (tu dominio real)
ALLOWED_ORIGINS=https://tu-dominio.com,https://www.tu-dominio.com

# Ambiente
ENVIRONMENT=production
DEBUG=False
```

### 4. Iniciar Aplicación

```bash
# Desde la raíz del proyecto
docker compose -f deployment/production/docker-compose.yml --env-file .env.production up -d
```

### 5. Verificar que Funciona

```bash
# Ver logs
docker compose -f deployment/production/docker-compose.yml logs -f

# Verificar health
curl http://localhost:8000/health

# Ver contenedores
docker ps
```

### 6. Configurar Nginx y SSL

Ver sección [Nginx + SSL](#nginx--ssl) más abajo.

---

## 📁 Archivos en esta Carpeta

### `docker-compose.yml`
Configuración optimizada para producción:
- ✅ Gunicorn con múltiples workers
- ✅ Health checks configurados
- ✅ Restart automático
- ✅ Variables de entorno desde archivo `.env.production`
- ✅ Sin Adminer ni herramientas de desarrollo

### `.env.production.example`
Template de variables de entorno.
**COPIAR a `.env.production` y configurar con valores reales.**

---

## 🔒 Seguridad

### 1. Generar SECRET_KEY Segura

```bash
# Desde la raíz del proyecto
python3 generate_secret_key.py
```

Copia la clave generada y pégala en `.env.production`.

### 2. Configurar Firewall

```bash
# Habilitar UFW
sudo ufw enable

# Permitir SSH (IMPORTANTE: antes de habilitar firewall)
sudo ufw allow 22

# Permitir HTTP y HTTPS
sudo ufw allow 80
sudo ufw allow 443

# Ver status
sudo ufw status
```

### 3. Configurar SSL/HTTPS

**Obligatorio para producción.**

```bash
# Instalar Certbot
sudo apt install certbot python3-certbot-nginx -y

# Obtener certificado
sudo certbot --nginx -d tu-dominio.com -d www.tu-dominio.com

# Verificar auto-renovación
sudo certbot renew --dry-run
```

---

## 🌐 Nginx + SSL

### Instalar Nginx

```bash
sudo apt install nginx -y
```

### Configurar como Proxy Inverso

Crear archivo `/etc/nginx/sites-available/vexus`:

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

    # SSL (Let's Encrypt)
    ssl_certificate /etc/letsencrypt/live/tu-dominio.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/tu-dominio.com/privkey.pem;
    ssl_protocols TLSv1.2 TLSv1.3;

    # Security headers
    add_header Strict-Transport-Security "max-age=31536000" always;
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;

    # Frontend
    location / {
        proxy_pass http://localhost:80;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    # Backend API
    location /api/ {
        proxy_pass http://localhost:8000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    # Health check
    location /health {
        proxy_pass http://localhost:8000/health;
        access_log off;
    }
}
```

### Habilitar y Reiniciar

```bash
# Habilitar sitio
sudo ln -s /etc/nginx/sites-available/vexus /etc/nginx/sites-enabled/

# Probar configuración
sudo nginx -t

# Reiniciar Nginx
sudo systemctl restart nginx
```

---

## 🔄 Actualizar Aplicación

Cuando haces cambios en el código:

```bash
# 1. SSH a tu servidor
ssh usuario@tu-servidor.com
cd VexusPage

# 2. Pull últimos cambios
git pull origin main

# 3. Rebuild y reiniciar
docker compose -f deployment/production/docker-compose.yml --env-file .env.production up -d --build

# 4. Verificar
docker compose -f deployment/production/docker-compose.yml logs -f
curl https://tu-dominio.com/health
```

---

## 💾 Backups

### Backup Manual

```bash
# Crear carpeta de backups
mkdir -p ~/backups

# Backup de base de datos
docker exec vexus-db pg_dump -U postgres vexus_db | gzip > ~/backups/backup_$(date +%Y%m%d_%H%M%S).sql.gz
```

### Backup Automático (Cron)

```bash
# Crear script de backup
sudo nano /usr/local/bin/backup-vexus.sh
```

Contenido del script:

```bash
#!/bin/bash
BACKUP_DIR="/var/backups/vexus"
mkdir -p $BACKUP_DIR

# Backup de DB
docker exec vexus-db pg_dump -U postgres vexus_db | gzip > $BACKUP_DIR/backup_$(date +%Y%m%d_%H%M%S).sql.gz

# Mantener solo últimos 7 días
find $BACKUP_DIR -name "backup_*.sql.gz" -mtime +7 -delete

echo "Backup completado: $(date)"
```

Hacer ejecutable y programar:

```bash
# Hacer ejecutable
sudo chmod +x /usr/local/bin/backup-vexus.sh

# Programar en cron (cada día a las 2 AM)
sudo crontab -e

# Agregar línea:
0 2 * * * /usr/local/bin/backup-vexus.sh >> /var/log/vexus-backup.log 2>&1
```

### Restaurar Backup

```bash
# Descomprimir y restaurar
gunzip -c backup_20250125_020000.sql.gz | docker exec -i vexus-db psql -U postgres vexus_db
```

---

## 📊 Monitoreo

### Ver Logs

```bash
# Todos los servicios
docker compose -f deployment/production/docker-compose.yml logs -f

# Solo backend
docker compose -f deployment/production/docker-compose.yml logs -f backend

# Solo DB
docker compose -f deployment/production/docker-compose.yml logs -f db

# Últimas 100 líneas
docker compose -f deployment/production/docker-compose.yml logs --tail=100 backend
```

### Health Check

```bash
# Verificar estado
curl https://tu-dominio.com/health

# Debe devolver:
# {"status": "healthy", "database": "connected", "timestamp": "..."}
```

### Ver Recursos

```bash
# CPU, RAM, etc de contenedores
docker stats

# Espacio en disco
df -h
docker system df
```

---

## 🔧 Comandos Útiles

### Docker Compose (Producción)

```bash
# Alias útil (agregar a ~/.bashrc)
alias dc-prod='docker compose -f deployment/production/docker-compose.yml --env-file .env.production'

# Luego puedes usar:
dc-prod up -d
dc-prod logs -f
dc-prod restart backend
dc-prod down
```

### Reiniciar Servicios

```bash
# Reiniciar todo
docker compose -f deployment/production/docker-compose.yml restart

# Reiniciar solo backend
docker compose -f deployment/production/docker-compose.yml restart backend
```

### Conectar a Base de Datos

```bash
docker exec -it vexus-db psql -U postgres vexus_db
```

---

## 🆘 Troubleshooting

### Aplicación No Responde

```bash
# 1. Ver logs
docker compose -f deployment/production/docker-compose.yml logs backend

# 2. Verificar contenedores
docker ps

# 3. Reiniciar
docker compose -f deployment/production/docker-compose.yml restart backend
```

### Base de Datos No Conecta

```bash
# Ver logs de DB
docker compose -f deployment/production/docker-compose.yml logs db

# Verificar que está corriendo
docker ps | grep vexus-db

# Reiniciar DB (CUIDADO: puede causar downtime)
docker compose -f deployment/production/docker-compose.yml restart db
```

### Error CORS

Verificar en `.env.production`:

```bash
# Debe incluir TU dominio (sin espacio después de la coma)
ALLOWED_ORIGINS=https://tu-dominio.com,https://www.tu-dominio.com
```

### SSL No Funciona

```bash
# Verificar certificados
sudo certbot certificates

# Renovar manualmente
sudo certbot renew

# Verificar Nginx
sudo nginx -t
sudo systemctl status nginx
```

---

## 📋 Checklist de Seguridad

Antes de ir a producción, verifica:

- [ ] `DEBUG=False` en `.env.production`
- [ ] `SECRET_KEY` generada aleatoriamente (64+ caracteres)
- [ ] `POSTGRES_PASSWORD` es fuerte (16+ caracteres)
- [ ] `ALLOWED_ORIGINS` especifica TU dominio (no `*`)
- [ ] Firewall configurado (solo puertos 22, 80, 443)
- [ ] SSL/HTTPS configurado y funcionando
- [ ] Backups automáticos configurados
- [ ] `.env.production` NO está en el repositorio git
- [ ] Monitoreo de logs configurado
- [ ] Has probado restaurar un backup

Ver checklist completo en `docs/guides/SECURITY_CHECKLIST.md`

---

## 📈 Escalamiento

Si necesitas manejar más tráfico:

### Aumentar Workers del Backend

Edita `deployment/production/docker-compose.yml`:

```yaml
backend:
  command: ["gunicorn", "app.main:app",
    "--workers", "8",  # Aumentar número de workers
    ...]
```

Regla general: `workers = (2 × CPU_cores) + 1`

### Usar Base de Datos Externa

Para mejor performance, usa PostgreSQL administrado (AWS RDS, DigitalOcean, etc):

```bash
# En .env.production
DATABASE_URL=postgresql://user:pass@db-servidor.com:5432/vexus_db
```

Luego elimina el servicio `db` de `docker-compose.yml`.

---

## 📞 Soporte

Ver documentación completa:
- `docs/guides/DEPLOYMENT.md` - Deployment detallado
- `docs/guides/SECURITY_CHECKLIST.md` - Seguridad completa

---

**Producción - Usar solo código estable de `main` branch**
