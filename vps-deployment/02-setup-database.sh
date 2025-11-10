#!/bin/bash

################################################################################
# Script de Configuración de Base de Datos - VexusPage VPS
# Versión: 1.0
# Descripción: Crea la base de datos PostgreSQL y las tablas necesarias
# Uso: sudo ./02-setup-database.sh
################################################################################

set -e  # Salir si hay errores

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

# Verificar que se ejecuta como root
if [ "$EUID" -ne 0 ]; then
    error "Este script debe ejecutarse como root (use sudo)"
    exit 1
fi

log "=========================================="
log "  CONFIGURACIÓN DE BASE DE DATOS"
log "=========================================="

################################################################################
# CONFIGURACIÓN - EDITA ESTOS VALORES
################################################################################

DB_NAME="vexus_db"
DB_USER="vexus_admin"
DB_PASSWORD="CAMBIAR_POR_PASSWORD_SEGURA"  # ⚠️ CAMBIAR ESTO

################################################################################
# VALIDACIONES
################################################################################

if [ "$DB_PASSWORD" = "CAMBIAR_POR_PASSWORD_SEGURA" ]; then
    error "DEBES CAMBIAR LA CONTRASEÑA DE LA BASE DE DATOS EN ESTE SCRIPT"
    error "Edita este archivo y cambia DB_PASSWORD por una contraseña segura"
    exit 1
fi

log "Configuración:"
log "  - Base de datos: $DB_NAME"
log "  - Usuario: $DB_USER"
log "  - Password: ********"

################################################################################
# PASO 1: Verificar que PostgreSQL está corriendo
################################################################################
log "PASO 1: Verificando PostgreSQL..."

if ! systemctl is-active --quiet postgresql; then
    error "PostgreSQL no está corriendo"
    log "Intentando iniciar PostgreSQL..."
    systemctl start postgresql
    sleep 3
fi

if systemctl is-active --quiet postgresql; then
    info "PostgreSQL está corriendo"
else
    error "No se pudo iniciar PostgreSQL"
    exit 1
fi

################################################################################
# PASO 2: Crear usuario y base de datos
################################################################################
log "PASO 2: Creando usuario y base de datos..."

# Crear usuario si no existe
sudo -u postgres psql -tAc "SELECT 1 FROM pg_roles WHERE rolname='$DB_USER'" | grep -q 1 || \
sudo -u postgres psql << EOF
CREATE USER $DB_USER WITH PASSWORD '$DB_PASSWORD';
ALTER USER $DB_USER WITH SUPERUSER;
EOF

info "Usuario '$DB_USER' creado/verificado"

# Crear base de datos si no existe
sudo -u postgres psql -tAc "SELECT 1 FROM pg_database WHERE datname='$DB_NAME'" | grep -q 1 || \
sudo -u postgres createdb -O $DB_USER $DB_NAME

info "Base de datos '$DB_NAME' creada/verificada"

################################################################################
# PASO 3: Habilitar extensiones
################################################################################
log "PASO 3: Habilitando extensiones..."

sudo -u postgres psql -d $DB_NAME << 'EOF'
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";
EOF

info "Extensiones habilitadas"

################################################################################
# PASO 4: Crear tablas
################################################################################
log "PASO 4: Creando tablas..."

sudo -u postgres psql -d $DB_NAME << 'EOF'

-- Tabla de usuarios
CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    hashed_password VARCHAR(255) NOT NULL,
    email_verified BOOLEAN DEFAULT FALSE,
    verification_token VARCHAR(255),
    verification_token_expires TIMESTAMP WITH TIME ZONE,
    is_active BOOLEAN DEFAULT TRUE,
    is_admin BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Tabla de sesiones de usuario
CREATE TABLE IF NOT EXISTS user_sessions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    token VARCHAR(500) NOT NULL UNIQUE,
    expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    user_agent VARCHAR(500),
    ip_address VARCHAR(45)
);

-- Tabla de cursos
CREATE TABLE IF NOT EXISTS courses (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    title VARCHAR(500) NOT NULL,
    description TEXT,
    instructor VARCHAR(255),
    duration_hours INTEGER,
    level VARCHAR(50),
    price DECIMAL(10, 2),
    image_url VARCHAR(500),
    category VARCHAR(100),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Tabla de inscripciones a cursos
CREATE TABLE IF NOT EXISTS course_enrollments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    course_id UUID NOT NULL REFERENCES courses(id) ON DELETE CASCADE,
    enrolled_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    completed_at TIMESTAMP WITH TIME ZONE,
    progress INTEGER DEFAULT 0,
    status VARCHAR(50) DEFAULT 'active',
    UNIQUE(user_id, course_id)
);

-- Tabla de proyectos
CREATE TABLE IF NOT EXISTS projects (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    title VARCHAR(500) NOT NULL,
    description TEXT,
    client VARCHAR(255),
    technologies TEXT[],
    image_url VARCHAR(500),
    project_url VARCHAR(500),
    status VARCHAR(50) DEFAULT 'active',
    start_date DATE,
    end_date DATE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Tabla de servicios
CREATE TABLE IF NOT EXISTS services (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    description TEXT,
    category VARCHAR(100),
    price_from DECIMAL(10, 2),
    icon VARCHAR(100),
    features TEXT[],
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Tabla de consultas/contactos
CREATE TABLE IF NOT EXISTS contact_requests (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL,
    phone VARCHAR(50),
    company VARCHAR(255),
    subject VARCHAR(500),
    message TEXT NOT NULL,
    status VARCHAR(50) DEFAULT 'new',
    priority VARCHAR(20) DEFAULT 'normal',
    assigned_to UUID REFERENCES users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Tabla de consultorías
CREATE TABLE IF NOT EXISTS consultancies (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE SET NULL,
    company_name VARCHAR(255),
    contact_name VARCHAR(255) NOT NULL,
    contact_email VARCHAR(255) NOT NULL,
    contact_phone VARCHAR(50),
    industry VARCHAR(100),
    service_type VARCHAR(100),
    description TEXT NOT NULL,
    budget_range VARCHAR(50),
    preferred_date DATE,
    status VARCHAR(50) DEFAULT 'pending',
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Tabla de herramientas/tools
CREATE TABLE IF NOT EXISTS tools (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    description TEXT,
    category VARCHAR(100),
    version VARCHAR(50),
    documentation_url VARCHAR(500),
    download_url VARCHAR(500),
    is_free BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Tabla de logs de auditoría
CREATE TABLE IF NOT EXISTS audit_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE SET NULL,
    action VARCHAR(100) NOT NULL,
    entity_type VARCHAR(100),
    entity_id UUID,
    details JSONB,
    ip_address VARCHAR(45),
    user_agent VARCHAR(500),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

EOF

info "Tablas creadas correctamente"

################################################################################
# PASO 5: Crear índices para performance
################################################################################
log "PASO 5: Creando índices..."

sudo -u postgres psql -d $DB_NAME << 'EOF'

-- Índices para users
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_users_email_verified ON users(email_verified);
CREATE INDEX IF NOT EXISTS idx_users_created_at ON users(created_at);

-- Índices para user_sessions
CREATE INDEX IF NOT EXISTS idx_sessions_user_id ON user_sessions(user_id);
CREATE INDEX IF NOT EXISTS idx_sessions_token ON user_sessions(token);
CREATE INDEX IF NOT EXISTS idx_sessions_expires_at ON user_sessions(expires_at);

-- Índices para courses
CREATE INDEX IF NOT EXISTS idx_courses_category ON courses(category);
CREATE INDEX IF NOT EXISTS idx_courses_is_active ON courses(is_active);

-- Índices para course_enrollments
CREATE INDEX IF NOT EXISTS idx_enrollments_user_id ON course_enrollments(user_id);
CREATE INDEX IF NOT EXISTS idx_enrollments_course_id ON course_enrollments(course_id);

-- Índices para projects
CREATE INDEX IF NOT EXISTS idx_projects_status ON projects(status);
CREATE INDEX IF NOT EXISTS idx_projects_created_at ON projects(created_at);

-- Índices para contact_requests
CREATE INDEX IF NOT EXISTS idx_contacts_status ON contact_requests(status);
CREATE INDEX IF NOT EXISTS idx_contacts_created_at ON contact_requests(created_at);

-- Índices para consultancies
CREATE INDEX IF NOT EXISTS idx_consultancies_status ON consultancies(status);
CREATE INDEX IF NOT EXISTS idx_consultancies_user_id ON consultancies(user_id);

-- Índices para audit_logs
CREATE INDEX IF NOT EXISTS idx_audit_user_id ON audit_logs(user_id);
CREATE INDEX IF NOT EXISTS idx_audit_created_at ON audit_logs(created_at);

EOF

info "Índices creados correctamente"

################################################################################
# PASO 6: Crear funciones auxiliares
################################################################################
log "PASO 6: Creando funciones auxiliares..."

sudo -u postgres psql -d $DB_NAME << 'EOF'

-- Función para actualizar updated_at automáticamente
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Triggers para actualizar updated_at
DROP TRIGGER IF EXISTS update_users_updated_at ON users;
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_courses_updated_at ON courses;
CREATE TRIGGER update_courses_updated_at BEFORE UPDATE ON courses
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_projects_updated_at ON projects;
CREATE TRIGGER update_projects_updated_at BEFORE UPDATE ON projects
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_services_updated_at ON services;
CREATE TRIGGER update_services_updated_at BEFORE UPDATE ON services
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_contacts_updated_at ON contact_requests;
CREATE TRIGGER update_contacts_updated_at BEFORE UPDATE ON contact_requests
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_consultancies_updated_at ON consultancies;
CREATE TRIGGER update_consultancies_updated_at BEFORE UPDATE ON consultancies
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

EOF

info "Funciones y triggers creados correctamente"

################################################################################
# PASO 7: Insertar datos de ejemplo (opcional)
################################################################################
log "PASO 7: Insertando datos de ejemplo..."

sudo -u postgres psql -d $DB_NAME << 'EOF'

-- Insertar un usuario administrador de ejemplo
-- Password: Admin123! (deberás cambiarlo después del primer login)
INSERT INTO users (name, email, hashed_password, email_verified, is_active, is_admin)
VALUES (
    'Administrador',
    'admin@grupovexus.com',
    '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewY5GyYzS6ZzqQm2',
    TRUE,
    TRUE,
    TRUE
)
ON CONFLICT (email) DO NOTHING;

EOF

info "Datos de ejemplo insertados (usuario: admin@grupovexus.com, password: Admin123!)"
warning "¡CAMBIA LA CONTRASEÑA DEL ADMIN DESPUÉS DEL PRIMER LOGIN!"

################################################################################
# PASO 8: Configurar permisos
################################################################################
log "PASO 8: Configurando permisos..."

sudo -u postgres psql -d $DB_NAME << EOF
GRANT ALL PRIVILEGES ON DATABASE $DB_NAME TO $DB_USER;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO $DB_USER;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO $DB_USER;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO $DB_USER;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO $DB_USER;
EOF

info "Permisos configurados correctamente"

################################################################################
# PASO 9: Optimizar PostgreSQL para la VPS
################################################################################
log "PASO 9: Optimizando configuración de PostgreSQL..."

PG_CONF="/etc/postgresql/$(ls /etc/postgresql)/main/postgresql.conf"

# Backup de configuración original
cp $PG_CONF ${PG_CONF}.backup

# Aplicar optimizaciones para VPS de 4GB RAM
cat >> $PG_CONF << 'PGCONF'

# ========================================
# OPTIMIZACIONES VEXUS - VPS 4GB RAM
# ========================================

# Memoria
shared_buffers = 1GB                    # 25% de RAM
effective_cache_size = 3GB              # 75% de RAM
maintenance_work_mem = 256MB
work_mem = 16MB

# Checkpoint
checkpoint_completion_target = 0.9
wal_buffers = 16MB
default_statistics_target = 100

# Conexiones
max_connections = 100

# Logging (para producción)
logging_collector = on
log_directory = 'pg_log'
log_filename = 'postgresql-%Y-%m-%d_%H%M%S.log'
log_rotation_age = 1d
log_rotation_size = 100MB
log_min_duration_statement = 1000       # Log queries > 1s
log_line_prefix = '%t [%p]: [%l-1] user=%u,db=%d,app=%a,client=%h '

# Performance
random_page_cost = 1.1                  # Para SSD
effective_io_concurrency = 200          # Para SSD

PGCONF

info "Configuración de PostgreSQL optimizada"

# Reiniciar PostgreSQL para aplicar cambios
log "Reiniciando PostgreSQL..."
systemctl restart postgresql
sleep 3

if systemctl is-active --quiet postgresql; then
    info "PostgreSQL reiniciado correctamente"
else
    error "Error al reiniciar PostgreSQL"
    exit 1
fi

################################################################################
# PASO 10: Crear script de limpieza automática
################################################################################
log "PASO 10: Creando script de limpieza automática..."

cat > /usr/local/bin/vexus-db-cleanup.sh << 'CLEANUP'
#!/bin/bash
# Script de limpieza de base de datos

DB_NAME="vexus_db"

echo "🧹 Limpiando base de datos..."

# Limpiar sesiones expiradas
sudo -u postgres psql -d $DB_NAME -c "DELETE FROM user_sessions WHERE expires_at < CURRENT_TIMESTAMP;" 2>&1 | grep "DELETE"

# Limpiar tokens de verificación expirados
sudo -u postgres psql -d $DB_NAME -c "UPDATE users SET verification_token = NULL, verification_token_expires = NULL WHERE verification_token_expires < CURRENT_TIMESTAMP;" 2>&1 | grep "UPDATE"

# Vacuum
sudo -u postgres psql -d $DB_NAME -c "VACUUM ANALYZE;" 2>&1

echo "✅ Limpieza completada"
CLEANUP

chmod +x /usr/local/bin/vexus-db-cleanup.sh

info "Script de limpieza creado: /usr/local/bin/vexus-db-cleanup.sh"

# Agregar a cron (ejecutar diariamente a las 2 AM)
(crontab -l 2>/dev/null; echo "0 2 * * * /usr/local/bin/vexus-db-cleanup.sh >> /var/log/vexus/db-cleanup.log 2>&1") | crontab -

info "Limpieza automática configurada (diaria a las 2 AM)"

################################################################################
# VERIFICACIÓN FINAL
################################################################################
log "=========================================="
log "  VERIFICACIÓN FINAL"
log "=========================================="

# Verificar conexión
log "Verificando conexión a la base de datos..."
if sudo -u postgres psql -d $DB_NAME -c "SELECT 1" > /dev/null 2>&1; then
    info "✓ Conexión exitosa"
else
    error "✗ Error de conexión"
    exit 1
fi

# Listar tablas
log ""
log "Tablas creadas:"
sudo -u postgres psql -d $DB_NAME -c "\dt" | grep -E "users|courses|projects|services"

# Contar registros
log ""
log "Registros iniciales:"
sudo -u postgres psql -d $DB_NAME -c "SELECT 'users' as table_name, COUNT(*) as count FROM users UNION ALL SELECT 'courses', COUNT(*) FROM courses;"

################################################################################
# GUARDAR CREDENCIALES
################################################################################
log ""
log "=========================================="
log "  GUARDANDO CREDENCIALES"
log "=========================================="

CRED_FILE="/root/.vexus-db-credentials"
cat > $CRED_FILE << EOF
# Credenciales de Base de Datos - VEXUS
# MANTÉN ESTE ARCHIVO SEGURO

DATABASE_URL=postgresql://${DB_USER}:${DB_PASSWORD}@localhost:5432/${DB_NAME}
DB_NAME=${DB_NAME}
DB_USER=${DB_USER}
DB_PASSWORD=${DB_PASSWORD}
DB_HOST=localhost
DB_PORT=5432

# Para usar en tu archivo .env:
# DATABASE_URL=postgresql://${DB_USER}:${DB_PASSWORD}@localhost:5432/${DB_NAME}
EOF

chmod 600 $CRED_FILE

info "Credenciales guardadas en: $CRED_FILE"

################################################################################
# RESUMEN
################################################################################
log ""
log "=========================================="
log "  CONFIGURACIÓN COMPLETADA"
log "=========================================="
log ""
log "✅ Base de datos configurada correctamente"
log ""
log "Información de conexión:"
log "  - Base de datos: $DB_NAME"
log "  - Usuario: $DB_USER"
log "  - Host: localhost"
log "  - Puerto: 5432"
log ""
log "DATABASE_URL:"
log "  postgresql://${DB_USER}:********@localhost:5432/${DB_NAME}"
log ""
log "Usuario administrador creado:"
log "  - Email: admin@grupovexus.com"
log "  - Password: Admin123!"
log "  ⚠️ CAMBIA ESTA CONTRASEÑA DESPUÉS DEL PRIMER LOGIN"
log ""
log "Siguiente paso:"
log "  ./03-deploy-backend.sh"
log ""
log "=========================================="

exit 0
