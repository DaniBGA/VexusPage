# ⚡ INICIO RÁPIDO - DEPLOYMENT EN 30 MINUTOS

Esta es una guía ultra-simplificada para hacer el deployment rápidamente si ya tienes experiencia con servidores Linux.

**⏱️ Tiempo estimado:** 30-45 minutos

---

## 🎯 PRE-REQUISITOS

Antes de comenzar, asegúrate de tener:

```
✅ VPS con Ubuntu 22.04 LTS (4GB RAM, 2 vCores, 50GB SSD)
✅ IP de la VPS
✅ Acceso SSH como root
✅ Dominio (grupovexus.com) apuntando a la IP
✅ Gmail App Password O SendGrid API Key
✅ 30-45 minutos de tiempo disponible
```

---

## 🚀 PASOS RÁPIDOS

### 1️⃣ CONECTAR Y PREPARAR (2 min)

```bash
# Conectar a la VPS
ssh root@TU_IP_VPS

# Actualizar sistema
apt update && apt upgrade -y

# Copiar archivos (desde tu máquina local, otra terminal)
# En tu máquina local:
cd VexusPage
tar -czf vps-deployment.tar.gz vps-deployment/
scp vps-deployment.tar.gz root@TU_IP_VPS:/root/

# En la VPS:
cd /root
tar -xzf vps-deployment.tar.gz
cd vps-deployment
```

---

### 2️⃣ INSTALAR SISTEMA BASE (15 min)

```bash
chmod +x 01-install-system.sh
./01-install-system.sh
```

☕ **Espera 10-15 minutos mientras se instala todo.**

**Verifica:**
```bash
python3.12 --version  # Debe mostrar Python 3.12.x
psql --version        # Debe mostrar PostgreSQL
nginx -v              # Debe mostrar nginx
```

---

### 3️⃣ CONFIGURAR BASE DE DATOS (5 min)

```bash
# Generar password segura
python3 -c "import secrets; print(secrets.token_urlsafe(24))"
# Copiar el resultado

# Editar script
nano 02-setup-database.sh
# Cambiar la línea:
# DB_PASSWORD="CAMBIAR_POR_PASSWORD_SEGURA"
# Por:
# DB_PASSWORD="TU_PASSWORD_COPIADA_AQUI"
# Guardar: Ctrl+O, Enter, Ctrl+X

# Ejecutar
chmod +x 02-setup-database.sh
./02-setup-database.sh
```

**Verifica:**
```bash
sudo -u postgres psql -d vexus_db -c "SELECT 1"
# Debe mostrar: 1
```

---

### 4️⃣ PREPARAR BACKEND (5 min)

```bash
# Generar SECRET_KEY
python3 -c "import secrets; print(secrets.token_urlsafe(32))"
# Copiar el resultado

# Copiar plantilla .env
cp 08-production.env.example /var/www/vexus-api/.env

# Editar .env
nano /var/www/vexus-api/.env
```

**Edita estos valores:**
```env
DATABASE_URL=postgresql://vexus_admin:TU_PASSWORD_DB@localhost:5432/vexus_db
SECRET_KEY=TU_SECRET_KEY_GENERADA
SMTP_USER=tu-email@gmail.com
SMTP_PASSWORD=tu-app-password-gmail
EMAIL_FROM=noreply@grupovexus.com
SENDGRID_API_KEY=tu-sendgrid-key (opcional)
```

Guardar: `Ctrl+O`, `Enter`, `Ctrl+X`

**Copiar código del backend:**
```bash
# En tu máquina local (otra terminal):
cd VexusPage/backend
tar -czf backend.tar.gz app/ requirements.txt
scp backend.tar.gz root@TU_IP_VPS:/var/www/vexus-api/

# En la VPS:
cd /var/www/vexus-api
tar -xzf backend.tar.gz
rm backend.tar.gz
```

**Ejecutar deployment:**
```bash
cd /root/vps-deployment
chmod +x 03-deploy-backend.sh
./03-deploy-backend.sh
```

**Verifica:**
```bash
curl http://localhost:8000/health
# Debe responder: {"status":"healthy","database":"connected"}
```

---

### 5️⃣ DESPLEGAR FRONTEND (3 min)

```bash
# En tu máquina local:
cd VexusPage/frontend
tar -czf frontend.tar.gz *
scp frontend.tar.gz root@TU_IP_VPS:/tmp/

# En la VPS:
mkdir -p /var/www/vexus-frontend
cd /var/www/vexus-frontend
tar -xzf /tmp/frontend.tar.gz
chown -R www-data:www-data .

# Verificar que no haya URLs hardcoded de localhost
grep -r "localhost:8000" . || echo "✓ OK"
```

---

### 6️⃣ CONFIGURAR NGINX (3 min)

```bash
cd /root/vps-deployment

# Copiar configuración
cp 05-nginx-config.conf /etc/nginx/sites-available/vexus

# Editar dominio si es diferente
nano /etc/nginx/sites-available/vexus
# Buscar: server_name grupovexus.com www.grupovexus.com;
# Cambiar si tu dominio es diferente

# Comentar temporalmente las líneas de SSL (líneas 64-66):
# #ssl_certificate /etc/letsencrypt/live/grupovexus.com/fullchain.pem;
# #ssl_certificate_key /etc/letsencrypt/live/grupovexus.com/privkey.pem;

# Habilitar sitio
ln -s /etc/nginx/sites-available/vexus /etc/nginx/sites-enabled/
rm /etc/nginx/sites-enabled/default

# Verificar
nginx -t

# Recargar
systemctl reload nginx
```

---

### 7️⃣ INSTALAR SSL (3 min)

```bash
# Instalar certificado
certbot --nginx \
  -d grupovexus.com \
  -d www.grupovexus.com \
  --email tu-email@ejemplo.com \
  --agree-tos \
  --no-eff-email \
  --redirect
```

Certbot modificará automáticamente la configuración de Nginx.

**Verifica:**
```bash
curl -I https://grupovexus.com
# Debe responder: HTTP/2 200
```

---

### 8️⃣ CONFIGURAR BACKUPS (2 min)

```bash
# Copiar script
cp 07-backup-script.sh /usr/local/bin/vexus-backup.sh
chmod +x /usr/local/bin/vexus-backup.sh

# Editar password (igual que en paso 3)
nano /usr/local/bin/vexus-backup.sh
# Cambiar: DB_PASSWORD="CAMBIAR_POR_PASSWORD_SEGURA"

# Agregar a cron
(crontab -l 2>/dev/null; echo "0 3 * * * /usr/local/bin/vexus-backup.sh >> /var/log/vexus-backup.log 2>&1") | crontab -

# Probar
/usr/local/bin/vexus-backup.sh manual
```

---

### 9️⃣ VERIFICACIÓN FINAL (2 min)

```bash
# Ver información del sistema
vexus-info

# Verificar servicios
systemctl status vexus-api
systemctl status nginx
systemctl status postgresql

# Probar endpoints
curl https://grupovexus.com/health
curl https://grupovexus.com/api/v1/debug/cors
```

**Abrir en navegador:**
- https://grupovexus.com
- https://grupovexus.com/docs

**Probar funcionalidad:**
1. Registrar una cuenta
2. Verificar email
3. Hacer login
4. Navegar por el sitio

---

## ✅ CHECKLIST RÁPIDO

```
□ Sistema base instalado (Python, PostgreSQL, Nginx)
□ Base de datos creada y configurada
□ Backend desplegado y corriendo
□ Frontend copiado y accesible
□ Nginx configurado correctamente
□ SSL instalado y funcionando
□ Backups configurados
□ Todos los servicios corriendo
□ Sitio accesible vía HTTPS
□ Registro/Login funcionando
```

---

## 🆘 SOLUCIÓN RÁPIDA DE PROBLEMAS

### Backend no responde
```bash
journalctl -u vexus-api -n 50
systemctl restart vexus-api
```

### Nginx error 502
```bash
tail -f /var/log/nginx/vexus-error.log
curl http://localhost:8000/health
systemctl restart vexus-api
```

### Base de datos no conecta
```bash
sudo -u postgres psql -d vexus_db
# Verificar DATABASE_URL en .env
cat /var/www/vexus-api/.env | grep DATABASE_URL
```

### SSL no funciona
```bash
certbot certificates
certbot renew --force-renewal
nginx -t && systemctl reload nginx
```

---

## 📞 COMANDOS ÚTILES POST-DEPLOYMENT

```bash
# Ver logs en tiempo real
vexus-api-logs

# Reiniciar API
vexus-api-restart

# Ver información del sistema
vexus-info

# Hacer backup manual
/usr/local/bin/vexus-backup.sh manual

# Ver últimos backups
ls -lht /var/backups/vexus/
```

---

## 🎉 ¡LISTO!

Si llegaste hasta aquí y todo funciona, **¡FELICITACIONES!** 🎊

Tu aplicación VexusPage está desplegada y funcionando en producción.

**URLs finales:**
- Frontend: https://grupovexus.com
- API: https://grupovexus.com/api/v1
- Docs: https://grupovexus.com/docs
- Health: https://grupovexus.com/health

---

## 📚 PRÓXIMOS PASOS

1. **Monitorear durante 24-48 horas**
   ```bash
   tail -f /var/log/nginx/vexus-access.log
   vexus-api-logs
   ```

2. **Verificar backups automáticos**
   ```bash
   # Al día siguiente, verificar que el backup se ejecutó
   ls -lh /var/backups/vexus/
   cat /var/log/vexus-backup.log
   ```

3. **Cambiar contraseña del admin**
   - Login con: admin@grupovexus.com / Admin123!
   - Cambiar contraseña inmediatamente

4. **Configurar monitoreo adicional** (opcional)
   - UptimeRobot
   - Google Analytics
   - Sentry

5. **Documentar credenciales** en lugar seguro
   - Passwords de DB
   - SECRET_KEY
   - Credenciales de email

---

## 💡 TIPS FINALES

- **Backups:** Descarga un backup manual cada semana a tu máquina local
- **Actualizaciones:** Mantén el sistema actualizado mensualmente
- **Monitoreo:** Revisa logs semanalmente
- **Seguridad:** Cambia passwords cada 3-6 meses
- **Performance:** Monitorea uso de recursos (CPU, RAM, disco)

---

**¡Éxito con tu proyecto! 🚀**

Si necesitas la guía completa con más detalles, consulta:
- `00-GUIA-MAESTRA.md` - Guía detallada paso a paso
- `09-post-deployment-checklist.md` - Checklist completo de verificación
- `README.md` - Documentación completa del directorio
