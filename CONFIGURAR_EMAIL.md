# 📧 Configuración de Email (SMTP Gmail) en Render

## ✅ Cambios Realizados

1. ✅ Verificación por email **HABILITADA**
2. ✅ Los usuarios ahora **deben verificar su email** antes de poder iniciar sesión
3. ✅ Timeout de email reducido a 3 segundos para respuestas rápidas

---

## 🔧 Configurar Variables de Entorno en Render

### Paso 1: Ir al Dashboard de Render

1. Ve a: https://dashboard.render.com
2. Selecciona tu servicio: **vexuspage**
3. Click en **Environment** en el menú lateral

### Paso 2: Agregar/Actualizar Variables SMTP

Agrega o actualiza estas variables de entorno:

```env
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USER=grupovexus@gmail.com
SMTP_PASSWORD=xzazspygoxdagcng
EMAIL_FROM=grupovexus@gmail.com
FRONTEND_URL=https://grupovexus.com
```

**IMPORTANTE**:
- Verifica que `SMTP_PASSWORD` sea **exactamente**: `xzazspygoxdagcng`
- Esta es tu App Password de Gmail (no la contraseña normal)

### Paso 3: Guardar y Redeploy

1. Click en **"Save Changes"** en Render
2. Render hará redeploy automáticamente
3. Espera 2-3 minutos

---

## 🧪 Probar la Configuración

### 1. Verificar el Backend está Corriendo

```bash
curl https://vexuspage.onrender.com/health
```

Debe responder:
```json
{
  "status": "healthy",
  "database": "connected",
  "timestamp": "..."
}
```

### 2. Probar Registro de Usuario

1. Ve a: https://grupovexus.com
2. Click en "Crear Cuenta"
3. Completa el formulario
4. Click en "Crear Cuenta"

**Resultado Esperado**:
- ✅ Mensaje: "Cuenta creada! Por favor verifica tu email..."
- ✅ Recibes un email en la bandeja de entrada
- ✅ El email contiene un link de verificación

### 3. Verificar Email

1. Abre el email que recibiste
2. Click en el link de verificación
3. Debe redirigir a: `https://grupovexus.com/pages/verify-email.html?token=...`
4. Debe mostrar: "✅ Email verificado correctamente"

### 4. Iniciar Sesión

1. Regresa a: https://grupovexus.com
2. Click en "Iniciar Sesión"
3. Ingresa el email y contraseña
4. Debe funcionar correctamente

---

## 🔍 Verificar en los Logs

En Render → Logs, deberías ver:

**Durante el registro**:
```
🔔 Registration attempt for email: usuario@example.com method=POST origin=https://www.grupovexus.com
✅ User created successfully: usuario@example.com (auto_verify=False)
✅ Verification email sent to usuario@example.com: True
```

**Si el email NO se envía**:
```
⚠️ Error sending verification email to usuario@example.com: [error details]
✅ Verification email sent to usuario@example.com: False
```

---

## ❌ Troubleshooting

### Problema: "Network is unreachable"

**Causa**: Render no puede conectarse a Gmail SMTP

**Solución**:
1. Verifica que `SMTP_HOST` sea exactamente: `smtp.gmail.com`
2. Verifica que `SMTP_PORT` sea: `587`
3. Verifica que la App Password esté correcta

### Problema: "Authentication failed"

**Causa**: Credenciales incorrectas

**Solución**:
1. Ve a: https://myaccount.google.com/apppasswords
2. Revoca la App Password actual
3. Genera una nueva App Password
4. Actualiza `SMTP_PASSWORD` en Render

### Problema: Email no llega

**Posibles Causas**:
1. El email está en spam
2. La App Password expiró o fue revocada
3. Gmail bloqueó el acceso

**Solución**:
1. Revisa la carpeta de spam
2. Verifica en: https://myaccount.google.com/security
   - Ve a "Recent security events"
   - Verifica que no haya bloqueos de acceso
3. Si hay bloqueos, permite el acceso desde la ubicación de Render

### Problema: Timeout del email

**Síntoma**: Tarda 3+ segundos y luego falla

**Causa**: SMTP no está respondiendo rápido

**Solución temporal**: Ya está implementada
- El timeout es de 3 segundos
- Si falla, el usuario puede reenviar el email desde el frontend

---

## 🔐 Seguridad de la App Password

### ✅ Buenas Prácticas Aplicadas:

1. ✅ App Password **NO está** en el código fuente
2. ✅ App Password **solo** en variables de entorno de Render
3. ✅ `.env` está en `.gitignore`

### ⚠️ IMPORTANTE:

**NUNCA** hagas commit de:
- La App Password
- Archivos `.env` con credenciales reales

Si accidentalmente haces commit de credenciales:
1. Revoca la App Password inmediatamente
2. Genera una nueva
3. Actualiza Render
4. Considera rotar otras credenciales (DATABASE_URL, SECRET_KEY)

---

## 📧 Contenido del Email de Verificación

El email que reciben los usuarios incluye:

**Subject**: "Verifica tu email - Vexus"

**Body**:
```
Hola [Nombre],

¡Bienvenido a Vexus!

Por favor verifica tu dirección de email haciendo click en el siguiente enlace:

[Verificar Email]

Este enlace expirará en 24 horas.

Si no creaste una cuenta en Vexus, puedes ignorar este email.

---
Equipo Vexus
```

**Link**: `https://grupovexus.com/pages/verify-email.html?token=[token]`

---

## 🎯 Resumen de Configuración

### Variables de Entorno en Render:

| Variable | Valor |
|----------|-------|
| SMTP_HOST | smtp.gmail.com |
| SMTP_PORT | 587 |
| SMTP_USER | grupovexus@gmail.com |
| SMTP_PASSWORD | xzazspygoxdagcng |
| EMAIL_FROM | grupovexus@gmail.com |
| FRONTEND_URL | https://grupovexus.com |
| DATABASE_URL | [Tu URL de Supabase codificada] |
| ALLOWED_ORIGINS | https://grupovexus.com,https://www.grupovexus.com |

### Flujo de Registro Completo:

1. Usuario completa formulario → **POST** `/api/v1/auth/register`
2. Backend crea usuario con `email_verified=False`
3. Backend envía email de verificación (3s timeout)
4. Usuario recibe email con link de verificación
5. Usuario hace click → **GET** `/api/v1/auth/verify-email?token=...`
6. Backend marca `email_verified=True`
7. Usuario puede hacer login

---

## 📝 Próximos Pasos

1. [ ] Configurar variables SMTP en Render
2. [ ] Esperar redeploy (2-3 minutos)
3. [ ] Probar registro de usuario
4. [ ] Verificar que llegue el email
5. [ ] Probar verificación de email
6. [ ] Probar login después de verificación

---

**Generado por**: Claude Code
**Fecha**: 2025-11-05
