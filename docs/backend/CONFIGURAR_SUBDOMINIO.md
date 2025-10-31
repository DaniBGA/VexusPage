# 🌐 CONFIGURAR SUBDOMINIO api.grupovexus.com

## 📋 RESUMEN

Esta guía te muestra cómo crear el subdominio `api.grupovexus.com` en Neatech para que el backend sea accesible.

---

## ❓ ¿POR QUÉ UN SUBDOMINIO?

### ✅ Ventajas:
1. **Más limpio:** `api.grupovexus.com` vs `grupovexus.com/private/backend/`
2. **Más seguro:** `/private/` no es accesible vía web por defecto
3. **CORS más simple:** No hay problemas de mismo origen
4. **SSL automático:** Let's Encrypt se configura solo
5. **Passenger funciona mejor:** Document root directo

### ❌ Sin subdominio sería:
- URL fea: `grupovexus.com/private/backend/api/v1/...`
- Problemas de permisos (private no es público)
- Configuración Apache compleja
- Posibles issues de seguridad

---

## 🚀 PASOS PARA CREAR SUBDOMINIO

### 1. Acceder a cPanel

1. Ve a tu panel de Neatech
2. Inicia sesión en cPanel

---

### 2. Crear Subdominio

1. **Busca:** "Subdominios" o "Subdomains"
2. **Click en:** Subdomains

---

### 3. Configurar el Subdominio

**Formulario de creación:**

| Campo | Valor |
|-------|-------|
| **Subdomain** | `api` |
| **Domain** | `grupovexus.com` |
| **Document Root** | `/home/grupovex/private/backend` |

**Resultado:** `api.grupovexus.com` → `/home/grupovex/private/backend`

4. **Click:** "Create" o "Crear"

---

### 4. Verificar Creación

Después de crear:
- DNS se configura automáticamente
- SSL (HTTPS) se instala automáticamente con Let's Encrypt
- Puede tomar 5-10 minutos en propagarse

**Verifica:**
```bash
# Espera unos minutos, luego:
ping api.grupovexus.com
```

---

## 📁 ESTRUCTURA FINAL

```
/home/grupovex/
├── web/grupovexus.com/
│   └── public_html/                  ← Frontend
│       ├── index.html
│       └── ...
│
└── private/backend/                  ← Backend (vía api.grupovexus.com)
    ├── app/
    ├── passenger_wsgi.py
    ├── .htaccess
    └── ...
```

---

## ⚙️ CONFIGURACIÓN DEL BACKEND

### Archivo: `/home/grupovex/private/backend/.htaccess`

```apache
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

---

### Archivo: `/home/grupovex/private/backend/.env`

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
# IMPORTANTE: Incluir el subdominio
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

### Archivo: `/home/grupovex/private/backend/passenger_wsgi.py`

```python
"""
Passenger WSGI para Neatech - Subdominio api.grupovexus.com
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
    print("✅ FastAPI app loaded successfully")
except Exception as e:
    print(f"❌ Error loading FastAPI app: {e}")
    raise
```

---

## 🌐 CONFIGURACIÓN DEL FRONTEND

### Archivo: `frontend/Static/js/config.prod.js`

```javascript
// Configuración de producción - Subdominio
const CONFIG = {
    API_BASE_URL: 'https://api.grupovexus.com/api/v1',
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

## ✅ VERIFICACIÓN

### 1. Verificar Backend

Abre en tu navegador:
```
https://api.grupovexus.com/api/v1/health
```

**Debería retornar:**
```json
{
  "status": "healthy",
  "database": "connected",
  "timestamp": "2025-10-31T..."
}
```

---

### 2. Verificar Frontend

Abre en tu navegador:
```
https://grupovexus.com
```

Abre la **consola del navegador** (F12) y verifica:
```
✅ Backend connected
```

---

### 3. Probar Login

1. Click en "Iniciar Sesión"
2. Ingresa credenciales
3. Verifica que no hay errores de CORS
4. Verifica que el login funciona

---

## 🐛 SOLUCIÓN DE PROBLEMAS

### Error: "Subdominio no accesible"

**Causa:** DNS no propagado o SSL no instalado

**Solución:**
1. Espera 10-15 minutos
2. Verifica en cPanel que el subdominio existe
3. Verifica que SSL esté activo (candado en el navegador)

---

### Error: "500 Internal Server Error"

**Causa:** Passenger no encuentra la app o error en el código

**Solución:**
1. Verifica que `passenger_wsgi.py` existe en `/private/backend/`
2. Verifica que `.htaccess` existe
3. Revisa logs: cPanel → Errors → `error_log`
4. Verifica que `.env` tiene todas las variables

---

### Error: "CORS Policy"

**Causa:** CORS mal configurado en backend

**Solución:**
1. Verifica `.env`:
   ```bash
   ALLOWED_ORIGINS=https://grupovexus.com,https://api.grupovexus.com
   ```
2. Verifica `.htaccess` tiene headers CORS
3. Reinicia app: Crea `/private/backend/tmp/restart.txt`

---

### Error: "Database connection failed"

**Causa:** Credenciales incorrectas en `.env`

**Solución:**
1. Verifica `DATABASE_URL` en `.env`
2. Prueba conexión en phpPgAdmin
3. Verifica que el usuario tiene permisos

---

## 📊 RESUMEN

### URLs Finales:

| Componente | URL |
|------------|-----|
| **Frontend** | `https://grupovexus.com` |
| **Backend API** | `https://api.grupovexus.com/api/v1` |
| **Health Check** | `https://api.grupovexus.com/api/v1/health` |
| **API Docs** | `https://api.grupovexus.com/docs` |

### Estructura:

```
Frontend:  https://grupovexus.com         → /public_html/
Backend:   https://api.grupovexus.com     → /private/backend/
Database:  PostgreSQL                      → localhost:5432
```

---

## 🎯 CHECKLIST COMPLETO

- [ ] Crear subdominio `api.grupovexus.com` en cPanel
- [ ] Document Root: `/home/grupovex/private/backend`
- [ ] Subir archivos del backend a `/private/backend/`
- [ ] Renombrar `passenger_wsgi_neatech.py` → `passenger_wsgi.py`
- [ ] Crear `.htaccess` en `/private/backend/`
- [ ] Crear `.env` con credenciales reales
- [ ] Incluir subdominio en `ALLOWED_ORIGINS`
- [ ] Frontend tiene `config.prod.js` con URL correcta ✅
- [ ] Ejecutar `deploy_neatech.sql` en phpPgAdmin
- [ ] Verificar: `https://api.grupovexus.com/api/v1/health`
- [ ] Verificar: `https://grupovexus.com` conecta con API
- [ ] Probar login/registro

---

## 📝 NOTAS FINALES

### Ventajas del Subdominio:

1. ✅ **Seguridad:** `/private/` no expuesto directamente
2. ✅ **Claridad:** URLs limpias y profesionales
3. ✅ **CORS:** Sin problemas de mismo origen
4. ✅ **SSL:** Automático con Let's Encrypt
5. ✅ **Escalabilidad:** Fácil mover backend a otro servidor

### Sin Subdominio (NO recomendado):

- ❌ URL: `grupovexus.com/private/backend/api/v1/...`
- ❌ `/private/` NO es accesible vía web por defecto
- ❌ Requiere configuración Apache compleja
- ❌ Posibles problemas de seguridad
- ❌ Más difícil de mantener

---

**Última actualización:** 2025-10-31
**Versión:** 1.0.0
**Estado:** ✅ Configuración Recomendada
