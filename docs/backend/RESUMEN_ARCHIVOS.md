# 📦 RESUMEN: ARCHIVOS PARA PRODUCCIÓN EN NEATECH

## ✅ ARCHIVOS QUE DEBES SUBIR A NEATECH

### 📂 Carpeta `/api/` (backend)

```
/web/grupovexus.com/api/
├── app/                           ← TODO el código Python
│   ├── __init__.py
│   ├── main.py
│   ├── config.py
│   ├── api/
│   │   ├── __init__.py
│   │   ├── deps.py
│   │   └── v1/
│   │       ├── __init__.py
│   │       ├── router.py
│   │       └── endpoints/
│   │           ├── auth.py
│   │           ├── courses.py
│   │           ├── contact.py
│   │           ├── users.py
│   │           └── ...
│   ├── core/
│   │   ├── __init__.py
│   │   ├── database.py
│   │   └── security.py
│   ├── models/
│   │   ├── __init__.py
│   │   └── schemas.py
│   └── services/
│       ├── __init__.py
│       └── email.py
├── passenger_wsgi.py              ← RENOMBRAR: passenger_wsgi_neatech.py → passenger_wsgi.py
├── .htaccess                      ← RENOMBRAR: .htaccess_neatech → .htaccess
├── requirements.txt               ← Dependencias Python
└── .env                           ← CREAR MANUALMENTE (no subir desde local)
```

### 📂 Carpeta `/public_html/` (frontend)

```
/web/grupovexus.com/public_html/
├── index.html
├── assets/
├── css/
├── js/
└── .htaccess                      ← CREAR: .htaccess_public_html → .htaccess
```

---

## ❌ ARCHIVOS QUE NO DEBES SUBIR

```
❌ .env                    # Tiene credenciales, créalo manualmente en servidor
❌ .env.neatech            # Tiene credenciales expuestas
❌ venv/                   # Entorno virtual local
❌ __pycache__/            # Cache de Python
❌ *.pyc                   # Archivos compilados
❌ test_*.py               # Scripts de testing
❌ Dockerfile              # No se usa en Neatech
❌ gunicorn.conf.py        # No se usa en Neatech (usa Passenger)
❌ database_schema_simple.sql  # Ya ejecutado en la BD
❌ deploy_neatech.sql      # Ya ejecutado en la BD
```

---

## 📝 ARCHIVOS CREADOS PARA TI

He creado estos archivos nuevos en tu carpeta local:

| Archivo Local | Qué es | Renombrar a |
|---------------|--------|-------------|
| `passenger_wsgi_neatech.py` | Entrada de la app para Passenger | `passenger_wsgi.py` |
| `.htaccess_neatech` | Config Passenger para `/api/` | `.htaccess` |
| `.htaccess_public_html` | Config proxy para frontend | `.htaccess` |
| `.env.example.safe` | Template seguro sin credenciales | `.env` (en servidor) |
| `DESPLIEGUE_NEATECH.md` | Guía completa paso a paso | - |
| `setup.py` | Instalador automático (opcional) | - |

---

## 🔧 CAMBIOS REALIZADOS

### ✅ Bugs corregidos:

1. **deploy_neatech.sql línea 118**
   ```sql
   # Antes:
   name varchar(255) NOT NOT,  ❌

   # Después:
   name varchar(255) NOT NULL, ✅
   ```

### ✅ Archivos optimizados:

1. **passenger_wsgi.py** - Versión sin dependencia de venv (funciona en Neatech)
2. **.htaccess** - Configuración correcta para Passenger + CORS
3. **.env.example.safe** - Sin credenciales expuestas

---

## 🚀 PROCESO DE DESPLIEGUE (RESUMEN)

### 1️⃣ Preparar localmente
```bash
# Renombrar archivos
passenger_wsgi_neatech.py → passenger_wsgi.py
.htaccess_neatech → .htaccess (para /api/)
.htaccess_public_html → .htaccess (para /public_html/)
```

### 2️⃣ Subir vía File Manager de cPanel
- Carpeta `app/` completa → `/web/grupovexus.com/api/app/`
- `passenger_wsgi.py` → `/web/grupovexus.com/api/`
- `.htaccess` → `/web/grupovexus.com/api/`
- `requirements.txt` → `/web/grupovexus.com/api/`

### 3️⃣ Crear `.env` en el servidor
- File Manager → Nueva archivo: `/web/grupovexus.com/api/.env`
- Copiar contenido de `.env.example.safe` y completar credenciales

### 4️⃣ Configurar frontend
- Crear `.htaccess` en `/web/grupovexus.com/public_html/.htaccess`

### 5️⃣ Crear base de datos
- phpPgAdmin → Ejecutar `deploy_neatech.sql`

### 6️⃣ Verificar
- Abrir: `https://grupovexus.com/api/v1/health`

---

## 📋 CHECKLIST PRE-DESPLIEGUE

Antes de subir archivos, verifica:

- [ ] Base de datos creada en phpPgAdmin
- [ ] Credenciales de DB anotadas
- [ ] Archivos renombrados correctamente
- [ ] `.env` NO incluido en los archivos a subir
- [ ] Frontend en `/public_html/`
- [ ] Backend preparado para subir a `/api/`

---

## 🆘 SI ALGO FALLA

1. **Ver logs:** cPanel → Errors → `error_log` o `passenger_app.log`
2. **Reiniciar app:** Crear archivo `/api/tmp/restart.txt`
3. **Verificar .env:** Revisar que las credenciales sean correctas
4. **Revisar guía completa:** Ver `DESPLIEGUE_NEATECH.md`

---

## 📞 CONTACTO

Si tienes dudas sobre el despliegue:
1. Lee la guía completa: `DESPLIEGUE_NEATECH.md`
2. Revisa los logs del servidor
3. Contacta soporte de Neatech

---

**Última actualización:** 2025-10-31
**Versión:** 1.0.0
