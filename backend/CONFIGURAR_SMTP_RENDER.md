# 📧 Configurar SMTP en Render

## 🚀 Solución Implementada: Email Asíncrono con BackgroundTasks

Se ha implementado una solución profesional para el envío de emails:

### ✅ Cambios Realizados:

1. **SMTP Asíncrono con `aiosmtplib`**
   - Reemplazado `smtplib` (síncrono) por `aiosmtplib` (asíncrono)
   - Conexiones no bloqueantes con timeout de 5 segundos
   - Mejor manejo de errores de red

2. **BackgroundTasks de FastAPI**
   - Los emails se envían **después** de que el usuario recibe la respuesta
   - El registro de usuario es **instantáneo** (no espera el email)
   - No más timeouts de 3 segundos bloqueando la respuesta

3. **Mejor Logging**
   - Mensajes claros sobre el estado del email
   - Indicador cuando SMTP no está configurado
   - Los emails se agregan a cola en background

### 📊 Antes vs Después:

| Aspecto | ❌ Antes | ✅ Después |
|---------|---------|-----------|
| Tiempo de registro | ~3-5 segundos | <500ms |
| Bloqueo por email | Sí, 3 segundos | No, en background |
| Error de red | Bloquea registro | No afecta registro |
| Librería SMTP | smtplib (sync) | aiosmtplib (async) |

---

## 🔧 Configurar Variables SMTP en Render

### Paso 1: Obtener App Password de Gmail

1. Ve a tu cuenta de Google: https://myaccount.google.com
2. Seguridad → Verificación en 2 pasos (activarla si no lo está)
3. Contraseñas de aplicación: https://myaccount.google.com/apppasswords
4. Genera una nueva contraseña de aplicación para "Correo"
5. Copia la contraseña de 16 caracteres (formato: `xxxx xxxx xxxx xxxx`)

### Paso 2: Configurar Variables en Render

1. Ve a tu servicio en Render Dashboard
2. Environment → Add Environment Variable
3. Agrega las siguientes variables:

```bash
# Email Configuration
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USER=grupovexus@gmail.com
SMTP_PASSWORD=tu_app_password_de_16_caracteres
EMAIL_FROM=grupovexus@gmail.com
```

### Paso 3: Re-deployar

Render detectará los cambios automáticamente, o puedes forzar un re-deploy:
- Manual Deploy → Deploy latest commit

---

## 🧪 Verificar que Funciona

### Logs Esperados SIN SMTP configurado:
```
🔔 Registration attempt for email: test@example.com
✅ User created successfully: test@example.com (auto_verify=False)
📧 Email de verificación agregado a cola en background para test@example.com
⚠️ SMTP no configurado. Falta configurar: SMTP_HOST, SMTP_USER, SMTP_PASSWORD
```

### Logs Esperados CON SMTP configurado:
```
🔔 Registration attempt for email: test@example.com
✅ User created successfully: test@example.com (auto_verify=False)
📧 Email de verificación agregado a cola en background para test@example.com
✅ Email de verificación enviado a test@example.com
```

---

## 🔥 Alternativas si Gmail no Funciona

### Opción 1: Resend (Recomendado - Gratis para 3k emails/mes)
```bash
# 1. Regístrate en https://resend.com
# 2. Obtén tu API key
# 3. Cambiar a usar Resend API en lugar de SMTP
pip install resend
```

### Opción 2: SendGrid (50k emails gratis/mes)
```bash
# 1. Regístrate en https://sendgrid.com
# 2. Obtén tu API key
# 3. Configurar:
SMTP_HOST=smtp.sendgrid.net
SMTP_PORT=587
SMTP_USER=apikey
SMTP_PASSWORD=tu_sendgrid_api_key
EMAIL_FROM=noreply@grupovexus.com
```

### Opción 3: Deshabilitar Email Verification (temporal)
En `backend/app/api/v1/endpoints/auth.py` línea 54:
```python
auto_verify = True  # Deshabilitar verificación temporal
```

---

## 📝 Notas Importantes

1. **Gmail SMTP tiene límites**: 500 emails/día en cuentas gratuitas
2. **Render Free Tier**: Las instancias se duermen después de 15 minutos de inactividad
3. **Primera conexión SMTP**: Puede tardar más debido al cold start
4. **Logs en Render**: Puedes ver los logs en tiempo real para debugging

---

## 🎯 Siguiente Paso Recomendado

Una vez que verifiques que todo funciona, considera migrar a **Resend** o **SendGrid** para:
- Mayor confiabilidad
- Mejor deliverability
- Templates profesionales
- Analytics de emails
- Sin límites de Gmail

¿Necesitas ayuda para configurar alguna de estas alternativas?
