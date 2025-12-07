# 🧪 PRUEBA DE SENDGRID - PASO A PASO

## 📋 PROBLEMA ACTUAL

- Tienes 3 archivos `.env` en AWS Lightsail: `.env`, `.env.production`, `.env.production.example`
- Esto puede causar conflictos (Docker puede cargar el `.env` equivocado)
- SendGrid no detecta tu email de prueba

---

## ✅ SOLUCIÓN - PASO A PASO

### 1️⃣ CONECTARSE AL SERVIDOR

```bash
ssh ubuntu@tu-ip-lightsail
cd ~/VexusPage
```

### 2️⃣ LIMPIAR ARCHIVOS .ENV DUPLICADOS

```bash
# Ver qué archivos .env existen
ls -la | grep env

# ELIMINAR los archivos que no necesitas
rm -f .env
rm -f .env.production.example

# Verificar que solo quede .env.production
ls -la | grep env
# Debe mostrar SOLO: .env.production
```

### 3️⃣ HACER PULL DE LOS CAMBIOS

```bash
git pull origin main
```

### 4️⃣ INSTALAR SENDGRID (si no está instalado)

```bash
# Verificar si sendgrid está instalado
pip list | grep sendgrid

# Si NO aparece, instalar:
pip install sendgrid
```

### 5️⃣ EJECUTAR SCRIPT DE PRUEBA

```bash
# Configurar la API key como variable de entorno (usa tu API key real de SendGrid)
export SENDGRID_API_KEY="TU_API_KEY_AQUI"

# Ejecutar el script de prueba
python3 test_sendgrid.py
```

**IMPORTANTE:** Reemplaza `TU_API_KEY_AQUI` con tu API key real de SendGrid (empieza con `SG.`).

**Deberías ver:**

```
============================================================
🧪 TEST DE SENDGRID
============================================================
📧 From: grupovexus@gmail.com
📧 To: grupovexus@gmail.com
🔑 API Key: SG.ZoZ_jx-WQgu...w-10
============================================================

📤 Enviando email de prueba...

============================================================
✅ RESPUESTA DE SENDGRID:
============================================================
Status Code: 202
Body: 
Headers: ...
============================================================

🎉 ¡EMAIL ENVIADO EXITOSAMENTE!
📬 Revisa tu bandeja de entrada: grupovexus@gmail.com

✅ SendGrid está configurado correctamente
```

---

## ⚠️ POSIBLES ERRORES

### Error 401 - Unauthorized

```
⚠️ ERROR DE AUTENTICACIÓN:
   - Verifica que tu API Key sea correcta
   - Verifica que la API Key tenga permisos de 'Mail Send'
```

**Solución:**
1. Ve a https://app.sendgrid.com/settings/api_keys
2. Verifica que tu API key tenga permisos de "Mail Send"
3. Si no, crea una nueva API key con "Full Access"

### Error 403 - Forbidden

```
⚠️ ERROR DE PERMISOS:
   - Verifica que el email FROM esté verificado en SendGrid
```

**Solución:**
1. Ve a https://app.sendgrid.com/settings/sender_auth
2. Verifica tu email `grupovexus@gmail.com`
3. O usa "Single Sender Verification" para verificar rápidamente

---

## 6️⃣ SI LA PRUEBA FUNCIONA → DEPLOY COMPLETO

```bash
# Parar contenedores
docker-compose -f docker-compose.prod.yml down

# Reconstruir backend
docker-compose -f docker-compose.prod.yml build backend

# Iniciar todo
docker-compose -f docker-compose.prod.yml up -d

# Ver logs
docker logs -f vexus-backend
```

Deberías ver en los logs:

```
📧 Enviando email via SendGrid SDK a: grupovexus@gmail.com
🔑 SendGrid API Key presente: SG.ZoZ_jx-W...w-10
✅ SendGrid Response Status: 202
✅ Email enviado exitosamente via SendGrid
```

---

## 7️⃣ PROBAR DESDE EL SITIO WEB

1. Abre https://www.grupovexus.com
2. Llena el formulario de consultoría
3. Envía
4. ✅ Debes recibir el email en menos de 2 segundos

---

## 🔍 VERIFICAR VARIABLES DE ENTORNO DEL CONTENEDOR

Si aún no funciona, verifica que el contenedor tenga la API key:

```bash
docker exec vexus-backend env | grep SENDGRID
```

Debe mostrar:
```
SENDGRID_API_KEY=SG.ZoZ_jx-W... (tu API key)
```

Si NO aparece, significa que el `.env.production` no se está leyendo.

---

## 📝 NOTAS IMPORTANTES

1. **SOLO debe existir `.env.production`** - elimina `.env` y `.env.production.example`
2. **El script `test_sendgrid.py` prueba SOLO SendGrid** sin Docker
3. **Una vez que funcione el test**, el deploy completo funcionará
4. **SendGrid usa puerto 443 (HTTPS)** - no tiene problemas con AWS Lightsail
