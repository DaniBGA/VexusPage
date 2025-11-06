# SendGrid - Guía Rápida (5 minutos)

## 🚀 Setup Rápido

### 1️⃣ Crear cuenta SendGrid
https://sendgrid.com/ → "Start for Free" → Verificar email

### 2️⃣ Obtener API Key
1. https://app.sendgrid.com/
2. Settings → API Keys
3. Create API Key → Full Access
4. **COPIAR LA KEY** (empieza con `SG.`)

### 3️⃣ Verificar email sender
1. Settings → Sender Authentication
2. "Verify a Single Sender"
3. Email: `grupovexus@gmail.com`
4. Verificar en tu email

### 4️⃣ Configurar en Render
Dashboard → tu servicio → Environment → Agregar:

```
SMTP_PASSWORD=SG.tu_api_key_completa_aqui
EMAIL_FROM=grupovexus@gmail.com
FRONTEND_URL=https://grupovexus.com
```

Guardar → Manual Deploy → Deploy latest commit

### 5️⃣ Probar
Ir a https://grupovexus.com → Registrarse → Revisar email

---

## ✅ Verificación Rápida

**Backend logs en Render deberían mostrar**:
```
📧 [Email Proxy HTTP] Recibida solicitud de verificación para: email@ejemplo.com
✅ Email enviado exitosamente a email@ejemplo.com
📊 Status Code: 202
```

**Si ves esto, todo funciona** ✅

---

## ❌ Errores Comunes

| Error | Solución |
|-------|----------|
| "Please configure SendGrid API Key" | API Key no está en Render o no empieza con `SG.` |
| "403 Forbidden" | Email no verificado en SendGrid |
| Email no llega | Revisar carpeta spam |

---

## 📊 Límites Free Plan

- **100 emails/día** - Suficiente para empezar
- Si necesitas más: Plan Essentials ($15/mes) = 50,000 emails/mes

---

**Documentación completa**: Ver `CONFIGURAR_SENDGRID.md`
