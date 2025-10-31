# 🚨 SOLUCIÓN DEFINITIVA ERROR 500

**Estado:** Error 500 incluso con scripts de diagnóstico simples
**Conclusión:** El problema NO es tu código, es la configuración del servidor

---

## 🎯 CAUSA MÁS PROBABLE

**Passenger no está habilitado en tu cuenta de Neatech**, o la configuración de Apache no permite ejecutar aplicaciones Python.

---

## ✅ PRUEBA FINAL: Test HTML Simple

### Paso 1: Crear archivo HTML de prueba

**En File Manager**, dentro de `public_html/API/`, crea un archivo:

**Nombre:** `test.html`

**Contenido:**
```html
<!DOCTYPE html>
<html>
<head><title>Test</title></head>
<body>
    <h1>La carpeta API es accesible!</h1>
    <p>Si ves esto, el problema NO es la carpeta ni los permisos.</p>
    <p>El problema es que Passenger no puede ejecutar Python.</p>
</body>
</html>
```

### Paso 2: Acceder

Abre: `https://www.grupovexus.com/API/test.html`

**Resultado esperado:**
- ✅ **Si funciona:** La carpeta es accesible, confirma que el problema es Passenger
- ❌ **Si da 500:** El problema está en el `.htaccess` de `public_html/.htaccess`

---

## 📋 SI EL HTML FUNCIONA (MUY PROBABLE)

Esto confirma que **Passenger no está habilitado o configurado** en tu cuenta.

### SOLUCIÓN: Contactar a Soporte de Neatech

Envía este mensaje exacto a soporte:

```
Asunto: Habilitar Passenger (Python) para mi cuenta

Hola equipo de Neatech,

Necesito ejecutar una aplicación Python con FastAPI en mi cuenta.

Detalles:
- Dominio: grupovexus.com
- Usuario: grupovex
- Ubicación de la app: ~/web/grupovexus.com/public_html/API/

He configurado el archivo .htaccess con:
- PassengerEnabled on
- PassengerAppType wsgi
- PassengerStartupFile passenger_wsgi.py

Sin embargo, obtengo error 500 al acceder a /API/

Preguntas:
1. ¿Está Passenger habilitado en mi plan de hosting?
2. ¿Mi plan soporta aplicaciones Python?
3. Si sí, ¿cuál es la ruta correcta para PassengerPython?
4. ¿Necesito hacer alguna configuración adicional?

Archivos actuales en public_html/API/:
- passenger_wsgi.py (archivo WSGI de entrada)
- .htaccess (configuración Passenger)
- app/ (código de la aplicación)
- requirements.txt (dependencias)

¿Pueden ayudarme a configurar Passenger correctamente o indicarme si mi plan no lo soporta?

Gracias.
```

---

## 🔄 ALTERNATIVA: Verificar Plan de Hosting

### Passenger puede NO estar disponible en todos los planes

Verifica en la documentación de Neatech o en tu panel:

1. **Busca** en cPanel secciones como:
   - "Setup Python App"
   - "Python Selector"
   - "Application Manager"
   - "Passenger"

2. **Si NO encuentras ninguna:**
   - Tu plan probablemente NO soporta aplicaciones Python
   - Necesitas upgrade de plan o cambiar de hosting

3. **Si SÍ encuentras:**
   - Úsala para configurar tu app en lugar de hacerlo manualmente
   - Esa interfaz configura Passenger automáticamente

---

## 🆘 PLAN B: Si Passenger NO está disponible

### Opción 1: VPS o Hosting que soporte Python

Si Neatech no soporta Python en tu plan:

**Alternativas de hosting que SÍ soportan Python:**
- **Render.com** (Free tier disponible)
- **Railway.app** (Free tier disponible)
- **Fly.io** (Free tier disponible)
- **PythonAnywhere** (Free tier para apps pequeñas)
- **DigitalOcean App Platform**

---

### Opción 2: Upgrade de plan en Neatech

Pregunta a Neatech:
- ¿Qué plan incluye soporte para Python/Passenger?
- ¿Cuánto cuesta?

---

## 📊 DIAGNÓSTICO COMPLETO

### Test 1: HTML Simple
```
Ubicación: public_html/API/test.html
URL: https://www.grupovexus.com/API/test.html
Resultado esperado: ✅ Debe funcionar
```

### Test 2: Passenger Mínimo
```
Archivo: test_minimo.py → renombrar a passenger_wsgi.py
.htaccess: Solo 3 líneas (PassengerEnabled on, etc.)
URL: https://www.grupovexus.com/API/
Resultado actual: ❌ Error 500
```

**Conclusión:** Passenger no está funcionando.

---

## 🎯 ACCIÓN INMEDIATA

### PASO 1: Confirmar que la carpeta es accesible

1. Crea `test.html` en `public_html/API/`
2. Accede a `https://www.grupovexus.com/API/test.html`
3. Debe funcionar

### PASO 2: Buscar "Setup Python App" en cPanel

1. Ingresa a cPanel
2. En el buscador escribe: `python`
3. ¿Aparece algo como "Setup Python App" o "Python Selector"?

**Si SÍ aparece:**
- Úsalo para configurar tu app
- Te pedirá:
  - Ruta de la app: `/home/grupovex/web/grupovexus.com/public_html/API`
  - Archivo de entrada: `passenger_wsgi.py`
  - Versión Python: 3.8 o superior
  - Application URL: `/API`

**Si NO aparece:**
- Passenger no está disponible en tu plan
- Contacta a soporte (mensaje arriba)

### PASO 3: Revisar logs de error en cPanel

1. cPanel → "Error Log" o "Registros de errores"
2. Busca mensajes con "passenger" o "API"
3. Copia el error EXACTO

---

## 📝 INFORMACIÓN QUE NECESITAS OBTENER DE NEATECH

1. ✅ ¿Tu plan soporta Passenger / Python?
2. ✅ ¿Cuál es la ruta de Python? (`/usr/bin/python3` ?)
3. ✅ ¿Cómo instalar dependencias Python?
4. ✅ ¿Hay interfaz web para configurar apps Python?
5. ✅ ¿Qué dice el error_log del servidor?

---

## 💡 MIENTRAS ESPERAS RESPUESTA

### Opción temporal: Desplegar backend en otro lugar

Puedes desplegar SOLO el backend en un servicio gratuito que soporte Python:

1. **Render.com** (Recomendado)
   - Crea cuenta gratis
   - Conecta tu repo de GitHub
   - Deploy automático
   - URL: `https://tu-app.onrender.com`

2. **Actualiza frontend** para que apunte a la nueva URL:
   ```javascript
   API_BASE_URL: 'https://tu-app.onrender.com/api/v1'
   ```

3. **Mantén frontend en Neatech** (funciona perfectamente)

**Ventajas:**
- Backend funciona inmediatamente
- Frontend en tu dominio grupovexus.com
- Gratis (tier free de Render)

**Desventajas:**
- Backend en un dominio diferente (requiere CORS)
- Pero CORS ya está configurado en tu backend ✅

---

## 🎯 RESUMEN

**Problema:** Error 500 en `/API` → Passenger no funciona

**Causa más probable:** Tu plan de Neatech no tiene Passenger habilitado

**Solución inmediata:**
1. Confirmar con test HTML
2. Buscar "Setup Python App" en cPanel
3. Contactar a soporte de Neatech

**Solución alternativa:**
- Frontend en Neatech ✅
- Backend en Render.com (gratis) ✅

---

## 📞 PRÓXIMOS PASOS

1. **AHORA:** Crea `test.html` y verifica que funciona
2. **HOY:** Contacta a soporte de Neatech con el mensaje de arriba
3. **SI NO RESPONDEN EN 24H:** Considera desplegar backend en Render.com

---

**Última actualización:** 2025-10-31
**Estado:** ⚠️ Esperando confirmación de soporte Neatech
