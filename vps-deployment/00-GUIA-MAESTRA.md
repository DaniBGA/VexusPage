# 🚀 GUÍA MAESTRA DE MIGRACIÓN A VPS - VEXUS

**Fecha de creación:** 2025-11-10
**Versión:** 1.0
**Proyecto:** VexusPage (FastAPI + PostgreSQL)

---

## 📋 ÍNDICE

1. [Información de la VPS](#1-información-de-la-vps)
2. [Preparativos Previos](#2-preparativos-previos)
3. [Orden de Ejecución](#3-orden-de-ejecución)
4. [Verificación Post-Deployment](#4-verificación-post-deployment)
5. [Troubleshooting](#5-troubleshooting)
6. [Mantenimiento Continuo](#6-mantenimiento-continuo)

---

## 1. INFORMACIÓN DE LA VPS

### Especificaciones Solicitadas a Neatech:
```
RAM: 4 GB
CPU: 2 vCores (2.4 GHz+)
Almacenamiento: 50 GB SSD
Red: 1 Gbps
SO: Ubuntu 22.04 LTS (64-bit)
```

### Información que Neatech te debe proveer:
```
[ ] Dirección IP de la VPS: ___________________
[ ] Usuario root o sudo: _____________________
[ ] Contraseña inicial: ______________________
[ ] Panel de control (si existe): ____________
[ ] Nameservers (si proveen DNS): ____________
```

---

## 2. PREPARATIVOS PREVIOS

### 2.1 Desde tu máquina local

#### A. Preparar credenciales y configuración

**Crea un archivo local con tus datos (NO lo subas a Git):**

```bash
# En tu máquina local, crea: vps-deployment/CREDENCIALES.txt
```

Contenido:
```
=== CREDENCIALES PRODUCCIÓN ===

[VPS]
IP:
Usuario:
Contraseña:

[BASE DE DATOS]
POSTGRES_USER: vexus_admin
POSTGRES_PASSWORD: [GENERAR_CONTRASEÑA_SEGURA]
POSTGRES_DB: vexus_db

[APLICACIÓN]
SECRET_KEY: [GENERAR_SECRET_KEY]
SMTP_USER: tu-email@gmail.com
SMTP_PASSWORD: [APP_PASSWORD_DE_GMAIL]
EMAIL_FROM: noreply@grupovexus.com

[SENDGRID]
SENDGRID_API_KEY: [TU_API_KEY]

[DOMINIO]
Dominio principal: grupovexus.com
Subdominio API: api.grupovexus.com (opcional)
```

#### B. Generar credenciales seguras

```bash
# Secret Key para FastAPI (ejecuta en tu terminal local)
python -c "import secrets; print(secrets.token_urlsafe(32))"

# Password para PostgreSQL (ejecuta en tu terminal local)
python -c "import secrets; print(secrets.token_urlsafe(24))"
```

#### C. Preparar archivos de deployment

```bash
# Asegúrate de que todos estos archivos están listos:
cd vps-deployment

ls -la
# Deberías ver:
# 00-GUIA-MAESTRA.md (este archivo)
# 01-install-system.sh
# 02-setup-database.sh
# 03-deploy-backend.sh
# 04-deploy-frontend.sh
# 05-nginx-config.conf
# 06-vexus-api.service
# 07-backup-script.sh
# 08-production.env.example
# 09-post-deployment-checklist.md
```

### 2.2 Configurar tu dominio (grupovexus.com)

#### En tu proveedor de dominio (ej: GoDaddy, Namecheap, etc.):

```
Tipo    Nombre          Valor                TTL
A       @               [IP_DE_TU_VPS]       600
A       www             [IP_DE_TU_VPS]       600
A       api             [IP_DE_TU_VPS]       600 (opcional)
```

**⏳ Nota:** Los cambios DNS pueden tardar 5-60 minutos en propagarse.

---

## 3. ORDEN DE EJECUCIÓN

### 🔴 IMPORTANTE: Ejecuta los pasos EN ORDEN

### Fase 1: Conexión Inicial (5 minutos)

#### Paso 1.1: Conectarse a la VPS

```bash
# Desde tu terminal local
ssh root@[IP_DE_TU_VPS]
# O si te dieron un usuario específico:
ssh [USUARIO]@[IP_DE_TU_VPS]
```

#### Paso 1.2: Actualizar el sistema

```bash
sudo apt update && sudo apt upgrade -y
```

---

### Fase 2: Instalación del Sistema (15-20 minutos)

#### Paso 2.1: Transferir scripts a la VPS

**Opción A - Desde tu máquina local:**
```bash
# Comprime los archivos
cd VexusPage
tar -czf vps-deployment.tar.gz vps-deployment/

# Transfiere a la VPS
scp vps-deployment.tar.gz root@[IP_VPS]:/root/

# En la VPS, descomprime
ssh root@[IP_VPS]
cd /root
tar -xzf vps-deployment.tar.gz
cd vps-deployment
```

**Opción B - Clonar desde Git (si el repo es privado, necesitas configurar SSH keys):**
```bash
# EN LA VPS
cd /root
git clone https://github.com/[TU_USUARIO]/VexusPage.git
cd VexusPage/vps-deployment
```

#### Paso 2.2: Ejecutar instalación del sistema

```bash
# Hacer ejecutable el script
chmod +x 01-install-system.sh

# Ejecutar (toma 10-15 minutos)
sudo ./01-install-system.sh

# Si hay errores, revisa:
cat /var/log/vexus-install.log
```

**✅ Verificación:**
```bash
python3.12 --version  # Debe mostrar Python 3.12.x
psql --version        # Debe mostrar PostgreSQL 15.x o 16.x
nginx -v              # Debe mostrar nginx version
systemctl status nginx  # Debe estar "active (running)"
```

---

### Fase 3: Configuración de Base de Datos (10 minutos)

#### Paso 3.1: Preparar configuración

```bash
# Edita el script con tus credenciales
nano 02-setup-database.sh

# Busca estas líneas y reemplaza con tus valores:
DB_NAME="vexus_db"
DB_USER="vexus_admin"
DB_PASSWORD="TU_PASSWORD_SEGURA_AQUI"
```

#### Paso 3.2: Ejecutar setup de base de datos

```bash
chmod +x 02-setup-database.sh
sudo ./02-setup-database.sh
```

**✅ Verificación:**
```bash
# Conectar a PostgreSQL
sudo -u postgres psql -d vexus_db -c "\dt"

# Deberías ver las tablas: users, user_sessions, courses, etc.
```

---

### Fase 4: Deployment del Backend (15 minutos)

#### Paso 4.1: Preparar archivo de entorno

```bash
# Copia el ejemplo y edítalo
cp 08-production.env.example /var/www/vexus-api/.env

# Edita con tus credenciales reales
nano /var/www/vexus-api/.env
```

**Completa TODOS los valores:**
```env
DATABASE_URL=postgresql://vexus_admin:TU_PASSWORD@localhost:5432/vexus_db
SECRET_KEY=tu-secret-key-generado
SMTP_USER=tu-email@gmail.com
SMTP_PASSWORD=tu-app-password
SENDGRID_API_KEY=tu-sendgrid-key
```

#### Paso 4.2: Ejecutar deployment

```bash
chmod +x 03-deploy-backend.sh
sudo ./03-deploy-backend.sh
```

**✅ Verificación:**
```bash
# Verificar que el servicio está corriendo
systemctl status vexus-api

# Debe mostrar: "active (running)"

# Verificar logs
journalctl -u vexus-api -n 50

# Verificar que responde
curl http://localhost:8000/health

# Debe responder: {"status":"healthy","database":"connected"}
```

---

### Fase 5: Deployment del Frontend (10 minutos)

#### Paso 5.1: Transferir archivos del frontend

```bash
# DESDE TU MÁQUINA LOCAL:
cd VexusPage/frontend
tar -czf frontend.tar.gz *

scp frontend.tar.gz root@[IP_VPS]:/tmp/

# EN LA VPS:
sudo mkdir -p /var/www/vexus-frontend
cd /var/www/vexus-frontend
sudo tar -xzf /tmp/frontend.tar.gz
sudo chown -R www-data:www-data /var/www/vexus-frontend
```

#### Paso 5.2: Actualizar URLs de API en el frontend

```bash
# Verificar que todos los archivos apunten a la URL correcta
cd /var/www/vexus-frontend

# Buscar hardcoded URLs
grep -r "localhost:8000" .
grep -r "vexus-api.onrender.com" .

# Reemplazar con tu dominio (si es necesario)
sudo find . -type f -name "*.js" -exec sed -i 's|http://localhost:8000|https://grupovexus.com|g' {} +
sudo find . -type f -name "*.html" -exec sed -i 's|http://localhost:8000|https://grupovexus.com|g' {} +
```

---

### Fase 6: Configuración de Nginx y SSL (15 minutos)

#### Paso 6.1: Configurar Nginx

```bash
# Copiar configuración
sudo cp 05-nginx-config.conf /etc/nginx/sites-available/vexus

# Editar con tu dominio
sudo nano /etc/nginx/sites-available/vexus

# Busca y reemplaza:
# server_name grupovexus.com www.grupovexus.com;

# Habilitar el sitio
sudo ln -s /etc/nginx/sites-available/vexus /etc/nginx/sites-enabled/

# Deshabilitar sitio default
sudo rm /etc/nginx/sites-enabled/default

# Verificar configuración
sudo nginx -t

# Si dice "syntax is ok", recargar
sudo systemctl reload nginx
```

#### Paso 6.2: Instalar SSL con Certbot

```bash
# Instalar Certbot
sudo apt install certbot python3-certbot-nginx -y

# Obtener certificado SSL (reemplaza con tu email y dominio)
sudo certbot --nginx -d grupovexus.com -d www.grupovexus.com \
  --email tu-email@ejemplo.com \
  --agree-tos \
  --no-eff-email \
  --redirect

# Verificar renovación automática
sudo certbot renew --dry-run
```

**✅ Verificación:**
```bash
# Verificar que Nginx está corriendo con SSL
systemctl status nginx

# Probar el sitio
curl -I https://grupovexus.com

# Debe responder con "200 OK" y "HTTP/2"
```

---

### Fase 7: Configuración de Backups (10 minutos)

#### Paso 7.1: Configurar script de backup

```bash
# Copiar script de backup
sudo cp 07-backup-script.sh /usr/local/bin/vexus-backup.sh

# Hacer ejecutable
sudo chmod +x /usr/local/bin/vexus-backup.sh

# Editar con tus credenciales
sudo nano /usr/local/bin/vexus-backup.sh

# Actualizar:
DB_NAME="vexus_db"
DB_USER="vexus_admin"
DB_PASSWORD="TU_PASSWORD"
```

#### Paso 7.2: Configurar cron para backups automáticos

```bash
# Editar crontab
sudo crontab -e

# Agregar al final (backup diario a las 3 AM):
0 3 * * * /usr/local/bin/vexus-backup.sh >> /var/log/vexus-backup.log 2>&1

# Agregar limpieza de logs antiguos (mensual)
0 4 1 * * find /var/backups/vexus -name "*.tar.gz" -mtime +30 -delete
```

**✅ Verificación:**
```bash
# Ejecutar backup manualmente
sudo /usr/local/bin/vexus-backup.sh

# Verificar que se creó
ls -lh /var/backups/vexus/

# Verificar que cron está configurado
sudo crontab -l
```

---

## 4. VERIFICACIÓN POST-DEPLOYMENT

### Checklist Completo

Abre y completa: `09-post-deployment-checklist.md`

### Tests Rápidos

```bash
# 1. Backend Health Check
curl https://grupovexus.com/api/v1/health

# 2. CORS Check
curl -H "Origin: https://grupovexus.com" \
  -H "Access-Control-Request-Method: POST" \
  -H "Access-Control-Request-Headers: Content-Type" \
  -X OPTIONS \
  https://grupovexus.com/api/v1/auth/register

# 3. Frontend accesible
curl -I https://grupovexus.com

# 4. SSL válido
curl -vI https://grupovexus.com 2>&1 | grep -i "SSL certificate verify"
```

### Tests Funcionales desde el Frontend

1. **Abrir:** https://grupovexus.com
2. **Probar registro:** Crear una cuenta nueva
3. **Probar login:** Iniciar sesión
4. **Probar funcionalidad:** Navegar por el sitio
5. **Verificar email:** Revisar si llegó el email de verificación

---

## 5. TROUBLESHOOTING

### Problema 1: Backend no inicia

```bash
# Ver logs detallados
journalctl -u vexus-api -n 100 --no-pager

# Verificar archivo .env
cat /var/www/vexus-api/.env

# Probar manualmente
cd /var/www/vexus-api
source venv/bin/activate
uvicorn app.main:app --host 0.0.0.0 --port 8000

# Ver errores en tiempo real
```

### Problema 2: Nginx 502 Bad Gateway

```bash
# Verificar que el backend está corriendo
systemctl status vexus-api

# Verificar que escucha en el puerto correcto
sudo netstat -tlnp | grep 8000

# Verificar permisos de socket
ls -l /var/www/vexus-api/

# Ver logs de Nginx
tail -f /var/log/nginx/error.log
```

### Problema 3: Database connection refused

```bash
# Verificar PostgreSQL
systemctl status postgresql

# Verificar que acepta conexiones
sudo -u postgres psql -c "SELECT 1"

# Verificar credenciales en .env
grep DATABASE_URL /var/www/vexus-api/.env

# Verificar conexión manual
psql postgresql://vexus_admin:PASSWORD@localhost:5432/vexus_db
```

### Problema 4: CORS errors en el navegador

```bash
# Verificar configuración CORS
curl https://grupovexus.com/api/v1/debug/cors

# Verificar Nginx permite headers CORS
sudo nano /etc/nginx/sites-available/vexus

# Debe tener:
# proxy_set_header Origin $http_origin;
# add_header Access-Control-Allow-Origin $http_origin always;
```

### Problema 5: SSL certificate errors

```bash
# Verificar certificados
sudo certbot certificates

# Renovar manualmente
sudo certbot renew --force-renewal

# Verificar Nginx
sudo nginx -t
sudo systemctl reload nginx
```

---

## 6. MANTENIMIENTO CONTINUO

### Tareas Diarias (Automatizadas)

```bash
# Backups automáticos (ya configurado en cron)
# Limpieza de logs (configurado)
# Monitoreo de servicios (opcional: configurar con systemd)
```

### Tareas Semanales (Manual)

```bash
# Revisar logs de errores
sudo journalctl -u vexus-api --since "7 days ago" | grep ERROR

# Revisar espacio en disco
df -h

# Revisar uso de memoria
free -h

# Revisar procesos
top
```

### Tareas Mensuales

```bash
# Actualizar sistema
sudo apt update && sudo apt upgrade -y

# Revisar backups antiguos
ls -lh /var/backups/vexus/

# Revisar certificados SSL
sudo certbot certificates

# Revisar logs de acceso
sudo goaccess /var/log/nginx/access.log  # (opcional)
```

### Actualizaciones de Código

```bash
# Para actualizar el backend:
cd /var/www/vexus-api
git pull origin main
source venv/bin/activate
pip install -r requirements.txt
sudo systemctl restart vexus-api

# Para actualizar el frontend:
cd /var/www/vexus-frontend
# Subir archivos nuevos por FTP/SCP
sudo chown -R www-data:www-data .
```

---

## 📞 CONTACTOS DE SOPORTE

```
Neatech: [Agregar número/email de soporte]
Tu email: [Tu email]
Repositorio: https://github.com/[usuario]/VexusPage
```

---

## 📚 RECURSOS ADICIONALES

- [Documentación FastAPI](https://fastapi.tiangolo.com/)
- [Nginx Docs](https://nginx.org/en/docs/)
- [PostgreSQL Docs](https://www.postgresql.org/docs/)
- [Certbot Docs](https://certbot.eff.org/)

---

**✅ GUÍA COMPLETADA**

Una vez que hayas ejecutado todos los pasos, tu aplicación debería estar corriendo en:

- **Frontend:** https://grupovexus.com
- **Backend API:** https://grupovexus.com/api/v1
- **Docs:** https://grupovexus.com/docs
- **Health:** https://grupovexus.com/health

**¡Éxito en tu deployment!**
