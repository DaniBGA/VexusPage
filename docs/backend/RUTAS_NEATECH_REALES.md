# 📂 RUTAS REALES EN NEATECH

**Fecha:** 2025-10-31
**Basado en:** Capturas de pantalla del File Manager de Neatech

---

## 🗂️ ESTRUCTURA REAL DEL SERVIDOR

### Navegación en File Manager:
```
Carpeta principal
└── web
    └── grupovexus.com
        ├── private/          ← Carpeta para backend (no accesible vía web)
        │   └── backend/      ← TU BACKEND VA AQUÍ
        │
        └── public_html/      ← Carpeta pública (accesible vía web)
            └── [frontend]    ← TU FRONTEND VA AQUÍ
```

---

## 📍 RUTAS ESPECÍFICAS

### Backend (Private):
```
Ruta en File Manager:
Carpeta principal → web → grupovexus.com → private → backend

Estructura interna:
private/backend/
├── app/
│   ├── __init__.py
│   ├── main.py
│   ├── config.py
│   ├── api/
│   ├── core/
│   ├── models/
│   └── services/
├── passenger_wsgi.py       ← Renombrar desde passenger_wsgi_neatech.py
├── .htaccess               ← Renombrar desde .htaccess_neatech
├── .env                    ← Crear basado en .env.example
└── requirements.txt
```

### Frontend (Public):
```
Ruta en File Manager:
Carpeta principal → web → grupovexus.com → public_html

Estructura interna:
public_html/
├── index.html
├── pages/
│   ├── about.html
│   ├── contact.html
│   ├── courses.html
│   ├── login.html
│   └── register.html
├── Static/
│   ├── css/
│   ├── js/
│   └── images/
├── .htaccess               ← Renombrar desde .htaccess_public_html
└── api/  ← SYMLINK (pedir a soporte que lo cree)
```

---

## 🔗 SYMLINK NECESARIO

### ¿Qué es?
Un enlace simbólico que hace que `public_html/api` apunte a `private/backend`

### ¿Por qué?
Para que `https://grupovexus.com/api/v1/...` funcione sin necesidad de subdominio.

### ¿Cómo?
**Debes pedirle a soporte de Neatech que lo cree**, porque no tienes acceso SSH.

### Solicitud para enviar a soporte:
```
Asunto: Solicitud de creación de symlink para API

Hola equipo de Neatech,

Necesito ayuda para crear un enlace simbólico (symlink) en mi sitio grupovexus.com.

Detalles:
- Dominio: grupovexus.com
- Usuario: grupovex

Necesito que el symlink apunte:
  DESDE: public_html/api
  HACIA: ../private/backend

O en ruta absoluta:
  FROM: [ruta_absoluta]/web/grupovexus.com/public_html/api
  TO:   [ruta_absoluta]/web/grupovexus.com/private/backend

Objetivo: Que https://grupovexus.com/api apunte a mi aplicación Python en /private/backend/

Gracias.
```

---

## 🌐 URLS FINALES

| Componente | URL Pública | Ubicación en Servidor |
|------------|-------------|----------------------|
| **Frontend** | `https://grupovexus.com` | `public_html/` |
| **Frontend** | `https://www.grupovexus.com` | `public_html/` |
| **Backend API** | `https://grupovexus.com/api/v1` | `private/backend/` (vía symlink) |
| **Health Check** | `https://grupovexus.com/api/v1/health` | `private/backend/app/main.py` |
| **API Docs** | `https://grupovexus.com/api/docs` | `private/backend/app/main.py` |

---

## ✅ ARCHIVOS DE CONFIGURACIÓN

### 1. Frontend: config.js
**Ubicación:** `public_html/Static/js/config.js`

```javascript
// Configuración de producción
// Backend en Neatech - Mismo dominio con symlink /api
const CONFIG = {
    API_BASE_URL: 'https://grupovexus.com/api/v1',
    TOKEN_KEY: 'vexusToken',
    USER_KEY: 'vexusUser',
    REQUEST_TIMEOUT: 30000,
    ENVIRONMENT: 'production',
    DEBUG: false
};

export default CONFIG;
```

✅ **Ya está configurado correctamente**

---

### 2. Backend: .env
**Ubicación:** `private/backend/.env`

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
# IMPORTANTE: Incluir AMBAS versiones
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

**Nota:** Usa el archivo `.env.example` como template.

---

### 3. Backend: .htaccess
**Ubicación:** `private/backend/.htaccess`
**Renombrar desde:** `.htaccess_neatech`

```apache
# Habilitar Passenger
PassengerEnabled on
PassengerAppType wsgi
PassengerStartupFile passenger_wsgi.py
PassengerPython /usr/bin/python3

# Ruta de la aplicación
PassengerAppRoot /ruta/absoluta/a/private/backend

# Performance
PassengerMinInstances 1
PassengerMaxPoolSize 6

# Base URI (IMPORTANTE para symlink)
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

**⚠️ IMPORTANTE:** `PassengerBaseURI /api` le dice a Passenger que la app está montada en `/api`

---

### 4. Frontend: .htaccess
**Ubicación:** `public_html/.htaccess`
**Renombrar desde:** `.htaccess_public_html`

```apache
RewriteEngine On
RewriteBase /

# ====== IMPORTANTE: Seguir Symlinks ======
Options +FollowSymLinks

# ====== BACKEND (via symlink /api → /private/backend) ======
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

**⚠️ IMPORTANTE:** `Options +FollowSymLinks` permite que Apache siga el symlink `api/`

---

## 🎯 PASOS PARA DESPLEGAR

### 1. Subir Backend
1. Ve a: `Carpeta principal → web → grupovexus.com → private`
2. Crea carpeta `backend` si no existe
3. Sube TODO el contenido de tu carpeta `backend/` local:
   - Carpeta `app/` completa
   - `passenger_wsgi_neatech.py` (renombrar a `passenger_wsgi.py`)
   - `.htaccess_neatech` (renombrar a `.htaccess`)
   - `requirements.txt`
4. Crea archivo `.env` basado en `.env.example`

---

### 2. Subir Frontend
1. Ve a: `Carpeta principal → web → grupovexus.com → public_html`
2. Sube TODO el contenido de tu carpeta `frontend/` local:
   - `index.html`
   - Carpeta `pages/`
   - Carpeta `Static/`
3. Sube `.htaccess_public_html` y renombra a `.htaccess`

---

### 3. Crear Base de Datos
1. En cPanel → PostgreSQL → Crear base de datos: `grupovex_db`
2. Crear usuario: `grupovex_db` con password seguro
3. Asignar usuario a la base de datos
4. En phpPgAdmin → Ejecutar script: `deploy_neatech.sql`

---

### 4. Solicitar Symlink
1. Contacta a soporte de Neatech
2. Envía la solicitud que está arriba en este documento
3. Espera confirmación

---

### 5. Verificar
1. **Backend:** Abre `https://grupovexus.com/api/v1/health`
   - Debe retornar: `{"status":"healthy","database":"connected","timestamp":"..."}`
2. **Frontend:** Abre `https://grupovexus.com`
   - Abre consola (F12) y verifica: "✅ Backend connected"
3. **Login:** Prueba login/registro

---

## ❌ ERRORES COMUNES

### Error: "Backend no responde"
**Causa:** Backend no está configurado correctamente

**Solución:**
1. Verifica que `passenger_wsgi.py` existe en `private/backend/`
2. Verifica que `.htaccess` existe en `private/backend/`
3. Verifica que `.env` tiene credenciales correctas
4. Revisa logs en cPanel → Errors

---

### Error: "CORS Policy"
**Causa:** Frontend está en `www.grupovexus.com` pero backend solo permite `grupovexus.com`

**Solución:**
1. En `private/backend/.env` asegúrate de tener:
   ```
   ALLOWED_ORIGINS=https://grupovexus.com,https://www.grupovexus.com
   ```
2. Reinicia app: Crea archivo `private/backend/tmp/restart.txt`

---

### Error: "404 Not Found en /api/"
**Causa:** Symlink no existe

**Solución:**
1. Verifica que el symlink `api` existe en `public_html/`
2. Si no existe, contacta a soporte de Neatech
3. Alternativa: Mover backend directamente a `public_html/api/` (menos seguro)

---

### Error: "500 Internal Server Error"
**Causa:** Passenger no puede ejecutar la app

**Solución:**
1. Verifica que `PassengerBaseURI /api` está en `.htaccess` del backend
2. Verifica que `passenger_wsgi.py` importa correctamente la app
3. Revisa logs: cPanel → Errors → `error_log`

---

## 📝 NOTAS IMPORTANTES

1. **NO uses `/home/grupovex/`** en las rutas - esa ruta no existe en tu hosting
2. **Usa `Carpeta principal → web → grupovexus.com`** en File Manager
3. **Symlink es CRÍTICO** - sin él, el backend no será accesible vía `/api`
4. **CORS debe incluir ambas versiones** - `www` y sin `www`
5. **config.js ya está actualizado** - apunta a `https://grupovexus.com/api/v1`

---

## 📞 SOPORTE

Si tienes problemas:
1. Lee [SIN_SUBDOMINIO.md](SIN_SUBDOMINIO.md) para más detalles
2. Revisa logs en cPanel → Errors
3. Contacta a soporte de Neatech para el symlink

---

**Última actualización:** 2025-10-31
**Versión:** 1.0.0
**Estado:** ✅ Documentación basada en estructura real del servidor
