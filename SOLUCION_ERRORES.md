# Solución de Errores - Vexus Page

## Problemas Identificados y Solucionados

### 1. ❌ Mixed Content Error (HTTPS/HTTP)

**Error:**
```
Mixed Content: The page at 'https://www.grupovexus.com/' was loaded over HTTPS, 
but requested an insecure resource 'http://www.grupovexus.com/api/v1/services/'
```

**Causa:** El navegador bloqueaba peticiones HTTP desde una página HTTPS.

**Solución Aplicada:**
- ✅ Actualizado `frontend/Static/js/main.js` para usar HTTPS en health check
- ✅ Verificado que `frontend/Static/js/config.js` use HTTPS correctamente

### 2. ❌ Error de Configuración de Email

**Problema:** Credenciales hardcodeadas en el código y FRONTEND_URL incorrecta.

**Solución Aplicada:**
- ✅ Removidas credenciales hardcodeadas de `backend/app/config.py`
- ✅ Actualizado FRONTEND_URL por defecto a `https://www.grupovexus.com`
- ✅ Actualizado EMAIL_FROM por defecto

### 3. ❌ CORS Configurado para Localhost

**Problema:** CORS configurado para localhost en lugar de dominio de producción.

**Solución Aplicada:**
- ✅ Actualizado ALLOWED_ORIGINS para usar dominios de producción por defecto

---

## 🚀 Pasos para Desplegar en AWS Lightsail

### 1. Configurar Variables de Entorno

Crea un archivo `.env` en el servidor:

```bash
# En tu servidor AWS Lightsail
cd /ruta/a/VexusPage
cp .env.production.example .env
nano .env
```

**IMPORTANTE:** Completa estos valores en el archivo `.env`:

1. **SECRET_KEY**: Genera una clave segura:
   ```bash
   openssl rand -hex 32
   ```

2. **Email SMTP** (para Gmail):
   - Ve a tu cuenta de Gmail
   - Configuración → Seguridad → Verificación en dos pasos (activar)
   - Contraseñas de aplicaciones → Generar nueva
   - Copia la contraseña generada en `SMTP_PASSWORD`
   - Actualiza `SMTP_USER` con tu email

3. **Database** (si usas PostgreSQL local en lugar de Supabase):
   - Actualiza `POSTGRES_PASSWORD` con una contraseña segura
   - Actualiza `DATABASE_URL` si es necesario

### 2. Reconstruir y Redesplegar

```bash
# Detener contenedores actuales
docker-compose -f docker-compose.prod.yml down

# Limpiar caché de Docker
docker system prune -af

# Reconstruir imágenes
docker-compose -f docker-compose.prod.yml build --no-cache

# Iniciar servicios
docker-compose -f docker-compose.prod.yml up -d

# Verificar logs
docker-compose -f docker-compose.prod.yml logs -f
```

### 3. Verificar que Todo Funciona

```bash
# Verificar que los contenedores están corriendo
docker ps

# Verificar logs del backend
docker logs vexus-backend

# Verificar logs del frontend (nginx)
docker logs vexus-frontend

# Probar el API
curl https://www.grupovexus.com/health
curl https://www.grupovexus.com/api/v1/services/
```

### 4. Limpiar Caché del Navegador

Después de redesplegar:
1. Abre DevTools (F12)
2. Click derecho en el botón de recargar
3. Selecciona "Vaciar caché y recargar de manera forzada"

O usa Ctrl + Shift + Delete y limpia:
- Imágenes y archivos en caché
- Cookies y datos de sitios

---

## 🔧 Troubleshooting

### El email no se envía

**Opción 1: Verificar configuración de Gmail**
```bash
# Ver logs del backend
docker logs vexus-backend | grep -i email

# Verificar que las variables de entorno están configuradas
docker exec vexus-backend printenv | grep SMTP
```

**Pasos para Gmail:**
1. Asegúrate de tener verificación en 2 pasos activada
2. Genera una "Contraseña de aplicación" específica
3. Usa esa contraseña en `SMTP_PASSWORD`
4. Verifica que `SMTP_USER` tenga el formato correcto (sin espacios)

**Opción 2: Usar SendGrid (Recomendado)**
```bash
# En .env, agrega:
SENDGRID_API_KEY="tu-api-key-aqui"
```

SendGrid es más confiable y fácil de configurar que Gmail SMTP.

### Mixed Content Error persiste

```bash
# Verificar que nginx está sirviendo HTTPS correctamente
docker exec vexus-frontend cat /etc/nginx/conf.d/default.conf

# Verificar certificados SSL
docker exec vexus-frontend ls -la /etc/letsencrypt/live/grupovexus.com/
```

### API no responde

```bash
# Verificar que el backend está corriendo
docker logs vexus-backend --tail 100

# Verificar conectividad desde frontend a backend
docker exec vexus-frontend wget -O- http://backend:8000/health

# Verificar desde el host
curl https://www.grupovexus.com/api/v1/health
```

### Base de datos no conecta

```bash
# Verificar logs de postgres
docker logs vexus-postgres

# Verificar conectividad
docker exec vexus-backend ping postgres

# Probar conexión directa
docker exec vexus-postgres psql -U vexus_admin -d vexus_db -c "SELECT 1;"
```

---

## 📝 Checklist de Verificación

- [ ] Archivo `.env` creado y configurado
- [ ] SECRET_KEY generada con `openssl rand -hex 32`
- [ ] SMTP_PASSWORD configurada (contraseña de aplicación de Gmail)
- [ ] FRONTEND_URL apunta a `https://www.grupovexus.com`
- [ ] ALLOWED_ORIGINS incluye el dominio HTTPS
- [ ] Certificados SSL están en su lugar
- [ ] Docker containers reconstruidos sin caché
- [ ] Logs del backend no muestran errores
- [ ] Logs de nginx no muestran errores
- [ ] API responde correctamente: `curl https://www.grupovexus.com/health`
- [ ] Caché del navegador limpiado
- [ ] Console del navegador no muestra errores de Mixed Content

---

## 🔗 Enlaces Útiles

- [Contraseñas de aplicación de Gmail](https://support.google.com/accounts/answer/185833)
- [SendGrid - Configuración](https://sendgrid.com/docs/for-developers/sending-email/quickstart-python/)
- [Let's Encrypt - Renovar certificados](https://letsencrypt.org/docs/)
- [Docker Compose - Documentación](https://docs.docker.com/compose/)

---

## 📞 Próximos Pasos

1. **Configura el archivo `.env` con tus credenciales reales**
2. **Redesplega la aplicación**
3. **Prueba el envío de emails desde la página**
4. **Verifica que no haya errores en la consola del navegador**
5. **Configura monitoreo (opcional pero recomendado)**

Si después de estos pasos sigues teniendo problemas, revisa los logs detalladamente:
```bash
docker-compose -f docker-compose.prod.yml logs -f
```
