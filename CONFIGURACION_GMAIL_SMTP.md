# 📧 Guía: Configurar Gmail SMTP para Vexus

## 🎯 Objetivo
Configurar Gmail SMTP para enviar emails de verificación y contacto desde el backend de Vexus.

---

## 📋 Requisitos Previos

- ✅ Cuenta de Gmail activa
- ✅ Verificación en 2 pasos habilitada
- ✅ Acceso a Google Account

---

## 🔐 Paso 1: Habilitar Verificación en 2 Pasos

1. Ve a tu cuenta de Google: https://myaccount.google.com/security
2. En la sección "Inicio de sesión en Google", haz clic en "Verificación en dos pasos"
3. Sigue las instrucciones para habilitar la verificación en 2 pasos
4. Usa tu método preferido (SMS, app autenticadora, etc.)

**⚠️ IMPORTANTE**: Sin verificación en 2 pasos, no podrás generar App Passwords.

---

## 🔑 Paso 2: Generar App Password

1. Ve a **Google App Passwords**: https://myaccount.google.com/apppasswords
2. Si no ves esta opción:
   - Verifica que la verificación en 2 pasos esté activada
   - Prueba acceder directamente al enlace de arriba
3. En "Selecciona la app", elige **Otra (nombre personalizado)**
4. Escribe: `Vexus Backend`
5. Haz clic en **Generar**
6. Google te mostrará un App Password de **16 caracteres**
7. **Copia este password inmediatamente** (no podrás verlo de nuevo)

**Formato del App Password:**
```
abcd efgh ijkl mnop
```

**⚠️ IMPORTANTE**: 
- NO uses tu contraseña normal de Gmail
- NO compartas este App Password
- Si lo pierdes, genera uno nuevo

---

## ⚙️ Paso 3: Configurar Variables de Entorno

### En Desarrollo Local

Edita `.env` o crea `.env.local` en `backend/`:

```bash
# Gmail SMTP Configuration
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USER=tu_email@gmail.com
SMTP_PASSWORD=abcdefghijklmnop  # ⚠️ Sin espacios, 16 caracteres
EMAIL_FROM=tu_email@gmail.com
```

### En Producción (AWS Lightsail)

Edita `.env.production`:

```bash
# === EMAIL (Gmail SMTP) ===
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USER=grupovexus@gmail.com
SMTP_PASSWORD=abcdefghijklmnop  # ⚠️ App Password sin espacios
EMAIL_FROM=grupovexus@gmail.com
```

**⚠️ CRÍTICO**:
- Elimina los espacios del App Password: `abcd efgh ijkl mnop` → `abcdefghijklmnop`
- Usa el mismo email en `SMTP_USER` y `EMAIL_FROM`
- Usa puerto `587` (TLS/STARTTLS)

---

## 🐳 Paso 4: Actualizar Docker (Producción)

Si estás usando Docker, reconstruye el backend:

```bash
# Detener contenedores
docker-compose -f docker-compose.prod.yml down

# Reconstruir backend con nuevas variables
docker-compose -f docker-compose.prod.yml build backend

# Iniciar todo
docker-compose -f docker-compose.prod.yml up -d

# Ver logs para verificar
docker logs vexus-backend -f
```

---

## ✅ Paso 5: Verificar Configuración

### Opción A: Endpoint de Debug (Recomendado)

```bash
curl -X POST http://localhost:8000/api/v1/debug/test-email \
  -H "Content-Type: application/json" \
  -d '{
    "email": "tu_email_de_prueba@gmail.com",
    "name": "Test User"
  }'
```

**Respuesta esperada:**
```json
{
  "success": true,
  "message": "✅ Email de prueba enviado exitosamente a tu_email_de_prueba@gmail.com usando Gmail SMTP. Revisa tu bandeja (y spam).",
  "email_sent_to": "tu_email_de_prueba@gmail.com",
  "method": "Gmail SMTP"
}
```

### Opción B: Verificar Variables

```bash
curl http://localhost:8000/api/v1/debug/smtp-status
```

**Respuesta esperada:**
```json
{
  "smtp_configured": true,
  "gmail_configured": true,
  "missing_variables": [],
  "config": {
    "smtp_host": "smtp.gmail.com",
    "smtp_port": 587,
    "smtp_user": "tu_email@gmail.com",
    "smtp_password_set": true,
    "email_from": "tu_email@gmail.com",
    "frontend_url": "http://localhost",
    "gmail_configured": true
  },
  "message": "Gmail SMTP configurado ✅",
  "note": "Gmail SMTP requiere: smtp.gmail.com:587 con App Password"
}
```

### Opción C: Registro de Usuario

1. Ve a tu frontend
2. Registra un usuario nuevo
3. Revisa tu bandeja de Gmail (y carpeta de spam)
4. Deberías recibir un email de verificación

---

## 🔍 Troubleshooting

### ❌ Error: "Authentication failed"

**Causa**: App Password incorrecto o verificación en 2 pasos no habilitada

**Solución**:
1. Verifica que la verificación en 2 pasos esté activa
2. Regenera el App Password: https://myaccount.google.com/apppasswords
3. Copia el nuevo password **sin espacios**
4. Actualiza `SMTP_PASSWORD` en `.env.production`
5. Reconstruye el contenedor Docker

```bash
docker-compose -f docker-compose.prod.yml down
docker-compose -f docker-compose.prod.yml up -d --build
```

---

### ❌ Error: "SMTP not configured"

**Causa**: Variables de entorno no cargadas

**Solución**:
1. Verifica que `.env.production` tenga todas las variables:
```bash
cat .env.production | grep SMTP
```

2. Deberías ver:
```bash
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USER=tu_email@gmail.com
SMTP_PASSWORD=abcdefghijklmnop
```

3. Si faltan variables, agrégalas y reconstruye:
```bash
docker-compose -f docker-compose.prod.yml down
docker-compose -f docker-compose.prod.yml up -d --build
```

---

### ❌ Error: "Timeout" o "Connection refused"

**Causa**: Puerto 587 bloqueado o servidor SMTP inaccesible

**Solución 1 - Verificar conectividad:**
```bash
telnet smtp.gmail.com 587
```

Si falla, tu servidor/firewall está bloqueando el puerto 587.

**Solución 2 - En AWS Lightsail:**

1. Ve a tu instancia en AWS Console
2. Click en "Networking" tab
3. Asegúrate de que el puerto 587 (SMTP) esté permitido en **Outbound Rules**
4. Si es necesario, edita el firewall para permitir tráfico saliente a 587

**Solución 3 - Alternativa (puerto 465):**

Si el puerto 587 está bloqueado, intenta con 465 (SSL):

```bash
SMTP_HOST=smtp.gmail.com
SMTP_PORT=465  # ⚠️ Cambiado de 587
SMTP_USER=tu_email@gmail.com
SMTP_PASSWORD=abcdefghijklmnop
```

---

### ❌ Error: "Email not received"

**Causa**: Email marcado como spam o dirección incorrecta

**Solución**:
1. Revisa tu carpeta de **Spam** en Gmail
2. Marca el email como "No es spam" si aparece ahí
3. Verifica que `EMAIL_FROM` use el mismo email que `SMTP_USER`
4. Considera agregar un registro SPF en tu DNS (si usas dominio personalizado)

---

### ⏱️ Error: "Operation timed out after 30 seconds"

**Causa**: Servidor SMTP de Gmail lento o sobrecargado

**Solución**:
1. Esto es normal en despliegues nuevos (cold start)
2. Reintenta después de unos minutos
3. Verifica logs del backend:
```bash
docker logs vexus-backend -f
```

4. Si persiste, verifica tu conexión a internet del servidor

---

## 📊 Límites de Gmail SMTP

| Tipo de Cuenta | Límite Diario |
|----------------|---------------|
| Gmail gratuito | 500 emails/día |
| Google Workspace | 2,000 emails/día |

**⚠️ IMPORTANTE**: 
- Si superas el límite, Gmail bloqueará el envío por 24 horas
- Para volúmenes mayores, considera usar SendGrid o Amazon SES

---

## 🔒 Seguridad

### Buenas Prácticas

1. ✅ **Nunca** compartas tu App Password
2. ✅ **Nunca** subas `.env.production` a Git (usa `.gitignore`)
3. ✅ Regenera el App Password si crees que fue comprometido
4. ✅ Usa variables de entorno, no hardcodees passwords
5. ✅ Revoca App Passwords que ya no uses

### Revocar App Password

1. Ve a https://myaccount.google.com/apppasswords
2. Encuentra "Vexus Backend"
3. Haz clic en "Eliminar"
4. Genera uno nuevo si es necesario

---

## 📝 Checklist Final

Antes de marcar como completado, verifica:

- [ ] Verificación en 2 pasos habilitada en Gmail
- [ ] App Password generado (16 caracteres)
- [ ] Variables de entorno configuradas en `.env.production`
- [ ] App Password copiado **sin espacios**
- [ ] Puerto 587 accesible desde el servidor
- [ ] Contenedor Docker reconstruido con nuevas variables
- [ ] Email de prueba enviado exitosamente
- [ ] Email recibido en bandeja de Gmail
- [ ] Logs del backend sin errores SMTP
- [ ] Endpoint `/api/v1/debug/smtp-status` retorna configuración correcta

---

## 🎯 Resumen

**Configuración mínima requerida:**
```bash
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USER=tu_email@gmail.com
SMTP_PASSWORD=tu_app_password_de_16_caracteres
EMAIL_FROM=tu_email@gmail.com
```

**Comando para verificar:**
```bash
curl -X POST http://localhost:8000/api/v1/debug/test-email \
  -H "Content-Type: application/json" \
  -d '{"email": "test@gmail.com", "name": "Test"}'
```

**Esperado:**
```json
{"success": true, "message": "✅ Email enviado"}
```

---

## 📚 Referencias

- Gmail App Passwords: https://myaccount.google.com/apppasswords
- Google 2-Step Verification: https://myaccount.google.com/security
- Gmail SMTP Documentation: https://support.google.com/mail/answer/7126229
- Vexus Email Service: `backend/app/services/email.py`
- Vexus Config: `backend/app/config.py`

---

**Estado**: ✅ Listo para usar
**Fecha**: 2025
**Versión**: 1.0.0
