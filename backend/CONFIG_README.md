# 🔧 Configuración de Vexus Backend

## 📋 Configuración Centralizada

Todas las configuraciones sensibles (contraseñas, claves secretas, etc.) se encuentran en **un solo archivo**: `.env`

## 🚀 Configuración Inicial

### 1. Crear archivo de configuración

```bash
# Copiar el archivo de ejemplo
cp .env.example .env
```

### 2. Editar el archivo `.env`

Abre el archivo `.env` y actualiza estos valores:

```env
# === BASE DE DATOS ===
DATABASE_URL=postgresql://postgres:TU_CONTRASEÑA@localhost:5432/vexus_db

# === SEGURIDAD ===
SECRET_KEY=una-clave-secreta-muy-segura-y-larga

# === CORS ===
ALLOWED_ORIGINS=http://localhost:3000,http://localhost:8080
```

## 📂 Estructura de Configuración

```
backend/
├── .env                 # ❌ NUNCA subir a Git (ignorado)
├── .env.example         # ✅ Plantilla para otros desarrolladores
├── app/
│   └── config.py        # 🔄 Lee variables del .env
└── CONFIG_README.md     # 📖 Esta documentación
```

## 🔐 Variables Disponibles

### Base de Datos
- `DATABASE_URL` - URL de conexión a PostgreSQL
- `DB_POOL_MIN_SIZE` - Tamaño mínimo del pool (default: 5)
- `DB_POOL_MAX_SIZE` - Tamaño máximo del pool (default: 20)

### Seguridad
- `SECRET_KEY` - Clave secreta para JWT
- `ALGORITHM` - Algoritmo de encriptación (default: HS256)
- `ACCESS_TOKEN_EXPIRE_MINUTES` - Duración del token (default: 30)

### CORS
- `ALLOWED_ORIGINS` - Dominios permitidos (separados por coma)

### Email (Opcional)
- `SMTP_HOST` - Servidor SMTP
- `SMTP_PORT` - Puerto SMTP
- `SMTP_USER` - Usuario de email
- `SMTP_PASSWORD` - Contraseña de email
- `EMAIL_FROM` - Email remitente

### Aplicación
- `PROJECT_NAME` - Nombre del proyecto
- `VERSION` - Versión de la API
- `ENVIRONMENT` - Entorno (development/production)
- `DEBUG` - Modo debug (True/False)

## 💡 Cómo Usar en el Código

```python
from app.config import settings

# Acceder a cualquier configuración
db_url = settings.DATABASE_URL
secret = settings.SECRET_KEY
origins = settings.ALLOWED_ORIGINS
```

## ⚠️ Importante

1. **NUNCA** subir el archivo `.env` a Git
2. El archivo `.env` está en `.gitignore` por seguridad
3. Cada desarrollador debe crear su propio `.env` basado en `.env.example`
4. En producción, usar un gestor de secretos (AWS Secrets Manager, etc.)

## 🔄 Actualizar Configuración

Si necesitas agregar nuevas variables:

1. Agrégala al archivo `.env`
2. Actualiza `.env.example` con un valor de ejemplo
3. Agrega la variable en `app/config.py` clase `Settings`
4. Documenta la nueva variable en este README

## 🆘 Problemas Comunes

### Error: "No module named 'dotenv'"
```bash
pip install python-dotenv
```

### Error: "Connection refused" a la base de datos
- Verifica que PostgreSQL esté corriendo
- Verifica el `DATABASE_URL` en tu `.env`
- Confirma usuario y contraseña correctos

### Error: "Invalid token"
- Regenera el `SECRET_KEY` en `.env`
- Usa un generador de claves seguras

## 🔑 Generar SECRET_KEY Segura

```python
# En Python
import secrets
print(secrets.token_urlsafe(32))
```

O usar herramientas online de generación de claves seguras.
