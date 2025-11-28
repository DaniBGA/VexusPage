# 🚀 GUÍA PASO A PASO: DEPLOY EN AWS LIGHTSAIL

## 📌 LO QUE VAS A HACER (Resumen Simple)

1. ✅ Crear una máquina virtual en AWS Lightsail
2. ✅ Copiar tu código a la máquina
3. ✅ Ejecutar UN comando
4. ✅ Apuntar tu dominio
5. ✅ ¡LISTO! 🎉

**TODO está en UNA máquina. NO necesitas crear base de datos separada.**

---

## 🎯 PARTE 1: CREAR LA INSTANCIA EN AWS LIGHTSAIL

### Paso 1.1: Entrar a AWS Lightsail
1. Ve a: https://lightsail.aws.amazon.com
2. Inicia sesión con tu cuenta de AWS
3. Si no tienes cuenta, créala (tarjeta de crédito necesaria)

### Paso 1.2: Crear Instancia
1. Clic en **"Create instance"** (botón naranja)
2. **Ubicación**: Escoge la más cercana (ejemplo: Ohio, USA)
3. **Platform**: Selecciona **"Linux/Unix"**
4. **Blueprint**: Selecciona **"OS Only"** → **"Ubuntu 22.04 LTS"**

### Paso 1.3: Escoger Plan
Recomendado para empezar:
- ✅ **$10/mes** - 2 GB RAM, 1 CPU, 60 GB SSD
- O si quieres más potencia: **$20/mes** - 4 GB RAM, 2 CPUs

### Paso 1.4: Configurar Nombre
- **Instance name**: `vexus-production`
- Clic en **"Create instance"**

⏱️ **ESPERA 2-3 MINUTOS** mientras se crea la instancia.

---

## 🔧 PARTE 2: CONFIGURAR LA INSTANCIA

### Paso 2.1: Abrir Networking
1. En tu instancia, ve a la pestaña **"Networking"**
2. En **"Firewall"**, clic en **"Add rule"**
3. Agrega estas 3 reglas:

| Application | Protocol | Port | Descripción |
|-------------|----------|------|-------------|
| HTTP | TCP | 80 | Frontend |
| HTTPS | TCP | 443 | Frontend seguro |
| Custom | TCP | 8000 | Backend API |

### Paso 2.2: Conectarte por SSH
**Opción Fácil (Navegador):**
1. En la página de tu instancia, clic en el ícono de terminal (naranja)
2. Se abre una terminal en tu navegador ✅

**Opción Avanzada (Descarga la llave):**
1. Pestaña **"Account"** → **"SSH keys"**
2. Descarga tu llave `.pem`
3. Usa PuTTY (Windows) o Terminal (Mac/Linux)

---

## 📦 PARTE 3: INSTALAR LO NECESARIO EN LA INSTANCIA

### Paso 3.1: Actualizar Sistema
Copia y pega estos comandos UNO POR UNO en la terminal:

```bash
# Actualizar sistema
sudo apt update && sudo apt upgrade -y
```

### Paso 3.2: Instalar Docker
```bash
# Instalar Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
```

```bash
# Permitir usar Docker sin sudo
sudo usermod -aG docker ubuntu
```

```bash
# Instalar Docker Compose
sudo apt install docker-compose -y
```

```bash
# Reiniciar sesión para aplicar cambios
exit
```

**IMPORTANTE**: Después del `exit`, vuelve a conectarte por SSH (clic en el ícono de terminal otra vez)

### Paso 3.3: Verificar Instalación
```bash
# Verificar que Docker funciona
docker --version
docker-compose --version
```

Deberías ver algo como:
```
Docker version 24.0.x
docker-compose version 1.29.x
```

---

## 🚚 PARTE 4: SUBIR TU CÓDIGO

### Paso 4.1: Instalar Git
```bash
sudo apt install git -y
```

### Paso 4.2: Clonar tu Repositorio
```bash
# Ir al directorio home
cd ~

# Clonar tu repositorio
git clone https://github.com/DaniBGA/VexusPage.git

# Entrar al directorio
cd VexusPage

# Obtener la última versión (por si acaso)
git pull
```

### Paso 4.3: Configurar Variables de Entorno

**OPCIÓN A: Editar el archivo manualmente (Recomendado)**
```bash
# Abrir editor
nano .env.production.example
```

Cambia estos valores:
```
SMTP_USER=grupovexus@gmail.com
SMTP_PASSWORD=xuaevwdoprogdwrl
EMAIL_FROM=grupovexus@gmail.com
FRONTEND_URL=https://www.grupovexus.com
ALLOWED_ORIGINS=https://grupovexus.com,https://www.grupovexus.com
```

Guarda con: `Ctrl + O`, Enter, `Ctrl + X`

```bash
# Renombrar el archivo
mv .env.production.example .env.production
```

**OPCIÓN B: Crear el archivo completo** (Copia y pega todo esto)
```bash
cat > .env.production << 'EOF'
# Base de Datos
POSTGRES_DB=vexus_db
POSTGRES_USER=vexus_admin
POSTGRES_PASSWORD=VexusDB2025!Secure

# Backend
PROJECT_NAME="Vexus API"
VERSION="1.0.0"
ENVIRONMENT=production
DEBUG=false
SECRET_KEY=jP8mK2nL9vR4tY6wQ1xE3sA5dF7gH0jK2mN4pQ6rT8vW
DB_POOL_MIN_SIZE=5
DB_POOL_MAX_SIZE=20
DB_CONNECT_TIMEOUT=10
ACCESS_TOKEN_EXPIRE_MINUTES=30

# CORS
ALLOWED_ORIGINS=https://grupovexus.com,https://www.grupovexus.com

# Email Gmail
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USER=grupovexus@gmail.com
SMTP_PASSWORD=xuaevwdoprogdwrl
EMAIL_FROM=grupovexus@gmail.com

# Frontend
FRONTEND_URL=https://www.grupovexus.com
API_URL=https://grupovexus.com/api
EOF
```

---

## 🎬 PARTE 5: LEVANTAR TODO (EL MOMENTO DE LA VERDAD)

### Paso 5.1: Construir y Levantar
```bash
# Este comando hace TODO:
# - Crea la base de datos PostgreSQL
# - Levanta el backend
# - Levanta el frontend
# - Conecta todo
docker-compose -f docker-compose.prod.yml --env-file .env.production up -d --build
```

⏱️ **ESPERA 5-10 MINUTOS** la primera vez (descarga imágenes y construye todo)

### Paso 5.2: Ver el Progreso
```bash
# Ver logs en tiempo real
docker-compose -f docker-compose.prod.yml logs -f
```

**Presiona `Ctrl + C` para salir de los logs** (NO detiene los contenedores)

### Paso 5.3: Verificar que TODO Funciona
```bash
# Ver contenedores corriendo
docker ps
```

Deberías ver 3 contenedores:
- ✅ `vexus-postgres` (Base de datos)
- ✅ `vexus-backend` (API)
- ✅ `vexus-frontend` (Página web)

### Paso 5.4: Probar en el Navegador
1. En Lightsail, copia la **IP Pública** de tu instancia (ejemplo: `3.14.159.26`)
2. Abre tu navegador
3. Ve a: `http://TU-IP-PUBLICA`

**Deberías ver tu página de Vexus funcionando! 🎉**

---

## 🌐 PARTE 6: CONECTAR TU DOMINIO (grupovexus.com)

### Paso 6.1: Crear IP Estática en Lightsail
1. En tu instancia, pestaña **"Networking"**
2. Sección **"IPv4 Networking"**
3. Clic en **"Create static IP"**
4. Nombre: `vexus-static-ip`
5. Clic en **"Create"**

Copia esta IP (ejemplo: `54.123.45.67`)

### Paso 6.2: Configurar en tu Proveedor de Dominio

Ve a donde compraste `grupovexus.com` (GoDaddy, Namecheap, etc.) y configura:

**Registros DNS:**

| Tipo | Nombre | Valor | TTL |
|------|--------|-------|-----|
| A | @ | 54.123.45.67 | 3600 |
| A | www | 54.123.45.67 | 3600 |
| CNAME | api | grupovexus.com | 3600 |

**Reemplaza `54.123.45.67` con tu IP estática de Lightsail**

⏱️ **ESPERA 5-60 MINUTOS** para que se propague el DNS

### Paso 6.3: Verificar
```bash
# En tu computadora local, no en Lightsail
ping grupovexus.com
```

Si responde con tu IP de Lightsail, ¡está funcionando! ✅

---

## 🔒 PARTE 7: AGREGAR HTTPS (OPCIONAL PERO RECOMENDADO)

### Paso 7.1: Instalar Certbot
```bash
# Conectado a tu instancia Lightsail
sudo apt install certbot python3-certbot-nginx -y
```

### Paso 7.2: Obtener Certificado SSL
```bash
# Detener Docker temporalmente
cd ~/VexusPage
docker-compose -f docker-compose.prod.yml down

# Obtener certificado
sudo certbot certonly --standalone -d grupovexus.com -d www.grupovexus.com

# Ingresar tu email cuando te lo pida
# Aceptar términos (Y)
```

### Paso 7.3: Copiar Certificados
```bash
# Crear carpeta SSL
mkdir -p ~/VexusPage/ssl

# Copiar certificados
sudo cp /etc/letsencrypt/live/grupovexus.com/fullchain.pem ~/VexusPage/ssl/
sudo cp /etc/letsencrypt/live/grupovexus.com/privkey.pem ~/VexusPage/ssl/
sudo chown -R ubuntu:ubuntu ~/VexusPage/ssl
```

### Paso 7.4: Levantar de Nuevo
```bash
docker-compose -f docker-compose.prod.yml --env-file .env.production up -d
```

Ahora puedes acceder con: `https://grupovexus.com` 🔒

---

## 📊 COMANDOS ÚTILES (PARA EL DÍA A DÍA)

### Ver Estado de los Contenedores
```bash
cd ~/VexusPage
docker-compose -f docker-compose.prod.yml ps
```

### Ver Logs (Errores)
```bash
# Logs del backend
docker-compose -f docker-compose.prod.yml logs backend

# Logs del frontend
docker-compose -f docker-compose.prod.yml logs frontend

# Logs de la base de datos
docker-compose -f docker-compose.prod.yml logs postgres
```

### Reiniciar un Servicio
```bash
# Reiniciar backend
docker-compose -f docker-compose.prod.yml restart backend

# Reiniciar frontend
docker-compose -f docker-compose.prod.yml restart frontend
```

### Detener TODO
```bash
docker-compose -f docker-compose.prod.yml down
```

### Actualizar Código (Después de hacer cambios)
```bash
# Ir al directorio
cd ~/VexusPage

# Obtener últimos cambios de GitHub
git pull

# Reconstruir y reiniciar
docker-compose -f docker-compose.prod.yml --env-file .env.production up -d --build
```

### Ver Base de Datos (Si necesitas)
```bash
# Conectarte a PostgreSQL
docker exec -it vexus-postgres psql -U vexus_admin -d vexus_db

# Comandos útiles dentro de PostgreSQL:
# \dt                 - Ver tablas
# \d users            - Ver estructura de tabla users
# SELECT * FROM users; - Ver usuarios
# \q                  - Salir
```

---

## ❓ PREGUNTAS FRECUENTES

### ¿Necesito crear la base de datos separada?
❌ **NO**. Docker crea PostgreSQL automáticamente en la misma instancia.

### ¿Qué pasa con mis datos si reinicio?
✅ Los datos están en un **volumen persistente**. No se pierden al reiniciar.

### ¿Cuánto cuesta AWS Lightsail?
- Plan $10/mes: Suficiente para empezar
- Plan $20/mes: Más tráfico y rendimiento
- Primer mes a veces gratis (verifica ofertas)

### ¿Puedo usar otro proveedor?
✅ SÍ. Estos pasos funcionan en:
- DigitalOcean
- Vultr
- Linode
- Cualquier VPS con Ubuntu

### ¿Y si algo sale mal?
1. Ver logs: `docker-compose logs`
2. Reiniciar: `docker-compose restart`
3. Empezar de cero: `docker-compose down && docker-compose up -d --build`

---

## ✅ CHECKLIST FINAL

Marca cada paso cuando lo completes:

- [x] 1. Crear instancia en Lightsail ($10/mes plan)
- [x] 2. Abrir puertos: 80, 443, 8000
- [x] 3. Conectar por SSH
- [x] 4. Instalar Docker y Docker Compose
- [x] 5. Clonar repositorio de GitHub
- [x] 6. Copiar archivo .env.production
- [x] 7. Ejecutar: `docker-compose up -d --build`
- [x] 8. Verificar que funciona en: `http://TU-IP`
- [x] 9. Crear IP estática en Lightsail
- [x] 10. Configurar DNS en proveedor de dominio
- [x] 11. Esperar propagación DNS (5-60 min)
- [x] 12. Acceder a: `http://grupovexus.com`
- [x] 13. (Opcional) Instalar certificado SSL
- [x] 14. Acceder a: `https://grupovexus.com`

---

## 🎉 ¡FELICIDADES!

Si llegaste aquí, tu página está en producción! 🚀

**URLs finales:**
- Frontend: https://www.grupovexus.com
- Backend API: https://grupovexus.com/api/v1/docs (Documentación)

**¿Necesitas ayuda?** Pregúntame cualquier cosa! 😊
