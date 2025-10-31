# 🔍 DIAGNÓSTICO ERROR 500 en /API

**Error:** `GET https://www.grupovexus.com/API 500 (Internal Server Error)`

---

## 🎯 CAUSA MÁS PROBABLE

El error 500 en `/API` significa que Passenger está intentando ejecutar el backend pero algo falla. Las causas más comunes son:

1. **Dependencias no instaladas** (python-dotenv, fastapi, uvicorn, etc.)
2. **Archivo `.env` falta o tiene errores**
3. **Error en el código Python** (passenger_wsgi.py o app/main.py)
4. **PassengerPython apunta a Python incorrecto**
5. **Permisos incorrectos**

---

## 📋 VERIFICACIONES INMEDIATAS

### 1. Verificar que los archivos existen en el servidor

En File Manager, navega a `public_html/API/` y verifica:

```
API/
├── app/                    ← Carpeta debe existir
│   └── __init__.py         ← Archivo debe existir
│   └── main.py             ← Archivo debe existir
├── passenger_wsgi.py       ← Archivo debe existir
├── .htaccess               ← Archivo debe existir
├── .env                    ← Archivo debe existir ⚠️ CRÍTICO
└── requirements.txt        ← Archivo debe existir
```

**Si `.env` NO existe:**
- Créalo usando el contenido de `.env.example`
- Asegúrate de poner credenciales reales

---

### 2. Verificar permisos

- Carpetas: **755**
- Archivos Python (.py): **644**
- .env: **600** o **644**
- .htaccess: **644**

---

### 3. Revisar logs de error

**ESTO ES LO MÁS IMPORTANTE:**

1. En cPanel, busca **"Error Log"** o **"Registros de errores"**
2. Busca errores recientes (últimos 5-10 minutos)
3. Busca líneas que contengan:
   - `passenger`
   - `python`
   - `API`
   - `ModuleNotFoundError`
   - `ImportError`

**Copia el error completo** y podremos identificar exactamente qué falta.

---

## 🧪 TEST DE DIAGNÓSTICO PASO A PASO

### TEST 1: ¿Passenger está habilitado?

**Crea archivo:** `public_html/API/test.html`

```html
<!DOCTYPE html>
<html>
<head><title>Test</title></head>
<body><h1>La carpeta API es accesible!</h1></body>
</html>
```

**Accede a:** `https://www.grupovexus.com/API/test.html`

- ✅ **Si funciona:** La carpeta API es accesible, el problema es Passenger
- ❌ **Si da 500:** El problema está en el `.htaccess` de `public_html/.htaccess`

---

### TEST 2: ¿Passenger puede ejecutar Python básico?

**Renombra temporalmente:**
```
passenger_wsgi.py  →  passenger_wsgi_original.py  (backup)
```

**Sube el archivo:** `test_passenger.py` como `passenger_wsgi.py`

Este archivo es un WSGI mínimo que solo muestra "Passenger funciona!"

**Accede a:** `https://www.grupovexus.com/API/`

**Resultados:**
- ✅ **Si muestra "Passenger funciona!"** → Passenger está bien, el problema está en tu código (falta dotenv, fastapi, o .env)
- ❌ **Si da 500** → Passenger no está habilitado o `.htaccess` está mal

---

### TEST 3: ¿Las dependencias están instaladas?

**El problema más probable es que faltan las dependencias Python.**

En Neatech (hosting compartido sin SSH), las dependencias deben instalarse de una de estas formas:

#### Opción A: Passenger instala automáticamente (si está configurado)

Algunos hostings con Passenger instalan automáticamente desde `requirements.txt`.

**Verifica agregando esto al `.htaccess`:**

```apache
PassengerEnabled on
PassengerAppType wsgi
PassengerStartupFile passenger_wsgi.py
PassengerPython /usr/bin/python3
PassengerBaseURI /API

# Auto-instalar dependencias (si está disponible)
PassengerAppEnv production
PassengerFriendlyErrorPages on  # Ver errores detallados
```

---

#### Opción B: Terminal de cPanel

Si tienes acceso a Terminal en cPanel:

```bash
cd ~/web/grupovexus.com/public_html/API
python3 -m pip install --user -r requirements.txt
```

---

#### Opción C: Solicitar a soporte

```
Asunto: Instalar dependencias Python para mi app

Hola,

Necesito instalar las dependencias Python para mi aplicación en:
~/web/grupovexus.com/public_html/API/

El archivo requirements.txt está en esa ubicación.

¿Pueden ejecutar:
cd ~/web/grupovexus.com/public_html/API
python3 -m pip install --user -r requirements.txt

O indicarme cómo instalar dependencias Python en mi cuenta?

Gracias.
```

---

## 🔧 SOLUCIONES SEGÚN EL ERROR EN LOS LOGS

### Error: `ModuleNotFoundError: No module named 'dotenv'`

**Causa:** python-dotenv no está instalado

**Solución temporal (NO RECOMENDADO para producción):**

Modifica `passenger_wsgi.py` para NO usar dotenv:

```python
import sys
import os

current_dir = os.path.dirname(__file__)
sys.path.insert(0, current_dir)

# Cargar .env manualmente SIN dotenv
env_path = os.path.join(current_dir, '.env')
if os.path.exists(env_path):
    with open(env_path) as f:
        for line in f:
            line = line.strip()
            if line and not line.startswith('#') and '=' in line:
                key, value = line.split('=', 1)
                os.environ[key.strip()] = value.strip()

from app.main import app as application
```

**Solución real:** Instalar dependencias (ver Opción B o C arriba)

---

### Error: `ModuleNotFoundError: No module named 'fastapi'`

**Causa:** FastAPI no está instalado

**Solución:** Instalar dependencias (ver TEST 3)

---

### Error: `No such file or directory: '.env'`

**Causa:** Archivo `.env` no existe

**Solución:**

1. Crea archivo `.env` en `public_html/API/.env`
2. Contenido mínimo:

```bash
DATABASE_URL=postgresql://usuario:password@localhost:5432/base_datos
SECRET_KEY=una-clave-secreta-muy-larga-y-aleatoria
ALLOWED_ORIGINS=https://grupovexus.com,https://www.grupovexus.com
```

---

### Error: `Permission denied`

**Causa:** Permisos incorrectos

**Solución:**
- passenger_wsgi.py: **644**
- Carpeta API: **755**
- Carpeta app: **755**

---

## 📝 .htaccess MÍNIMO (sin errores)

Si el `.htaccess` está causando problemas, usa esta versión ultra-simple:

**`public_html/API/.htaccess`:**

```apache
PassengerEnabled on
PassengerAppType wsgi
PassengerStartupFile passenger_wsgi.py
PassengerPython /usr/bin/python3
PassengerFriendlyErrorPages on
```

**Solo 5 líneas.** Si esto da error, Passenger no está habilitado.

---

## 🆘 SI TODO FALLA

### Crear un archivo de diagnóstico automático

**Crea:** `public_html/API/info.py` y súbelo como `passenger_wsgi.py`

```python
import sys

def application(environ, start_response):
    status = '200 OK'

    info = f"""
    <html>
    <head><title>Diagnostic Info</title></head>
    <body>
        <h1>Python Info</h1>
        <p><strong>Python Version:</strong> {sys.version}</p>
        <p><strong>Python Path:</strong> {sys.executable}</p>
        <h2>sys.path:</h2>
        <ul>
    """

    for path in sys.path:
        info += f"<li>{path}</li>"

    info += """
        </ul>
        <h2>Installed Modules:</h2>
        <ul>
    """

    # Intentar importar módulos comunes
    modules_to_test = ['dotenv', 'fastapi', 'uvicorn', 'pydantic', 'asyncpg', 'sqlalchemy']
    for module_name in modules_to_test:
        try:
            __import__(module_name)
            info += f"<li style='color:green'>{module_name} ✓</li>"
        except ImportError:
            info += f"<li style='color:red'>{module_name} ✗ NOT INSTALLED</li>"

    info += """
        </ul>
    </body>
    </html>
    """

    output = info.encode('utf-8')
    response_headers = [
        ('Content-Type', 'text/html; charset=utf-8'),
        ('Content-Length', str(len(output)))
    ]
    start_response(status, response_headers)
    return [output]
```

**Accede a:** `https://www.grupovexus.com/API/`

Esto te mostrará:
- Qué versión de Python está usando
- Qué módulos están instalados ✓
- Qué módulos faltan ✗

---

## 🎯 PLAN DE ACCIÓN

1. **Revisa los logs de error** en cPanel (lo más importante)
2. **Verifica que `.env` existe** en `public_html/API/.env`
3. **Ejecuta TEST 1:** Ver si la carpeta es accesible
4. **Ejecuta TEST 2:** Ver si Passenger funciona con Python básico
5. **Ejecuta el diagnóstico automático:** Ver qué módulos faltan
6. **Instala dependencias:** Via Terminal o contacta soporte

---

**Última actualización:** 2025-10-31
**Estado:** ⚠️ Diagnóstico de error 500 en /API
