# 🔧 Fix: Problema de Registro - OPTIONS sin POST

## 🔍 Problema Identificado

**Síntoma**:
- El botón se queda en "CREANDO CUENTA..."
- En logs de Render solo aparece: `OPTIONS /api/v1/auth/register HTTP/1.1" 200 OK`
- No aparece el `POST` real
- El email de verificación no se envía

**Causa Raíz**:
El navegador está haciendo el preflight CORS (OPTIONS) pero no está enviando el POST real después. Esto ocurre cuando:
1. Las cabeceras CORS en la respuesta OPTIONS no son correctas
2. El origen del frontend no está en la lista de orígenes permitidos

---

## ✅ Solución Paso a Paso

### 1. Verificar ALLOWED_ORIGINS en Render

**Tu frontend está en**: `https://grupovexus.com`

**En el dashboard de Render** → Tu servicio `vexuspage` → **Environment**:

Verifica que `ALLOWED_ORIGINS` tenga **EXACTAMENTE**:
```
https://grupovexus.com,https://www.grupovexus.com
```

**IMPORTANTE**:
- ❌ NO debe incluir espacios: `https://grupovexus.com, https://www...`
- ❌ NO debe tener barra al final: `https://grupovexus.com/`
- ✅ Debe ser exactamente: `https://grupovexus.com,https://www.grupovexus.com`

---

### 2. Verificar DATABASE_URL

El backend necesita conectarse a Supabase. Verifica que tengas:

```
DATABASE_URL=postgresql://postgres.fjfucvwpstrujpqsvuvr:%7C%24CwsRZa%25BM2F%2F%2A%29@aws-1-sa-east-1.pooler.supabase.com:6543/postgres?sslmode=require
```

**Nota**: Si cambiaste la contraseña de Supabase, necesitas regenerar esta URL.

---

### 3. Verificar que las tablas existan en Supabase

El backend necesita que las tablas estén creadas.

**Acción**:
1. Ve a Supabase → SQL Editor
2. Ejecuta el script: `backend/database/supabase_schema.sql`
3. Verifica que se crearon todas las tablas

---

### 4. Agregar Headers Explícitos para OPTIONS (Opcional)

Si el problema persiste, podemos agregar un handler explícito para OPTIONS:

**Archivo**: `backend/app/main.py`

Agregar ANTES de los routers:

```python
# Agregar después de los exception handlers, antes de include_router

@app.options("/{path:path}")
async def options_handler(request: Request):
    """Handler explícito para requests OPTIONS (CORS preflight)"""
    origin = request.headers.get("origin", "*")

    # Verificar si el origen está permitido
    allowed = origin in settings.ALLOWED_ORIGINS or "*" in settings.ALLOWED_ORIGINS

    headers = {
        "Access-Control-Allow-Origin": origin if allowed else settings.ALLOWED_ORIGINS[0],
        "Access-Control-Allow-Methods": "GET,HEAD,PUT,PATCH,POST,DELETE,OPTIONS",
        "Access-Control-Allow-Headers": "Content-Type,Authorization",
        "Access-Control-Allow-Credentials": "true",
        "Access-Control-Max-Age": "3600",
    }

    return Response(status_code=200, headers=headers)
```

---

### 5. Verificar en el Navegador

Abre las **DevTools** (F12) en el navegador:

1. Ve a la tab **Network**
2. Intenta registrar un usuario
3. Busca la request a `/api/v1/auth/register`
4. Click en la request → **Headers** tab

**Verifica**:

**Request Headers** debe incluir:
```
Origin: https://grupovexus.com
```

**Response Headers** debe incluir:
```
access-control-allow-origin: https://grupovexus.com
access-control-allow-credentials: true
access-control-allow-methods: GET,HEAD,PUT,PATCH,POST,DELETE,OPTIONS
```

---

## 🐛 Debugging Adicional

Si el problema persiste, necesitamos más información:

### Ver logs completos en Render:

1. Dashboard de Render → Tu servicio
2. **Logs** tab
3. Busca líneas que digan:
   - `🔔 Registration attempt for email: ...`
   - `✅ User created successfully: ...`
   - `⚠️ Error...`

### Agregar más logging temporal:

En `backend/app/main.py`, agregar DESPUÉS del middleware CORS:

```python
@app.middleware("http")
async def log_requests(request: Request, call_next):
    """Log temporal para debugging"""
    print(f"🔍 {request.method} {request.url.path}")
    print(f"   Origin: {request.headers.get('origin', 'None')}")
    print(f"   Content-Type: {request.headers.get('content-type', 'None')}")

    response = await call_next(request)

    print(f"   Response: {response.status_code}")
    print(f"   CORS headers: {response.headers.get('access-control-allow-origin', 'None')}")

    return response
```

---

## 📋 Checklist de Verificación

Marca cada item cuando lo hayas verificado:

### En Render:
- [ ] `ALLOWED_ORIGINS` está configurado correctamente (sin espacios, sin barras finales)
- [ ] `DATABASE_URL` está configurado con la URL codificada
- [ ] `SECRET_KEY` está generado
- [ ] Las demás variables de entorno están configuradas

### En Supabase:
- [ ] Las tablas están creadas (ejecutado `supabase_schema.sql`)
- [ ] Puedes ver las tablas en el SQL Editor
- [ ] La URL de conexión funciona

### En el Frontend:
- [ ] `config.js` apunta a `https://vexuspage.onrender.com/api/v1`
- [ ] No hay errores en la consola del navegador (F12)
- [ ] El request OPTIONS tiene el header `Origin` correcto

### En los Logs de Render:
- [ ] Aparece "🚀 Starting application..."
- [ ] Aparece "✅ Database connected successfully"
- [ ] Aparece el log del registro: "🔔 Registration attempt..."

---

## 🎯 Si Todo Falla: Plan B

Si después de verificar todo lo anterior el problema persiste:

1. **Temporalmente** cambia `ALLOWED_ORIGINS` a `*` en Render
   - Esto permitirá todos los orígenes (inseguro, solo para testing)
   - Si funciona, confirma que es un problema de CORS configuration
   - **NO DEJAR EN PRODUCCIÓN**

2. Verifica que el frontend **realmente** esté en `https://grupovexus.com`
   - Abre el sitio y verifica la URL en la barra del navegador
   - Debe ser HTTPS, no HTTP

3. Prueba desde Postman o cURL:
```bash
curl -X POST https://vexuspage.onrender.com/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -H "Origin: https://grupovexus.com" \
  -d '{"name":"Test User","email":"test@example.com","password":"TestPass123"}'
```

---

## 📞 Siguiente Paso

Haz las verificaciones en orden:
1. ✅ ALLOWED_ORIGINS en Render
2. ✅ DATABASE_URL en Render
3. ✅ Tablas creadas en Supabase
4. ✅ Ver logs completos de Render durante el registro

**Dime qué encuentras en cada paso** y te ayudaré a resolverlo.
