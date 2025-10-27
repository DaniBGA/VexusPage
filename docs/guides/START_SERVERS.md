# Cómo Iniciar los Servidores de Vexus

## 🚀 Inicio Rápido

Necesitas ejecutar **DOS servidores** simultáneamente:

### 1. Backend (Puerto 8000)

**Abrir una terminal y ejecutar:**

```bash
cd backend
python -m uvicorn app.main:app --reload
```

✅ El backend estará disponible en: `http://localhost:8000`
✅ Documentación de la API: `http://localhost:8000/docs`

---

### 2. Frontend (Puerto 5500)

**Abrir OTRA terminal (nueva ventana) y ejecutar:**

**Opción A - Usando Python:**
```bash
cd frontend
python -m http.server 5500
```

**Opción B - Usando archivo bat (Windows):**
```bash
# Desde la raíz del proyecto
start-frontend.bat
```

**Opción C - Usando Live Server (VS Code):**
1. Instala la extensión "Live Server" en VS Code
2. Haz clic derecho en `frontend/index.html`
3. Selecciona "Open with Live Server"

✅ El frontend estará disponible en: `http://localhost:5500`

---

## 📋 Verificación

Una vez que ambos servidores estén corriendo:

1. ✅ Backend: Abre `http://localhost:8000/health` - Deberías ver `{"status": "healthy"}`
2. ✅ Frontend: Abre `http://localhost:5500` - Deberías ver la página principal de Vexus
3. ✅ Verificación de email: Navega a `http://localhost:5500/pages/verify-email.html?token=test`

---

## 🔧 Solución de Problemas

### "Cannot GET /pages/verify-email.html"

❌ **Problema:** Estás accediendo al backend (puerto 8000) en lugar del frontend
✅ **Solución:** Usa `http://localhost:5500/pages/verify-email.html`

### "Connection refused" o "Backend not available"

❌ **Problema:** El backend no está corriendo
✅ **Solución:**
```bash
cd backend
python -m uvicorn app.main:app --reload
```

### "Puerto ya en uso"

❌ **Problema:** El puerto 5500 u 8000 está ocupado
✅ **Solución:**
```bash
# Cambiar el puerto del frontend
python -m http.server 5501

# Cambiar el puerto del backend
uvicorn app.main:app --reload --port 8001
```

No olvides actualizar `FRONTEND_URL` en `.env` si cambias puertos.

---

## 📁 Estructura de URLs

### Backend (puerto 8000):
- `http://localhost:8000` - Raíz de la API
- `http://localhost:8000/api/v1/auth/register` - Registro
- `http://localhost:8000/api/v1/auth/login` - Login
- `http://localhost:8000/api/v1/auth/verify-email` - Verificar email
- `http://localhost:8000/docs` - Documentación interactiva

### Frontend (puerto 5500):
- `http://localhost:5500` - Página principal
- `http://localhost:5500/pages/verify-email.html` - Verificación de email
- `http://localhost:5500/pages/dashboard.html` - Dashboard
- `http://localhost:5500/pages/courses.html` - Cursos

---

## 🎯 Flujo Completo de Verificación de Email

1. Usuario se registra en `http://localhost:5500` ✅
2. Backend (8000) crea la cuenta y envía email ✅
3. Email contiene enlace: `http://localhost:5500/pages/verify-email.html?token=xxx` ✅
4. Usuario hace clic → página de verificación (puerto 5500) ✅
5. Frontend llama a API: `http://localhost:8000/api/v1/auth/verify-email?token=xxx` ✅
6. Backend verifica y marca la cuenta ✅
7. Usuario redirigido al login ✅

---

## 💡 Consejos

- **Usa dos terminales separadas** para ver los logs de ambos servidores
- **Modo desarrollo:** Usa `--reload` en uvicorn para auto-recargar al hacer cambios
- **Producción:** Consulta la documentación en `deployment/` para deployment en servidor

---

## 🆘 Ayuda Adicional

Si tienes problemas, revisa:
- `VERIFICACION_EMAIL_INSTRUCCIONES.md` - Guía completa del sistema de verificación
- `backend/EMAIL_VERIFICATION_SETUP.md` - Documentación técnica detallada
