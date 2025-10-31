# 🚀 DEPLOYMENT PARA GRUPOVEXUS.COM

## ✅ Ya tienes configurado:
- ✅ Dominio: `grupovexus.com`
- ✅ Servidor preparado
- ✅ Archivo `.env.production` creado con valores correctos

---

## 📋 PASOS PARA DEPLOYMENT

### 1. 🔐 Verificar que .env.production NO esté en Git

```bash
# En tu computadora local:
git status

# Si ves .env.production, DEBES agregarlo a .gitignore
# Ya debería estar en .gitignore, pero verifica
```

**IMPORTANTE:** El archivo `.env.production` debe estar en tu servidor, NO en Git.

---

### 2. 📤 Subir código a GitHub (si no lo has hecho)

```bash
# En tu computadora local:
git add .
git commit -m "Preparar para producción - grupovexus.com"
git push origin main
```

**NOTA:** Asegúrate de que `.env.production` NO se suba (debe estar en .gitignore)

---

### 3. 🖥️ Conectar a tu servidor

```bash
ssh tu-usuario@grupovexus.com
# O la IP de tu servidor
```

---

### 4. 📦 Instalar Docker en el servidor

```bash
# Actualizar sistema
sudo apt update && sudo apt upgrade -y

# Instalar Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Agregar tu usuario al grupo docker
sudo usermod -aG docker $USER

# Instalar Docker Compose
sudo apt install docker-compose-plugin -y

# Verificar instalación
docker --version
docker compose version

# IMPORTANTE: Salir y volver a entrar para que los cambios tomen efecto
exit
```

```bash
# Volver a conectar
ssh tu-usuario@grupovexus.com
```

---

### 5. 📁 Clonar repositorio en el servidor

```bash
# En el servidor:
cd ~
git clone https://github.com/tu-usuario/VexusPage.git
cd VexusPage
git checkout main
```

**Reemplaza `tu-usuario` con tu usuario de GitHub**

---

### 6. 📝 Subir archivo .env.production al servidor

Desde tu computadora local, copia el archivo al servidor:

```bash
# En tu computadora local:
scp .env.production tu-usuario@grupovexus.com:~/VexusPage/.env.production
```

**O** puedes crear el archivo directamente en el servidor:

```bash
# En el servidor:
cd ~/VexusPage
nano .env.production
# Pegar el contenido del archivo .env.production
# Ctrl+O para guardar, Ctrl+X para salir
```

---

### 7. 🗄️ Copiar archivo SQL de base de datos

Si tienes el archivo `vexus_db.sql`, debes copiarlo:

```bash
# Desde tu computadora local:
scp backend/vexus_db.sql tu-usuario@grupovexus.com:~/VexusPage/deployment/production/vexus_db.sql
```

---

### 8. 🚀 Levantar la aplicación

```bash
# En el servidor:
cd ~/VexusPage

# Copiar Dockerfiles a los directorios correctos si es necesario
cp backend/Dockerfile backend/Dockerfile
cp frontend/Dockerfile frontend/Dockerfile

# Levantar servicios
docker compose -f deployment/production/docker-compose.yml --env-file .env.production up -d --build

# Ver logs
docker compose -f deployment/production/docker-compose.yml logs -f
```

**Espera a que todo inicie (puede tardar 1-2 minutos)**

Presiona `Ctrl+C` para salir de los logs (los contenedores seguirán corriendo)

---

### 9. ✅ Verificar que funciona

```bash
# En el servidor:

# Ver contenedores corriendo
docker ps

# Debe mostrar 3 contenedores:
# - vexus-db (PostgreSQL)
# - vexus-backend (FastAPI)
# - vexus-frontend (Nginx)

# Probar health check
curl http://localhost:8000/health

# Debe devolver: {"status":"healthy","database":"connected",...}
```

---

### 10. 🌐 Configurar Nginx como Proxy Reverso

```bash
# En el servidor:

# Instalar Nginx
sudo apt install nginx -y

# Crear configuración
sudo nano /etc/nginx/sites-available/vexus
```

Pegar esta configuración (reemplazar `grupovexus.com` si es necesario):

```nginx
# HTTP - Redirigir a HTTPS
server {
    listen 80;
    server_name grupovexus.com www.grupovexus.com;

    # Permitir Certbot para verificación
    location /.well-known/acme-challenge/ {
        root /var/www/html;
    }

    # Redirigir todo a HTTPS
    location / {
        return 301 https://$server_name$request_uri;
    }
}

# HTTPS
server {
    listen 443 ssl http2;
    server_name grupovexus.com www.grupovexus.com;

    # SSL (se configurará con Certbot)
    ssl_certificate /etc/letsencrypt/live/grupovexus.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/grupovexus.com/privkey.pem;
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

Guardar: `Ctrl+O`, `Enter`, `Ctrl+X`

```bash
# Habilitar sitio
sudo ln -s /etc/nginx/sites-available/vexus /etc/nginx/sites-enabled/

# Eliminar sitio default (opcional)
sudo rm /etc/nginx/sites-enabled/default

# Probar configuración
sudo nginx -t
```

**NOTA:** El test fallará porque aún no tenemos SSL. Continuemos.

---

### 11. 🔒 Configurar SSL con Let's Encrypt

```bash
# En el servidor:

# Instalar Certbot
sudo apt install certbot python3-certbot-nginx -y

# Obtener certificado SSL
sudo certbot --nginx -d grupovexus.com -d www.grupovexus.com

# Seguir las instrucciones:
# - Ingresar email
# - Aceptar términos
# - (Opcional) Compartir email con EFF
```

Certbot configurará automáticamente SSL en Nginx.

```bash
# Verificar renovación automática
sudo certbot renew --dry-run

# Reiniciar Nginx
sudo systemctl restart nginx
```

---

### 12. 🔥 Configurar Firewall

```bash
# En el servidor:

# Habilitar firewall
sudo ufw enable

# IMPORTANTE: Permitir SSH primero
sudo ufw allow 22

# Permitir HTTP y HTTPS
sudo ufw allow 80
sudo ufw allow 443

# Ver estado
sudo ufw status

# Debe mostrar:
# 22/tcp    ALLOW
# 80/tcp    ALLOW
# 443/tcp   ALLOW
```

---

### 13. ✅ VERIFICAR QUE TODO FUNCIONA

```bash
# Desde cualquier navegador:
https://grupovexus.com

# Debe cargar tu sitio web

# Probar formulario de contacto
# Debe enviar email a grupovexus@gmail.com

# Verificar health
https://grupovexus.com/health
```

---

## 🎉 ¡LISTO! Tu sitio está en producción

---

## 📊 COMANDOS ÚTILES

### Ver logs
```bash
cd ~/VexusPage
docker compose -f deployment/production/docker-compose.yml logs -f
```

### Reiniciar servicios
```bash
docker compose -f deployment/production/docker-compose.yml restart
```

### Detener todo
```bash
docker compose -f deployment/production/docker-compose.yml down
```

### Ver estado de contenedores
```bash
docker ps
```

### Actualizar aplicación (después de cambios)
```bash
cd ~/VexusPage
git pull origin main
docker compose -f deployment/production/docker-compose.yml up -d --build
```

---

## 💾 BACKUP DE BASE DE DATOS

### Backup manual
```bash
# Crear backup
docker exec vexus-db pg_dump -U postgres vexus_db | gzip > backup_$(date +%Y%m%d).sql.gz

# Ver backups
ls -lh backup_*.sql.gz
```

### Restaurar backup
```bash
gunzip -c backup_20250127.sql.gz | docker exec -i vexus-db psql -U postgres vexus_db
```

---

## 🆘 TROUBLESHOOTING

### Contenedor no inicia
```bash
# Ver logs
docker compose -f deployment/production/docker-compose.yml logs backend

# Ver todos los logs
docker compose -f deployment/production/docker-compose.yml logs
```

### Error de base de datos
```bash
# Verificar que DB esté corriendo
docker ps | grep vexus-db

# Ver logs de DB
docker compose -f deployment/production/docker-compose.yml logs db
```

### Error 502 Bad Gateway
```bash
# Verificar que backend esté corriendo
curl http://localhost:8000/health

# Ver logs de Nginx
sudo tail -f /var/log/nginx/error.log
```

### Renovar SSL manualmente
```bash
sudo certbot renew
sudo systemctl restart nginx
```

---

## 📝 RESUMEN DE ARCHIVOS

### EN TU COMPUTADORA LOCAL:
- `.env` - Para desarrollo local (NO subir a Git)
- `.env.production` - Para producción (NO subir a Git, copiar al servidor)

### EN TU SERVIDOR:
- `.env.production` - Configuración de producción
- `docker-compose.yml` - Configuración de contenedores
- `/etc/nginx/sites-available/vexus` - Configuración de Nginx

---

## ⚠️ IMPORTANTE

1. **NUNCA** subas `.env` o `.env.production` a Git
2. **SIEMPRE** usa HTTPS en producción
3. **CONFIGURA** backups automáticos
4. **MONITOREA** los logs regularmente
5. **ACTUALIZA** el sistema periódicamente:
   ```bash
   sudo apt update && sudo apt upgrade -y
   ```

---

## 📞 SOPORTE

Si tienes problemas:
1. Revisa los logs: `docker compose logs -f`
2. Verifica que todos los contenedores estén corriendo: `docker ps`
3. Verifica el health check: `curl https://grupovexus.com/health`
4. Revisa logs de Nginx: `sudo tail -f /var/log/nginx/error.log`

---

**Tu dominio:** `grupovexus.com`
**Email:** `grupovexus@gmail.com`
**Backend:** FastAPI + PostgreSQL
**Frontend:** HTML/CSS/JS + Nginx
