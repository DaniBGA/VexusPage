# 🚀 DEPLOY EN RENDER.COM - Guía Paso a Paso

**Fecha:** 2025-10-31
**Tiempo estimado:** 10-15 minutos
**Costo:** Gratis (Free tier)

---

## 📋 QUÉ VAMOS A LOGRAR

- ✅ Backend FastAPI funcionando en Render.com
- ✅ Base de datos PostgreSQL gratuita en Render
- ✅ SSL/HTTPS automático
- ✅ Deploy automático desde GitHub
- ✅ Frontend en Neatech apuntando al backend en Render

---

## 🎯 ESTRUCTURA FINAL

```
Frontend:  https://grupovexus.com (Neatech)
           ↓ llama a ↓
Backend:   https://vexus-api.onrender.com/api/v1 (Render)
           ↓ conecta a ↓
Database:  PostgreSQL en Render (gratis)
```

---

## 📦 ARCHIVOS PREPARADOS

Ya he creado estos archivos en tu proyecto:

1. **`backend/render.yaml`** - Configuración de deploy para Render
2. **`backend/runtime.txt`** - Versión de Python (3.11)
3. **`backend/requirements.txt`** - Ya existía ✅

---

## 🚀 PASO 1: Subir Código a GitHub

### Si NO tienes repo de GitHub todavía:

1. **Ve a** [github.com](https://github.com)
2. **Crea cuenta** (si no tienes)
3. **Crear nuevo repositorio:**
   - Click en **"New repository"**
   - Nombre: `VexusPage` o `vexus-backend`
   - Privado o Público (tu elección)
   - NO marcar "Initialize with README"
   - Click **"Create repository"**

4. **En tu computadora**, abre terminal en la carpeta del proyecto:

```bash
cd c:\Users\Daniel\Desktop\VexusPage

# Inicializar git (si no está inicializado)
git init

# Agregar archivos
git add .

# Commit
git commit -m "Deploy backend to Render"

# Agregar remote
git remote add origin https://github.com/TU_USUARIO/VexusPage.git

# Push
git branch -M main
git push -u origin main
```

**Nota:** Reemplaza `TU_USUARIO` con tu usuario de GitHub.

### Si YA tienes repo de GitHub:

```bash
cd c:\Users\Daniel\Desktop\VexusPage

# Asegurarte de que los cambios están commiteados
git add .
git commit -m "Add Render deployment files"
git push
```

---

## 🎨 PASO 2: Crear Cuenta en Render

1. **Ve a** [render.com](https://render.com)
2. **Click** en **"Get Started"** o **"Sign Up"**
3. **Elige** "Sign up with GitHub" (más fácil)
4. **Autoriza** Render a acceder a tus repositorios

---

## 🗄️ PASO 3: Crear Base de Datos PostgreSQL

1. **En Render Dashboard**, click en **"New +"** → **"PostgreSQL"**

2. **Configuración:**
   - **Name:** `vexus-db`
   - **Database:** `vexus_db` (o déjalo por defecto)
   - **User:** (se crea automáticamente)
   - **Region:** `Oregon (US West)` (recomendado, gratis)
   - **PostgreSQL Version:** `16` (o la más reciente)
   - **Plan:** `Free`

3. **Click** en **"Create Database"**

4. **Espera** ~2 minutos a que se cree

5. **IMPORTANTE - Copiar datos de conexión:**
   - En la página de la base de datos, ve a **"Info"** tab
   - **Copia** el **"Internal Database URL"** (empieza con `postgres://...`)
   - Lo necesitarás después

---

## 🖥️ PASO 4: Crear Web Service (Backend)

1. **En Render Dashboard**, click en **"New +"** → **"Web Service"**

2. **Conectar repositorio:**
   - Si es la primera vez, autoriza Render a acceder a tus repos
   - **Selecciona** tu repositorio `VexusPage` o como lo hayas llamado

3. **Configuración:**
   - **Name:** `vexus-api` (o el que quieras)
   - **Region:** `Oregon (US West)` (mismo que la DB)
   - **Branch:** `main`
   - **Root Directory:** `backend` ⚠️ **MUY IMPORTANTE**
   - **Environment:** `Python 3`
   - **Build Command:** `pip install -r requirements.txt`
   - **Start Command:** `uvicorn app.main:app --host 0.0.0.0 --port $PORT`
   - **Plan:** `Free`

4. **Click** en **"Advanced"** para agregar variables de entorno

---

## 🔐 PASO 5: Configurar Variables de Entorno

En la sección **"Environment Variables"**, agrega estas variables:

| Key | Value | Notas |
|-----|-------|-------|
| `DATABASE_URL` | `postgres://...` | ⚠️ Pega la URL que copiaste en PASO 3 |
| `SECRET_KEY` | `tu-clave-secreta-muy-larga` | Genera una aleatoria (ver abajo) |
| `ALLOWED_ORIGINS` | `https://grupovexus.com,https://www.grupovexus.com` | URLs permitidas para CORS |
| `SMTP_HOST` | `smtp.gmail.com` | Tu servidor SMTP |
| `SMTP_PORT` | `587` | Puerto SMTP |
| `SMTP_USER` | `grupovexus@gmail.com` | Tu email |
| `SMTP_PASSWORD` | `tnquxwpqddhxlxaf` | App password de Gmail |
| `EMAIL_FROM` | `grupovexus@gmail.com` | Email remitente |
| `FRONTEND_URL` | `https://grupovexus.com` | URL de tu frontend |
| `PROJECT_NAME` | `Vexus API` | Nombre del proyecto |
| `API_V1_PREFIX` | `/api/v1` | Prefijo de la API |
| `ENVIRONMENT` | `production` | Entorno |
| `DEBUG` | `False` | Desactivar debug |

### 🔑 Generar SECRET_KEY

Ejecuta esto en Python (o usa generador online):

```python
import secrets
print(secrets.token_urlsafe(32))
```

Copia el resultado y úsalo como `SECRET_KEY`.

---

## 🚀 PASO 6: Deploy!

1. **Click** en **"Create Web Service"**
2. **Render comenzará a:**
   - Clonar tu repo
   - Instalar dependencias
   - Iniciar la aplicación
3. **Espera** ~5 minutos
4. **Verás** logs en tiempo real

**Logs que deberías ver:**
```
==> Building backend...
==> Installing dependencies...
==> Successfully installed fastapi uvicorn...
==> Starting service...
INFO:     Started server process
INFO:     Uvicorn running on http://0.0.0.0:10000
```

5. **Cuando termine**, verás **"Your service is live 🎉"**

---

## ✅ PASO 7: Verificar que Funciona

### a) Obtener URL del backend

En Render, copia la URL de tu servicio:
- Formato: `https://vexus-api.onrender.com`
- (El nombre puede variar según lo que elegiste)

### b) Probar Health Check

Abre en tu navegador:
```
https://vexus-api.onrender.com/api/v1/health
```

**Deberías ver:**
```json
{
  "status": "healthy",
  "database": "connected",
  "timestamp": "2025-10-31T..."
}
```

### c) Probar API Docs

Abre:
```
https://vexus-api.onrender.com/docs
```

Deberías ver la documentación interactiva de FastAPI.

---

## 🔧 PASO 8: Inicializar Base de Datos

Necesitas ejecutar el script SQL para crear las tablas.

### Opción 1: Usar psql (si lo tienes instalado)

```bash
psql "postgres://user:password@host/database" -f backend/deploy_neatech.sql
```

(Reemplaza con tu Database URL completa)

### Opción 2: Via Render Shell

1. En Render, ve a tu Web Service
2. Click en **"Shell"** en el menú lateral
3. Se abrirá una terminal
4. Ejecuta:

```bash
# Copiar el contenido de deploy_neatech.sql manualmente
# O usar psql si está disponible
```

### Opción 3: Via GUI PostgreSQL (TablePlus, DBeaver, etc.)

1. Descarga [TablePlus](https://tableplus.com/) o [DBeaver](https://dbeaver.io/)
2. Conecta usando la "External Database URL" de Render
3. Ejecuta el contenido de `deploy_neatech.sql`

---

## 🌐 PASO 9: Actualizar Frontend

Ahora que el backend está funcionando en Render, actualiza el frontend:

### Actualizar config.js

**En tu proyecto local:**

`frontend/Static/js/config.js`:

```javascript
// Configuración de producción
// Backend en Render.com
const CONFIG = {
    API_BASE_URL: 'https://vexus-api.onrender.com/api/v1',  // ← Tu URL de Render
    TOKEN_KEY: 'vexusToken',
    USER_KEY: 'vexusUser',
    REQUEST_TIMEOUT: 30000,
    ENVIRONMENT: 'production',
    DEBUG: false
};

export default CONFIG;
```

**Reemplaza `vexus-api` con el nombre real de tu servicio en Render.**

### Subir a Neatech

1. **Sube** el `config.js` actualizado a: `public_html/Static/js/config.js`
2. **Reemplaza** el archivo existente

---

## ✅ PASO 10: Probar Todo Junto

1. **Abre** `https://www.grupovexus.com`
2. **Abre** la consola del navegador (F12)
3. **Deberías ver:** "✅ Backend connected"
4. **Prueba** login/registro

---

## 🎉 ¡LISTO!

Tu stack completo está funcionando:

```
Frontend: https://grupovexus.com (Neatech)
Backend:  https://vexus-api.onrender.com/api/v1 (Render)
Database: PostgreSQL en Render
```

---

## 🐛 TROUBLESHOOTING

### Error: "Application failed to respond"

**Causa:** Error en el código o falta alguna variable de entorno

**Solución:**
1. Ve a **Logs** en Render
2. Busca el error específico
3. Generalmente falta `DATABASE_URL` o está mal configurada

---

### Error: "Database connection failed"

**Causa:** `DATABASE_URL` incorrecta

**Solución:**
1. Ve a tu PostgreSQL database en Render
2. Copia la **Internal Database URL** (no la External)
3. Pégala en las variables de entorno del Web Service
4. Redeploy (Manual Deploy → Clear build cache & deploy)

---

### Error: "CORS Policy"

**Causa:** `ALLOWED_ORIGINS` no incluye tu dominio

**Solución:**
1. Verifica que `ALLOWED_ORIGINS` tenga: `https://grupovexus.com,https://www.grupovexus.com`
2. Redeploy

---

### Backend responde lento (primera vez)

**Normal:** El plan Free de Render "duerme" la app después de 15 minutos de inactividad

**Primera request después de dormir:** ~30-60 segundos

**Requests subsecuentes:** Rápidas

**Solución (opcional):**
- Upgrade a plan de pago ($7/mes) → app siempre activa
- O aceptar el delay ocasional (es gratis)

---

## 💰 COSTOS

| Servicio | Plan | Costo |
|----------|------|-------|
| Web Service (Backend) | Free | $0/mes |
| PostgreSQL Database | Free | $0/mes |
| **Total** | | **$0/mes** ✅ |

**Límites del plan Free:**
- 750 horas/mes de uptime (suficiente)
- 100 GB de ancho de banda
- Database: 1 GB de almacenamiento
- App se duerme después de 15 min de inactividad

**Para la mayoría de sitios pequeños/medianos, el plan Free es suficiente.**

---

## 🔄 DEPLOY AUTOMÁTICO

**Una vez configurado**, cada vez que hagas `git push`:

1. Render detecta los cambios
2. Construye automáticamente
3. Despliega la nueva versión
4. ¡Sin tocar nada!

---

## 📊 MONITOREO

En Render puedes ver:
- **Logs** en tiempo real
- **Métricas** de uso (CPU, memoria, requests)
- **Deploy history**
- **Eventos** y errores

---

## 🎯 CHECKLIST COMPLETO

- [ ] Código en GitHub
- [ ] Cuenta en Render.com
- [ ] PostgreSQL database creada
- [ ] Database URL copiada
- [ ] Web Service configurado (root: `backend`)
- [ ] Variables de entorno agregadas
- [ ] Deploy exitoso (logs sin errores)
- [ ] Health check funciona
- [ ] Base de datos inicializada (SQL ejecutado)
- [ ] Frontend actualizado con nueva URL
- [ ] config.js subido a Neatech
- [ ] Login/registro funcionando

---

## 📝 NOTAS FINALES

### Ventajas de esta solución:

- ✅ Backend funciona **AHORA**
- ✅ Frontend en tu dominio
- ✅ Deploy automático
- ✅ Gratis
- ✅ SSL/HTTPS automático
- ✅ Base de datos incluida
- ✅ Fácil de mantener

### Desventajas:

- ⚠️ App se duerme tras 15 min (plan Free)
- ⚠️ Backend en dominio diferente (pero CORS resuelto)

### Cuándo hacer upgrade:

- Si necesitas que la app esté siempre activa
- Si superas los límites del plan Free
- Si quieres custom domain para el backend

---

**Última actualización:** 2025-10-31
**Versión:** 1.0.0
**Estado:** ✅ Guía completa de deploy en Render
