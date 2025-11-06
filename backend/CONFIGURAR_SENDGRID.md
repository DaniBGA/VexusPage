# Configuración de SendGrid para Vexus Backend

## Por qué SendGrid HTTP API

**Problema resuelto**: Render Free bloquea conexiones SMTP (puertos 587, 465), incluyendo:
- Gmail SMTP ❌
- SendGrid SMTP ❌

**Solución**: SendGrid HTTP API ✅ (usa puertos HTTP/HTTPS estándar, NO bloqueados)

---

## Paso 1: Crear cuenta en SendGrid

1. Ve a https://sendgrid.com/
2. Haz clic en "Start for Free"
3. Regístrate con tu email (puedes usar grupovexus@gmail.com)
4. Verifica tu email
5. **Plan Free incluye**: 100 emails/día gratis (suficiente para testing y uso inicial)

---

## Paso 2: Obtener SendGrid API Key

1. Inicia sesión en https://app.sendgrid.com/
2. Ve a **Settings** → **API Keys** (en el menú lateral izquierdo)
3. Haz clic en **"Create API Key"**
4. Configuración:
   - **API Key Name**: `Vexus Backend Production`
   - **API Key Permissions**: Selecciona **"Full Access"** (o "Restricted Access" → "Mail Send" → "Full Access")
5. Haz clic en **"Create & View"**
6. **IMPORTANTE**: Copia la API Key INMEDIATAMENTE (comienza con `SG.`)
   - Solo se muestra UNA VEZ
   - Si la pierdes, deberás crear una nueva

Ejemplo de API Key:
```
SG.xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
```

---

## Paso 3: Verificar Sender Identity (Dominio o Email)

SendGrid requiere verificar el email desde el cual enviarás:

### Opción A: Single Sender Verification (Más rápido, recomendado para empezar)

1. Ve a **Settings** → **Sender Authentication**
2. Haz clic en **"Verify a Single Sender"**
3. Completa el formulario:
   - **From Email Address**: `grupovexus@gmail.com`
   - **From Name**: `Vexus`
   - **Reply To**: `grupovexus@gmail.com`
   - **Company Address**: Tu dirección
4. Haz clic en **"Create"**
5. **Revisa tu email** (`grupovexus@gmail.com`) y haz clic en el link de verificación

### Opción B: Domain Authentication (Más profesional, pero requiere acceso a DNS)

Si quieres enviar desde `@grupovexus.com`:
1. Ve a **Settings** → **Sender Authentication**
2. Haz clic en **"Authenticate Your Domain"**
3. Sigue las instrucciones para agregar registros DNS
4. Esto requiere acceso al DNS de tu dominio

**Para empezar, usa la Opción A** (Single Sender con Gmail)

---

## Paso 4: Configurar Variables de Entorno en Render

1. Ve a tu Dashboard de Render: https://dashboard.render.com/
2. Selecciona tu servicio **"vexus-backend"** (o como lo hayas nombrado)
3. Ve a la pestaña **"Environment"**
4. Agrega/actualiza estas variables:

```bash
# SendGrid API Key (la que copiaste en el Paso 2)
SMTP_PASSWORD=SG.xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

# Email desde el cual enviarás (debe estar verificado en SendGrid)
EMAIL_FROM=grupovexus@gmail.com

# Frontend URL (para links de verificación)
FRONTEND_URL=https://grupovexus.com
```

5. **IMPORTANTE**: Después de agregar/modificar variables, haz clic en **"Manual Deploy"** → **"Deploy latest commit"** para reiniciar el servicio

---

## Paso 5: Verificar que Funciona

### Opción A: Desde la interfaz web
1. Ve a https://grupovexus.com
2. Intenta registrarte con un email real
3. Revisa tu bandeja de entrada (y spam)

### Opción B: Probar el endpoint directamente
```bash
curl -X POST https://tu-backend.onrender.com/api/v1/email/send-verification \
  -H "Content-Type: application/json" \
  -d '{
    "email": "tu_email@gmail.com",
    "user_name": "Test User",
    "verification_token": "test123"
  }'
```

Respuesta esperada:
```json
{
  "success": true,
  "message": "Verification email sent successfully"
}
```

---

## Troubleshooting

### Error: "Failed to send verification email. Please configure SendGrid API Key."

**Causa**: La API Key no está configurada o es incorrecta

**Solución**:
1. Verifica que `SMTP_PASSWORD` en Render empiece con `SG.`
2. Asegúrate de haber copiado la API Key completa
3. Reinicia el servicio en Render después de cambiar variables

### Error: "403 Forbidden" o "Sender verification required"

**Causa**: El email en `EMAIL_FROM` no está verificado en SendGrid

**Solución**:
1. Ve a SendGrid → Settings → Sender Authentication
2. Verifica que tu email aparezca como "Verified"
3. Si no, completa el proceso de verificación (Paso 3)

### Emails no llegan (pero API devuelve success)

**Causas posibles**:
1. **Revisa spam/junk folder**
2. **SendGrid está en modo "sandbox"**: Durante los primeros días, SendGrid puede limitar entregas
3. **Límite de free tier alcanzado**: 100 emails/día en plan free

**Solución**:
1. Revisa la carpeta de spam
2. Ve a SendGrid → Activity para ver el estado de los emails
3. Si es necesario, actualiza a plan paid de SendGrid

---

## Arquitectura Actual

```
Frontend (grupovexus.com)
    ↓
    | HTTP POST /api/v1/email/send-verification
    ↓
Backend en Render
    ↓
    | SendGrid HTTP API (puerto 443)
    ↓
SendGrid
    ↓
    | SMTP externo (SendGrid maneja esto)
    ↓
Usuario (Gmail, etc.)
```

**Ventaja**: Render NO bloquea HTTP/HTTPS, solo SMTP directo

---

## Resumen de Archivos Modificados

- `backend/app/api/v1/endpoints/email_proxy.py`: Endpoints que usan SendGrid HTTP API
- `backend/app/services/email_sendgrid.py`: Implementación de SendGrid HTTP API
- `frontend/Static/js/email-service.js`: Llama al backend proxy
- `backend/requirements.txt`: Incluye `sendgrid==6.11.0`

---

## Notas Importantes

1. **API Key es SECRETA**: Nunca la compartas ni la subas a Git
2. **Plan Free de SendGrid**: 100 emails/día (suficiente para empezar)
3. **Emails transaccionales**: Verificación y contacto son transaccionales (alta tasa de entrega)
4. **Monitoreo**: Usa SendGrid Activity dashboard para ver estadísticas

---

¿Necesitas ayuda? Revisa los logs en Render para más detalles sobre errores.
