# 🚀 Inicio Rápido - Vexus

## Para Iniciar Todo el Sistema

### Opción 1: Scripts Automatizados (Recomendado)

**Windows:**

1. **Abre DOS terminales separadas:**

   **Terminal 1 - Backend:**
   ```bash
   start-backend.bat
   ```

   **Terminal 2 - Frontend:**
   ```bash
   start-frontend.bat
   ```

2. **Abre tu navegador:**
   ```
   http://localhost:5500
   ```

---

### Opción 2: Manual

**Terminal 1 - Backend:**
```bash
cd backend
python -m uvicorn app.main:app --reload
```

**Terminal 2 - Frontend:**
```bash
cd frontend
python -m http.server 5500
```

---

## ✅ Verificación

Una vez iniciados ambos servidores:

- ✅ **Backend:** http://localhost:8000/health
- ✅ **Frontend:** http://localhost:5500
- ✅ **API Docs:** http://localhost:8000/docs

---

## 🔧 Si tienes errores de CORS

**Problema:** `Access-Control-Allow-Origin` bloqueado

**Solución:**
1. Asegúrate de que el archivo `backend/.env` tenga:
   ```env
   ALLOWED_ORIGINS=http://localhost:5500
   ```

2. **Reinicia el backend** (esto es importante):
   - Detén el servidor (Ctrl+C)
   - Vuelve a iniciarlo con `start-backend.bat`

---

## 📧 Sistema de Verificación de Email

### Flujo Completo:

1. **Registro:**
   - Abre http://localhost:5500
   - Click en "Iniciar Sesión" → "Regístrate aquí"
   - Completa el formulario

2. **Verificación:**
   - Revisa la **consola del backend**
   - Copia el enlace que aparece:
     ```
     📧 Para tu@email.com: http://localhost:5500/pages/verify-email.html?token=...
     ```
   - Pega ese enlace en tu navegador

3. **Login:**
   - Regresa a http://localhost:5500
   - Inicia sesión con tu cuenta verificada

---

## 🆘 Solución de Problemas Comunes

### "Cannot GET /pages/verify-email.html"
❌ Estás usando `localhost:8000` (backend)
✅ Usa `localhost:5500` (frontend)

### "CORS policy blocked"
❌ El backend no se reinició después de cambiar `.env`
✅ Reinicia el backend

### "Connection refused"
❌ Algún servidor no está corriendo
✅ Inicia ambos servidores

### "Email not sent"
⚠️ SMTP no configurado (normal en desarrollo)
✅ Busca el enlace en la consola del backend

---

## 📁 Archivos de Ayuda

- `START_SERVERS.md` - Guía detallada de servidores
- `VERIFICACION_EMAIL_INSTRUCCIONES.md` - Guía del sistema de verificación
- `backend/EMAIL_VERIFICATION_SETUP.md` - Documentación técnica completa

---

## 🎯 URLs Importantes

| Servicio | URL | Descripción |
|----------|-----|-------------|
| **Frontend** | http://localhost:5500 | Página principal |
| **Backend API** | http://localhost:8000 | API REST |
| **API Docs** | http://localhost:8000/docs | Swagger UI |
| **Health Check** | http://localhost:8000/health | Estado del backend |
| **Verificación** | http://localhost:5500/pages/verify-email.html | Página de verificación |

---

¡Listo para empezar! 🚀
