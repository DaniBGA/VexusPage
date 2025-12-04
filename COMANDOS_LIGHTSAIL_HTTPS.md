# 🔒 Comandos para Configurar HTTPS en Lightsail

## 📋 Resumen del Problema
- ❌ Los certificados NO están montados correctamente en el contenedor
- ❌ Nginx NO tiene HTTPS activado (todo está comentado)
- ❌ `server_name` está en `_` en lugar de `grupovexus.com www.grupovexus.com`
- ❌ Healthcheck falla porque intenta HTTP en lugar de HTTPS

## ✅ Solución Aplicada
He actualizado 2 archivos localmente:
1. ✅ `frontend/nginx.prod.conf` - HTTPS activado con certificados correctos
2. ✅ `docker-compose.prod.yml` - Volúmenes y healthcheck corregidos

---

## 🚀 COMANDOS PARA EJECUTAR EN LIGHTSAIL

### PASO 1: Conectar a tu servidor Lightsail
```bash
ssh ubuntu@TU_IP_LIGHTSAIL
```

---

### PASO 2: Crear carpeta SSL y copiar certificados
```bash
# Crear carpeta para certificados
sudo mkdir -p /home/ubuntu/VexusPage/ssl

# Copiar certificados de Let's Encrypt
sudo cp -r /etc/letsencrypt/live/grupovexus.com /home/ubuntu/VexusPage/ssl/
sudo cp -r /etc/letsencrypt/archive/grupovexus.com /home/ubuntu/VexusPage/ssl/

# Dar permisos de lectura
sudo chmod -R 755 /home/ubuntu/VexusPage/ssl

# Cambiar dueño a ubuntu
sudo chown -R ubuntu:ubuntu /home/ubuntu/VexusPage/ssl
```

---

### PASO 3: Verificar que los certificados se copiaron correctamente
```bash
ls -la /home/ubuntu/VexusPage/ssl/live/grupovexus.com/
```

**Deberías ver:**
```
fullchain.pem
privkey.pem
cert.pem
chain.pem
```

---

### PASO 4: Ir a tu directorio del proyecto
```bash
cd /home/ubuntu/VexusPage
```

---

### PASO 5: Hacer pull de los cambios desde Git
```bash
git pull origin main
```

**Esto traerá:**
- ✅ `frontend/nginx.prod.conf` con HTTPS activado
- ✅ `docker-compose.prod.yml` con volúmenes corregidos

---

### PASO 6: Detener contenedores actuales
```bash
docker compose -f docker-compose.prod.yml down
```

---

### PASO 7: Reconstruir y levantar con los nuevos cambios
```bash
docker compose -f docker-compose.prod.yml up -d --build
```

**Esto tomará 2-3 minutos. Espera a que termine.**

---

### PASO 8: Verificar que los contenedores están corriendo
```bash
docker ps
```

**Deberías ver 3 contenedores:**
- `vexus-postgres` (healthy)
- `vexus-backend` (healthy)
- `vexus-frontend` (healthy)

---

### PASO 9: Verificar certificados DENTRO del contenedor
```bash
docker exec -it vexus-frontend ls -la /etc/letsencrypt/live/grupovexus.com/
```

**Deberías ver:**
```
fullchain.pem
privkey.pem
cert.pem
chain.pem
```

---

### PASO 10: Ver logs del frontend para verificar que Nginx cargó SSL
```bash
docker logs vexus-frontend
```

**Deberías ver algo como:**
```
nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
nginx: configuration file /etc/nginx/nginx.conf test is successful
```

**NO deberías ver errores de certificados.**

---

## 🧪 PASO 11: TESTS DE VERIFICACIÓN

### Test 1: HTTPS funciona (sin www)
```bash
curl -I https://grupovexus.com
```

**Respuesta esperada:**
```
HTTP/2 200
server: nginx
content-type: text/html
```

---

### Test 2: HTTPS funciona (con www)
```bash
curl -I https://www.grupovexus.com
```

**Respuesta esperada:**
```
HTTP/2 200
server: nginx
content-type: text/html
```

---

### Test 3: Redirección HTTP → HTTPS (sin www)
```bash
curl -I http://grupovexus.com
```

**Respuesta esperada:**
```
HTTP/1.1 301 Moved Permanently
Location: https://grupovexus.com/
```

---

### Test 4: Redirección HTTP → HTTPS (con www)
```bash
curl -I http://www.grupovexus.com
```

**Respuesta esperada:**
```
HTTP/1.1 301 Moved Permanently
Location: https://www.grupovexus.com/
```

---

### Test 5: Verificar certificado SSL
```bash
openssl s_client -connect grupovexus.com:443 -servername grupovexus.com < /dev/null | grep "Verify return code"
```

**Respuesta esperada:**
```
Verify return code: 0 (ok)
```

---

### Test 6: Verificar healthcheck del contenedor
```bash
docker inspect vexus-frontend --format='{{.State.Health.Status}}'
```

**Respuesta esperada:**
```
healthy
```

---

## 🎯 RESULTADO FINAL ESPERADO

Cuando abras en Chrome:
- ✅ `https://grupovexus.com` → 🔒 Conexión segura
- ✅ `https://www.grupovexus.com` → 🔒 Conexión segura
- ✅ `http://grupovexus.com` → Redirige a HTTPS automáticamente
- ✅ `http://www.grupovexus.com` → Redirige a HTTPS automáticamente
- ✅ Sin warnings de "sitio no seguro"
- ✅ Candado verde en la barra de direcciones

---

## 🔍 TROUBLESHOOTING

### ❌ Error: "No such file or directory" en certificados
```bash
# Verificar que los certificados existen en el host
ls -la /etc/letsencrypt/live/grupovexus.com/

# Si no existen, regenerar con certbot
sudo certbot certonly --nginx -d grupovexus.com -d www.grupovexus.com
```

---

### ❌ Error: "Permission denied" en certificados
```bash
# Dar permisos correctos
sudo chmod -R 755 /home/ubuntu/VexusPage/ssl
sudo chown -R ubuntu:ubuntu /home/ubuntu/VexusPage/ssl
```

---

### ❌ Contenedor frontend "unhealthy"
```bash
# Ver logs detallados
docker logs vexus-frontend --tail 50

# Verificar configuración de Nginx dentro del contenedor
docker exec -it vexus-frontend nginx -t
```

---

### ❌ Chrome sigue mostrando "no seguro"
```bash
# Limpiar caché de Chrome
# Ctrl + Shift + Delete → Borrar caché e imágenes

# O abrir en modo incógnito
# Ctrl + Shift + N
```

---

### ❌ Certificados expirados
```bash
# Verificar fecha de expiración
sudo certbot certificates

# Renovar certificados
sudo certbot renew

# Reiniciar contenedores
docker compose -f docker-compose.prod.yml restart frontend
```

---

## 📝 CHECKLIST FINAL

Antes de marcar como completado:

- [ ] Certificados copiados a `/home/ubuntu/VexusPage/ssl/`
- [ ] `git pull` ejecutado correctamente
- [ ] Contenedores reconstruidos con `--build`
- [ ] 3 contenedores en estado `healthy`
- [ ] Certificados visibles dentro del contenedor frontend
- [ ] `curl https://grupovexus.com` retorna 200
- [ ] `curl https://www.grupovexus.com` retorna 200
- [ ] `curl http://grupovexus.com` redirige a HTTPS (301)
- [ ] `curl http://www.grupovexus.com` redirige a HTTPS (301)
- [ ] Chrome muestra candado verde 🔒
- [ ] Sin warnings de seguridad

---

## 🎉 SI TODO FUNCIONA

¡Felicitaciones! Tu sitio ahora está:
- ✅ Seguro con HTTPS
- ✅ Redirigiendo automáticamente de HTTP a HTTPS
- ✅ Funcionando con y sin `www`
- ✅ Con certificados válidos de Let's Encrypt
- ✅ Sin warnings de Chrome

---

## 📞 SI ALGO FALLA

Ejecuta este comando y copia el output completo:

```bash
# Reporte completo de diagnóstico
echo "=== ESTADO DE CONTENEDORES ==="
docker ps -a

echo -e "\n=== LOGS FRONTEND (últimas 50 líneas) ==="
docker logs vexus-frontend --tail 50

echo -e "\n=== VERIFICAR CERTIFICADOS EN HOST ==="
ls -la /home/ubuntu/VexusPage/ssl/live/grupovexus.com/

echo -e "\n=== VERIFICAR CERTIFICADOS EN CONTENEDOR ==="
docker exec -it vexus-frontend ls -la /etc/letsencrypt/live/grupovexus.com/

echo -e "\n=== TEST NGINX CONFIG ==="
docker exec -it vexus-frontend nginx -t

echo -e "\n=== HEALTHCHECK STATUS ==="
docker inspect vexus-frontend --format='{{.State.Health.Status}}'

echo -e "\n=== TEST HTTPS ==="
curl -I https://grupovexus.com 2>&1 | head -10
```

---

**Fecha**: Diciembre 2025
**Servidor**: AWS Lightsail
**Dominio**: grupovexus.com
**SSL**: Let's Encrypt
