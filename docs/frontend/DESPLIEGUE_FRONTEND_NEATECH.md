# 🌐 GUÍA DE DESPLIEGUE DEL FRONTEND EN NEATECH

## 📋 RESUMEN RÁPIDO

El frontend de Vexus es una Single Page Application (SPA) que debe subirse a la carpeta `public_html` de Neatech.

---

## 📁 ESTRUCTURA DE ARCHIVOS A SUBIR

```
/home/grupovex/web/grupovexus.com/public_html/
├── index.html                    # ← Página principal
├── pages/                        # ← Páginas secundarias
│   ├── proyectos.html
│   ├── course-view.html
│   ├── course-editor.html
│   ├── course-editor-improved.html
│   ├── verify-email.html
│   ├── courses.html
│   └── dashboard.html
├── Static/                       # ← Assets (CSS, JS, imágenes)
│   ├── css/
│   ├── js/
│   └── images/
└── .htaccess                     # ← Configuración Apache
```

---

## 🔧 PASO 1: PREPARAR ARCHIVOS LOCALMENTE

### 1.1 Cambiar configuración a producción

**Opción A - Editar config.js directamente:**

Edita: `frontend/Static/js/config.js`

```javascript
const CONFIG = {
    API_BASE_URL: 'https://grupovexus.com/api/v1',  // ← Cambiar aquí
    TOKEN_KEY: 'vexusToken',
    USER_KEY: 'vexusUser',
    REQUEST_TIMEOUT: 30000
};
```

**Opción B - Usar config.prod.js (RECOMENDADO):**

Ya está actualizado en `frontend/Static/js/config.prod.js`

Luego en `index.html` y todas las páginas, cambiar la importación:

**Buscar:**
```html
<script type="module" src="/Static/js/main.js"></script>
```

**Verificar que main.js importe de config.prod.js:**
```javascript
// En main.js (línea 2)
import CONFIG from './config.prod.js';  // ← Usar config.prod en producción
```

---

### 1.2 Verificar .htaccess

Debe existir: `frontend/.htaccess` con este contenido:

```apache
RewriteEngine On
RewriteBase /

# ====== PROXY A LA API ======
# Redirigir /api/* al backend
RewriteCond %{REQUEST_URI} ^/api/(.*)$
RewriteRule ^api/(.*)$ /api/$1 [L,P]

# ====== FRONTEND (SPA) ======
# Si el archivo no existe, servir index.html (para rutas de SPA)
RewriteCond %{REQUEST_FILENAME} !-f
RewriteCond %{REQUEST_FILENAME} !-d
RewriteRule ^ /index.html [L]

# ====== HEADERS CORS ======
Header always set Access-Control-Allow-Origin "*"
Header always set Access-Control-Allow-Methods "GET, POST, PUT, DELETE, OPTIONS, PATCH"
Header always set Access-Control-Allow-Headers "Content-Type, Authorization"

# ====== COMPRESIÓN GZIP ======
<IfModule mod_deflate.c>
    AddOutputFilterByType DEFLATE text/html text/plain text/xml text/css text/javascript application/javascript application/json
</IfModule>

# ====== CACHE ======
<IfModule mod_expires.c>
    ExpiresActive On
    # Imágenes
    ExpiresByType image/jpg "access plus 1 year"
    ExpiresByType image/jpeg "access plus 1 year"
    ExpiresByType image/png "access plus 1 year"
    ExpiresByType image/gif "access plus 1 year"
    ExpiresByType image/webp "access plus 1 year"
    ExpiresByType image/svg+xml "access plus 1 year"
    # CSS y JavaScript
    ExpiresByType text/css "access plus 1 month"
    ExpiresByType application/javascript "access plus 1 month"
    # Fonts
    ExpiresByType font/woff2 "access plus 1 year"
</IfModule>

# ====== SEGURIDAD ======
# No mostrar listado de directorios
Options -Indexes

# Proteger archivos sensibles
<FilesMatch "\.(env|md|json|lock)$">
    Order allow,deny
    Deny from all
</FilesMatch>
```

---

## 📤 PASO 2: SUBIR ARCHIVOS A NEATECH

### 2.1 Usando File Manager de cPanel

1. Accede a **cPanel → File Manager**
2. Navega a: `/home/grupovex/web/grupovexus.com/public_html/`
3. **ELIMINA** todo el contenido actual (si existe)
4. Sube los siguientes archivos/carpetas:

```
✅ SUBIR TODO:
- index.html
- pages/ (carpeta completa)
- Static/ (carpeta completa)
    ├── css/
    ├── js/
    └── images/
- .htaccess (crear/editar)
```

```
❌ NO SUBIR:
- node_modules/ (si existe)
- .git/
- .env
- *.md (documentación)
- .DS_Store
```

### 2.2 Estructura final en el servidor

```
/home/grupovex/web/grupovexus.com/
├── public_html/              # ← FRONTEND (TODO LO QUE SUBISTE)
│   ├── index.html
│   ├── pages/
│   ├── Static/
│   └── .htaccess
│
└── api/                      # ← BACKEND (subido por separado)
    ├── app/
    ├── passenger_wsgi.py
    └── .htaccess
```

---

## 🔍 PASO 3: VERIFICAR DESPLIEGUE

### 3.1 Probar el frontend

Abre en tu navegador:
- **Homepage:** `https://grupovexus.com`
- **Proyectos:** `https://grupovexus.com/pages/proyectos.html`

### 3.2 Verificar conexión con API

1. Abre la consola del navegador (F12)
2. Deberías ver en la consola:
   ```
   ✅ Backend connected
   ```
3. Si ves error de conexión, verifica:
   - Que el backend esté desplegado en `/api/`
   - Que la URL en `config.js` sea correcta
   - Que CORS esté configurado en el backend

### 3.3 Probar funcionalidades

**Test básico:**
1. ✅ La página carga correctamente
2. ✅ Estilos (CSS) se aplican
3. ✅ Animaciones funcionan
4. ✅ Modal de login se abre
5. ✅ Modal de registro se abre

**Test con backend:**
1. ✅ Crear una cuenta (registro)
2. ✅ Verificar email
3. ✅ Iniciar sesión
4. ✅ Ver cursos
5. ✅ Enviar mensaje de contacto

---

## 🐛 SOLUCIÓN DE PROBLEMAS

### Error: "404 Not Found" en rutas

**Problema:** Las rutas como `/pages/proyectos.html` dan 404

**Solución:**
1. Verifica que `.htaccess` existe en `public_html/`
2. Verifica que `mod_rewrite` esté habilitado (normalmente sí en cPanel)
3. Revisa permisos de archivos (644 para archivos, 755 para carpetas)

---

### Error: "API connection failed"

**Problema:** Frontend no se conecta con el backend

**Posibles causas:**
1. Backend no está desplegado
2. URL incorrecta en `config.js`
3. CORS mal configurado en backend

**Solución:**
1. Verifica que `https://grupovexus.com/api/v1/health` responda
2. Verifica `config.js`:
   ```javascript
   API_BASE_URL: 'https://grupovexus.com/api/v1'
   ```
3. Verifica `.env` del backend:
   ```
   ALLOWED_ORIGINS=https://grupovexus.com,https://www.grupovexus.com
   ```

---

### Error: Estilos CSS no se aplican

**Problema:** La página se ve sin estilos

**Solución:**
1. Verifica que la carpeta `Static/` se subió completa
2. Verifica rutas en `index.html`:
   ```html
   <link rel="stylesheet" href="/Static/css/main.css">
   ```
3. Abre la consola (F12) y busca errores 404

---

### Error: JavaScript no funciona

**Problema:** Los modales, animaciones, etc no funcionan

**Solución:**
1. Verifica que `Static/js/` se subió completa
2. Abre consola (F12) y busca errores
3. Verifica que los scripts se importan como módulos:
   ```html
   <script type="module" src="/Static/js/main.js"></script>
   ```

---

## 🔄 ACTUALIZAR EL FRONTEND

### Método rápido (via File Manager):

1. Edita el archivo específico en cPanel File Manager
2. Click en "Edit"
3. Guarda cambios
4. Limpia caché del navegador (Ctrl + Shift + R)

### Método completo (resubir):

1. Haz cambios localmente
2. Sube solo los archivos modificados via File Manager
3. Limpia caché del navegador

---

## ⚙️ CONFIGURACIÓN AVANZADA

### Habilitar compresión GZIP

Ya está en `.htaccess`, pero verifica que está habilitado:
```apache
<IfModule mod_deflate.c>
    AddOutputFilterByType DEFLATE text/html text/plain text/xml text/css text/javascript application/javascript application/json
</IfModule>
```

### Cache de archivos estáticos

Ya configurado en `.htaccess`:
- Imágenes: 1 año
- CSS/JS: 1 mes

### HTTPS forzado

Agrega al inicio de `.htaccess`:
```apache
# Forzar HTTPS
RewriteCond %{HTTPS} off
RewriteRule ^(.*)$ https://%{HTTP_HOST}%{REQUEST_URI} [L,R=301]
```

---

## 📊 OPTIMIZACIÓN

### 1. Minificar archivos (opcional)

Para producción, considera minificar:
- CSS: Usar herramientas como `cssnano`
- JS: Usar `terser` o `uglify-js`

### 2. Comprimir imágenes

Reduce tamaño de imágenes en `Static/images/`:
- Usa WebP en lugar de PNG/JPG
- Comprime con herramientas como TinyPNG

### 3. CDN (opcional)

Para mejor rendimiento, considera:
- Cloudflare (gratis)
- Servir assets estáticos desde CDN

---

## 🎯 CHECKLIST DE DESPLIEGUE

Antes de considerar el despliegue completo:

- [ ] `config.js` o `config.prod.js` apunta a `grupovexus.com`
- [ ] `.htaccess` existe en `public_html/`
- [ ] Todos los archivos subidos a `public_html/`
- [ ] Backend funcionando en `/api/`
- [ ] Homepage carga correctamente
- [ ] Modales funcionan (login, registro)
- [ ] Conexión con API funciona
- [ ] Registro de usuario funciona
- [ ] Login funciona
- [ ] Cursos se cargan
- [ ] Formulario de contacto funciona
- [ ] Responsive funciona en móvil
- [ ] Sin errores en consola del navegador

---

## 📞 SOPORTE

Si encuentras problemas:

1. **Revisa logs:**
   - cPanel → Errors → error_log
   - Consola del navegador (F12)

2. **Verifica configuración:**
   - `.htaccess` existe
   - `config.js` tiene URL correcta
   - Backend está funcionando

3. **Limpia caché:**
   - Navegador: Ctrl + Shift + R
   - Cloudflare (si usas): Purge cache

---

## 🎉 ¡LISTO!

Tu frontend debería estar funcionando en:
**https://grupovexus.com**

Prueba todas las funcionalidades y disfruta de tu sitio en producción.

---

**Última actualización:** 2025-10-31
**Versión:** 1.0.0
