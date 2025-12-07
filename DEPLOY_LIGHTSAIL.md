# GUÍA RÁPIDA: Desplegar en AWS Lightsail

## 🚀 Pasos para Desplegar

### 1️⃣ Subir cambios a Git (en tu PC local)

```powershell
git add .
git commit -m "Fix: DATABASE_URL, nginx timeouts y cache version"
git push origin main
```

### 2️⃣ Conectarse a AWS Lightsail

**Opción A - Desde consola de AWS:**
- Ve a AWS Lightsail
- Click en tu instancia
- Click en "Connect using SSH"

**Opción B - Desde terminal:**
```bash
ssh -i tu-clave.pem ubuntu@tu-ip-lightsail
# o
ssh usuario@tu-ip-lightsail
```

### 3️⃣ Ir al directorio del proyecto

```bash
cd /ruta/a/VexusPage
# Ejemplo: cd ~/VexusPage o cd /opt/VexusPage
```

### 4️⃣ Ejecutar el script de despliegue

```bash
chmod +x deploy-lightsail.sh
./deploy-lightsail.sh
```

**O manualmente:**

```bash
# Actualizar código
git pull origin main

# Detener y eliminar volumen viejo
docker-compose -f docker-compose.prod.yml down
docker volume rm vexuspage_postgres_data

# Reconstruir y levantar
docker-compose -f docker-compose.prod.yml build --no-cache
docker-compose -f docker-compose.prod.yml up -d

# Ver logs
docker-compose -f docker-compose.prod.yml logs -f backend
```

### 5️⃣ Verificar que funciona

```bash
# Ver contenedores activos
docker ps

# Ver logs del backend
docker logs vexus-backend --tail 50

# Verificar health check
curl http://localhost:8000/health

# Ver logs en tiempo real
docker-compose -f docker-compose.prod.yml logs -f
```

---

## 🔧 Solución de Problemas

### Error: "password authentication failed"

El volumen de postgres no se eliminó. Fuerza la eliminación:

```bash
docker-compose -f docker-compose.prod.yml down -v
docker volume ls
docker volume rm vexuspage_postgres_data -f
```

### Error 504 Gateway Timeout

Los timeouts de nginx están muy bajos. Ya se aumentaron a 180s en el código.

### Mixed Content Error (HTTP/HTTPS)

El navegador tiene caché. Usuarios deben:
1. **Ctrl + Shift + Delete** → Limpiar caché
2. O **Ctrl + Shift + R** (hard refresh)
3. O modo incógnito

---

## 📋 Checklist Post-Despliegue

- [ ] Contenedores corriendo: `docker ps`
- [ ] Backend sin errores: `docker logs vexus-backend`
- [ ] Base de datos conectada (no "password authentication failed")
- [ ] Health check OK: `curl localhost:8000/health`
- [ ] Frontend carga: `curl localhost:80`
- [ ] API funciona: `curl localhost:8000/api/v1/services/`
- [ ] Emails se envían (probar desde la web)

---

## 🌐 Verificar desde Internet

```bash
# API
curl https://www.grupovexus.com/health
curl https://www.grupovexus.com/api/v1/services/

# Frontend
curl https://www.grupovexus.com/
```

---

## 📝 Variables Importantes en .env.production

Verifica que estén configuradas:

```bash
cat .env.production | grep DATABASE_URL
cat .env.production | grep POSTGRES_PASSWORD
cat .env.production | grep SMTP_PASSWORD
```

Todas deben tener valores, no estar vacías.

---

## ⚡ Comandos Útiles

```bash
# Reiniciar solo el backend
docker-compose -f docker-compose.prod.yml restart backend

# Ver logs específicos
docker logs vexus-backend -f
docker logs vexus-frontend -f
docker logs vexus-postgres -f

# Entrar a un contenedor
docker exec -it vexus-backend bash
docker exec -it vexus-postgres psql -U vexus_admin -d vexus_db

# Ver uso de recursos
docker stats

# Limpiar todo y empezar de cero
docker-compose -f docker-compose.prod.yml down -v
docker system prune -af --volumes
```
