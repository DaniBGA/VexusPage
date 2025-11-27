# 🚀 Quick Start - Vexus en AWS Lightsail

## ⚡ Instalación en 5 Minutos

### 1️⃣ Conectar al Servidor
```bash
ssh ubuntu@TU_IP_LIGHTSAIL
```

### 2️⃣ Instalar Docker (una sola vez)
```bash
# Instalar Docker + Docker Compose
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER
newgrp docker

# Instalar Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
```

### 3️⃣ Clonar y Configurar
```bash
cd ~
git clone https://github.com/TU_USUARIO/VexusPage.git
cd VexusPage
cp .env.production.example .env.production
nano .env.production  # Editar estos valores ⬇️
```

**Valores OBLIGATORIOS a cambiar en `.env.production`:**
```bash
POSTGRES_PASSWORD=TU_CONTRASEÑA_AQUI
SECRET_KEY=TU_SECRET_KEY_AQUI        # Generar con: python3 -c "import secrets; print(secrets.token_urlsafe(32))"
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USER=tu_email@gmail.com
SMTP_PASSWORD=tu_app_password_aqui   # App Password de Gmail (16 caracteres)
EMAIL_FROM=tu_email@gmail.com
FRONTEND_URL=https://tudominio.com
ALLOWED_ORIGINS=https://tudominio.com
```

### 4️⃣ Desplegar
```bash
docker-compose -f docker-compose.prod.yml up -d
```

### 5️⃣ Verificar
```bash
docker ps                                    # Ver contenedores
curl http://localhost:8000/health           # Backend OK
curl http://localhost                       # Frontend OK
docker-compose -f docker-compose.prod.yml logs -f  # Ver logs
```

---

## 🌐 Configurar Dominio y SSL (Opcional)

### DNS
En tu proveedor de dominio:
```
Tipo    Nombre    Valor
A       @         TU_IP_LIGHTSAIL
A       www       TU_IP_LIGHTSAIL
```

### SSL con Let's Encrypt
```bash
# Instalar certbot
sudo apt install -y certbot

# Detener frontend temporalmente
cd ~/VexusPage
docker-compose -f docker-compose.prod.yml stop frontend

# Obtener certificado
sudo certbot certonly --standalone -d tudominio.com -d www.tudominio.com

# Copiar certificados
mkdir -p ssl
sudo cp /etc/letsencrypt/live/tudominio.com/fullchain.pem ssl/
sudo cp /etc/letsencrypt/live/tudominio.com/privkey.pem ssl/
sudo chown $USER:$USER ssl/*

# Habilitar SSL en nginx
nano frontend/nginx.prod.conf  # Descomentar líneas SSL

# Reiniciar
docker-compose -f docker-compose.prod.yml up -d
```

---

## 🔧 Comandos Útiles

```bash
# Ver logs en tiempo real
docker-compose -f docker-compose.prod.yml logs -f

# Reiniciar servicios
docker-compose -f docker-compose.prod.yml restart

# Detener todo
docker-compose -f docker-compose.prod.yml down

# Actualizar aplicación
git pull origin main
docker-compose -f docker-compose.prod.yml down
docker-compose -f docker-compose.prod.yml build
docker-compose -f docker-compose.prod.yml up -d

# Backup de base de datos
docker exec vexus-postgres pg_dump -U vexus_admin vexus_db > backup_$(date +%Y%m%d).sql

# Ver uso de recursos
docker stats

# Limpiar espacio
docker system prune -a
```

---

## 🔥 Troubleshooting

### Backend no inicia
```bash
docker logs vexus-backend
# Verifica DATABASE_URL en .env.production
# Verifica que postgres esté corriendo: docker ps | grep postgres
```

### Frontend no carga
```bash
docker logs vexus-frontend
# Verifica que el puerto 80 esté abierto en Lightsail Firewall
```

### No se conecta a la base de datos
```bash
docker exec vexus-postgres pg_isready -U vexus_admin
# Si falla, verifica POSTGRES_PASSWORD en .env.production
```

---

## 📊 URLs de tu Aplicación

- **Frontend:** http://TU_IP_O_DOMINIO
- **Backend API:** http://TU_IP_O_DOMINIO/api
- **Health Check:** http://TU_IP_O_DOMINIO/api/health
- **API Docs:** http://TU_IP_O_DOMINIO/api/docs

Con SSL:
- **Frontend:** https://tudominio.com
- **Backend API:** https://tudominio.com/api

---

## 📖 Documentación Completa

- **Guía completa:** `docs/DEPLOYMENT_AWS_LIGHTSAIL.md`
- **README de producción:** `PRODUCTION_README.md`
- **Checklist detallado:** `DEPLOYMENT_CHECKLIST.md`
- **Resumen de archivos:** `DEPLOYMENT_SUMMARY.md`

---

## ✅ Checklist Mínimo

- [ ] Docker instalado
- [ ] Repositorio clonado
- [ ] `.env.production` configurado
- [ ] Puertos 80 y 443 abiertos en Lightsail
- [ ] Servicios corriendo: `docker ps`
- [ ] Backend responde: `curl http://localhost:8000/health`
- [ ] Frontend responde: `curl http://localhost`

**¡Listo! Tu aplicación está en producción 🎉**
