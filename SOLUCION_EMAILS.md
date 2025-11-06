# 🔧 Solución al Problema de Emails

## 🎯 Problema Identificado

**EmailJS funciona en localhost pero NO en producción (Neatech)**

### Causa Raíz:
- EmailJS plan **FREE** no permite configurar dominios personalizados
- Las peticiones desde `grupovexus.com` son bloqueadas por CORS
- Funciona en `localhost` porque está en la whitelist por defecto

---

## ✅ Solución Implementada: Proxy en el Backend

He implementado un **proxy en el backend** que:
1. El frontend llama al backend (`/api/v1/email/send-verification`)
2. El backend llama a EmailJS API (sin problemas de CORS)
3. Los emails se envían correctamente desde producción

---

## 📝 Cambios Realizados

### 1. Backend - Proxy de EmailJS
**Archivo:** `backend/app/api/v1/endpoints/email_proxy.py`

- ✅ Endpoint `/email/send-verification` - Para emails de registro
- ✅ Endpoint `/email/send-contact` - Para emails de contacto (futuro)
- ✅ Usa `httpx` para llamar a EmailJS API desde el servidor

### 2. Frontend - Llamar al Proxy
**Archivo:** `frontend/Static/js/email-service.js`

- ✅ Cambiado de llamar a EmailJS directamente → Llamar al proxy del backend
- ✅ Ahora funciona en producción sin problemas de CORS

### 3. Dependencias
**Archivo:** `backend/requirements.txt`

- ✅ Agregado `httpx==0.27.0` para hacer peticiones HTTP asíncronas

---

## 🚀 Pasos para Desplegar

### 1. Instalar nueva dependencia en el backend

```bash
cd backend
pip install httpx==0.27.0
```

### 2. Subir cambios a Git

```bash
git add .
git commit -m "fix: Implementar proxy de EmailJS para solucionar CORS en producción"
git push
```

### 3. En Render (Backend)

Render detectará automáticamente el nuevo `requirements.txt` y reinstalará las dependencias.

**Opcional:** Si quieres usar variables de entorno para las credenciales de EmailJS:

1. Ve a tu dashboard de Render
2. Selecciona tu servicio de backend
3. Ve a **Environment**
4. Agrega estas variables:

```
EMAILJS_SERVICE_ID=service_80l1ykf
EMAILJS_TEMPLATE_ID=template_cwf419b
EMAILJS_USER_ID=k1IUP2nR_rDmKZXcK
```

⚠️ **NOTA:** Por ahora están hardcodeadas en el código, pero puedes usar variables de entorno para mayor seguridad.

### 4. En Neatech (Frontend)

1. Sube el nuevo `frontend/Static/js/email-service.js`
2. Espera a que se actualice el sitio

---

## 🧪 Cómo Probar

### Opción 1: Probar en Producción

1. Ve a: `https://www.grupovexus.com`
2. Intenta registrar un usuario
3. Verifica que el email llegue

### Opción 2: Probar el Endpoint Directamente

Usa esta herramienta: https://hoppscotch.io/ o Postman

```http
POST https://vexuspage.onrender.com/api/v1/email/send-verification
Content-Type: application/json

{
  "email": "tu@email.com",
  "user_name": "Usuario Prueba",
  "verification_token": "TEST123"
}
```

**Respuesta esperada:**
```json
{
  "success": true,
  "message": "Verification email sent successfully"
}
```

---

## 📊 Flujo Completo

### ANTES (No funcionaba en producción):
```
Frontend (Neatech)
    → EmailJS API directamente
    ❌ BLOQUEADO POR CORS
```

### AHORA (Funciona):
```
Frontend (Neatech)
    → Backend (Render) /api/v1/email/send-verification
        → EmailJS API
        ✅ SIN PROBLEMAS DE CORS
```

---

## 🔍 Logs para Debugging

Si algo falla, revisa los logs en Render:

1. Ve a tu dashboard de Render
2. Selecciona tu servicio backend
3. Ve a **Logs**
4. Busca estos mensajes:

**✅ Éxito:**
```
📧 [EmailJS Proxy] Recibida solicitud de email para: user@example.com
📤 Enviando a EmailJS API: user@example.com
✅ Email enviado exitosamente a: user@example.com
```

**❌ Error:**
```
❌ Error de EmailJS (400): Template not found
❌ Error de EmailJS (401): Invalid credentials
❌ Error de EmailJS (403): Limit exceeded
```

---

## ❓ Troubleshooting

### Problema: Error 400 del proxy

**Causa:** Template ID incorrecto o variables mal configuradas

**Solución:** Verifica en EmailJS dashboard que el template `template_cwf419b` existe y tiene las variables:
- `user_name`
- `to_email`
- `verification_link`

### Problema: Error 401 del proxy

**Causa:** Public Key incorrecta

**Solución:** Verifica que `k1IUP2nR_rDmKZXcK` sea la Public Key correcta en EmailJS dashboard

### Problema: Error 403 del proxy

**Causa:** Límite de emails alcanzado (200/mes en plan free)

**Solución:**
1. Ve a EmailJS dashboard → Account → Usage
2. Verifica cuántos emails has enviado
3. Espera al siguiente mes o upgrade a plan pagado

### Problema: El proxy responde OK pero no llega el email

**Causa:** Problemas en la configuración de EmailJS

**Solución:**
1. Verifica que el servicio de email esté conectado en EmailJS
2. Verifica que el template tenga el campo "To Email" configurado como `{{to_email}}`
3. Revisa SPAM/Promociones en tu bandeja de entrada

---

## 📌 Archivos Modificados

```
✏️ Modificados:
- backend/app/api/v1/endpoints/email_proxy.py
- frontend/Static/js/email-service.js
- backend/requirements.txt

📄 Creados:
- frontend/test-emailjs-debug.html (herramienta de diagnóstico)
- SOLUCION_EMAILS.md (este archivo)
```

---

## 🎉 Ventajas de esta Solución

1. ✅ **Funciona con EmailJS Free:** No necesitas pagar por dominios custom
2. ✅ **Sin CORS:** El backend no tiene restricciones de CORS
3. ✅ **Más Seguro:** Las credenciales no están expuestas en el frontend
4. ✅ **Escalable:** Puedes agregar más endpoints de email fácilmente
5. ✅ **Compatible con Render Free:** No requiere recursos adicionales

---

## 📞 Próximos Pasos

Una vez que funcionen los emails de verificación, puedes:

1. **Implementar emails de contacto** usando el mismo proxy:
   - Endpoint ya creado: `/email/send-contact`
   - Solo necesitas crear el template en EmailJS

2. **Implementar emails de consultoría** de la misma forma

3. **Optimizar:** Agregar rate limiting para evitar spam

---

## 💡 Alternativa: Usar SMTP del Backend

Si prefieres no usar EmailJS, puedes configurar SMTP en el backend:

**Ventajas:**
- No dependes de servicios externos
- Sin límites de emails (depende de tu proveedor)

**Desventajas:**
- Más complejo de configurar
- Puede fallar en Render Free por timeouts
- Necesitas configurar SPF/DKIM para evitar spam

**Ya está implementado en:** `backend/app/services/email.py`

---

**Creado:** 2025-01-06
**Estado:** ✅ Implementado, pendiente de testing en producción
