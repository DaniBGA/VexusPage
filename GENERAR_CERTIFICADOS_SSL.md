# 🔐 Generar Certificados SSL con Let's Encrypt

## 📋 Problema Actual
No existen certificados SSL para `grupovexus.com` en el servidor.

---

## ✅ SOLUCIÓN: Generar Certificados con Certbot

### PASO 1: Instalar Certbot (si no está instalado)

```bash
# Actualizar repositorios
sudo apt update

# Instalar Certbot y el plugin de Nginx
sudo apt install certbot python3-certbot-nginx -y
```

---

### PASO 2: Detener el contenedor frontend (temporalmente)

```bash
cd /home/ubuntu/VexusPage
docker compose -f docker-compose.prod.yml stop frontend
```

**¿Por qué?** Certbot necesita usar el puerto 80 temporalmente para verificar el dominio.

---

### PASO 3: Generar certificados para grupovexus.com

```bash
sudo certbot certonly --nginx \
  -d grupovexus.com \
  -d www.grupovexus.com \
  --email tu_email@gmail.com \
  --agree-tos \
  --no-eff-email
```

**⚠️ IMPORTANTE:** Reemplaza `tu_email@gmail.com` con tu email real.

**Respuestas esperadas durante el proceso:**
1. **"Enter email address"** → Escribe tu email
2. **"Agree to Terms of Service"** → `Y`
3. **"Share email with EFF"** → `N` (opcional)

**Salida esperada:**
```
Saving debug log to /var/log/letsencrypt/letsencrypt.log
Requesting a certificate for grupovexus.com and www.grupovexus.com

Successfully received certificate.
Certificate is saved at: /etc/letsencrypt/live/grupovexus.com/fullchain.pem
Key is saved at:         /etc/letsencrypt/live/grupovexus.com/privkey.pem
This certificate expires on 2026-03-04.
```

---

### PASO 4: Verificar que los certificados se generaron

```bash
sudo ls -la /etc/letsencrypt/live/grupovexus.com/
```

**Deberías ver:**
```
cert.pem
chain.pem
fullchain.pem -> ../../archive/grupovexus.com/fullchain1.pem
privkey.pem -> ../../archive/grupovexus.com/privkey1.pem
```

---

### PASO 5: Volver a ejecutar el script de configuración HTTPS

```bash
cd /home/ubuntu/VexusPage
./setup-https.sh
```

**Ahora sí debería funcionar completamente.**

---

## 🔄 ALTERNATIVA: Si Certbot no puede usar puerto 80

Si el puerto 80 está ocupado y no puedes detener el frontend, usa el método standalone:

```bash
# Detener TODOS los contenedores
docker compose -f docker-compose.prod.yml down

# Generar certificados con standalone
sudo certbot certonly --standalone \
  -d grupovexus.com \
  -d www.grupovexus.com \
  --email tu_email@gmail.com \
  --agree-tos \
  --no-eff-email

# Verificar certificados
sudo ls -la /etc/letsencrypt/live/grupovexus.com/

# Ejecutar script de configuración
./setup-https.sh
```

---

## 🆘 TROUBLESHOOTING

### ❌ Error: "Failed authorization procedure"

**Causa:** El dominio no apunta a la IP del servidor o el puerto 80 está bloqueado.

**Solución:**
1. Verifica DNS: `nslookup grupovexus.com`
2. Debe retornar la IP de tu Lightsail
3. Verifica firewall de Lightsail permite puerto 80

---

### ❌ Error: "Port 80 is already in use"

**Solución:**
```bash
# Detener frontend
docker compose -f docker-compose.prod.yml stop frontend

# Reintentar certbot
sudo certbot certonly --nginx -d grupovexus.com -d www.grupovexus.com
```

---

### ❌ Error: "Name or service not known"

**Causa:** DNS no configurado correctamente.

**Solución:**
1. Ve a tu proveedor de DNS (Namecheap, GoDaddy, etc.)
2. Agrega estos registros:
   - **Tipo A**: `grupovexus.com` → IP de Lightsail
   - **Tipo A**: `www.grupovexus.com` → IP de Lightsail
3. Espera 5-10 minutos para propagación
4. Verifica: `nslookup grupovexus.com`
5. Reintenta certbot

---

## 🔄 Renovación Automática

Los certificados de Let's Encrypt expiran cada 90 días. Certbot configura renovación automática, pero verifica:

```bash
# Ver timer de renovación
sudo systemctl status certbot.timer

# Probar renovación (dry-run)
sudo certbot renew --dry-run
```

---

## 📝 RESUMEN DE COMANDOS COMPLETOS

Copia y pega todo esto en Lightsail:

```bash
# 1. Instalar Certbot
sudo apt update
sudo apt install certbot python3-certbot-nginx -y

# 2. Detener frontend temporalmente
cd /home/ubuntu/VexusPage
docker compose -f docker-compose.prod.yml stop frontend

# 3. Generar certificados (⚠️ CAMBIAR EMAIL)
sudo certbot certonly --nginx \
  -d grupovexus.com \
  -d www.grupovexus.com \
  --email TU_EMAIL@gmail.com \
  --agree-tos \
  --no-eff-email

# 4. Verificar certificados generados
sudo ls -la /etc/letsencrypt/live/grupovexus.com/

# 5. Ejecutar script de configuración HTTPS
./setup-https.sh
```

---

## ✅ RESULTADO ESPERADO

Después de ejecutar estos comandos:

1. ✅ Certificados SSL generados en `/etc/letsencrypt/live/grupovexus.com/`
2. ✅ `setup-https.sh` completa sin errores
3. ✅ Contenedores levantados con HTTPS
4. ✅ https://grupovexus.com funciona con candado verde 🔒
5. ✅ https://www.grupovexus.com funciona con candado verde 🔒

---

**📍 SIGUIENTE PASO:** 

Ejecuta estos comandos y dime qué sale. Si hay algún error, cópialo completo.
