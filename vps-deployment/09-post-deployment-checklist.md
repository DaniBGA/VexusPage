# ✅ CHECKLIST POST-DEPLOYMENT - VEXUSPAGE

**Fecha de deployment:** _______________
**Ejecutado por:** _______________
**IP VPS:** _______________

---

## 📋 FASE 1: VERIFICACIONES BÁSICAS

### Sistema Operativo
- [ ] Sistema actualizado: `apt update && apt upgrade`
- [ ] Zona horaria configurada: `timedatectl`
- [ ] Espacio en disco disponible (>50%): `df -h`
- [ ] Memoria RAM disponible (>1GB): `free -h`

### Servicios Críticos
- [ ] PostgreSQL corriendo: `systemctl status postgresql`
- [ ] Nginx corriendo: `systemctl status nginx`
- [ ] Vexus API corriendo: `systemctl status vexus-api`
- [ ] Fail2Ban activo: `systemctl status fail2ban`

---

## 🔒 FASE 2: SEGURIDAD

### Firewall (UFW)
- [ ] Firewall habilitado: `ufw status`
- [ ] Puerto 22 (SSH) permitido
- [ ] Puerto 80 (HTTP) permitido
- [ ] Puerto 443 (HTTPS) permitido
- [ ] Puerto 5432 (PostgreSQL) bloqueado externamente

### SSH
- [ ] PermitRootLogin deshabilitado en `/etc/ssh/sshd_config`
- [ ] Usuario 'deploy' creado y con permisos sudo
- [ ] Claves SSH configuradas (opcional pero recomendado)

### Certificados SSL
- [ ] Certificado SSL instalado: `certbot certificates`
- [ ] Certificado válido (no expirado)
- [ ] Auto-renovación configurada: `certbot renew --dry-run`
- [ ] HTTPS funcionando: `curl -I https://grupovexus.com`

### Permisos de Archivos
- [ ] `/var/www/vexus-api` propiedad de www-data: `ls -la /var/www/`
- [ ] `.env` con permisos 600: `ls -la /var/www/vexus-api/.env`
- [ ] Backups con permisos 700: `ls -la /var/backups/vexus/`

---

## 🗄️ FASE 3: BASE DE DATOS

### Conexión y Estructura
- [ ] Conexión exitosa: `sudo -u postgres psql -d vexus_db -c "SELECT 1"`
- [ ] Todas las tablas creadas: `\dt` en psql
- [ ] Índices creados correctamente
- [ ] Triggers funcionando (updated_at)

### Datos Iniciales
- [ ] Usuario admin creado y verificado
- [ ] Contraseña del admin CAMBIADA (no usar Admin123!)
- [ ] No hay datos de prueba/desarrollo en producción

### Backup
- [ ] Script de backup configurado: `/usr/local/bin/vexus-backup.sh`
- [ ] Backup manual ejecutado exitosamente
- [ ] Cron de backups configurado: `crontab -l`
- [ ] Backup automático probado

---

## 🔧 FASE 4: BACKEND (API)

### Servicio
- [ ] Servicio systemd creado: `/etc/systemd/system/vexus-api.service`
- [ ] Auto-inicio habilitado: `systemctl is-enabled vexus-api`
- [ ] Logs accesibles: `journalctl -u vexus-api -n 20`
- [ ] Sin errores críticos en logs

### Configuración
- [ ] Archivo `.env` configurado con credenciales reales
- [ ] `DATABASE_URL` correcta y funcional
- [ ] `SECRET_KEY` generada (no usar valores de ejemplo)
- [ ] `ALLOWED_ORIGINS` incluye el dominio correcto
- [ ] Email configurado (SMTP o SendGrid)

### Endpoints
- [ ] Health check: `curl http://localhost:8000/health`
  - Respuesta: `{"status":"healthy","database":"connected"}`
- [ ] Root endpoint: `curl http://localhost:8000/`
- [ ] API docs: `curl http://localhost:8000/docs`
- [ ] CORS funcionando correctamente

### Funcionalidad
- [ ] Registro de usuario funciona
- [ ] Login funciona y retorna token
- [ ] Email de verificación se envía (revisar logs)
- [ ] Endpoints protegidos requieren autenticación

---

## 🎨 FASE 5: FRONTEND

### Archivos
- [ ] Archivos copiados a `/var/www/vexus-frontend`
- [ ] Permisos correctos (www-data): `ls -la /var/www/vexus-frontend/`
- [ ] Estructura de directorios completa (Static, pages, etc.)

### Configuración
- [ ] URLs de API apuntan a producción (no localhost)
- [ ] `CONFIG.API_BASE_URL` configurado correctamente
- [ ] No hay console.logs de debug en producción
- [ ] Analytics configurado (si aplica)

### Accesibilidad
- [ ] Sitio accesible vía HTTP: `curl http://grupovexus.com`
- [ ] Sitio accesible vía HTTPS: `curl https://grupovexus.com`
- [ ] Redirección HTTP → HTTPS funciona
- [ ] Archivos estáticos se cargan correctamente

---

## 🌐 FASE 6: NGINX

### Configuración
- [ ] Archivo de configuración copiado: `/etc/nginx/sites-available/vexus`
- [ ] Symlink creado: `/etc/nginx/sites-enabled/vexus`
- [ ] Sitio default deshabilitado
- [ ] Sintaxis correcta: `nginx -t`

### Proxy al Backend
- [ ] Proxy a backend funcionando: `/api/v1/*`
- [ ] Headers de proxy configurados
- [ ] CORS headers configurados
- [ ] Timeouts apropiados

### Optimizaciones
- [ ] Gzip habilitado
- [ ] Cache de archivos estáticos configurado
- [ ] SSL/TLS configurado correctamente
- [ ] Security headers presentes

---

## 🧪 FASE 7: TESTING FUNCIONAL

### Tests desde Navegador
- [ ] Abrir: https://grupovexus.com
- [ ] Página carga sin errores
- [ ] Recursos estáticos cargan (CSS, JS, imágenes)
- [ ] No hay errores en consola del navegador

### Tests de Registro/Login
- [ ] Crear cuenta nueva
- [ ] Email de verificación recibido (revisar spam)
- [ ] Verificar email (click en link)
- [ ] Login con cuenta verificada
- [ ] Token guardado correctamente

### Tests de Funcionalidad
- [ ] Ver cursos/servicios
- [ ] Formulario de contacto funciona
- [ ] Dashboard accesible (si aplica)
- [ ] Navegación entre páginas funciona

### Tests de API (con Postman o curl)

**Registro:**
```bash
curl -X POST https://grupovexus.com/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{"name":"Test User","email":"test@ejemplo.com","password":"Test123!"}'
```
- [ ] Responde 200 OK
- [ ] No hay errores CORS

**Login:**
```bash
curl -X POST https://grupovexus.com/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@ejemplo.com","password":"Test123!"}'
```
- [ ] Responde con token
- [ ] Token es válido

**Health Check:**
```bash
curl https://grupovexus.com/api/v1/health
```
- [ ] Responde `healthy`
- [ ] Base de datos `connected`

---

## 📊 FASE 8: MONITOREO Y LOGS

### Logs del Sistema
- [ ] Logs de sistema accesibles: `journalctl -n 50`
- [ ] Logs de Nginx: `tail -f /var/log/nginx/vexus-*.log`
- [ ] Logs de API: `vexus-api-logs`
- [ ] Rotación de logs configurada

### Métricas
- [ ] Uso de CPU normal (<50%): `top`
- [ ] Uso de RAM normal (<70%): `free -h`
- [ ] Uso de disco normal (<70%): `df -h`
- [ ] Conexiones PostgreSQL normales: `ss -tlnp | grep 5432`

### Alertas (Opcional)
- [ ] Monitoreo de uptime configurado
- [ ] Alertas de email configuradas
- [ ] Notificaciones de backup configuradas

---

## 🔄 FASE 9: AUTOMATIZACIONES

### Cron Jobs
- [ ] Backup diario configurado (3 AM): `crontab -l`
- [ ] Limpieza de DB configurada (2 AM)
- [ ] Limpieza de logs antiguos configurada
- [ ] Renovación SSL automática (Certbot)

### Scripts de Utilidad
- [ ] `vexus-info` funciona: muestra info del sistema
- [ ] `vexus-api-logs` funciona: muestra logs en tiempo real
- [ ] `vexus-api-restart` funciona: reinicia la API
- [ ] `vexus-api-update` funciona: actualiza código
- [ ] `vexus-backup.sh` funciona: crea backup

---

## 🌍 FASE 10: DNS Y DOMINIO

### Configuración DNS
- [ ] Registro A apunta a IP correcta
- [ ] Registro A para www configurado
- [ ] DNS propagado (puede tardar 24-48h)
- [ ] Dominio resuelve correctamente: `nslookup grupovexus.com`

### Verificaciones
- [ ] Dominio sin www funciona: https://grupovexus.com
- [ ] Dominio con www funciona: https://www.grupovexus.com
- [ ] Redirección www → non-www (o viceversa) funciona
- [ ] SSL válido para ambas versiones

---

## 📱 FASE 11: PERFORMANCE

### Velocidad de Carga
- [ ] Página inicial carga en <3 segundos
- [ ] Time to First Byte (TTFB) <500ms
- [ ] Recursos estáticos con cache correcto
- [ ] Imágenes optimizadas

### Tools de Testing
- [ ] Google PageSpeed Insights: >80
- [ ] GTmetrix: Grade A o B
- [ ] SSL Labs: A rating
- [ ] Security Headers: A rating

**URLs para testing:**
- PageSpeed: https://pagespeed.web.dev/
- GTmetrix: https://gtmetrix.com/
- SSL Labs: https://www.ssllabs.com/ssltest/
- Security Headers: https://securityheaders.com/

---

## 📝 FASE 12: DOCUMENTACIÓN

### Información Registrada
- [ ] Credenciales guardadas en lugar seguro
- [ ] IPs documentadas
- [ ] Puertos documentados
- [ ] Procedimientos de deployment documentados

### Accesos
- [ ] Usuario SSH anotado
- [ ] Credenciales de base de datos guardadas
- [ ] API keys guardadas (SendGrid, etc.)
- [ ] Contraseñas del admin guardadas

---

## ⚠️ FASE 13: TROUBLESHOOTING COMÚN

### Si el Backend no responde:
```bash
# Ver logs
journalctl -u vexus-api -n 100

# Verificar que escucha en puerto 8000
netstat -tlnp | grep 8000

# Reiniciar servicio
systemctl restart vexus-api

# Ver estado
systemctl status vexus-api
```

### Si hay errores de base de datos:
```bash
# Verificar PostgreSQL
systemctl status postgresql

# Conectar manualmente
sudo -u postgres psql -d vexus_db

# Ver conexiones activas
sudo -u postgres psql -c "SELECT * FROM pg_stat_activity;"
```

### Si Nginx muestra 502:
```bash
# Ver logs de Nginx
tail -f /var/log/nginx/vexus-error.log

# Verificar que backend está corriendo
curl http://localhost:8000/health

# Verificar configuración
nginx -t

# Recargar Nginx
systemctl reload nginx
```

### Si CORS no funciona:
```bash
# Verificar ALLOWED_ORIGINS en .env
cat /var/www/vexus-api/.env | grep ALLOWED_ORIGINS

# Probar desde el frontend
# Abrir consola del navegador y buscar errores CORS

# Verificar headers de Nginx
curl -I https://grupovexus.com/api/v1/health
```

---

## ✅ FIRMA Y APROBACIÓN

Una vez completados todos los items:

```
Deployment completado por: _______________
Fecha: _______________
Firma: _______________

Verificado por: _______________
Fecha: _______________
Firma: _______________
```

---

## 📞 CONTACTOS DE EMERGENCIA

```
Soporte VPS (Neatech): _______________
Email: _______________
Teléfono: _______________

Admin del Sistema: _______________
Email: _______________
Teléfono: _______________
```

---

## 🎉 DEPLOYMENT EXITOSO

Si todos los items están marcados:

**¡FELICITACIONES! 🎊**

Tu aplicación VexusPage está completamente desplegada y funcionando en producción.

**URLs Finales:**
- Frontend: https://grupovexus.com
- Backend: https://grupovexus.com/api/v1
- Docs: https://grupovexus.com/docs
- Health: https://grupovexus.com/health

**Próximos Pasos:**
1. Monitorear logs durante las primeras 24-48 horas
2. Verificar que los backups automáticos funcionan
3. Probar todos los flujos de usuario
4. Configurar monitoreo adicional (opcional)
5. Planear estrategia de actualizaciones

**¡Éxito con tu proyecto! 🚀**
