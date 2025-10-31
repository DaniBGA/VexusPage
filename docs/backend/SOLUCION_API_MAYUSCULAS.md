# ✅ SOLUCIÓN: Backend en carpeta API (MAYÚSCULAS)

**Fecha:** 2025-10-31
**Problema:** Carpeta `API` (mayúsculas) + archivo `api` (minúsculas) que no se puede borrar

---

## 📋 SITUACIÓN ACTUAL

En tu servidor tienes:
- **`API`** (carpeta, mayúsculas) → Tu backend correcto está aquí ✅
- **`api`** (archivo, 18 bytes, minúsculas) → Symlink fallido que no se puede borrar ❌

**Solución:** Usar `/API` (mayúsculas) en lugar de `/api` (minúsculas)

---

## ✅ CAMBIOS REALIZADOS

### 1. Frontend actualizado

Los archivos `config.js` y `config.prod.js` ahora usan:

```javascript
API_BASE_URL: 'https://grupovexus.com/API/v1'  // ← API en MAYÚSCULAS
```

**✅ Ya está actualizado en tu proyecto local.**

---

### 2. Archivos .htaccess actualizados

#### a) Frontend (.htaccess en public_html/)

**Archivo:** [htaccess_frontend_MINIMO.txt](../../htaccess_frontend_MINIMO.txt)

```apache
RewriteEngine On
RewriteCond %{REQUEST_FILENAME} !-f
RewriteCond %{REQUEST_FILENAME} !-d
RewriteCond %{REQUEST_URI} !^/API
RewriteCond %{REQUEST_URI} !^/api
RewriteRule . /index.html [L]
```

**Cambio:** Ahora excluye tanto `/API` como `/api` del rewrite.

---

#### b) Backend (.htaccess en public_html/API/)

**Archivo:** [htaccess_API_mayusculas.txt](../../htaccess_API_mayusculas.txt)

```apache
PassengerEnabled on
PassengerAppType wsgi
PassengerStartupFile passenger_wsgi.py
PassengerPython /usr/bin/python3
PassengerBaseURI /API    ← API en MAYÚSCULAS
PassengerLogLevel 3

<FilesMatch "\.(py|pyc|pyo)$">
    Deny from all
</FilesMatch>
<Files "passenger_wsgi.py">
    Allow from all
</Files>
<Files ".env">
    Deny from all
</Files>
```

**Cambio:** `PassengerBaseURI /API` (mayúsculas)

---

## 🚀 PASOS PARA IMPLEMENTAR

### Paso 1: Subir frontend actualizado

1. **Sube** el nuevo `config.js` a: `public_html/Static/js/config.js`
2. **Reemplaza** el archivo existente

---

### Paso 2: Actualizar .htaccess del frontend

1. **En File Manager**, ve a `public_html/`
2. **Renombra** `.htaccess` actual a `.htaccess.old` (backup)
3. **Sube** el archivo `htaccess_frontend_MINIMO.txt`
4. **Renómbralo** a `.htaccess`

---

### Paso 3: Actualizar .htaccess del backend

1. **En File Manager**, ve a `public_html/API/`
2. Si existe `.htaccess`, **renómbralo** a `.htaccess.old`
3. **Sube** el archivo `htaccess_API_mayusculas.txt`
4. **Renómbralo** a `.htaccess`

---

### Paso 4: Verificar estructura del backend

Dentro de `public_html/API/` debes tener:

```
API/
├── app/                    ← Carpeta completa del código
│   ├── __init__.py
│   ├── main.py
│   ├── config.py
│   ├── api/
│   ├── core/
│   ├── models/
│   └── services/
├── passenger_wsgi.py       ← Archivo de entrada
├── .htaccess               ← Nuevo archivo con PassengerBaseURI /API
├── .env                    ← Credenciales
└── requirements.txt        ← Dependencias
```

---

### Paso 5: Probar

#### a) Backend:
```
https://grupovexus.com/API/v1/health
```

Debe retornar:
```json
{
  "status": "healthy",
  "database": "connected",
  "timestamp": "..."
}
```

#### b) Frontend:
```
https://www.grupovexus.com/
```

Debe cargar correctamente y conectarse al backend.

---

## 🗑️ INTENTAR ELIMINAR EL ARCHIVO `api` (minúsculas)

### Opción 1: Via Terminal de cPanel

Si tienes acceso a Terminal en cPanel:

```bash
cd ~/web/grupovexus.com/public_html
rm -f api
# O si es un symlink:
unlink api
```

---

### Opción 2: Via File Manager con permisos

1. **Click derecho** en el archivo `api`
2. **Change Permissions** → 777
3. Intenta **Delete** de nuevo

---

### Opción 3: Via soporte

Si no se puede borrar, envía este mensaje a soporte:

```
Asunto: Eliminar archivo bloqueado

Hola,

Tengo un archivo llamado "api" (minúsculas, 18 bytes) en:
public_html/api

Este archivo fue creado por un intento fallido de symlink y no puedo eliminarlo via File Manager.

¿Pueden eliminarlo por mí?

ruta: ~/web/grupovexus.com/public_html/api

Gracias.
```

---

### Opción 4: Ignorarlo

**Realmente no es necesario eliminarlo** si:
- Tu backend funciona en `/API` (mayúsculas) ✅
- El `.htaccess` excluye ambos `/API` y `/api` ✅
- No interfiere con tu aplicación ✅

---

## 🌐 URLS FINALES

| Componente | URL |
|------------|-----|
| **Frontend** | `https://grupovexus.com` |
| **Frontend (www)** | `https://www.grupovexus.com` |
| **Backend API** | `https://grupovexus.com/API/v1` |
| **Health Check** | `https://grupovexus.com/API/v1/health` |
| **API Docs** | `https://grupovexus.com/API/docs` |

**Nota:** Las URLs son **case-sensitive** en el path: `/API` ≠ `/api`

---

## 📁 ESTRUCTURA FINAL

```
public_html/
├── index.html              ← Frontend
├── pages/
├── Static/
│   └── js/
│       └── config.js       ← API_BASE_URL: 'https://grupovexus.com/API/v1' ✅
├── .htaccess               ← Excluye /API y /api
├── api                     ← Archivo problemático (18 bytes) - ignorar
└── API/                    ← BACKEND AQUÍ ✅
    ├── app/
    ├── passenger_wsgi.py
    ├── .htaccess           ← PassengerBaseURI /API
    ├── .env
    └── requirements.txt
```

---

## ✅ CHECKLIST

- [x] `config.js` actualizado con `/API` (mayúsculas)
- [x] `config.prod.js` actualizado con `/API` (mayúsculas)
- [x] `.htaccess` de frontend excluye `/API` y `/api`
- [x] `.htaccess` de backend usa `PassengerBaseURI /API`
- [ ] Subir `config.js` actualizado al servidor
- [ ] Subir `.htaccess` del frontend al servidor
- [ ] Subir `.htaccess` del backend al servidor
- [ ] Probar: `https://grupovexus.com/API/v1/health`
- [ ] Probar: Frontend carga correctamente
- [ ] (Opcional) Intentar eliminar archivo `api` minúsculas

---

## 📝 ARCHIVOS PARA SUBIR

1. **`config.js`** → Subir a: `public_html/Static/js/config.js`
2. **`htaccess_frontend_MINIMO.txt`** → Renombrar y subir a: `public_html/.htaccess`
3. **`htaccess_API_mayusculas.txt`** → Renombrar y subir a: `public_html/API/.htaccess`

---

**Última actualización:** 2025-10-31
**Estado:** ✅ Solución con /API en mayúsculas implementada
