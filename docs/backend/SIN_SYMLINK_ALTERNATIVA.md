# 🔧 SOLUCIÓN SIN SYMLINK - Backend en public_html/api/

**Fecha:** 2025-10-31
**Problema:** No se pueden crear symlinks en Neatech

---

## 📋 RESUMEN

Si no puedes crear el symlink (porque están deshabilitados en tu hosting), la solución es **mover el backend directamente a `public_html/api/`**.

**⚠️ IMPORTANTE:** Esta solución es menos segura que usar `/private/`, pero `.htaccess` protegerá los archivos sensibles.

---

## 📂 ESTRUCTURA FINAL

```
Carpeta principal/
└── web/
    └── grupovexus.com/
        ├── private/                  ← Puedes eliminar o dejar vacío
        │
        └── public_html/
            ├── index.html            ← Frontend
            ├── pages/
            ├── Static/
            ├── .htaccess             ← Config para frontend
            │
            └── api/                  ← BACKEND AQUÍ (sin symlink)
                ├── app/
                │   ├── __init__.py
                │   ├── main.py
                │   ├── config.py
                │   ├── api/
                │   ├── core/
                │   ├── models/
                │   └── services/
                ├── passenger_wsgi.py
                ├── .htaccess         ← Config Passenger + seguridad
                ├── .env              ← Credenciales (protegido por .htaccess)
                └── requirements.txt
```

---

## 🚀 PASOS PARA IMPLEMENTAR

### 1. Mover Backend a public_html/api/

#### Opción A: Vía File Manager

1. **Ir a:** `Carpeta principal → web → grupovexus.com → public_html`

2. **Crear carpeta `api`:**
   - Click en **"+ Nuevo"** o **"New Folder"**
   - Nombre: `api`

3. **Subir archivos del backend:**
   - Entra a la carpeta `api/`
   - Sube TODO el contenido de tu carpeta `backend/` local:
     - Carpeta `app/` completa (con todas sus subcarpetas)
     - `passenger_wsgi.py` (renombrar desde `passenger_wsgi_neatech.py`)
     - `.htaccess` (renombrar desde `.htaccess_neatech`)
     - `requirements.txt`

4. **Crear archivo `.env`:**
   - Usa el template de `.env.example`
   - Agrega tus credenciales reales

#### Opción B: Mover desde /private/backend/ (si ya lo subiste ahí)

Si ya subiste el backend a `private/backend/`, puedes moverlo:

1. Selecciona TODO el contenido de `private/backend/`
2. Click en **"Mover"** o **"Move"**
3. Destino: `public_html/api/`

---

### 2. Configurar .htaccess del Backend (CRÍTICO para seguridad)

**Ubicación:** `public_html/api/.htaccess`

Este archivo es **CRÍTICO** porque protege tus archivos sensibles:

```apache
# ====================================
# BACKEND - .htaccess
# ⚠️ IMPORTANTE: Proteger archivos sensibles
# ====================================

# Habilitar Passenger
PassengerEnabled on
PassengerAppType wsgi
PassengerStartupFile passenger_wsgi.py
PassengerPython /usr/bin/python3

# Ruta de la aplicación (ajustar según ruta real del servidor)
PassengerAppRoot /path/to/public_html/api

# Performance
PassengerMinInstances 1
PassengerMaxPoolSize 6

# Base URI para /api
PassengerBaseURI /api

# Headers CORS
Header always set Access-Control-Allow-Origin "*"
Header always set Access-Control-Allow-Methods "GET, POST, PUT, DELETE, OPTIONS, PATCH"
Header always set Access-Control-Allow-Headers "Content-Type, Authorization"

# Logging
PassengerLogLevel 3

# ====================================
# SEGURIDAD CRÍTICA
# ====================================

# Bloquear acceso a archivos Python
<FilesMatch "\.(py|pyc|pyo)$">
    Order allow,deny
    Deny from all
</FilesMatch>

# EXCEPCIÓN: Permitir passenger_wsgi.py (Passenger lo necesita)
<Files "passenger_wsgi.py">
    Allow from all
</Files>

# Bloquear acceso a archivos sensibles
<FilesMatch "^\.env|\.env\..*|requirements\.txt|\.git.*|\.htaccess$">
    Order allow,deny
    Deny from all
</FilesMatch>

# Bloquear listado de directorios
Options -Indexes

# Bloquear acceso a carpetas de código
<DirectoryMatch "/(app|__pycache__|\.git)">
    Order allow,deny
    Deny from all
</DirectoryMatch>
```

**⚠️ CRUCIAL:** Este `.htaccess` protege:
- ✅ Archivos `.py` (código Python)
- ✅ Archivo `.env` (credenciales)
- ✅ Carpeta `app/` (código fuente)
- ✅ `requirements.txt`
- ✅ Archivos de configuración

---

### 3. Configurar passenger_wsgi.py

**Ubicación:** `public_html/api/passenger_wsgi.py`

```python
"""
Passenger WSGI para Neatech
Backend en public_html/api/ (sin symlink)
"""
import sys
import os

# Añadir el directorio actual al path
current_dir = os.path.dirname(__file__)
sys.path.insert(0, current_dir)

# Cargar variables de entorno
from dotenv import load_dotenv
load_dotenv(os.path.join(current_dir, '.env'))

# Importar la aplicación FastAPI
try:
    from app.main import app as application
    print("✅ FastAPI app loaded successfully from public_html/api/")
except Exception as e:
    print(f"❌ Error loading FastAPI app: {e}")
    import traceback
    traceback.print_exc()
    raise
```

---

### 4. Configurar .env

**Ubicación:** `public_html/api/.env`

```bash
# === BASE DE DATOS ===
DATABASE_URL=postgresql://grupovex_db:TU_PASSWORD@localhost:5432/grupovex_db
DB_POOL_MIN_SIZE=5
DB_POOL_MAX_SIZE=20
DB_CONNECT_TIMEOUT=10

# === SEGURIDAD ===
SECRET_KEY=GENERA-CLAVE-SECRETA-AQUI
ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=30

# === CORS ===
ALLOWED_ORIGINS=https://grupovexus.com,https://www.grupovexus.com

# === EMAIL ===
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USER=grupovexus@gmail.com
SMTP_PASSWORD=tu-app-password-aqui
EMAIL_FROM=grupovexus@gmail.com

# === FRONTEND ===
FRONTEND_URL=https://grupovexus.com

# === APP ===
PROJECT_NAME=Vexus API
VERSION=1.0.0
API_V1_PREFIX=/api/v1
ENVIRONMENT=production
DEBUG=False
```

---

### 5. Configurar .htaccess del Frontend

**Ubicación:** `public_html/.htaccess`

```apache
RewriteEngine On
RewriteBase /

# ====== BACKEND en /api ======
# Passenger se encarga de ejecutarlo
# (No hay symlink, es una carpeta real)

# ====== FRONTEND (SPA) ======
# Si no existe el archivo y NO es /api/, servir index.html
RewriteCond %{REQUEST_FILENAME} !-f
RewriteCond %{REQUEST_FILENAME} !-d
RewriteCond %{REQUEST_URI} !^/api/
RewriteRule ^ /index.html [L]

# ====== HEADERS CORS ======
Header always set Access-Control-Allow-Origin "*"
Header always set Access-Control-Allow-Methods "GET, POST, PUT, DELETE, OPTIONS, PATCH"
Header always set Access-Control-Allow-Headers "Content-Type, Authorization"

# ====== COMPRESIÓN ======
<IfModule mod_deflate.c>
    AddOutputFilterByType DEFLATE text/html text/plain text/xml text/css text/javascript application/javascript application/json
</IfModule>

# ====== CACHE ======
<IfModule mod_expires.c>
    ExpiresActive On
    ExpiresByType image/jpg "access plus 1 year"
    ExpiresByType image/jpeg "access plus 1 year"
    ExpiresByType image/png "access plus 1 year"
    ExpiresByType text/css "access plus 1 month"
    ExpiresByType application/javascript "access plus 1 month"
</IfModule>

# ====== SEGURIDAD ======
Options -Indexes
<FilesMatch "\.(env|md|json|lock)$">
    Order allow,deny
    Deny from all
</FilesMatch>
```

---

## 🌐 URLS FINALES

| Componente | URL | Ubicación |
|------------|-----|-----------|
| **Frontend** | `https://grupovexus.com` | `public_html/` |
| **Backend API** | `https://grupovexus.com/api/v1` | `public_html/api/` |
| **Health Check** | `https://grupovexus.com/api/v1/health` | `public_html/api/app/main.py` |
| **API Docs** | `https://grupovexus.com/api/docs` | `public_html/api/app/main.py` |

---

## ✅ VERIFICACIÓN

### 1. Verificar estructura de archivos

En File Manager, navega a `public_html/api/` y verifica que tienes:

```
public_html/api/
├── app/              ← Carpeta completa del código
├── passenger_wsgi.py ← Archivo de entrada
├── .htaccess         ← Configuración de seguridad
├── .env              ← Credenciales
└── requirements.txt  ← Dependencias
```

### 2. Verificar permisos

Los archivos deben tener permisos correctos:
- Carpetas: `755`
- Archivos Python: `644`
- `.env`: `600` o `644` (protegido por .htaccess)

### 3. Verificar Backend

Abre en navegador:
```
https://grupovexus.com/api/v1/health
```

Deberías ver:
```json
{
  "status": "healthy",
  "database": "connected",
  "timestamp": "2025-10-31T..."
}
```

### 4. Verificar que archivos sensibles NO son accesibles

Intenta acceder a estas URLs (deberían dar **403 Forbidden**):

```
https://grupovexus.com/api/.env              ← 403 Forbidden ✅
https://grupovexus.com/api/app/main.py       ← 403 Forbidden ✅
https://grupovexus.com/api/requirements.txt  ← 403 Forbidden ✅
```

Si alguno es accesible, **URGENTE**: revisa el `.htaccess` del backend.

---

## 🔒 SEGURIDAD

### ⚠️ IMPORTANTE: Diferencias con /private/

Esta solución es **menos segura** que usar `/private/` porque:
- El código está en una carpeta accesible vía web
- Dependes 100% de `.htaccess` para protección
- Si `.htaccess` falla, el código queda expuesto

### ✅ Mitigación de riesgos:

1. **`.htaccess` robusto:** Bloquea acceso a todos los archivos sensibles
2. **`.env` protegido:** No debe ser accesible vía web
3. **Sin `DEBUG=True`:** Nunca en producción
4. **Verifica regularmente:** Que archivos `.py` y `.env` den 403

### 🛡️ Checklist de seguridad:

- [ ] `.htaccess` existe en `public_html/api/`
- [ ] `.env` da 403 Forbidden al intentar accederlo
- [ ] Archivos `.py` dan 403 Forbidden
- [ ] `/api/app/` no es accesible
- [ ] `DEBUG=False` en `.env`
- [ ] `SECRET_KEY` es fuerte y aleatoria
- [ ] Base de datos tiene password seguro

---

## 🐛 SOLUCIÓN DE PROBLEMAS

### Error: "500 Internal Server Error"

**Causa:** Passenger no puede ejecutar la app.

**Solución:**
1. Verifica que `passenger_wsgi.py` existe
2. Verifica que `.htaccess` existe
3. Verifica que `.env` tiene todas las variables
4. Revisa logs: cPanel → Errors → `error_log`

### Error: "403 Forbidden en /api"

**Causa:** `.htaccess` está bloqueando el acceso a todo.

**Solución:**
1. Revisa que `PassengerBaseURI /api` esté en el `.htaccess`
2. Verifica que `passenger_wsgi.py` tiene permisos 644
3. Asegúrate de que la excepción para `passenger_wsgi.py` está en el `.htaccess`

### Error: "Se puede acceder a .env vía web"

**Causa:** `.htaccess` no está funcionando.

**Solución:**
1. Verifica que `.htaccess` existe en `public_html/api/`
2. Verifica que tiene las reglas de seguridad
3. Si persiste, contacta a soporte de Neatech

---

## 📊 COMPARACIÓN: /private/ vs /public_html/api/

| Aspecto | /private/backend/ + symlink | /public_html/api/ |
|---------|----------------------------|-------------------|
| **Seguridad** | 🟢 Muy segura | 🟡 Media (depende de .htaccess) |
| **Complejidad** | 🟡 Requiere symlink | 🟢 Simple |
| **Compatibilidad** | 🟡 No todos los hostings | 🟢 Todos los hostings |
| **Protección** | 🟢 Carpeta no accesible | 🟡 Protección por .htaccess |
| **Recomendada** | ✅ Sí (si es posible) | ⚠️ Solo si symlink no funciona |

---

## 🎯 CHECKLIST COMPLETO

- [ ] Crear carpeta `public_html/api/`
- [ ] Subir carpeta `app/` completa
- [ ] Subir `passenger_wsgi.py` (renombrado)
- [ ] Subir `.htaccess` con reglas de seguridad
- [ ] Crear `.env` con credenciales reales
- [ ] Subir `requirements.txt`
- [ ] Verificar permisos de archivos
- [ ] Crear base de datos PostgreSQL
- [ ] Ejecutar `deploy_neatech.sql`
- [ ] Probar: `https://grupovexus.com/api/v1/health`
- [ ] Verificar: `.env` da 403 Forbidden
- [ ] Verificar: archivos `.py` dan 403 Forbidden
- [ ] Probar login/registro desde frontend

---

**Última actualización:** 2025-10-31
**Versión:** 1.0.0
**Estado:** ✅ Solución alternativa sin symlink (menos segura pero funcional)
