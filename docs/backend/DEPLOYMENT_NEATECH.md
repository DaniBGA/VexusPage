# Guía de Deployment: Neatech + Render

Esta guía explica cómo configurar el dominio `grupovexus.com` en Neatech para el frontend, mientras el backend permanece alojado en Render.com.

## Arquitectura

```
┌─────────────────────────────────────────────────┐
│                                                 │
│  Usuario accede a: https://grupovexus.com      │
│                                                 │
└────────────────┬────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────┐
│                                                 │
│  NEATECH (Frontend estático)                    │
│  - HTML, CSS, JavaScript                        │
│  - Archivos estáticos                           │
│                                                 │
└────────────────┬────────────────────────────────┘
                 │
                 │ API calls a:
                 │ https://vexuspage.onrender.com/api/v1
                 │
                 ▼
┌─────────────────────────────────────────────────┐
│                                                 │
│  RENDER.COM (Backend)                           │
│  - FastAPI                                      │
│  - PostgreSQL (Supabase)                        │
│  - Lógica de negocio                            │
│                                                 │
└─────────────────────────────────────────────────┘
```

## 1. Configuración Actual

### Backend (Render.com)
- **URL:** `https://vexuspage.onrender.com`
- **API:** `https://vexuspage.onrender.com/api/v1`
- **Health Check:** `https://vexuspage.onrender.com/health`
- **Base de datos:** Supabase PostgreSQL

### Frontend (a subir a Neatech)
- **Dominio objetivo:** `https://grupovexus.com`
- **API configurada:** Ya apunta a Render
- **CORS:** Ya configurado para permitir el dominio

## 2. Pasos para Configurar Neatech

### Paso 1: Preparar archivos del frontend

Los archivos que debes subir a Neatech están en la carpeta `/frontend`:

```
frontend/
├── index.html                 # Página principal
├── pages/                     # Páginas adicionales
│   ├── proyectos.html
│   ├── admin-panel.html
│   └── course-viewer.html
└── Static/                    # Archivos estáticos
    ├── css/
    ├── js/
    └── images/
```

### Paso 2: Verificar configuración del API

El archivo `frontend/Static/js/config.js` ya está configurado correctamente:

```javascript
const CONFIG = {
    API_BASE_URL: 'https://vexuspage.onrender.com/api/v1',
    TOKEN_KEY: 'vexusToken',
    USER_KEY: 'vexusUser',
    REQUEST_TIMEOUT: 30000
};
```

### Paso 3: Configurar el dominio en Neatech

1. **Accede al panel de Neatech**
   - Inicia sesión en tu cuenta de Neatech

2. **Sube los archivos del frontend**
   - Sube toda la carpeta `frontend` a tu hosting
   - Asegúrate de que `index.html` esté en la raíz del dominio
   - Mantén la estructura de carpetas intacta

3. **Configurar el dominio `grupovexus.com`**
   - Ve a la configuración de dominios
   - Agrega o verifica que `grupovexus.com` esté apuntando a tu hosting
   - También configura `www.grupovexus.com` (opcional)

4. **Configurar DNS (si es necesario)**

   Si Neatech requiere que configures DNS externos:

   ```
   Tipo: A
   Nombre: @
   Valor: [IP proporcionada por Neatech]
   TTL: 3600

   Tipo: CNAME
   Nombre: www
   Valor: [dominio proporcionado por Neatech]
   TTL: 3600
   ```

5. **Habilitar HTTPS/SSL**
   - Asegúrate de que Neatech tenga SSL habilitado
   - Esto es crítico porque el backend en Render usa HTTPS

### Paso 4: Verificar CORS en Render

El CORS ya está configurado en `render.yaml` para permitir tu dominio:

```yaml
- key: ALLOWED_ORIGINS
  value: https://grupovexus.com,https://www.grupovexus.com,http://localhost:3000
```

Si necesitas actualizar esto más adelante:

1. Ve a [Render Dashboard](https://dashboard.render.com/)
2. Selecciona el servicio `vexus-backend`
3. Ve a **Environment** → **ALLOWED_ORIGINS**
4. Agrega o modifica los dominios permitidos (separados por comas)
5. Guarda y espera el redespliegue automático

## 3. Verificación Post-Deployment

Después de subir los archivos a Neatech, verifica:

### ✅ Checklist de verificación

1. **Frontend accesible**
   - [ ] `https://grupovexus.com` carga correctamente
   - [ ] `https://www.grupovexus.com` redirige a la versión principal
   - [ ] El certificado SSL está activo (candado verde)

2. **Conexión con el backend**
   - [ ] Abre la consola del navegador (F12)
   - [ ] Ve a la pestaña "Network"
   - [ ] Recarga la página
   - [ ] Verifica que las llamadas a `vexuspage.onrender.com` respondan con código 200
   - [ ] No debe haber errores de CORS

3. **Funcionalidades críticas**
   - [ ] El botón "Iniciar Sesión" abre el modal
   - [ ] El formulario de contacto funciona
   - [ ] Los cursos cargan correctamente (si tienes datos)
   - [ ] El indicador de conexión muestra "Conectado al servidor"

### 🔍 Troubleshooting

#### Error: "CORS policy blocked"

```
Access to XMLHttpRequest at 'https://vexuspage.onrender.com/api/v1/...'
from origin 'https://grupovexus.com' has been blocked by CORS policy
```

**Solución:**
1. Ve a Render Dashboard
2. Verifica que `ALLOWED_ORIGINS` incluya `https://grupovexus.com`
3. Si no está, agrégalo y guarda
4. Espera 2-3 minutos para el redespliegue

#### Error: "Mixed Content"

```
Mixed Content: The page at 'https://grupovexus.com' was loaded over HTTPS,
but requested an insecure resource 'http://...'
```

**Solución:**
- Verifica que TODAS las URLs en tu código usen `https://`
- Revisa `config.js` y asegúrate de que use `https://vexuspage.onrender.com`

#### El backend no responde

**Solución:**
1. Verifica que Render esté activo:
   ```bash
   curl https://vexuspage.onrender.com/health
   ```
2. Respuesta esperada:
   ```json
   {
     "status": "healthy",
     "database": "connected",
     "timestamp": "2025-10-28T..."
   }
   ```
3. Si el backend está "dormido" (free tier), la primera carga puede tardar 30-60 segundos

## 4. Mantenimiento

### Actualizar el frontend

Para actualizar el frontend en Neatech:

1. Edita los archivos en la carpeta `frontend` localmente
2. Sube los archivos modificados a Neatech
3. Limpia el caché del navegador (Ctrl + Shift + R)

### Actualizar el backend

El backend en Render se actualiza automáticamente cuando haces push a GitHub:

```bash
git add .
git commit -m "Update: descripción del cambio"
git push origin main
```

Render detectará el push y redesplegará automáticamente.

## 5. Estructura de archivos para subir a Neatech

```
grupovexus.com/
│
├── index.html                      # ← Página principal (RAÍZ)
│
├── pages/                          # Páginas adicionales
│   ├── proyectos.html
│   ├── admin-panel.html
│   └── course-viewer.html
│
└── Static/                         # Archivos estáticos
    ├── css/
    │   └── main.css
    │
    ├── js/
    │   ├── config.js              # ← Configuración del API
    │   ├── config.prod.js
    │   ├── main.js
    │   ├── page-loader.js
    │   ├── typewriter.js
    │   ├── terminal-animation.js
    │   ├── proyectos.js
    │   ├── course-view.js
    │   ├── course-editor.js
    │   ├── course-editor-improved.js
    │   │
    │   ├── api/
    │   │   ├── client.js
    │   │   ├── auth.js
    │   │   └── services.js
    │   │
    │   ├── ui/
    │   │   ├── modal.js
    │   │   ├── animations.js
    │   │   └── navigation.js
    │   │
    │   └── utils/
    │       ├── helpers.js
    │       ├── storage.js
    │       ├── icons.js
    │       └── theme-customizer.js
    │
    └── images/
        ├── logo.png
        ├── ecosystem/
        └── [todas las imágenes]
```

## 6. Comandos útiles

### Verificar el backend desde la terminal

```bash
# Health check
curl https://vexuspage.onrender.com/health

# Verificar CORS
curl https://vexuspage.onrender.com/debug/cors

# Probar login (ejemplo)
curl -X POST https://vexuspage.onrender.com/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"test123"}'
```

### Comprimir archivos para subir a Neatech

Si Neatech requiere un ZIP:

```bash
cd frontend
zip -r ../vexus-frontend.zip .
```

## 7. Contacto y Soporte

Si encuentras problemas:

1. **Backend (Render):** Revisa los logs en [Render Dashboard](https://dashboard.render.com/)
2. **Frontend (Neatech):** Contacta el soporte de Neatech
3. **CORS/Conexión:** Verifica los pasos de troubleshooting arriba

---

## Resumen rápido

1. ✅ **Backend:** Ya está funcionando en Render.com
2. ✅ **Frontend:** Ya está configurado para usar el backend de Render
3. ⏳ **Pendiente:** Subir los archivos de `/frontend` a Neatech
4. ⏳ **Pendiente:** Configurar el dominio `grupovexus.com` en Neatech
5. ⏳ **Pendiente:** Verificar que todo funcione correctamente

**¡Todo está listo para el deployment!** Solo necesitas acceso al panel de Neatech para subir los archivos.
