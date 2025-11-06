# 🔍 Guía de Debugging de Email

## ✅ SMTP está configurado

El endpoint `/api/v1/debug/smtp-status` confirma que todas las variables están configuradas.

Ahora vamos a **probar el envío real** para ver el error específico.

---

## 🧪 Endpoints de Debugging Disponibles

### 1. Verificar Configuración SMTP
```bash
GET https://tu-backend.onrender.com/api/v1/debug/smtp-status
```

**Ya lo probaste - muestra que está configurado ✅**

---

### 2. **NUEVO: Test de Email Directo**
```bash
POST https://vexuspage.onrender.com/api/v1/debug/test-email
Content-Type: application/json

{
  "email": "dgongorabanegas@alumnos.exa.unicen.edu.ar",
  "name": "Daniel Test"
}
```

**Este endpoint:**
- ✅ Envía un email de prueba inmediatamente
- ✅ Muestra logs detallados en tiempo real
- ✅ Te dice exactamente qué está fallando

---

## 🚀 Pasos para Debugging

### Paso 1: Hacer commit y push
```bash
git add .
git commit -m "feat: improve email logging and add test endpoint"
git push origin main
```

### Paso 2: Esperar deploy de Render (2-3 minutos)

### Paso 3: Probar el endpoint de test
```bash
# Con curl
curl -X POST https://tu-backend.onrender.com/api/v1/debug/test-email \
  -H "Content-Type: application/json" \
  -d '{"email":"dgongorabanegas@alumnos.exa.unicen.edu.ar","name":"Daniel Test"}'

# O con Postman/Thunder Client
POST https://tu-backend.onrender.com/api/v1/debug/test-email
Body (JSON):
{
  "email": "dgongorabanegas@alumnos.exa.unicen.edu.ar",
  "name": "Daniel Test"
}
```

### Paso 4: Revisar logs en Render

Ve a tu servicio en Render → Logs

Deberías ver uno de estos escenarios:

---

## 📊 Escenarios Posibles

### ✅ Escenario 1: ÉXITO
```log
🧪 TEST DE EMAIL INICIADO
📧 Destinatario: dgongorabanegas@alumnos.exa.unicen.edu.ar
🔌 Conectando a SMTP: smtp.gmail.com:587
🔐 Conectando al servidor SMTP...
🔒 Iniciando STARTTLS...
👤 Autenticando como grupovexus@gmail.com...
📨 Enviando mensaje...
✅ Email de verificación enviado exitosamente
🧪 TEST DE EMAIL FINALIZADO
📊 Resultado: ✅ ÉXITO
```

**Acción:** Revisa tu bandeja de entrada y carpeta de Spam

---

### ❌ Escenario 2: Error de Autenticación
```log
🧪 TEST DE EMAIL INICIADO
🔌 Conectando a SMTP: smtp.gmail.com:587
🔐 Conectando al servidor SMTP...
🔒 Iniciando STARTTLS...
👤 Autenticando como grupovexus@gmail.com...
🔐 ERROR DE AUTENTICACIÓN SMTP
   Código: 535
   Mensaje: Username and Password not accepted
   Verifica que SMTP_PASSWORD sea un App Password válido de Gmail
```

**Solución:**
1. Ve a: https://myaccount.google.com/apppasswords
2. Elimina el App Password anterior
3. Genera uno nuevo
4. Actualiza `SMTP_PASSWORD` en Render (sin espacios, 16 caracteres)
5. Re-deploy

---

### ❌ Escenario 3: Timeout
```log
🧪 TEST DE EMAIL INICIADO
🔌 Conectando a SMTP: smtp.gmail.com:587
🔐 Conectando al servidor SMTP...
⏱️ TIMEOUT: El servidor SMTP no respondió en 10 segundos
```

**Posibles causas:**
1. Render free tier tiene restricciones de red
2. Gmail bloqueó la IP de Render

**Solución:** Migrar a SendGrid (ver abajo)

---

### ❌ Escenario 4: Conexión Rechazada
```log
🔌 Conectando a SMTP: smtp.gmail.com:587
❌ ERROR SMTP: Connection refused
```

**Solución:** Verificar SMTP_PORT (debe ser 587, no 465)

---

## 🔧 Soluciones Específicas

### Problema: App Password Incorrecto

**Cómo generar correctamente:**

1. **Activar 2FA primero:**
   - https://myaccount.google.com/security
   - "Verificación en 2 pasos" → Activar

2. **Generar App Password:**
   - https://myaccount.google.com/apppasswords
   - Seleccionar: "Correo" / "Otro (personalizado)"
   - Nombre: "Vexus Backend"
   - Clic en "Generar"

3. **Copiar correctamente:**
   - Formato mostrado: `xxxx xxxx xxxx xxxx`
   - **Copiar SIN espacios:** `xxxxxxxxxxxxxxxx`
   - Total: 16 caracteres

4. **Actualizar en Render:**
   - Environment → SMTP_PASSWORD
   - Pegar sin espacios
   - Save

---

### Problema: Gmail Bloquea Conexión desde Render

**Solución: Migrar a SendGrid** (más confiable)

```bash
# 1. Regístrate: https://signup.sendgrid.com/
# 2. Plan gratuito: 100 emails/día

# 3. Obtén API Key:
#    Settings → API Keys → Create API Key → Full Access

# 4. Actualizar variables en Render:
SMTP_HOST=smtp.sendgrid.net
SMTP_PORT=587
SMTP_USER=apikey
SMTP_PASSWORD=tu_sendgrid_api_key
EMAIL_FROM=noreply@grupovexus.com
```

**Ventajas:**
- ✅ Más confiable que Gmail
- ✅ 100 emails/día gratis (vs 500/día Gmail)
- ✅ No requiere App Password
- ✅ Mejor deliverability

---

## 📝 Checklist de Debugging

```
1. [✅] SMTP configurado en Render
2. [ ] Commit y push del código nuevo
3. [ ] Esperar deploy de Render
4. [ ] Probar endpoint: POST /api/v1/debug/test-email
5. [ ] Revisar logs en Render
6. [ ] Identificar error específico
7. [ ] Aplicar solución correspondiente
8. [ ] Re-testear
9. [ ] ✅ Email funcionando!
```

---

## 🎯 Próximos Pasos

1. **Commit y push** del código mejorado
2. **Probar** el endpoint `/debug/test-email`
3. **Ver logs** en Render para identificar el error exacto
4. **Aplicar solución** según el escenario

Una vez que funcione, puedes:
- Eliminar los endpoints de debug
- Hacer un registro normal
- Verificar que el email llegue

---

**¿Quieres que te ayude con SendGrid o necesitas más ayuda con Gmail?** 🚀
