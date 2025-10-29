# 🔧 SOLUCIÓN URGENTE: Error de CORS en Render.com

## ❌ Error Actual:
```
Access to fetch at 'https://vexuspage.onrender.com/api/v1/auth/register'
from origin 'https://www.grupovexus.com' has been blocked by CORS policy
```

## ✅ Solución (Configurar en Render.com):

### Paso 1: Ir a tu Dashboard de Render
1. Abre https://dashboard.render.com
2. Busca tu servicio **vexuspage**
3. Haz clic en él

### Paso 2: Configurar Variables de Entorno
1. En el menú lateral izquierdo, haz clic en **"Environment"**
2. Busca la variable `ALLOWED_ORIGINS` (si existe, edítala; si no, agrégala)
3. Haz clic en **"Add Environment Variable"** o edita la existente

### Paso 3: Agregar el valor correcto
```
Key:   ALLOWED_ORIGINS
Value: https://www.grupovexus.com,https://grupovexus.com,http://localhost:5500
```

**IMPORTANTE:**
- NO uses espacios después de las comas
- Incluye tanto `www` como sin `www`
- Mantén `localhost` para desarrollo local

### Paso 4: Guardar y Redesplegar
1. Haz clic en **"Save Changes"**
2. Render redesplegará automáticamente tu servicio
3. Espera 2-3 minutos a que termine el despliegue

---

## 🎯 Verificación Visual de las Variables

Tus variables de entorno deberían verse así:

```
DATABASE_URL          = postgresql://vexus_user:password@...
SECRET_KEY           = tu-clave-secreta-aqui
ALLOWED_ORIGINS      = https://www.grupovexus.com,https://grupovexus.com,http://localhost:5500
SMTP_HOST            = smtp.gmail.com
SMTP_PORT            = 587
SMTP_USER            = grupovexus@gmail.com
SMTP_PASSWORD        = tnquxwpqddhxlxaf
EMAIL_FROM           = grupovexus@gmail.com
FRONTEND_URL         = https://www.grupovexus.com
ENVIRONMENT          = production
DEBUG                = False
```

---

## 🚨 ATENCIÓN: NO usar asterisco (*) en producción

❌ **NUNCA hagas esto en producción:**
```
ALLOWED_ORIGINS = *
```

✅ **Siempre especifica los dominios exactos:**
```
ALLOWED_ORIGINS = https://www.grupovexus.com,https://grupovexus.com
```

---

## 📸 Captura de Pantalla de Referencia

Tu configuración en Render debería verse así:

```
┌─────────────────────────────────────────────────────────────┐
│ Environment Variables                                        │
├─────────────────────────────────────────────────────────────┤
│ Key                    │ Value                               │
├─────────────────────────────────────────────────────────────┤
│ ALLOWED_ORIGINS        │ https://www.grupovexus.com,https... │
│ DATABASE_URL           │ postgresql://vexus_user:pass...     │
│ SECRET_KEY             │ ●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●  │
│ FRONTEND_URL           │ https://www.grupovexus.com          │
│ ENVIRONMENT            │ production                          │
│ DEBUG                  │ False                               │
└─────────────────────────────────────────────────────────────┘
```

---

## ✅ Después de Configurar

1. Espera a que Render termine de redesplegar (verás un log como este):
   ```
   ==> Starting service with 'gunicorn backend.app.main:app...'
   ==> Service started successfully
   ```

2. Prueba nuevamente el registro en https://www.grupovexus.com

3. El error de CORS debería desaparecer

---

## 🔍 Si el problema persiste

### Opción 1: Verifica que la variable esté correcta
```bash
# Revisa los logs de Render para ver qué orígenes se están permitiendo
# Deberías ver algo como:
✓ CORS configured for origins: ['https://www.grupovexus.com', 'https://grupovexus.com']
```

### Opción 2: Revisa el endpoint /debug/cors
Abre en tu navegador:
```
https://vexuspage.onrender.com/debug/cors
```

Deberías ver:
```json
{
  "allowed_origins": [
    "https://www.grupovexus.com",
    "https://grupovexus.com",
    "http://localhost:5500"
  ],
  "environment": "production",
  "debug": false
}
```

### Opción 3: Forzar redespliegue manual
1. Ve a tu servicio en Render
2. Haz clic en **"Manual Deploy"** → **"Deploy latest commit"**

---

## 📞 Resumen Rápido

1. ✅ Ve a Render Dashboard
2. ✅ Selecciona servicio **vexuspage**
3. ✅ Ve a **Environment**
4. ✅ Agrega/edita `ALLOWED_ORIGINS`
5. ✅ Valor: `https://www.grupovexus.com,https://grupovexus.com,http://localhost:5500`
6. ✅ Guarda y espera redespliegue
7. ✅ Prueba de nuevo

**¡El error de CORS desaparecerá!** 🎉
