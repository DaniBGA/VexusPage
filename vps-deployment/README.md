# 🚀 DEPLOYMENT SCRIPTS PARA VPS - VEXUSPAGE

Este directorio contiene todos los scripts y archivos necesarios para desplegar VexusPage en un VPS con Ubuntu 22.04 LTS.

---

## 📁 CONTENIDO DEL DIRECTORIO

```
vps-deployment/
├── 00-GUIA-MAESTRA.md              # ⭐ EMPIEZA AQUÍ - Guía completa paso a paso
├── 01-install-system.sh            # Script de instalación del sistema base
├── 02-setup-database.sh            # Script de configuración de PostgreSQL
├── 03-deploy-backend.sh            # Script de deployment del backend FastAPI
├── 05-nginx-config.conf            # Configuración de Nginx con SSL
├── 07-backup-script.sh             # Script de backup automático
├── 08-production.env.example       # Plantilla de variables de entorno
├── 09-post-deployment-checklist.md # Checklist de verificación post-deployment
└── README.md                       # Este archivo
```

---

## 🎯 INICIO RÁPIDO

### 1. Lee la Guía Maestra PRIMERO

```bash
cat 00-GUIA-MAESTRA.md
```

Esta guía contiene toda la información detallada del proceso.

### 2. Prepara las Credenciales

Antes de comenzar, necesitas:

- ✅ IP de tu VPS
- ✅ Usuario SSH con permisos sudo
- ✅ Dominio apuntando a la VPS (grupovexus.com)
- ✅ Credenciales de email (Gmail App Password o SendGrid)
- ✅ Contraseñas seguras para PostgreSQL

### 3. Ejecuta los Scripts EN ORDEN

```bash
# 1. Conectarse a la VPS
ssh root@TU_IP_VPS

# 2. Copiar estos archivos a la VPS (desde tu máquina local)
# Opción A: SCP
scp -r vps-deployment root@TU_IP_VPS:/root/

# Opción B: Git (si tu repo es privado, configura SSH keys)
# cd /root && git clone https://github.com/TU_USUARIO/VexusPage.git

# 3. En la VPS, ejecutar scripts
cd /root/vps-deployment

# Paso 1: Instalar sistema base (15-20 min)
chmod +x 01-install-system.sh
sudo ./01-install-system.sh

# Paso 2: Configurar base de datos (10 min)
# ⚠️ EDITAR PRIMERO: nano 02-setup-database.sh
chmod +x 02-setup-database.sh
sudo ./02-setup-database.sh

# Paso 3: Desplegar backend (15 min)
# ⚠️ CONFIGURAR: nano /var/www/vexus-api/.env
chmod +x 03-deploy-backend.sh
sudo ./03-deploy-backend.sh

# Paso 4: Copiar frontend
# (Desde tu máquina local)
cd VexusPage/frontend
tar -czf frontend.tar.gz *
scp frontend.tar.gz root@TU_IP_VPS:/tmp/
# (En la VPS)
sudo mkdir -p /var/www/vexus-frontend
cd /var/www/vexus-frontend
sudo tar -xzf /tmp/frontend.tar.gz
sudo chown -R www-data:www-data .

# Paso 5: Configurar Nginx
sudo cp 05-nginx-config.conf /etc/nginx/sites-available/vexus
sudo ln -s /etc/nginx/sites-available/vexus /etc/nginx/sites-enabled/
sudo rm /etc/nginx/sites-enabled/default
sudo nginx -t
sudo systemctl reload nginx

# Paso 6: Instalar SSL
sudo certbot --nginx -d grupovexus.com -d www.grupovexus.com \
  --email tu-email@ejemplo.com --agree-tos --no-eff-email --redirect

# Paso 7: Configurar backups
sudo cp 07-backup-script.sh /usr/local/bin/vexus-backup.sh
sudo chmod +x /usr/local/bin/vexus-backup.sh
# Editar con tus credenciales
sudo nano /usr/local/bin/vexus-backup.sh
# Agregar a cron
(crontab -l 2>/dev/null; echo "0 3 * * * /usr/local/bin/vexus-backup.sh >> /var/log/vexus-backup.log 2>&1") | crontab -

# Paso 8: Verificar todo
sudo /usr/local/bin/vexus-info
curl https://grupovexus.com/health
```

---

## 📋 ORDEN DE EJECUCIÓN DETALLADO

### Fase 1: Preparación (Local)

1. **Lee la documentación completa**
   - `00-GUIA-MAESTRA.md`
   - Este README

2. **Prepara credenciales**
   - Genera SECRET_KEY
   - Obtén Gmail App Password o SendGrid API Key
   - Define contraseña para PostgreSQL

3. **Configura DNS**
   - Apunta grupovexus.com a la IP de tu VPS
   - Espera propagación (5-60 minutos)

### Fase 2: Instalación Base (VPS)

4. **Conectarse a VPS**
   ```bash
   ssh root@TU_IP_VPS
   ```

5. **Copiar archivos de deployment**
   ```bash
   # Opción recomendada: SCP desde local
   scp -r vps-deployment root@TU_IP_VPS:/root/
   ```

6. **Ejecutar instalación del sistema**
   ```bash
   cd /root/vps-deployment
   chmod +x 01-install-system.sh
   sudo ./01-install-system.sh
   ```

   ✅ **Verifica:** Python 3.12, PostgreSQL, Nginx instalados

### Fase 3: Base de Datos (VPS)

7. **Configurar script de DB**
   ```bash
   nano 02-setup-database.sh
   # Cambiar DB_PASSWORD por tu contraseña
   ```

8. **Ejecutar setup de DB**
   ```bash
   chmod +x 02-setup-database.sh
   sudo ./02-setup-database.sh
   ```

   ✅ **Verifica:** Base de datos creada, tablas existentes

### Fase 4: Backend (VPS)

9. **Copiar código del backend**
   ```bash
   # Desde tu máquina local
   cd VexusPage/backend
   tar -czf backend.tar.gz app/ requirements.txt
   scp backend.tar.gz root@TU_IP_VPS:/var/www/vexus-api/

   # En la VPS
   cd /var/www/vexus-api
   tar -xzf backend.tar.gz
   ```

10. **Configurar .env**
    ```bash
    cp /root/vps-deployment/08-production.env.example /var/www/vexus-api/.env
    nano /var/www/vexus-api/.env
    # Completar TODOS los valores
    ```

11. **Ejecutar deployment del backend**
    ```bash
    cd /root/vps-deployment
    chmod +x 03-deploy-backend.sh
    sudo ./03-deploy-backend.sh
    ```

    ✅ **Verifica:** `curl http://localhost:8000/health`

### Fase 5: Frontend (VPS)

12. **Copiar archivos del frontend**
    ```bash
    # Desde tu máquina local
    cd VexusPage/frontend
    tar -czf frontend.tar.gz *
    scp frontend.tar.gz root@TU_IP_VPS:/tmp/

    # En la VPS
    sudo mkdir -p /var/www/vexus-frontend
    cd /var/www/vexus-frontend
    sudo tar -xzf /tmp/frontend.tar.gz
    sudo chown -R www-data:www-data .
    ```

13. **Verificar URLs de API**
    ```bash
    cd /var/www/vexus-frontend
    # Verificar que no haya localhost
    grep -r "localhost:8000" . || echo "OK"
    ```

### Fase 6: Nginx y SSL (VPS)

14. **Configurar Nginx**
    ```bash
    sudo cp /root/vps-deployment/05-nginx-config.conf /etc/nginx/sites-available/vexus

    # Editar si es necesario
    sudo nano /etc/nginx/sites-available/vexus

    # Habilitar
    sudo ln -s /etc/nginx/sites-available/vexus /etc/nginx/sites-enabled/
    sudo rm /etc/nginx/sites-enabled/default

    # Verificar
    sudo nginx -t
    sudo systemctl reload nginx
    ```

15. **Instalar certificado SSL**
    ```bash
    sudo certbot --nginx \
      -d grupovexus.com \
      -d www.grupovexus.com \
      --email tu-email@ejemplo.com \
      --agree-tos \
      --no-eff-email \
      --redirect
    ```

    ✅ **Verifica:** `curl -I https://grupovexus.com`

### Fase 7: Backups y Mantenimiento (VPS)

16. **Configurar backups**
    ```bash
    sudo cp /root/vps-deployment/07-backup-script.sh /usr/local/bin/vexus-backup.sh
    sudo chmod +x /usr/local/bin/vexus-backup.sh

    # Editar credenciales
    sudo nano /usr/local/bin/vexus-backup.sh

    # Probar manualmente
    sudo /usr/local/bin/vexus-backup.sh manual

    # Agregar a cron (backup diario a las 3 AM)
    (crontab -l 2>/dev/null; echo "0 3 * * * /usr/local/bin/vexus-backup.sh >> /var/log/vexus-backup.log 2>&1") | crontab -
    ```

### Fase 8: Verificación Final (VPS)

17. **Ejecutar checklist completo**
    ```bash
    cat /root/vps-deployment/09-post-deployment-checklist.md
    ```

    Marca cada item según lo vayas completando.

---

## 🛠️ COMANDOS ÚTILES

### Información del Sistema
```bash
vexus-info                    # Ver información general del sistema
systemctl status vexus-api    # Estado de la API
systemctl status nginx        # Estado de Nginx
systemctl status postgresql   # Estado de PostgreSQL
```

### Logs
```bash
vexus-api-logs               # Ver logs de la API en tiempo real
tail -f /var/log/nginx/vexus-access.log   # Logs de acceso Nginx
tail -f /var/log/nginx/vexus-error.log    # Logs de error Nginx
journalctl -u vexus-api -n 100            # Últimos 100 logs de la API
```

### Reiniciar Servicios
```bash
vexus-api-restart            # Reiniciar API
systemctl restart nginx      # Reiniciar Nginx
systemctl restart postgresql # Reiniciar PostgreSQL
```

### Actualizar Código
```bash
vexus-api-update             # Actualizar backend (si usas Git)
```

### Backups
```bash
/usr/local/bin/vexus-backup.sh manual   # Backup manual
ls -lh /var/backups/vexus/              # Ver backups disponibles
```

---

## 🔧 TROUBLESHOOTING

### API no responde (502 Bad Gateway)

```bash
# Verificar que la API está corriendo
systemctl status vexus-api

# Ver logs
journalctl -u vexus-api -n 50

# Verificar que escucha en puerto 8000
netstat -tlnp | grep 8000

# Reiniciar
systemctl restart vexus-api
```

### Error de conexión a base de datos

```bash
# Verificar PostgreSQL
systemctl status postgresql

# Probar conexión manual
sudo -u postgres psql -d vexus_db

# Verificar credenciales en .env
cat /var/www/vexus-api/.env | grep DATABASE_URL
```

### Errores de CORS

```bash
# Verificar ALLOWED_ORIGINS
cat /var/www/vexus-api/.env | grep ALLOWED_ORIGINS

# Debe incluir: https://grupovexus.com

# Ver headers de respuesta
curl -I https://grupovexus.com/api/v1/health
```

### SSL no funciona

```bash
# Ver certificados
sudo certbot certificates

# Renovar
sudo certbot renew --force-renewal

# Verificar Nginx
sudo nginx -t
sudo systemctl reload nginx
```

---

## 📊 ESPECIFICACIONES DE VPS RECOMENDADAS

```
RAM: 4 GB
CPU: 2 vCores (2.4 GHz+)
Almacenamiento: 50 GB SSD
Red: 1 Gbps
SO: Ubuntu 22.04 LTS (64-bit)
```

Estas specs soportan:
- 100-500 usuarios concurrentes
- 50-200 requests/segundo
- Crecimiento futuro sin migración inmediata

---

## 🔐 SEGURIDAD

### Credenciales a Proteger

1. **Base de datos**
   - Usuario: vexus_admin
   - Password: [en 02-setup-database.sh]
   - Guardar en: `/root/.vexus-db-credentials`

2. **Aplicación**
   - SECRET_KEY en `.env`
   - SMTP_PASSWORD / SENDGRID_API_KEY
   - Guardar en: `/var/www/vexus-api/.env`

3. **Sistema**
   - Usuario SSH (deploy)
   - Password de root (si aplica)

### Mejores Prácticas

- ✅ Usar permisos 600 para archivos sensibles
- ✅ No subir `.env` a Git (ya está en `.gitignore`)
- ✅ Rotar SECRET_KEY cada 3-6 meses
- ✅ Mantener backups en ubicación segura
- ✅ Habilitar 2FA en servicios críticos

---

## 📚 DOCUMENTACIÓN ADICIONAL

- [FastAPI Docs](https://fastapi.tiangolo.com/)
- [PostgreSQL Docs](https://www.postgresql.org/docs/)
- [Nginx Docs](https://nginx.org/en/docs/)
- [Let's Encrypt Docs](https://letsencrypt.org/docs/)
- [Ubuntu Server Guide](https://ubuntu.com/server/docs)

---

## 🆘 SOPORTE

### Si necesitas ayuda:

1. **Revisar logs**
   ```bash
   vexus-api-logs
   tail -f /var/log/nginx/vexus-error.log
   ```

2. **Revisar el checklist**
   ```bash
   cat 09-post-deployment-checklist.md
   ```

3. **Revisar la guía maestra**
   ```bash
   cat 00-GUIA-MAESTRA.md
   ```

4. **Contactar a Neatech**
   - Soporte VPS de tu proveedor

---

## ✅ VERIFICACIÓN DE DEPLOYMENT EXITOSO

Tu deployment está completo cuando:

- ✅ `https://grupovexus.com` carga sin errores
- ✅ `https://grupovexus.com/health` responde `{"status":"healthy"}`
- ✅ Registro e inicio de sesión funcionan
- ✅ Email de verificación se envía
- ✅ SSL con candado verde en navegador
- ✅ No hay errores en logs
- ✅ Backup automático configurado

---

## 📝 NOTAS FINALES

- **Tiempo estimado total:** 2-3 horas
- **Dificultad:** Intermedia
- **Prerequisitos:** Conocimientos básicos de Linux y terminal

**¡Éxito con tu deployment! 🎉**

Si completaste todo correctamente, tu aplicación VexusPage debería estar funcionando perfectamente en producción.

Para cualquier actualización futura del código, usa:
```bash
vexus-api-update  # Actualiza backend
# Frontend: copiar archivos manualmente por SCP/FTP
```

---

**Versión:** 1.0
**Fecha:** 2025-11-10
**Autor:** Claude Code
**Proyecto:** VexusPage Migration to VPS
