# 📧 Cómo Configurar SMTP para Envío de Emails

## 🎯 Problema Actual

- ❌ EmailJS NO funciona desde el backend (solo navegador)
- ❌ Necesitas configurar SMTP en Render para enviar emails

---

## ✅ SOLUCIÓN: Configurar Gmail SMTP (GRATIS y FÁCIL)

### **Requisitos:**
- Cuenta de Gmail: `grupovexus@gmail.com`
- Acceso a la configuración de seguridad de Gmail

---

## 📝 **Paso a Paso: Obtener App Password de Gmail**

### **Paso 1: Activar Verificación en 2 Pasos**

1. Ve a: **https://myaccount.google.com/security**
2. Busca la sección **"Verificación en dos pasos"**
3. Si no está activada, haz clic en **"Empezar"** y sigue los pasos
4. Usa tu teléfono para recibir códigos de verificación

### **Paso 2: Generar App Password**

Una vez activada la verificación en 2 pasos:

1. Ve a: **https://myaccount.google.com/apppasswords**
2. En "Seleccionar app", elige: **"Correo"** o **"Otra (nombre personalizado)"**
   - Si eliges "Otra", ponle nombre: **"Vexus Backend"**
3. En "Seleccionar dispositivo", elige: **"Otro (nombre personalizado)"**
   - Ponle nombre: **"Render Server"**
4. Haz clic en **"Generar"**

**IMPORTANTE:** Gmail te mostrará una contraseña de 16 caracteres como esta:
```
xxxx xxxx xxxx xxxx
```

**¡CÓPIALA AHORA!** No la volverás a ver.

### **Paso 3: Configurar en Render**

1. Ve a tu dashboard de Render: **https://dashboard.render.com/**
2. Selecciona tu servicio de backend (vexuspage)
3. Ve a la pestaña **"Environment"**
4. Agrega estas 5 variables de entorno:

```
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USER=grupovexus@gmail.com
SMTP_PASSWORD=xxxx xxxx xxxx xxxx    ← Pega aquí la App Password (CON espacios o SIN espacios, ambos funcionan)
EMAIL_FROM=grupovexus@gmail.com
```

5. Haz clic en **"Save Changes"**
6. Render reiniciará automáticamente el servicio

---

## 🧪 **Cómo Probar que Funciona**

### **Opción 1: Probar con Postman**

Espera 2-3 minutos después de configurar las variables, luego:

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

### **Opción 2: Usar la herramienta de prueba**

Abre el archivo `frontend/test-proxy-emails.html` en tu navegador y prueba.

---

## 🔍 **Verificar en los Logs de Render**

Ve a: Dashboard → Tu servicio → **Logs**

**Si funciona correctamente, verás:**
```
📧 [Email Proxy] Recibida solicitud de verificación para: tu@email.com
🔌 Conectando a SMTP: smtp.gmail.com:587
✅ Email de verificación enviado exitosamente a tu@email.com
```

**Si hay error, verás:**
```
❌ ERROR DE AUTENTICACIÓN SMTP
🔐 Verifica que SMTP_PASSWORD sea un App Password válido
```

---

## ⚠️ **Troubleshooting**

### **Error: "Authentication failed"**

**Causa:** App Password incorrecta

**Solución:**
1. Genera una nueva App Password desde Gmail
2. Actualiza `SMTP_PASSWORD` en Render
3. Asegúrate de NO usar tu contraseña normal de Gmail

### **Error: "Timeout"**

**Causa:** Render Free puede tener restricciones de red

**Solución:**
1. Verifica que `SMTP_PORT=587` (NO uses 465)
2. Espera 2-3 minutos y vuelve a intentar
3. Si persiste, considera usar SendGrid

### **Error: "Connection refused"**

**Causa:** Puerto bloqueado o configuración incorrecta

**Solución:**
```
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587    ← IMPORTANTE: usar 587, NO 465
```

---

## 🎉 **Alternativa: SendGrid (si Gmail no funciona)**

Si Gmail SMTP sigue fallando en Render, usa SendGrid:

### **Paso 1: Crear cuenta en SendGrid**

1. Ve a: **https://signup.sendgrid.com/**
2. Crea cuenta gratuita (100 emails/día gratis)
3. Verifica tu email
4. Ve a: **Settings → API Keys**
5. Crea una nueva API Key con permisos de "Mail Send"

### **Paso 2: Configurar en Render**

```
SMTP_HOST=smtp.sendgrid.net
SMTP_PORT=587
SMTP_USER=apikey
SMTP_PASSWORD=SG.xxxxxxxxxxxxxxxxxxxxxxxxxxxxx    ← Tu API Key de SendGrid
EMAIL_FROM=grupovexus@gmail.com
```

---

## 📊 **¿Cuál usar?**

| Opción | Pros | Contras | Recomendación |
|--------|------|---------|---------------|
| **Gmail SMTP** | Gratis, fácil, familiar | Puede tener límites, a veces bloqueado | ⭐⭐⭐⭐ Prueba primero |
| **SendGrid** | Más confiable, diseñado para esto | Requiere configuración extra | ⭐⭐⭐⭐⭐ Si Gmail falla |

---

## 📋 **Checklist**

- [ ] Activar verificación en 2 pasos en Gmail
- [ ] Generar App Password
- [ ] Copiar la App Password (16 caracteres)
- [ ] Agregar variables en Render (SMTP_HOST, SMTP_PORT, SMTP_USER, SMTP_PASSWORD, EMAIL_FROM)
- [ ] Guardar cambios en Render
- [ ] Esperar 2-3 minutos
- [ ] Probar con Postman
- [ ] Verificar que el email llegue
- [ ] Subir frontend actualizado a Neatech

---

## 🚀 **Después de Configurar**

1. **Sube los cambios a Git:**
   ```bash
   git add .
   git commit -m "fix: Cambiar proxy de EmailJS a SMTP del backend"
   git push
   ```

2. **Sube el frontend a Neatech**
   - El archivo `frontend/Static/js/email-service.js` ya está actualizado

3. **Prueba el registro** en producción:
   - Ve a: https://www.grupovexus.com
   - Registra un usuario
   - Verifica que llegue el email

---

**Creado:** 2025-01-06
**Estado:** Listo para implementar
