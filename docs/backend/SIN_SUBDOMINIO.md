# 🔧 SOLUCIÓN SIN SUBDOMINIO - Backend en Neatech

## 📋 PROBLEMA

No puedes crear subdominio `api.grupovexus.com`, pero necesitas que el backend sea accesible.

---

## ✅ SOLUCIÓN: Enlace Simbólico (Symlink)

Crear un **enlace simbólico** desde `public_html/api` → `/private/backend`

### ¿Qué es un symlink?
Un "atajo" que hace que `public_html/api` apunte directamente a `/private/backend`

---

## 🚀 PASOS PARA IMPLEMENTAR

### 1. Subir Backend a /private/backend/

**Ruta real en Neatech basada en File Manager:**
```
Carpeta principal/
└── web/
    └── grupovexus.com/
        ├── private/
        │   └── backend/          ← AQUÍ VA EL BACKEND
        │       ├── app/
        │       │   ├── __init__.py
        │       │   ├── main.py
        │       │   └── ...
        │       ├── passenger_wsgi.py
        │       ├── .htaccess
        │       ├── .env
        │       └── requirements.txt
        │
        └── public_html/          ← AQUÍ VA EL FRONTEND
            ├── index.html
            ├── pages/
            ├── Static/
            └── api/  ← SYMLINK (crear después)
```

**Nota:** La estructura en el servidor es `Carpeta principal/web/grupovexus.com/`, no `/home/grupovex/`.

---

### 2. Crear Symlink vía Soporte de Neatech

**IMPORTANTE:** Dado que no tienes acceso SSH y la estructura es diferente, debes contactar a soporte de Neatech.

#### Solicitud para enviar a Soporte:

```
Hola, necesito que creen un enlace simbólico (symlink) para mi sitio:

DESDE: Carpeta principal/web/grupovexus.com/public_html/api
HACIA: Carpeta principal/web/grupovexus.com/private/backend

Comando (ajusten la ruta según su sistema):
ln -s /ruta/absoluta/a/private/backend /ruta/absoluta/a/public_html/api

El objetivo es que https://grupovexus.com/api apunte a mi backend en /private/backend/

Gracias.
```

**Alternativa si no pueden crear el symlink:** Ver "ALTERNATIVA SI SYMLINKS NO FUNCIONAN" al final de este documento.

---

### 3. Configurar .htaccess en public_html/

**Archivo:** `/home/grupovex/web/grupovexus.com/public_html/.htaccess`

```apache
# ====================================
# PUBLIC_HTML - .htaccess
# ====================================

RewriteEngine On
RewriteBase /

# ====== IMPORTANTE: Seguir Symlinks ======
Options +FollowSymLinks

# ====== BACKEND (via symlink /api → /private/backend) ======
# Las peticiones /api/* van al symlink que apunta a /private/backend/
# Passenger se encarga de ejecutar la app Python

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

### 4. Configurar .htaccess en el Backend

**Archivo:** `/home/grupovex/private/backend/.htaccess`

```apache
# ====================================
# BACKEND - .htaccess
# Accesible via symlink desde /api
# ====================================

# Habilitar Passenger
PassengerEnabled on
PassengerAppType wsgi
PassengerStartupFile passenger_wsgi.py
PassengerPython /usr/bin/python3

# Ruta de la aplicación
PassengerAppRoot /home/grupovex/private/backend

# Performance
PassengerMinInstances 1
PassengerMaxPoolSize 6

# Base URI (importante para symlink)
PassengerBaseURI /api

# Headers CORS
Header always set Access-Control-Allow-Origin "*"
Header always set Access-Control-Allow-Methods "GET, POST, PUT, DELETE, OPTIONS, PATCH"
Header always set Access-Control-Allow-Headers "Content-Type, Authorization"

# Logging
PassengerLogLevel 3

# Seguridad: No mostrar código Python
<FilesMatch "\.(py|pyc|pyo)$">
    Order allow,deny
    Deny from all
</FilesMatch>

<Files "passenger_wsgi.py">
    Allow from all
</Files>
```

**Nota importante:** `PassengerBaseURI /api` le dice a Passenger que la app está montada en `/api`

---

### 5. Configurar passenger_wsgi.py

**Archivo:** `/home/grupovex/private/backend/passenger_wsgi.py`

```python
"""
Passenger WSGI para Neatech
Accesible via symlink desde /public_html/api → /private/backend
"""
import sys
import os

# Añadir el directorio actual al path
sys.path.insert(0, os.path.dirname(__file__))

# Cargar variables de entorno
from dotenv import load_dotenv
load_dotenv(os.path.join(os.path.dirname(__file__), '.env'))

# Importar la aplicación FastAPI
try:
    from app.main import app as application
    print("✅ FastAPI app loaded successfully via symlink")
except Exception as e:
    print(f"❌ Error loading FastAPI app: {e}")
    raise
```

---

### 6. Configurar .env

**Archivo:** `/home/grupovex/private/backend/.env`

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
# Mismo dominio, sin subdominio
ALLOWED_ORIGINS=https://grupovexus.com,https://www.grupovexus.com

# === EMAIL ===
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USER=grupovexus@gmail.com
SMTP_PASSWORD=tnquxwpqddhxlxaf
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

## 📁 ESTRUCTURA FINAL

**Estructura real en Neatech (basada en File Manager):**

```
Carpeta principal/
└── web/
    └── grupovexus.com/
        ├── private/
        │   └── backend/                ← Backend (código real aquí)
        │       ├── app/
        │       ├── passenger_wsgi.py
        │       ├── .htaccess           ← Config Passenger + BaseURI
        │       ├── .env
        │       └── requirements.txt
        │
        └── public_html/                ← Frontend
            ├── index.html
            ├── pages/
            ├── Static/
            ├── .htaccess               ← Config con FollowSymLinks
            └── api/  → SYMLINK → ../private/backend
```

**Nota:** El symlink `api/` dentro de `public_html/` debe apuntar a `../private/backend` (ruta relativa).

---

## 🌐 URLS FINALES

| Componente | URL |
|------------|-----|
| **Frontend** | `https://grupovexus.com` |
| **Backend API** | `https://grupovexus.com/api/v1` |
| **Health Check** | `https://grupovexus.com/api/v1/health` |
| **API Docs** | `https://grupovexus.com/api/docs` |

---

## ✅ VERIFICACIÓN

### 1. Verificar que el symlink existe

**Vía File Manager de Neatech:**
1. Navega a: `Carpeta principal → web → grupovexus.com → public_html`
2. Deberías ver una carpeta/enlace llamado `api`
3. El enlace simbólico puede aparecer con un icono especial o como carpeta

**Nota:** Sin acceso SSH, solo puedes verificar visualmente en el File Manager.

---

### 2. Verificar Backend

```
https://grupovexus.com/api/v1/health
```

Debe retornar:
```json
{
  "status": "healthy",
  "database": "connected",
  "timestamp": "..."
}
```

---

### 3. Verificar Frontend

```
https://grupovexus.com
```

Abre consola (F12) y verifica:
```
✅ Backend connected
```

---

## 🐛 SOLUCIÓN DE PROBLEMAS

### Error: "Symlink no permitido"

**Causa:** Hosting no permite symlinks por seguridad

**Solución:** Contacta a Neatech pidiendo que lo habiliten o que ellos creen el symlink.

---

### Error: "403 Forbidden en /api"

**Causa:** Apache no sigue symlinks

**Solución:**
1. Verifica que `.htaccess` en `public_html` tiene:
   ```apache
   Options +FollowSymLinks
   ```
2. Contacta a Neatech para verificar que `FollowSymLinks` esté habilitado

---

### Error: "500 Internal Server Error"

**Causa:** Passenger no encuentra la app

**Solución:**
1. Verifica que `.htaccess` en `/private/backend/` tiene:
   ```apache
   PassengerBaseURI /api
   ```
2. Verifica que `passenger_wsgi.py` existe
3. Revisa logs: cPanel → Errors

---

### Error: "CORS Policy"

**Causa:** CORS mal configurado

**Solución:**
1. Verifica `.env`:
   ```bash
   ALLOWED_ORIGINS=https://grupovexus.com
   ```
2. Verifica que `.htaccess` tiene headers CORS
3. Reinicia: Crea `/private/backend/tmp/restart.txt`

---

## 🔄 ALTERNATIVA SI SYMLINKS NO FUNCIONAN

### Opción B: Mover Backend a public_html/api/

Si symlinks no están permitidos, mueve todo el backend:

```
/home/grupovex/web/grupovexus.com/public_html/
├── index.html
├── pages/
├── Static/
└── api/                                ← Backend directamente aquí
    ├── app/
    ├── passenger_wsgi.py
    ├── .htaccess
    └── .env
```

**⚠️ Menos seguro:** El código backend está en una carpeta pública.

**Mitiga riesgos:**
1. `.htaccess` bloquea acceso a archivos `.py`
2. `.env` nunca debe ser accesible

---

## 📝 SOLICITUD PARA SOPORTE DE NEATECH

**Envía este mensaje a soporte si no tienes acceso SSH:**

```
Asunto: Solicitud de creación de symlink para API

Hola equipo de Neatech,

Necesito ayuda para crear un enlace simbólico (symlink) en mi sitio web grupovexus.com.

Detalles:
- Dominio: grupovexus.com
- Usuario: grupovex

Necesito que el symlink apunte desde:
  public_html/api  →  ../private/backend

O en ruta absoluta (ajusten según su sistema):
  FROM: [ruta_absoluta]/web/grupovexus.com/public_html/api
  TO:   [ruta_absoluta]/web/grupovexus.com/private/backend

Objetivo: Que https://grupovexus.com/api apunte a mi aplicación Python en /private/backend/

Por favor confirmen cuando esté creado.

Gracias.
```

---

## 🎯 CHECKLIST

- [ ] Backend subido a `/private/backend/`
- [ ] Archivos renombrados (`passenger_wsgi_neatech.py` → `passenger_wsgi.py`)
- [ ] `.env` creado con credenciales reales
- [ ] `.htaccess` en `/private/backend/` con `PassengerBaseURI /api`
- [ ] Symlink creado: `public_html/api` → `/private/backend`
- [ ] `.htaccess` en `public_html/` con `Options +FollowSymLinks`
- [ ] `config.prod.js` tiene URL correcta: `https://grupovexus.com/api/v1` ✅
- [ ] Base de datos creada y configurada
- [ ] Verificar: `https://grupovexus.com/api/v1/health`
- [ ] Verificar: Frontend conecta con API

---

## 🎉 RESUMEN

**Sin subdominio, usamos un symlink:**

```
Frontend:  https://grupovexus.com          → /public_html/
Backend:   https://grupovexus.com/api/v1   → /public_html/api (symlink → /private/backend)
```

**Ventajas:**
- ✅ Mismo dominio (sin CORS issues)
- ✅ Backend en `/private/` (más seguro)
- ✅ URL limpia

**Desventaja:**
- ⚠️ Requiere que Neatech permita symlinks (mayoría sí)

---

**Última actualización:** 2025-10-31
**Versión:** 1.0.0
**Estado:** ✅ Solución sin Subdominio
