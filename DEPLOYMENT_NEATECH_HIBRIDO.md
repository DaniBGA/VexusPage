# 🚀 DEPLOYMENT HÍBRIDO - NEATECH + RAILWAY

## 📊 Arquitectura
- **Frontend:** Neatech/cPanel (grupovexus.com)
- **Backend + BD:** Railway.app (GRATIS)

---

## PARTE 1: DESPLEGAR BACKEND EN RAILWAY (15 minutos)

### Paso 1: Crear cuenta en Railway
1. Ve a: https://railway.app
2. Click en "Start a New Project"
3. Conecta con GitHub

### Paso 2: Subir proyecto a GitHub (si no lo has hecho)

Desde tu computadora local:

```bash
cd C:\Users\Daniel\Desktop\VexusPage

# Inicializar Git (si no está inicializado)
git init
git add .
git commit -m "Preparar para deployment"

# Crear repositorio en GitHub
# Ve a: https://github.com/new
# Nombre: VexusPage
# Luego:

git remote add origin https://github.com/TU-USUARIO/VexusPage.git
git branch -M main
git push -u origin main
```

### Paso 3: Desplegar en Railway

1. En Railway, click "Deploy from GitHub repo"
2. Selecciona tu repositorio "VexusPage"
3. Railway detectará automáticamente el backend

**Configurar variables de entorno en Railway:**

Click en tu proyecto → Variables → Add Variables:

```bash
# Copiar TODAS estas variables:
DATABASE_URL=postgresql://postgres:POSTGRES_PASSWORD@postgres:5432/vexus_db
SECRET_KEY=7dyWPVjAdHIzOh-A9p-MOZAqvejk4EqfdfvA6EEK4lyoshMPC8yuLpHrP-a-Oka1FYqkAOqr0vmDuIScb8_XLw
ALLOWED_ORIGINS=https://grupovexus.com,https://www.grupovexus.com
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USER=grupovexus@gmail.com
SMTP_PASSWORD=tnquxwpqddhxlxaf
EMAIL_FROM=grupovexus@gmail.com
FRONTEND_URL=https://grupovexus.com
ENVIRONMENT=production
DEBUG=False
API_V1_PREFIX=/api/v1
ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=60
PROJECT_NAME=Vexus API
VERSION=1.0.0
```

### Paso 4: Agregar PostgreSQL en Railway

1. En Railway, click "+ New"
2. Selecciona "Database" → "PostgreSQL"
3. Railway creará la base de datos automáticamente
4. Conectará automáticamente con tu backend

### Paso 5: Obtener URL del backend

Una vez desplegado:
1. Click en el servicio del backend
2. Ve a "Settings" → "Generate Domain"
3. Copia la URL (ejemplo: `vexus-backend.up.railway.app`)

**Guarda esta URL, la necesitarás**

### Paso 6: Inicializar base de datos

En Railway, abre la terminal del backend:
1. Click en el servicio backend
2. Click en "Deployments" → última versión → "View Logs"
3. Si hay errores de base de datos, ve al siguiente paso

**Opción A: Usar Railway CLI**
```bash
# Instalar Railway CLI
npm i -g @railway/cli

# Login
railway login

# Conectar a tu proyecto
railway link

# Abrir shell en el backend
railway run bash

# Dentro del shell, crear tablas:
python -c "from app.core.database import db; import asyncio; asyncio.run(db.connect())"
```

**Opción B: Usar script SQL**
1. Ve a PostgreSQL en Railway
2. Click "Connect"
3. Usa "Query" o conéctate con cliente PostgreSQL
4. Ejecuta el SQL de `deployment/production/vexus_db.sql`

---

## PARTE 2: SUBIR FRONTEND A NEATECH/CPANEL

### Paso 1: Actualizar configuración del frontend

En tu computadora local, edita:

**`frontend/Static/js/config.prod.js`:**
```javascript
const CONFIG = {
    API_BASE_URL: 'https://vexus-backend.up.railway.app/api/v1', // URL de Railway
    TOKEN_KEY: 'vexusToken',
    USER_KEY: 'vexusUser',
    REQUEST_TIMEOUT: 30000
};

export default CONFIG;
```

**IMPORTANTE:** Reemplaza `vexus-backend.up.railway.app` con tu URL real de Railway.

### Paso 2: Crear archivo .htaccess para el frontend

Crea en `frontend/.htaccess`:

```apache
# Habilitar CORS
<IfModule mod_headers.c>
    Header set Access-Control-Allow-Origin "*"
    Header set Access-Control-Allow-Methods "GET, POST, PUT, DELETE, OPTIONS"
    Header set Access-Control-Allow-Headers "Content-Type, Authorization"
</IfModule>

# Redireccionar a HTTPS
RewriteEngine On
RewriteCond %{HTTPS} off
RewriteRule ^(.*)$ https://%{HTTP_HOST}%{REQUEST_URI} [L,R=301]

# Configuración de cache
<IfModule mod_expires.c>
    ExpiresActive On
    ExpiresByType image/jpg "access plus 1 year"
    ExpiresByType image/jpeg "access plus 1 year"
    ExpiresByType image/gif "access plus 1 year"
    ExpiresByType image/png "access plus 1 year"
    ExpiresByType image/webp "access plus 1 year"
    ExpiresByType text/css "access plus 1 month"
    ExpiresByType application/javascript "access plus 1 month"
</IfModule>

# Comprimir archivos
<IfModule mod_deflate.c>
    AddOutputFilterByType DEFLATE text/html text/plain text/xml text/css text/javascript application/javascript application/json
</IfModule>
```

### Paso 3: Decidir qué config.js usar

Tienes 2 opciones:

**Opción A: Usar config.prod.js (Recomendado)**

Renombra o edita el import en tus archivos JS:

En `frontend/Static/js/main.js` (y otros que importen config):
```javascript
// Cambiar de:
import CONFIG from './config.js';

// A:
import CONFIG from './config.prod.js';
```

**Opción B: Sobrescribir config.js**
```bash
# En tu computadora:
cd C:\Users\Daniel\Desktop\VexusPage\frontend\Static\js
copy config.prod.js config.js
# Sobrescribir cuando pregunte: Sí
```

### Paso 4: Subir archivos a cPanel

**Método 1: File Manager de cPanel (Más fácil)**

1. Entra a tu cPanel de Neatech/Neothek
2. Busca "File Manager" o "Administrador de archivos"
3. Ve a la carpeta `public_html` o `www` o `htdocs`
4. **Elimina todo lo que haya ahí** (backup primero si hay algo importante)
5. Sube todos los archivos de la carpeta `frontend/`:
   - index.html
   - pages/
   - Static/
   - .htaccess

**Método 2: FTP (FileZilla)**

1. Descargar FileZilla: https://filezilla-project.org/
2. Conectar con credenciales FTP de tu hosting:
   - Host: grupovexus.com o ftp.grupovexus.com
   - Usuario: (proporcionado por Neatech)
   - Contraseña: (proporcionado por Neatech)
   - Puerto: 21
3. Ir a carpeta `public_html`
4. Subir todo el contenido de `frontend/`

### Paso 5: Configurar SSL en cPanel

1. En cPanel, busca "SSL/TLS Status" o "Let's Encrypt"
2. Habilitar SSL para `grupovexus.com`
3. Si hay opción "AutoSSL" o "Let's Encrypt", activarla

### Paso 6: Verificar permisos

En el File Manager de cPanel:
- Carpetas: 755
- Archivos: 644

---

## PARTE 3: CONECTAR TODO

### Paso 1: Actualizar CORS en Railway

En Railway, ve a variables de entorno del backend:

```bash
ALLOWED_ORIGINS=https://grupovexus.com,https://www.grupovexus.com,http://grupovexus.com,http://www.grupovexus.com
```

### Paso 2: Reiniciar backend en Railway

1. En Railway, ve al servicio backend
2. Click en "Redeploy"

### Paso 3: Probar todo

1. Abre: https://grupovexus.com
2. Prueba el formulario de contacto
3. Prueba login/registro

---

## ✅ VERIFICACIÓN FINAL

### Backend (Railway):
- [ ] Backend desplegado: https://tu-backend.up.railway.app
- [ ] Health check funciona: https://tu-backend.up.railway.app/health
- [ ] PostgreSQL conectado

### Frontend (Neatech):
- [ ] Sitio carga: https://grupovexus.com
- [ ] HTTPS funciona (candado verde)
- [ ] Formulario envía emails
- [ ] Login/registro funciona

---

## 💰 COSTOS

- **Neatech/Neothek:** Lo que ya pagas (hosting)
- **Railway:** GRATIS ($5/mes de crédito, suficiente para este proyecto)
- **Total extra:** $0

Si Railway se queda sin crédito gratuito (raro), puedes:
- Migrar a Render.com (también gratis)
- Migrar a Fly.io (también gratis)

---

## 🆘 TROUBLESHOOTING

### Error CORS
Verificar en Railway que `ALLOWED_ORIGINS` incluya tu dominio.

### Backend no responde
1. Ver logs en Railway
2. Verificar que PostgreSQL esté corriendo
3. Reiniciar servicio

### Frontend no carga
1. Verificar que archivos estén en `public_html`
2. Verificar permisos (755 carpetas, 644 archivos)
3. Limpiar caché del navegador

### Formulario no envía
1. Verificar URL del backend en `config.prod.js`
2. Ver logs en Railway
3. Verificar credenciales SMTP

---

## 🔄 ACTUALIZAR DESPUÉS DE CAMBIOS

### Backend:
```bash
# En tu computadora:
git add .
git commit -m "Actualización"
git push origin main

# Railway desplegará automáticamente
```

### Frontend:
1. Subir archivos actualizados a cPanel via File Manager o FTP
2. Limpiar caché del navegador

---

## 📞 CONTACTO RAILWAY SUPPORT

Si tienes problemas con Railway:
- Discord: https://discord.gg/railway
- Docs: https://docs.railway.app/

---

**¡Con esta solución tu sitio estará 100% funcional sin necesidad de cambiar de hosting!** 🚀
