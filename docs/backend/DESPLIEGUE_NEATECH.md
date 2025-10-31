# 🚀 GUÍA DE DESPLIEGUE EN NEATECH (SIN CONSOLA SSH)

Esta guía te permitirá desplegar el backend de Vexus en Neatech usando solo el File Manager de cPanel.

---

## 📋 PREREQUISITOS

1. Acceso al panel de Neatech (cPanel)
2. Base de datos PostgreSQL creada en phpPgAdmin
3. Usuario y contraseña de la base de datos
4. Python 3.8+ instalado en el servidor (Neatech lo tiene por defecto)

---

## 📁 ESTRUCTURA FINAL EN NEATECH

```
/home/grupovex/web/grupovexus.com/
├── public_html/              # ← FRONTEND aquí
│   ├── index.html
│   ├── assets/
│   ├── css/
│   ├── js/
│   └── .htaccess            # ← CREAR ESTE
│
└── private/                     # ← BACKEND aquí (crear esta carpeta)
    ├── app/                 # ← Todo tu código Python
    │   ├── __init__.py
    │   ├── main.py
    │   ├── config.py
    │   ├── api/
    │   ├── core/
    │   ├── models/
    │   └── services/
    ├── passenger_wsgi.py    # ← IMPORTANTE
    ├── .htaccess            # ← IMPORTANTE
    ├── requirements.txt     # ← Dependencias
    └── .env                 # ← CREAR MANUALMENTE (con tus credenciales)
```

---

## 🔧 PASO 1: CREAR LA BASE DE DATOS

1. Ve a **phpPgAdmin** en cPanel
2. Ejecuta el archivo `deploy_neatech.sql` completo
3. Verifica que todas las tablas se crearon correctamente
4. Anota las credenciales:
   - Host: `localhost`
   - Puerto: `5432`
   - Database: `grupovex_db`
   - Usuario: `grupovex_db`
   - Password: (la que te dio Neatech)

---

## 📤 PASO 2: SUBIR ARCHIVOS AL SERVIDOR

### 2.1 Crear carpeta `api`

1. En File Manager, navega a: `/web/grupovexus.com/`
2. Crea una nueva carpeta llamada `api` (al mismo nivel que `public_html`)

### 2.2 Subir el backend

Sube los siguientes archivos/carpetas a `/web/grupovexus.com/api/`:

```
✅ SUBIR:
- Carpeta completa: app/ (con todo su contenido)
- passenger_wsgi_neatech.py → renombrar a passenger_wsgi.py
- .htaccess_neatech → renombrar a .htaccess
- requirements.txt
```

```
❌ NO SUBIR:
- venv/ (entorno virtual)
- .env (créalo manualmente en el servidor)
- .env.neatech (tiene credenciales)
- test_*.py (archivos de prueba)
- __pycache__/
- *.pyc
```

---

## 🔐 PASO 3: CREAR ARCHIVO .env

1. En File Manager, navega a `/web/grupovexus.com/api/`
2. Crea un nuevo archivo llamado `.env`
3. Copia el siguiente contenido y completa con TUS datos:

```env
# === BASE DE DATOS NEATECH ===
DATABASE_URL=postgresql://grupovex_db:TU_PASSWORD_AQUI@localhost:5432/grupovex_db
DB_POOL_MIN_SIZE=5
DB_POOL_MAX_SIZE=20
DB_CONNECT_TIMEOUT=10

# === SEGURIDAD ===
SECRET_KEY=GENERA-UNA-CLAVE-SECRETA-FUERTE-AQUI
ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=30

# === CORS ===
ALLOWED_ORIGINS=https://grupovexus.com,https://www.grupovexus.com

# === EMAIL (SMTP) ===
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USER=grupovexus@gmail.com
SMTP_PASSWORD=tnquxwpqddhxlxaf
EMAIL_FROM=grupovexus@gmail.com

# === FRONTEND ===
FRONTEND_URL=https://grupovexus.com

# === APLICACIÓN ===
PROJECT_NAME=Vexus API
VERSION=1.0.0
API_V1_PREFIX=/api/v1
ENVIRONMENT=production
DEBUG=False
```

4. **IMPORTANTE:** Cambia `TU_PASSWORD_AQUI` por la contraseña real de tu base de datos
5. Genera una `SECRET_KEY` segura (puedes usar: https://djecrety.ir/)

---

## ⚙️ PASO 4: CONFIGURAR .htaccess EN API

Verifica que el archivo `/web/grupovexus.com/api/.htaccess` tenga este contenido:

```apache
# Habilitar Passenger para Python
PassengerEnabled on
PassengerAppType wsgi
PassengerStartupFile passenger_wsgi.py
PassengerPython /usr/bin/python3

# Ruta de la aplicación (CAMBIA grupovex por tu usuario)
PassengerAppRoot /home/grupovex/web/grupovexus.com/api

# Performance
PassengerMinInstances 1
PassengerMaxPoolSize 6

# Headers CORS
Header always set Access-Control-Allow-Origin "*"
Header always set Access-Control-Allow-Methods "GET, POST, PUT, DELETE, OPTIONS, PATCH"
Header always set Access-Control-Allow-Headers "Content-Type, Authorization"

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

## 🌐 PASO 5: CONFIGURAR .htaccess EN PUBLIC_HTML

Crea/edita el archivo `/web/grupovexus.com/public_html/.htaccess`:

```apache
RewriteEngine On
RewriteBase /

# ====== REDIRIGIR /api/* A LA CARPETA API ======
RewriteCond %{REQUEST_URI} ^/api/(.*)$
RewriteRule ^api/(.*)$ /api/$1 [L,P]

# ====== FRONTEND (SPA) ======
# Si no existe el archivo, servir index.html
RewriteCond %{REQUEST_FILENAME} !-f
RewriteCond %{REQUEST_FILENAME} !-d
RewriteRule ^ /index.html [L]

# ====== HEADERS CORS ======
Header always set Access-Control-Allow-Origin "*"
Header always set Access-Control-Allow-Methods "GET, POST, PUT, DELETE, OPTIONS, PATCH"
Header always set Access-Control-Allow-Headers "Content-Type, Authorization"
```

---

## 🔄 PASO 6: INSTALAR DEPENDENCIAS (Opción A - Manual)

### Opción A: Usando Python Selector de cPanel

1. En cPanel, busca "**Setup Python App**" o "**Python Selector**"
2. Crea una nueva aplicación Python:
   - Python version: `3.8` o superior
   - Application root: `/web/grupovexus.com/api`
   - Application URL: `grupovexus.com/api`
3. En "**Configuration files**", pega el contenido de `requirements.txt`
4. Click en "**Add**" para instalar dependencias

### Opción B: Si no tienes Python Selector

Passenger instalará las dependencias automáticamente al primer request.
Solo asegúrate de que `requirements.txt` esté en la carpeta `/api/`.

---

## ✅ PASO 7: VERIFICAR EL DESPLIEGUE

### 7.1 Verificar la API

Abre en tu navegador:
- `https://grupovexus.com/api/v1/health`

Deberías ver:
```json
{
  "status": "healthy",
  "database": "connected",
  "timestamp": "2025-10-31T..."
}
```

### 7.2 Ver logs de errores

Si algo falla:
1. Ve a **cPanel → Errors** o **cPanel → Logs**
2. Busca el archivo: `passenger_app.log` o `error_log`
3. Los errores de Python aparecerán ahí

### 7.3 Reiniciar la aplicación

Si necesitas reiniciar:
1. En File Manager, crea un archivo vacío llamado `tmp/restart.txt` dentro de `/api/`
2. Passenger detectará el cambio y reiniciará automáticamente

---

## 🔍 SOLUCIÓN DE PROBLEMAS

### Error: "500 Internal Server Error"

**Causa:** Error en el código o falta de dependencias

**Solución:**
1. Revisa los logs en cPanel → Errors
2. Verifica que `.env` tenga las credenciales correctas
3. Verifica que `passenger_wsgi.py` existe y tiene el nombre correcto

---

### Error: "Database connection failed"

**Causa:** Credenciales incorrectas en `.env`

**Solución:**
1. Verifica el `DATABASE_URL` en `.env`
2. Prueba la conexión en phpPgAdmin
3. Asegúrate de que el usuario tiene permisos

---

### Error: "Module not found"

**Causa:** Dependencias no instaladas

**Solución:**
1. Usa Python Selector en cPanel para instalar dependencias
2. Verifica que `requirements.txt` esté en `/api/`
3. Crea el archivo `tmp/restart.txt` para reiniciar

---

### La API no responde en /api/v1/...

**Causa:** Proxy mal configurado

**Solución:**
1. Verifica `.htaccess` en `public_html/`
2. Asegúrate de que el RewriteRule esté correcto
3. Verifica que mod_rewrite esté habilitado (normalmente sí en cPanel)

---

## 📞 ENDPOINTS DE LA API

Una vez desplegada, tu API estará disponible en:

- Base: `https://grupovexus.com/api/v1`
- Health: `https://grupovexus.com/api/v1/health`
- Auth: `https://grupovexus.com/api/v1/auth/login`
- Cursos: `https://grupovexus.com/api/v1/courses`
- etc.

---

## 🔒 SEGURIDAD POST-DESPLIEGUE

### ✅ Checklist de seguridad:

- [ ] `.env` NO está en git
- [ ] `SECRET_KEY` es única y fuerte
- [ ] Base de datos usa contraseña segura
- [ ] CORS solo permite tu dominio
- [ ] DEBUG=False en producción
- [ ] Archivos `.py` no son accesibles directamente (bloqueado por .htaccess)

---

## 📝 MANTENIMIENTO

### Actualizar el código:

1. Sube los archivos modificados via File Manager
2. Crea/toca el archivo: `/api/tmp/restart.txt`
3. Passenger reiniciará automáticamente

### Ver logs:

- Logs de aplicación: `/home/grupovex/logs/passenger_app.log`
- Logs de Apache: cPanel → Errors → error_log

### Backup:

- Descarga toda la carpeta `/api/` regularmente
- Exporta la base de datos desde phpPgAdmin

---

## 🎉 ¡LISTO!

Tu backend debería estar funcionando en:
**https://grupovexus.com/api/v1/**

Si tienes problemas, revisa los logs y contacta al soporte de Neatech.
