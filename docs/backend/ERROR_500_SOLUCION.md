# 🔧 SOLUCIÓN ERROR 500 - Neatech

**Problema:** Error 500 (Internal Server Error) en frontend y/o backend

---

## 🔍 CAUSAS COMUNES DEL ERROR 500

### 1. Error de sintaxis en `.htaccess`
El archivo `.htaccess` tiene directivas no soportadas o sintaxis incorrecta.

### 2. Módulos de Apache no habilitados
Directivas como `Header` requieren `mod_headers` habilitado.

### 3. PassengerAppRoot con ruta incorrecta
La ruta en el `.htaccess` del backend no coincide con la ruta real del servidor.

### 4. Permisos de archivos incorrectos
Archivos con permisos muy restrictivos o muy permisivos.

### 5. Error en el código Python
El `passenger_wsgi.py` o la app FastAPI tienen errores.

---

## ✅ SOLUCIÓN PASO A PASO

### PASO 1: Simplificar .htaccess del FRONTEND

El error 500 en el frontend sugiere problema con el `.htaccess` principal.

**Crea este archivo simplificado en `public_html/.htaccess`:**

```apache
# ====================================
# FRONTEND - .htaccess SIMPLIFICADO
# ====================================

# Habilitar reescritura
RewriteEngine On

# Frontend SPA fallback
# Si no es archivo ni directorio, y NO es /api/, servir index.html
RewriteCond %{REQUEST_FILENAME} !-f
RewriteCond %{REQUEST_FILENAME} !-d
RewriteCond %{REQUEST_URI} !^/api
RewriteRule . /index.html [L]

# No listar directorios
Options -Indexes
```

**Guarda esto como:** `htaccess_frontend_simple.txt` y súbelo a `public_html/` renombrándolo a `.htaccess`

---

### PASO 2: Simplificar .htaccess del BACKEND

**Crea este archivo en `public_html/api/.htaccess`:**

```apache
# ====================================
# BACKEND - .htaccess SIMPLIFICADO
# ====================================

# Habilitar Passenger
PassengerEnabled on
PassengerAppType wsgi
PassengerStartupFile passenger_wsgi.py
PassengerPython /usr/bin/python3

# CRÍTICO: Ajusta esta ruta según tu servidor
# Opción 1: Ruta relativa (probar primero)
PassengerBaseURI /api

# Si no funciona, comenta la línea anterior y usa ruta absoluta
# Opción 2: Ruta absoluta (reemplaza con la ruta real)
# PassengerAppRoot /home/grupovex/web/grupovexus.com/public_html/api

# Performance básica
PassengerMinInstances 1
PassengerMaxPoolSize 2

# Logging
PassengerLogLevel 3

# Seguridad básica
<FilesMatch "\.(py|pyc|pyo)$">
    Deny from all
</FilesMatch>

<Files "passenger_wsgi.py">
    Allow from all
</Files>

# Proteger .env
<Files ".env">
    Deny from all
</Files>

# No listar directorios
Options -Indexes
```

**Guarda esto como:** `htaccess_backend_simple.txt` y súbelo a `public_html/api/` renombrándolo a `.htaccess`

---

### PASO 3: Verificar estructura de archivos

**En `public_html/`:**
```
public_html/
├── index.html              ← DEBE existir
├── .htaccess               ← Archivo simplificado
├── pages/
├── Static/
│   ├── css/
│   ├── js/
│   │   └── config.js       ← URL correcta: https://grupovexus.com/api/v1
│   └── images/
└── api/                    ← Carpeta del backend
    ├── app/
    ├── passenger_wsgi.py
    ├── .htaccess           ← Archivo simplificado
    ├── .env
    └── requirements.txt
```

---

### PASO 4: Verificar permisos

**Permisos correctos:**
- Carpetas: `755` (rwxr-xr-x)
- Archivos `.html`, `.css`, `.js`: `644` (rw-r--r--)
- Archivos `.py`: `644`
- `.env`: `600` o `644` (protegido por .htaccess)
- `.htaccess`: `644`

**Cambiar permisos en File Manager:**
1. Click derecho en archivo/carpeta
2. "Change Permissions" o "Permisos"
3. Establece el número correcto

---

### PASO 5: Revisar logs de error

**Ubicación de logs en cPanel:**
1. Ve a cPanel
2. Busca "Errors" o "Error Log" o "Registros de errores"
3. Busca errores recientes

**Errores comunes y soluciones:**

| Error en log | Causa | Solución |
|--------------|-------|----------|
| `Invalid command 'Header'` | mod_headers no habilitado | Elimina líneas `Header` del .htaccess |
| `Invalid command 'PassengerEnabled'` | Passenger no instalado | Contacta soporte |
| `PassengerAppRoot ... does not exist` | Ruta incorrecta | Usa `PassengerBaseURI /api` en lugar de `PassengerAppRoot` |
| `No such file or directory: .htaccess` | Archivo mal nombrado | Asegúrate de que se llama `.htaccess` (con punto al inicio) |
| `Python application ... failed to start` | Error en código Python | Revisa passenger_wsgi.py y .env |

---

### PASO 6: Probar sin .htaccess

**Para identificar si el problema es el .htaccess:**

1. **Renombra temporalmente** `public_html/.htaccess` a `public_html/.htaccess.bak`
2. **Intenta acceder** a `https://www.grupovexus.com/`
3. **Resultado:**
   - ✅ Si funciona: El problema está en el `.htaccess` - usa la versión simplificada
   - ❌ Si sigue fallando: El problema es otro (permisos, configuración del servidor, etc.)

---

### PASO 7: Verificar PassengerAppRoot

El problema más común del backend es la ruta de `PassengerAppRoot`.

**Encontrar la ruta real:**

Si tienes acceso a Terminal de cPanel:
```bash
cd ~/web/grupovexus.com/public_html/api
pwd
```

Esa es la ruta que debes usar en `PassengerAppRoot`.

**Alternativa:** Usa `PassengerBaseURI /api` que es más simple y no requiere ruta absoluta.

---

## 📝 ARCHIVOS .HTACCESS COMPLETOS PARA COPIAR

### public_html/.htaccess (VERSION MINIMA - Sin errores)

```apache
RewriteEngine On
RewriteCond %{REQUEST_FILENAME} !-f
RewriteCond %{REQUEST_FILENAME} !-d
RewriteCond %{REQUEST_URI} !^/api
RewriteRule . /index.html [L]
```

**Esto es lo MÍNIMO necesario** para que el frontend funcione.

---

### public_html/api/.htaccess (VERSION MINIMA)

```apache
PassengerEnabled on
PassengerAppType wsgi
PassengerStartupFile passenger_wsgi.py
PassengerPython /usr/bin/python3
PassengerBaseURI /api
PassengerLogLevel 3

<FilesMatch "\.(py|env)$">
    Deny from all
</FilesMatch>
<Files "passenger_wsgi.py">
    Allow from all
</Files>
```

**Esto es lo MÍNIMO necesario** para que Passenger ejecute el backend.

---

## 🧪 PRUEBA DE DIAGNÓSTICO

### Test 1: ¿El frontend HTML se puede servir?

**Crea un archivo de prueba:** `public_html/test.html`

```html
<!DOCTYPE html>
<html>
<head><title>Test</title></head>
<body><h1>HTML works!</h1></body>
</html>
```

**Accede a:** `https://www.grupovexus.com/test.html`

- ✅ Si funciona: El servidor funciona, problema es con .htaccess o index.html
- ❌ Si falla: Problema con permisos o configuración general

---

### Test 2: ¿El backend responde?

**Crea un archivo de prueba:** `public_html/api/test.html`

```html
<!DOCTYPE html>
<html>
<head><title>API Test</title></head>
<body><h1>API folder works!</h1></body>
</html>
```

**Accede a:** `https://www.grupovexus.com/api/test.html`

- ✅ Si funciona: La carpeta /api/ es accesible
- ❌ Si falla: Problema con permisos de la carpeta /api

---

### Test 3: ¿Passenger está funcionando?

**Accede a:** `https://www.grupovexus.com/api/v1/health`

- ✅ Si retorna JSON: Backend funciona perfectamente
- ❌ Error 500: Problema con Passenger, passenger_wsgi.py o .env
- ❌ Error 404: Passenger no está sirviendo la app, revisa .htaccess

---

## 🆘 SI NADA FUNCIONA

### Opción 1: .htaccess en blanco

Temporalmente, deja los `.htaccess` casi vacíos para identificar el problema:

**`public_html/.htaccess`:**
```apache
# Vacío - solo para probar
```

**`public_html/api/.htaccess`:**
```apache
PassengerEnabled on
PassengerAppType wsgi
PassengerStartupFile passenger_wsgi.py
PassengerPython /usr/bin/python3
```

---

### Opción 2: Contactar soporte

Si todo falla, envía este mensaje a soporte:

```
Asunto: Error 500 en mi sitio - Necesito ayuda

Hola equipo de Neatech,

Estoy configurando una aplicación Python con Passenger en:
- Dominio: grupovexus.com
- Usuario: grupovex

Frontend: public_html/
Backend: public_html/api/

Tengo error 500 al acceder al sitio. He verificado:
- Permisos de archivos (755 carpetas, 644 archivos)
- .htaccess simplificado
- passenger_wsgi.py existe

¿Pueden revisar los logs de error del servidor y ayudarme a identificar el problema?

Archivos relevantes:
- public_html/.htaccess
- public_html/api/.htaccess
- public_html/api/passenger_wsgi.py

¿Está Passenger habilitado para mi cuenta?
¿Hay algún error en los logs del servidor que pueda revisar?

Gracias.
```

---

## 📊 CHECKLIST DE VERIFICACIÓN

- [ ] `public_html/.htaccess` usa versión simplificada
- [ ] `public_html/api/.htaccess` usa versión simplificada
- [ ] `public_html/index.html` existe y tiene contenido
- [ ] `public_html/api/passenger_wsgi.py` existe
- [ ] `public_html/api/.env` existe y tiene credenciales
- [ ] Permisos: carpetas 755, archivos 644
- [ ] Logs de error revisados
- [ ] Test HTML funciona: `test.html`
- [ ] Backend responde: `/api/v1/health`

---

**Última actualización:** 2025-10-31
**Estado:** ⚠️ Troubleshooting error 500
