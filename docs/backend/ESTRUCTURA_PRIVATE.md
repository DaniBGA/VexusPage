# 📂 BACKEND EN CARPETA PRIVATE (Neatech)

## 📋 RESUMEN

Ya que no puedes crear la carpeta `api/` en Neatech, vamos a usar la carpeta `private/` en su lugar.

---

## 📁 NUEVA ESTRUCTURA EN NEATECH

```
/home/grupovex/
├── web/grupovexus.com/
│   └── public_html/                # ← FRONTEND
│       ├── index.html
│       ├── pages/
│       ├── Static/
│       └── .htaccess              # ← Config con proxy a private/
│
└── private/                        # ← BACKEND AQUÍ
    └── backend/                    # ← Todo tu código Python
        ├── app/
        │   ├── __init__.py
        │   ├── main.py
        │   ├── config.py
        │   ├── api/
        │   ├── core/
        │   ├── models/
        │   └── services/
        ├── passenger_wsgi.py       # ← Entrada de la app
        ├── .htaccess               # ← Config Passenger
        ├── requirements.txt
        └── .env                    # ← Credenciales
```

---

## 🔧 CAMBIOS NECESARIOS

### 1. Actualizar .htaccess en public_html/

Ya que el backend estará en `/private/backend/`, necesitas actualizar el .htaccess del frontend:

**Archivo:** `/home/grupovex/web/grupovexus.com/public_html/.htaccess`

```apache
RewriteEngine On
RewriteBase /

# ====== IMPORTANTE: BACKEND EN /private/backend/ ======

# Opción A: Proxy directo (si Passenger lo permite)
RewriteCond %{REQUEST_URI} ^/api/(.*)$
RewriteRule ^api/(.*)$ http://127.0.0.1:8000/api/$1 [P,L]

# Opción B: Si Passenger no permite proxy interno
# Necesitarás configurar un subdominio o usar PHP como intermediario

# ====== FRONTEND (SPA) ======
RewriteCond %{REQUEST_FILENAME} !-f
RewriteCond %{REQUEST_FILENAME} !-d
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

### 2. Configurar Passenger en /private/backend/

**Archivo:** `/home/grupovex/private/backend/.htaccess`

```apache
# ==================================
# NEATECH - Backend en Private
# ==================================

# Habilitar Passenger
PassengerEnabled on
PassengerAppType wsgi
PassengerStartupFile passenger_wsgi.py

# Intérprete Python
PassengerPython /usr/bin/python3

# Ruta de la aplicación
PassengerAppRoot /home/grupovex/private/backend

# Performance
PassengerMinInstances 1
PassengerMaxPoolSize 6

# Hacer accesible vía web (IMPORTANTE)
# Esto permite que se pueda acceder al backend
PassengerBaseURI /api

# Headers CORS
Header always set Access-Control-Allow-Origin "*"
Header always set Access-Control-Allow-Methods "GET, POST, PUT, DELETE, OPTIONS, PATCH"
Header always set Access-Control-Allow-Headers "Content-Type, Authorization"

# Logs
PassengerLogLevel 3

# No mostrar archivos Python
<FilesMatch "\.(py|pyc|pyo)$">
    Order allow,deny
    Deny from all
</FilesMatch>

<Files "passenger_wsgi.py">
    Allow from all
</Files>
```

---

## 🚀 SOLUCIÓN RECOMENDADA: Usar Subdominio

La forma más confiable es crear un subdominio para la API:

### Paso 1: Crear subdominio en cPanel

1. Ve a **cPanel → Subdomains**
2. Crea: `api.grupovexus.com`
3. Document Root: `/home/grupovex/private/backend`

### Paso 2: Configurar .htaccess en el subdominio

**Archivo:** `/home/grupovex/private/backend/.htaccess`

```apache
PassengerEnabled on
PassengerAppType wsgi
PassengerStartupFile passenger_wsgi.py
PassengerPython /usr/bin/python3
PassengerAppRoot /home/grupovex/private/backend
PassengerMinInstances 1
PassengerMaxPoolSize 6

Header always set Access-Control-Allow-Origin "*"
Header always set Access-Control-Allow-Methods "GET, POST, PUT, DELETE, OPTIONS, PATCH"
Header always set Access-Control-Allow-Headers "Content-Type, Authorization"

<FilesMatch "\.(py|pyc|pyo)$">
    Order allow,deny
    Deny from all
</FilesMatch>

<Files "passenger_wsgi.py">
    Allow from all
</Files>
```

### Paso 3: Actualizar config.prod.js

**Archivo:** `frontend/Static/js/config.prod.js`

```javascript
const CONFIG = {
    API_BASE_URL: 'https://api.grupovexus.com/api/v1',  // ← Subdominio
    TOKEN_KEY: 'vexusToken',
    USER_KEY: 'vexusUser',
    REQUEST_TIMEOUT: 30000,
    ENVIRONMENT: 'production',
    DEBUG: false
};

export default CONFIG;
```

### Paso 4: Actualizar CORS en backend

**Archivo:** `/home/grupovex/private/backend/.env`

```bash
ALLOWED_ORIGINS=https://grupovexus.com,https://www.grupovexus.com,https://api.grupovexus.com
```

---

## 📋 GUÍA PASO A PASO (Con Subdominio)

### 1. Crear subdominio `api.grupovexus.com`

1. **cPanel → Domains → Subdomains**
2. **Subdomain:** `api`
3. **Document Root:** `/home/grupovex/private/backend`
4. Click **Create**

---

### 2. Subir archivos del backend

Sube estos archivos a `/home/grupovex/private/backend/`:

```
✅ SUBIR:
- app/ (carpeta completa)
- passenger_wsgi_neatech.py → passenger_wsgi.py
- .htaccess_neatech → .htaccess
- requirements.txt
```

---

### 3. Crear .env en el servidor

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
ALLOWED_ORIGINS=https://grupovexus.com,https://www.grupovexus.com,https://api.grupovexus.com

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

### 4. Actualizar frontend

**Archivo local:** `frontend/Static/js/config.prod.js`

```javascript
const CONFIG = {
    API_BASE_URL: 'https://api.grupovexus.com/api/v1',
    TOKEN_KEY: 'vexusToken',
    USER_KEY: 'vexusUser',
    REQUEST_TIMEOUT: 30000,
    ENVIRONMENT: 'production',
    DEBUG: false
};
```

**Luego sube el frontend completo a:** `/home/grupovex/web/grupovexus.com/public_html/`

---

### 5. Verificar

**Backend:**
- Abre: `https://api.grupovexus.com/api/v1/health`
- Debe retornar JSON con `status: "healthy"`

**Frontend:**
- Abre: `https://grupovexus.com`
- Consola debe mostrar: "✅ Backend connected"

---

## 🐛 SOLUCIÓN DE PROBLEMAS

### Error: "Subdomain already exists"

Si el subdominio ya existe:
1. **cPanel → Domains → Subdomains**
2. Busca `api.grupovexus.com`
3. Click en **Manage** → Cambiar Document Root a `/home/grupovex/private/backend`

---

### Error: "500 Internal Server Error"

**Causa:** Passenger no encuentra la app o hay error en el código

**Solución:**
1. Verifica que `passenger_wsgi.py` existe
2. Revisa logs: **cPanel → Errors** → busca `passenger`
3. Verifica que `.env` tenga todas las variables

---

### Error: "Connection refused"

**Causa:** Backend no está iniciado o no es accesible

**Solución:**
1. Verifica que el subdominio apunta correctamente
2. Prueba acceder a: `https://api.grupovexus.com`
3. Debe mostrar algo (aunque sea un error de la app)

---

### Error: CORS

**Causa:** CORS mal configurado

**Solución:**
1. Verifica `.env` del backend:
   ```bash
   ALLOWED_ORIGINS=https://grupovexus.com,https://api.grupovexus.com
   ```
2. Reinicia la app: Crear `/home/grupovex/private/backend/tmp/restart.txt`

---

## 📊 VENTAJAS DE USAR SUBDOMINIO

### ✅ Pros:
- Más confiable que proxies internos
- Fácil de configurar en cPanel
- Logs separados
- SSL automático (Let's Encrypt)
- Mejor para debugging

### ❌ Contras:
- Requiere DNS adicional (auto-configurado por cPanel)
- URL del API visible en el navegador

---

## 🎯 CHECKLIST

- [ ] Crear subdominio `api.grupovexus.com` en cPanel
- [ ] Document Root apunta a `/home/grupovex/private/backend`
- [ ] Subir archivos del backend a `/private/backend/`
- [ ] Crear `.env` con credenciales reales
- [ ] Crear `.htaccess` en `/private/backend/`
- [ ] Actualizar `config.prod.js` con URL del subdominio
- [ ] Subir frontend actualizado a `public_html/`
- [ ] Verificar `https://api.grupovexus.com/api/v1/health`
- [ ] Verificar `https://grupovexus.com` conecta con API
- [ ] Probar login/registro

---

## 🎉 RESUMEN

**Estructura final:**

```
Frontend:  https://grupovexus.com        → /public_html/
Backend:   https://api.grupovexus.com    → /private/backend/
Database:  PostgreSQL                     → localhost:5432
```

**Esto es la forma más limpia y confiable de desplegar en Neatech sin acceso a consola SSH.**

---

**Última actualización:** 2025-10-31
**Versión:** 1.0.0
