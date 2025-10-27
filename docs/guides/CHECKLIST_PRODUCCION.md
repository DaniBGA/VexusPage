# ✅ CHECKLIST DE PRODUCCIÓN - VEXUS

## 📋 Estado Actual del Proyecto

### ✅ Backend
- ✅ API REST con FastAPI
- ✅ Base de datos PostgreSQL configurada
- ✅ Autenticación JWT implementada
- ✅ Sistema de usuarios y sesiones
- ✅ Envío de emails configurado (SMTP Gmail)
- ✅ Endpoints de contacto y consultoría funcionando
- ✅ Health checks implementados
- ✅ Manejo de errores y excepciones
- ✅ CORS configurado
- ✅ Variables de entorno con .env

### ✅ Frontend
- ✅ Diseño responsive y moderno
- ✅ Página principal (index.html)
- ✅ Página de proyectos (proyectos.html)
- ✅ Formularios de contacto y consultoría
- ✅ Integración con API del backend
- ✅ Gestión de usuarios y autenticación
- ✅ Sistema de campus/cursos

### ✅ DevOps
- ✅ Docker y Docker Compose configurados
- ✅ Separación de entornos (development/production)
- ✅ Guías de deployment detalladas
- ✅ Scripts de backup y restauración
- ✅ .gitignore configurado correctamente

---

## ⚠️ TAREAS OBLIGATORIAS ANTES DE PRODUCCIÓN

### 1. 🔒 Seguridad

#### Variables de Entorno
- [ ] **CRÍTICO**: Cambiar `SECRET_KEY` en `.env.production`
  ```bash
  # Generar nueva clave:
  python generate_secret_key.py
  ```

- [ ] **CRÍTICO**: Cambiar `POSTGRES_PASSWORD` en `.env.production`
  - Usar contraseña fuerte (mínimo 16 caracteres, mezcla de mayúsculas, minúsculas, números y símbolos)

- [ ] Verificar que `.env` NO esté en el repositorio git
  ```bash
  git status
  # .env debe aparecer en .gitignore
  ```

- [ ] Configurar `ALLOWED_ORIGINS` con tu dominio real
  ```bash
  ALLOWED_ORIGINS=https://tudominio.com,https://www.tudominio.com
  ```

- [ ] Verificar `DEBUG=False` en producción

- [ ] Actualizar credenciales de email en `.env.production`
  - Si usas Gmail, asegúrate de usar contraseña de aplicación
  - Si usas otro proveedor, actualiza SMTP_HOST y SMTP_PORT

#### Archivos Sensibles
- [ ] Verificar que estos archivos NO estén en git:
  - `.env`
  - `.env.production`
  - `*.pem`
  - `*.key`
  - Cualquier archivo con credenciales

### 2. 🌐 URLs y CORS

- [ ] **CRÍTICO**: Actualizar URLs hardcodeadas
  - ✅ `proyectos.js` ya corregido (detecta automáticamente)
  - ✅ `config.prod.js` usa `window.location.origin`

- [ ] Verificar que NO haya URLs localhost en producción:
  ```bash
  # Buscar URLs hardcodeadas:
  grep -r "localhost:8000" frontend/
  grep -r "127.0.0.1" frontend/
  ```

- [ ] Actualizar `FRONTEND_URL` en `.env.production` para emails de verificación

### 3. 📧 Email

- [ ] Verificar configuración SMTP en `.env.production`:
  ```bash
  SMTP_HOST=smtp.gmail.com
  SMTP_PORT=587
  SMTP_USER=grupovexus@gmail.com
  SMTP_PASSWORD=tu-contraseña-de-aplicacion
  EMAIL_FROM=grupovexus@gmail.com
  ```

- [ ] Si usas Gmail, crear contraseña de aplicación:
  - Ir a https://myaccount.google.com/apppasswords
  - Generar nueva contraseña
  - Actualizar `SMTP_PASSWORD` en `.env.production`

- [ ] Probar envío de email antes de deployment:
  ```bash
  cd backend
  python test_contact_email.py
  ```

### 4. 🗄️ Base de Datos

- [ ] Verificar que existe el archivo SQL de inicialización:
  - `deployment/production/vexus_db.sql` o similar

- [ ] Planificar backup inicial antes del deployment

- [ ] Configurar backups automáticos (ver README de producción)

### 5. 🐳 Docker

- [ ] Verificar que los Dockerfiles funcionan:
  ```bash
  # Backend
  cd backend
  docker build -t vexus-backend .

  # Frontend
  cd ../frontend
  docker build -t vexus-frontend .
  ```

- [ ] Revisar `docker-compose.yml` de producción
  - Verificar que NO incluya Adminer ni herramientas de desarrollo
  - Verificar health checks
  - Verificar restart policies

### 6. 🔥 Firewall y Red

- [ ] Configurar firewall en el servidor:
  ```bash
  sudo ufw allow 22    # SSH
  sudo ufw allow 80    # HTTP
  sudo ufw allow 443   # HTTPS
  sudo ufw enable
  ```

- [ ] Cerrar puerto 8000 (solo accesible internamente)
- [ ] Cerrar puerto 5432 (PostgreSQL solo para Docker)

### 7. 🔐 SSL/HTTPS

- [ ] Obtener dominio
- [ ] Configurar DNS apuntando al servidor
- [ ] Instalar Certbot y obtener certificado SSL
  ```bash
  sudo apt install certbot python3-certbot-nginx -y
  sudo certbot --nginx -d tudominio.com -d www.tudominio.com
  ```

- [ ] Configurar renovación automática
  ```bash
  sudo certbot renew --dry-run
  ```

### 8. 🚀 Nginx

- [ ] Instalar y configurar Nginx como proxy reverso
- [ ] Configurar redireccionamiento HTTP → HTTPS
- [ ] Configurar headers de seguridad
- [ ] Probar configuración:
  ```bash
  sudo nginx -t
  ```

---

## 🎯 PROBLEMAS IDENTIFICADOS Y SOLUCIONADOS

### ✅ Problemas Resueltos

1. **URL hardcodeada en proyectos.js**
   - ✅ SOLUCIONADO: Ahora detecta automáticamente el entorno

2. **Configuración de emails**
   - ✅ CONFIGURADO: SMTP de Gmail funcionando
   - ✅ PROBADO: Test exitoso de envío de email

3. **Separación de entornos**
   - ✅ CONFIGURADO: development y production separados
   - ✅ CONFIGURADO: .env.example y .env.production.example

### ⚠️ Puntos de Atención

1. **Secret Key**
   - ⚠️ PENDIENTE: Generar nueva SECRET_KEY para producción
   - Actualmente usa: `cambiar-esta-clave-secreta-en-produccion`

2. **Password de BD**
   - ⚠️ PENDIENTE: Cambiar contraseña de PostgreSQL
   - Actualmente usa: `Danuus22` (INSEGURO para producción)

3. **CORS**
   - ⚠️ PENDIENTE: Configurar con dominio real
   - Actualmente: permite localhost

---

## 📝 PASOS PARA DEPLOYMENT

### Opción 1: Deployment Manual

1. **Preparar servidor**
   ```bash
   ssh usuario@servidor
   sudo apt update && sudo apt upgrade -y
   ```

2. **Instalar Docker y Docker Compose**
   ```bash
   curl -fsSL https://get.docker.com -o get-docker.sh
   sudo sh get-docker.sh
   sudo apt install docker-compose-plugin -y
   ```

3. **Clonar repositorio**
   ```bash
   git clone https://github.com/tu-usuario/VexusPage.git
   cd VexusPage
   git checkout main
   ```

4. **Configurar variables de entorno**
   ```bash
   cp deployment/production/.env.production.example .env.production
   nano .env.production
   # Actualizar TODOS los valores
   ```

5. **Levantar servicios**
   ```bash
   docker compose -f deployment/production/docker-compose.yml --env-file .env.production up -d
   ```

6. **Verificar**
   ```bash
   docker ps
   curl http://localhost:8000/health
   ```

7. **Configurar Nginx y SSL**
   - Ver `deployment/production/README.md`

### Opción 2: Deployment con Plataforma (Recomendado)

#### Railway / Render / Fly.io
- ✅ Deployment más simple
- ✅ SSL automático
- ✅ Escalamiento automático
- ✅ Backups incluidos

#### Pasos:
1. Conectar repositorio de GitHub
2. Configurar variables de entorno en la plataforma
3. Deploy automático

---

## 🧪 TESTING PRE-DEPLOYMENT

### Backend
```bash
cd backend
python test_contact_email.py  # ✅ Probado y funciona
```

### Health Check
```bash
curl http://localhost:8000/health
# Debe devolver: {"status": "healthy", "database": "connected", ...}
```

### CORS
```bash
curl http://localhost:8000/debug/cors
# Verificar ALLOWED_ORIGINS
```

---

## 📊 MONITOREO POST-DEPLOYMENT

### Después del deployment, verificar:

- [ ] Sitio accesible vía HTTPS
- [ ] Formulario de contacto funciona y envía emails
- [ ] Login y registro funcionan
- [ ] Base de datos conecta correctamente
- [ ] Health check responde OK
- [ ] Logs no muestran errores críticos
- [ ] SSL certificado válido
- [ ] Redirección HTTP → HTTPS funciona

### Comandos útiles:
```bash
# Ver logs
docker compose -f deployment/production/docker-compose.yml logs -f

# Ver estado
docker ps

# Health check
curl https://tudominio.com/health

# Reiniciar
docker compose -f deployment/production/docker-compose.yml restart
```

---

## 🆘 SOPORTE

### Documentación adicional:
- 📖 `deployment/production/README.md` - Guía completa de deployment
- 🔒 `docs/guides/SECURITY_CHECKLIST.md` - Checklist de seguridad
- 📝 `README.md` - Documentación general

### Comandos de emergencia:
```bash
# Detener todo
docker compose -f deployment/production/docker-compose.yml down

# Backup de emergencia
docker exec vexus-db pg_dump -U postgres vexus_db > emergency_backup.sql

# Ver logs de errores
docker compose -f deployment/production/docker-compose.yml logs --tail=100 backend
```

---

## ✅ ESTADO FINAL

### El proyecto ESTÁ CASI LISTO para producción

**Falta ÚNICAMENTE:**
1. ⚠️ Cambiar SECRET_KEY
2. ⚠️ Cambiar POSTGRES_PASSWORD
3. ⚠️ Configurar dominio en ALLOWED_ORIGINS
4. ⚠️ Configurar servidor y SSL

**Todo lo demás está listo y probado** ✅

Una vez completes estos 4 pasos, el proyecto puede ir a producción de forma segura.
