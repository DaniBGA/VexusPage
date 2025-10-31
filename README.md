# 🚀 Vexus Platform

Plataforma web completa con backend FastAPI, frontend moderno y sistema de gestión de cursos.

**Estado actual:** ✅ Listo para producción en Neatech

---

## 📂 ESTRUCTURA DEL PROYECTO

```
VexusPage/
├── 📚 docs/                            # ⭐ TODA LA DOCUMENTACIÓN
│   ├── README.md                       # Índice de documentación
│   ├── backend/                        # Docs del backend
│   │   ├── DESPLIEGUE_NEATECH.md      # ⭐ Guía principal despliegue
│   │   ├── ESTRUCTURA_PRIVATE.md      # Backend en /private/
│   │   └── RESUMEN_ARCHIVOS.md        # Qué subir/no subir
│   ├── frontend/                       # Docs del frontend
│   │   └── DESPLIEGUE_FRONTEND_NEATECH.md  # ⭐ Guía despliegue
│   ├── ANALISIS_INTEGRACION_FRONTEND_BACKEND.md
│   ├── RESUMEN_ANALISIS_COMPLETO.md
│   └── ... (más guías)
│
├── backend/                            # 🔥 Código backend (FastAPI)
│   ├── app/                            # Aplicación principal
│   ├── passenger_wsgi_neatech.py       # Entrada Passenger
│   ├── .htaccess_neatech               # Config Apache
│   ├── .env.example.safe               # Template credenciales
│   ├── deploy_neatech.sql              # Schema PostgreSQL
│   └── requirements.txt                # Dependencias Python
│
└── frontend/                           # 🎨 Código frontend (Vanilla JS)
    ├── index.html                      # Página principal
    ├── pages/                          # Páginas secundarias
    └── Static/                         # Assets
        ├── css/                        # Estilos
        ├── js/                         # JavaScript
        │   ├── config.js               # Config desarrollo
        │   └── config.prod.js          # Config producción ✅
        └── images/                     # Imágenes
```

---

## 🚀 GUÍA DE DESPLIEGUE EN NEATECH

### 📖 Documentación Principal

**TODO está documentado en la carpeta `docs/`**

| Guía | Descripción |
|------|-------------|
| **[docs/README.md](docs/README.md)** | 📚 Índice de toda la documentación |
| **[docs/backend/DESPLIEGUE_NEATECH.md](docs/backend/DESPLIEGUE_NEATECH.md)** | ⭐ Cómo desplegar el backend |
| **[docs/frontend/DESPLIEGUE_FRONTEND_NEATECH.md](docs/frontend/DESPLIEGUE_FRONTEND_NEATECH.md)** | ⭐ Cómo desplegar el frontend |
| **[docs/backend/ESTRUCTURA_PRIVATE.md](docs/backend/ESTRUCTURA_PRIVATE.md)** | 📂 Backend en carpeta `/private/` |
| **[docs/RESUMEN_ANALISIS_COMPLETO.md](docs/RESUMEN_ANALISIS_COMPLETO.md)** | 📊 Estado del proyecto |

---

### 🎯 Pasos Rápidos

#### 1. Backend (va en `/private/backend/`)

```bash
# En Neatech:
1. Ejecutar deploy_neatech.sql en phpPgAdmin
2. Subir carpeta app/ a /private/backend/
3. Renombrar passenger_wsgi_neatech.py → passenger_wsgi.py
4. Crear .env con credenciales reales
5. Verificar: https://api.grupovexus.com/api/v1/health
```

📖 **Guía completa:** [docs/backend/DESPLIEGUE_NEATECH.md](docs/backend/DESPLIEGUE_NEATECH.md)

---

#### 2. Frontend (va en `/public_html/`)

```bash
# En Neatech:
1. Verificar config.prod.js (ya está configurado ✅)
2. Subir todo a public_html/
3. Crear .htaccess en public_html/
4. Verificar: https://grupovexus.com
```

📖 **Guía completa:** [docs/frontend/DESPLIEGUE_FRONTEND_NEATECH.md](docs/frontend/DESPLIEGUE_FRONTEND_NEATECH.md)

---

## 📊 ESTADO DEL PROYECTO

### ✅ Completamente Funcional

| Componente | Estado | Endpoints/Archivos |
|------------|--------|-------------------|
| **Backend API** | ✅ Funcional | 33 endpoints REST |
| **Frontend SPA** | ✅ Funcional | 28 archivos JS, 31 CSS |
| **Autenticación** | ✅ JWT + Email verification | Login, Register, Logout |
| **Base de datos** | ✅ PostgreSQL | 13 tablas + triggers |
| **Integración** | ✅ Compatible | Todos los endpoints verificados |
| **Documentación** | ✅ Completa | Guías paso a paso |

---

## 🛠️ STACK TECNOLÓGICO

**Backend:**
- Python 3.12 + FastAPI
- PostgreSQL 13+ (asyncpg)
- JWT Authentication
- Bcrypt password hashing
- SMTP Email (Gmail)
- Phusion Passenger (Neatech)

**Frontend:**
- Vanilla JavaScript (ES6 Modules)
- CSS3 con variables
- Fetch API
- localStorage
- Apache + mod_rewrite

**Servidor:**
- Neatech (cPanel)
- Apache
- PostgreSQL
- Python 3.8+

---

## 📝 FUNCIONALIDADES

### ✅ Implementadas:
- Sistema de autenticación completo (JWT)
- Verificación de email obligatoria
- Gestión de usuarios y perfiles
- Cursos (listado, detalle, progreso)
- Panel de administración
- CRUD de cursos (admin)
- Formularios de contacto y consultoría
- Dashboard con estadísticas
- Sistema de sesiones seguro
- CORS configurado
- Manejo de errores y fallbacks

### ⚠️ Pendientes (futuras mejoras):
- Editor completo de cursos (unidades y recursos)
- Sistema de inscripción a cursos
- Upload de archivos (PDFs, videos)
- Certificados de cursos
- Notificaciones push
- Chat de soporte

---

## 🔒 SEGURIDAD

### Implementado:
- ✅ Passwords hasheados con bcrypt
- ✅ JWT tokens seguros
- ✅ Verificación de email obligatoria
- ✅ Sesiones almacenadas en BD
- ✅ CORS configurado
- ✅ Headers de seguridad
- ✅ `.env` no en git

### Checklist Pre-Despliegue:
- [ ] `DEBUG=False` en `.env`
- [ ] `SECRET_KEY` fuerte y aleatoria
- [ ] `DATABASE_URL` con password seguro
- [ ] `ALLOWED_ORIGINS` con tu dominio específico
- [ ] SMTP credentials correctas
- [ ] SSL/HTTPS configurado en Neatech

---

## 🆘 AYUDA Y SOPORTE

### Documentación:
- **Índice completo:** [docs/README.md](docs/README.md)
- **Despliegue backend:** [docs/backend/DESPLIEGUE_NEATECH.md](docs/backend/DESPLIEGUE_NEATECH.md)
- **Despliegue frontend:** [docs/frontend/DESPLIEGUE_FRONTEND_NEATECH.md](docs/frontend/DESPLIEGUE_FRONTEND_NEATECH.md)
- **Análisis completo:** [docs/RESUMEN_ANALISIS_COMPLETO.md](docs/RESUMEN_ANALISIS_COMPLETO.md)

### Problemas comunes:
- **API no responde:** Verifica que backend esté en `/private/backend/` con `passenger_wsgi.py`
- **CORS errors:** Revisa `ALLOWED_ORIGINS` en `.env` del backend
- **Emails no llegan:** Verifica credenciales SMTP en `.env`
- **DB no conecta:** Verifica `DATABASE_URL` en `.env`

---

## 📞 CONTACTO

- **Email:** grupovexus@gmail.com
- **Web:** https://grupovexus.com

---

## 📝 RESUMEN RÁPIDO

**📂 Estructura:**
- `docs/` - TODA la documentación
- `backend/` - Código Python (FastAPI)
- `frontend/` - Código JavaScript (SPA)

**🚀 Para desplegar:**
1. Lee [docs/README.md](docs/README.md)
2. Backend → `/private/backend/` en Neatech
3. Frontend → `/public_html/` en Neatech
4. Verifica que todo funcione

**✅ Estado: LISTO PARA PRODUCCIÓN**

---

**Última actualización:** 2025-10-31
**Versión:** 1.0.0
**Licencia:** [Especificar]
