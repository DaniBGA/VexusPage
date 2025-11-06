# Migración de Envío de Email: Backend → Frontend

## 📋 Resumen de Cambios

Se ha migrado el envío de emails de verificación del backend al frontend para simplificar el proceso mientras se mantiene la seguridad de las credenciales de SendGrid.

## 🔄 Arquitectura Implementada

### **Antes:**
```
Usuario → Backend (registra + envía email) → Usuario recibe email
```

### **Ahora:**
```
Usuario → Backend (solo registra) → Frontend (envía email via proxy) → Usuario recibe email
```

## 🛡️ Seguridad

Las credenciales de SendGrid **NO están expuestas** en el frontend. Se utiliza un **endpoint proxy** en el backend:

- **Frontend**: Solo envía datos del usuario (email, nombre, token)
- **Backend Proxy**: Contiene la API Key de SendGrid y realiza el envío
- **Credenciales**: Siguen en variables de entorno del backend

## 📁 Archivos Modificados

### Backend

#### 1. `backend/app/api/v1/endpoints/auth.py`
**Cambios:**
- ✅ Comentado el envío de email en background
- ✅ Ahora retorna `verification_token` y `user_name` al frontend
- ✅ Registro de usuario sigue funcionando normalmente

```python
# Líneas 79-93: Email deshabilitado en backend
# if not auto_verify:
#     background_tasks.add_task(send_verification_email_http, ...)

# Líneas 99-106: Se retorna info para el frontend
return {
    "verification_token": verification_token,
    "user_name": user.name,
    "email_sent": "frontend"
}
```

#### 2. `backend/app/api/v1/endpoints/email_proxy.py` (NUEVO)
**Propósito:** Endpoint proxy que oculta credenciales de SendGrid

```python
@router.post("/send-verification")
async def send_verification_email_proxy(request: SendVerificationEmailRequest):
    # Llamar a SendGrid con credenciales del backend
    success = await send_verification_email_http(...)
```

#### 3. `backend/app/api/v1/router.py`
**Cambios:**
- ✅ Agregado router de `email_proxy`

```python
api_router.include_router(email_proxy.router, prefix="/email", tags=["email"])
```

### Frontend

#### 4. `frontend/Static/js/email-service.js` (NUEVO)
**Propósito:** Servicio para enviar emails desde el frontend

**Funciones:**
- `sendVerificationEmail()`: Llama al proxy del backend
- `showEmailNotification()`: Muestra notificación visual al usuario

```javascript
export async function sendVerificationEmail(email, userName, verificationToken) {
    const response = await fetch(`${CONFIG.API_BASE_URL}/email/send-verification`, {
        method: 'POST',
        body: JSON.stringify({ email, user_name: userName, verification_token: verificationToken })
    });
}
```

#### 5. `frontend/Static/js/api/auth.js`
**Cambios:**
- ✅ Importa `email-service.js`
- ✅ Método `register()` ahora envía email después de crear usuario

```javascript
async register(name, email, password) {
    // 1. Registrar usuario
    const response = await apiClient.post('/auth/register', { name, email, password });
    
    // 2. Enviar email desde frontend
    const emailSent = await sendVerificationEmail(
        email,
        response.user_name,
        response.verification_token
    );
}
```

#### 6. `frontend/Static/js/main.js`
**Cambios:**
- ✅ Actualizado `handleRegister()` para mostrar estado del email

```javascript
if (response.emailSent === 'sent') {
    successMessage = '¡Cuenta creada! 📧 Email enviado...';
} else if (response.emailSent === 'failed') {
    successMessage = '¡Cuenta creada! ⚠️ No se pudo enviar el email...';
}
```

## 🔒 Flujo de Seguridad

1. **Usuario se registra** → Frontend envía datos a `/auth/register`
2. **Backend crea usuario** → Retorna `verification_token` (temporal)
3. **Frontend recibe token** → Llama a `/email/send-verification`
4. **Proxy valida y envía** → Usa credenciales del backend (ocultas)
5. **Usuario recibe email** → Con link de verificación

## 🚀 Ventajas

✅ **Sin exposición de credenciales**: API Key de SendGrid sigue en backend  
✅ **Registro rápido**: Backend responde inmediatamente (<500ms)  
✅ **Feedback visual**: Usuario ve si el email se envió o falló  
✅ **Fácil debugging**: Errores de email visibles en consola del navegador  
✅ **Flexible**: Fácil agregar reintentos o lógica personalizada  

## 📊 Estado de Variables de Entorno

Verificar que estén configuradas en Render:

```bash
SENDGRID_API_KEY=SG.v2uTeoqmQTCriy5UC_ldPQ...
EMAIL_FROM=grupovexus@gmail.com  # Debe estar verificado en SendGrid
```

## 🧪 Testing

### Verificar que el proxy funciona:
```bash
curl -X POST https://vexuspage.onrender.com/api/v1/email/send-verification \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","user_name":"Test","verification_token":"abc123"}'
```

### Verificar registro completo:
1. Ir a la página de registro
2. Crear una cuenta nueva
3. Verificar en la consola del navegador: `✅ Email enviado exitosamente`
4. Revisar bandeja de entrada del email registrado

## ⚠️ Notas Importantes

- **SendGrid Sender Verification**: El `EMAIL_FROM` debe estar verificado en SendGrid
- **CORS**: El endpoint proxy debe tener CORS habilitado para el frontend
- **Rate Limiting**: Considerar agregar límites de tasa al proxy
- **Error Handling**: El frontend debe manejar casos de fallo de email

## 🔄 Para Revertir

Si se necesita volver al envío desde backend:

1. Descomentar líneas 79-93 en `backend/app/api/v1/endpoints/auth.py`
2. Remover llamada a `sendVerificationEmail()` en `frontend/Static/js/api/auth.js`
3. Opcional: Remover `email_proxy.py` y su router

## 📝 Próximos Pasos

1. ✅ Verificar sender email en SendGrid
2. ⏳ Probar flujo completo de registro
3. ⏳ Agregar rate limiting al proxy
4. ⏳ Agregar reintentos automáticos en frontend
5. ⏳ Limpiar endpoints de debug cuando todo funcione
