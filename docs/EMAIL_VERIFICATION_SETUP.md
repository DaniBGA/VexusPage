# Configuración de Verificación de Email - Vexus

## Descripción General

Este documento explica cómo configurar y usar el sistema de verificación de email en la plataforma Vexus. El sistema requiere que los usuarios verifiquen su dirección de email antes de poder acceder a la plataforma.

## Características Implementadas

- ✅ Registro de usuarios con generación de token de verificación
- ✅ Envío de email personalizado con la estética de Vexus
- ✅ Verificación de email mediante enlace único
- ✅ Bloqueo de login si el email no está verificado
- ✅ Reenvío de email de verificación
- ✅ Tokens con expiración de 24 horas
- ✅ Interfaz de usuario para manejar el flujo de verificación

## Pasos de Configuración

### 1. Actualizar la Base de Datos

Ejecuta el script de migración para agregar los campos necesarios a la tabla `users`:

```bash
psql -U postgres -d vexus_db -f backend/migrations/add_email_verification.sql
```

O si ya tienes acceso a la base de datos, ejecuta:

```sql
-- Agregar columnas de verificación
ALTER TABLE users ADD COLUMN IF NOT EXISTS email_verification_token VARCHAR(255);
ALTER TABLE users ADD COLUMN IF NOT EXISTS email_verification_token_expires TIMESTAMP WITH TIME ZONE;

-- Crear índices
CREATE INDEX IF NOT EXISTS idx_users_email_verification_token
ON users(email_verification_token)
WHERE email_verification_token IS NOT NULL;

CREATE INDEX IF NOT EXISTS idx_users_email_verified
ON users(email_verified);
```

### 2. Configurar Variables de Entorno

Edita el archivo `backend/.env` y agrega las siguientes configuraciones de SMTP:

```env
# === EMAIL CONFIGURATION ===
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USER=tu-email@gmail.com
SMTP_PASSWORD=tu-contraseña-de-aplicacion
EMAIL_FROM=noreply@vexus.com
```

#### Configuración para Gmail

Si usas Gmail, necesitas:

1. **Habilitar "Acceso de aplicaciones menos seguras"** (no recomendado) O
2. **Crear una contraseña de aplicación** (recomendado):
   - Ve a tu cuenta de Google: https://myaccount.google.com/
   - Seguridad → Verificación en dos pasos (debe estar activada)
   - Contraseñas de aplicaciones
   - Selecciona "Correo" y "Otro"
   - Nombra "Vexus" y genera la contraseña
   - Usa esta contraseña en `SMTP_PASSWORD`

#### Configuración para otros proveedores

**Outlook/Hotmail:**
```env
SMTP_HOST=smtp-mail.outlook.com
SMTP_PORT=587
```

**SendGrid:**
```env
SMTP_HOST=smtp.sendgrid.net
SMTP_PORT=587
SMTP_USER=apikey
SMTP_PASSWORD=tu-api-key-de-sendgrid
```

**Amazon SES:**
```env
SMTP_HOST=email-smtp.us-east-1.amazonaws.com
SMTP_PORT=587
SMTP_USER=tu-smtp-username
SMTP_PASSWORD=tu-smtp-password
```

### 3. Actualizar la URL del Frontend en el Servicio de Email

Edita `backend/app/services/email.py` y actualiza la URL base del frontend:

```python
# Línea ~195 en email.py
base_url = frontend_url or "http://localhost:3000"  # Cambiar a tu dominio
```

Para producción, podría ser:
```python
base_url = frontend_url or "https://www.vexus.com"
```

O mejor aún, agrégalo como variable de entorno en `.env`:

```env
FRONTEND_URL=https://www.vexus.com
```

Y actualiza el código:
```python
from app.config import settings
base_url = frontend_url or settings.FRONTEND_URL
```

### 4. Instalar Dependencias (si es necesario)

El sistema de email usa bibliotecas estándar de Python, pero verifica que tengas todas las dependencias:

```bash
cd backend
pip install -r requirements.txt
```

## Flujo de Usuario

### Registro

1. Usuario completa el formulario de registro
2. El backend crea la cuenta con `email_verified = false`
3. Se genera un token único de verificación (válido por 24 horas)
4. Se envía un email HTML personalizado con el enlace de verificación
5. Usuario recibe confirmación visual de que debe verificar su email

### Verificación

1. Usuario hace clic en el enlace del email
2. Se abre la página `/pages/verify-email.html?token=xxx`
3. El frontend llama al endpoint `/api/v1/auth/verify-email`
4. El backend valida el token y marca `email_verified = true`
5. Usuario es redirigido al login

### Login

1. Usuario intenta iniciar sesión
2. Backend valida credenciales
3. Si `email_verified = false`, retorna error 403
4. Frontend muestra opción para reenviar email de verificación
5. Si está verificado, se permite el acceso

## Endpoints de la API

### POST `/api/v1/auth/register`
Registra un nuevo usuario y envía email de verificación.

**Request:**
```json
{
  "name": "John Doe",
  "email": "john@example.com",
  "password": "securePassword123"
}
```

**Response:**
```json
{
  "message": "User created successfully. Please check your email to verify your account.",
  "user_id": "uuid-aqui",
  "email_sent": true
}
```

### GET `/api/v1/auth/verify-email?token=xxx`
Verifica el email del usuario.

**Response (Éxito):**
```json
{
  "message": "Email verified successfully. You can now log in.",
  "email": "john@example.com"
}
```

**Response (Error - Token expirado):**
```json
{
  "detail": "Verification token has expired. Please request a new verification email."
}
```

### POST `/api/v1/auth/resend-verification`
Reenvía el email de verificación.

**Request:**
```json
{
  "email": "john@example.com"
}
```

**Response:**
```json
{
  "message": "Verification email sent successfully. Please check your inbox.",
  "email_sent": true
}
```

### POST `/api/v1/auth/login`
Login del usuario (requiere email verificado).

**Response (Error - Email no verificado):**
```json
{
  "detail": "Email not verified. Please check your email and verify your account before logging in."
}
```
HTTP Status: 403

## Modo de Desarrollo (Sin SMTP)

Si no configuras SMTP, el sistema funcionará de la siguiente manera:

1. ✅ El usuario puede registrarse
2. ⚠️ No se envía email real
3. 📝 El enlace de verificación se imprime en la consola del servidor
4. ❌ El usuario NO puede iniciar sesión hasta verificar

Para facilitar el testing en desarrollo, puedes:

1. Buscar el token en los logs del servidor
2. Manualmente construir la URL: `http://localhost:3000/pages/verify-email.html?token=TOKEN_AQUI`
3. O modificar temporalmente el código para permitir login sin verificación

## Personalización del Email

La plantilla HTML del email se encuentra en `backend/app/services/email.py` en la función `get_email_verification_template()`.

Los colores y estilos están alineados con la estética de Vexus:
- Color principal: `#d4af37` (dorado)
- Fondo: `#0a0a0a` y `#1a1a1a` (negro)
- Texto: `#e0e0e0` y `#c0c0c0` (gris claro)
- Fuente: Space Grotesk

## Seguridad

- ✅ Tokens generados con `secrets.token_urlsafe(32)` (criptográficamente seguros)
- ✅ Expiración de 24 horas
- ✅ Tokens de un solo uso (se eliminan después de la verificación)
- ✅ Índices en la base de datos para búsquedas eficientes
- ✅ Validación de expiración antes de verificar

## Troubleshooting

### El email no se envía

1. Verifica las credenciales SMTP en `.env`
2. Revisa los logs del servidor para errores
3. Verifica que el puerto SMTP no esté bloqueado por firewall
4. Para Gmail, asegúrate de usar contraseña de aplicación

### Token inválido o expirado

1. Los tokens expiran después de 24 horas
2. Usa el botón "Reenviar Email de Verificación"
3. Verifica que la URL esté completa y sin modificaciones

### Usuario ya verificado

Si intentas verificar un email que ya fue verificado, recibirás el mensaje:
"Email already verified"

## Testing

Para probar el sistema:

```bash
# 1. Ejecutar el backend
cd backend
python -m uvicorn app.main:app --reload

# 2. Registrar un usuario desde el frontend
# 3. Revisar los logs del servidor para ver el enlace de verificación
# 4. Copiar el token y construir la URL manualmente
# 5. Navegar a la página de verificación
```

## Producción

Para producción, asegúrate de:

1. ✅ Configurar SMTP con un servicio confiable (SendGrid, Amazon SES, etc.)
2. ✅ Usar HTTPS para todas las URLs
3. ✅ Configurar `FRONTEND_URL` correctamente
4. ✅ Configurar límites de tasa para evitar spam
5. ✅ Monitorear los logs de envío de emails
6. ✅ Implementar reintentos para emails fallidos

## Soporte

Para más información o problemas, consulta la documentación de FastAPI y PostgreSQL, o contacta al equipo de desarrollo de Vexus.
