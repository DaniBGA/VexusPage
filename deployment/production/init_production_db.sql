-- ====================================
-- VEXUS CAMPUS - BASE DE DATOS DE PRODUCCIÓN
-- ====================================
-- Script completo para inicializar la base de datos en AWS Lightsail
-- Incluye: estructura de tablas + datos iniciales del campus

-- ====================================
-- EXTENSIONES REQUERIDAS
-- ====================================
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ====================================
-- ELIMINAR TABLAS EXISTENTES (OPCIONAL - SOLO EN PRIMERA INSTALACIÓN)
-- ====================================
-- DESCOMENTA ESTAS LÍNEAS SI NECESITAS REINICIAR LA BASE DE DATOS
/*
DROP TABLE IF EXISTS user_unit_progress CASCADE;
DROP TABLE IF EXISTS user_tool_access CASCADE;
DROP TABLE IF EXISTS user_sessions CASCADE;
DROP TABLE IF EXISTS user_projects CASCADE;
DROP TABLE IF EXISTS user_course_progress CASCADE;
DROP TABLE IF EXISTS course_resources CASCADE;
DROP TABLE IF EXISTS course_units CASCADE;
DROP TABLE IF EXISTS course_enrollments CASCADE;
DROP TABLE IF EXISTS contact_messages CASCADE;
DROP TABLE IF EXISTS consultancy_requests CASCADE;
DROP TABLE IF EXISTS campus_tools CASCADE;
DROP TABLE IF EXISTS campus_sections CASCADE;
DROP TABLE IF EXISTS services CASCADE;
DROP TABLE IF EXISTS learning_courses CASCADE;
DROP TABLE IF EXISTS users CASCADE;
*/

-- ====================================
-- 1. TABLAS PRINCIPALES
-- ====================================

-- Tabla de usuarios
CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email VARCHAR(255) NOT NULL UNIQUE,
    hashed_password VARCHAR(255) NOT NULL,
    full_name VARCHAR(255) NOT NULL,
    is_active BOOLEAN DEFAULT false,
    is_verified BOOLEAN DEFAULT false,
    verification_token VARCHAR(255),
    verification_token_expires TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Índices para users
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_users_verification_token ON users(verification_token);
CREATE INDEX IF NOT EXISTS idx_users_is_active ON users(is_active);

-- Tabla de sesiones de usuario
CREATE TABLE IF NOT EXISTS user_sessions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    session_token VARCHAR(500) NOT NULL UNIQUE,
    expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    ip_address VARCHAR(45),
    user_agent TEXT
);

-- Índices para user_sessions
CREATE INDEX IF NOT EXISTS idx_user_sessions_user_id ON user_sessions(user_id);
CREATE INDEX IF NOT EXISTS idx_user_sessions_token ON user_sessions(session_token);
CREATE INDEX IF NOT EXISTS idx_user_sessions_expires ON user_sessions(expires_at);

-- ====================================
-- 2. TABLAS DEL CAMPUS
-- ====================================

-- Secciones del campus (Dashboard, Cursos, Herramientas)
CREATE TABLE IF NOT EXISTS campus_sections (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    title VARCHAR(255) NOT NULL,
    description TEXT,
    icon_name VARCHAR(100),
    order_index INTEGER NOT NULL,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Índice para campus_sections
CREATE INDEX IF NOT EXISTS idx_campus_sections_order ON campus_sections(order_index);

-- Herramientas del campus
CREATE TABLE IF NOT EXISTS campus_tools (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    description TEXT,
    icon_name VARCHAR(100),
    url VARCHAR(500),
    category VARCHAR(100),
    is_active BOOLEAN DEFAULT true,
    requires_authentication BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Índices para campus_tools
CREATE INDEX IF NOT EXISTS idx_campus_tools_category ON campus_tools(category);
CREATE INDEX IF NOT EXISTS idx_campus_tools_is_active ON campus_tools(is_active);

-- Acceso de usuarios a herramientas
CREATE TABLE IF NOT EXISTS user_tool_access (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    tool_id UUID NOT NULL REFERENCES campus_tools(id) ON DELETE CASCADE,
    granted_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMP WITH TIME ZONE,
    UNIQUE(user_id, tool_id)
);

-- Índices para user_tool_access
CREATE INDEX IF NOT EXISTS idx_user_tool_access_user ON user_tool_access(user_id);
CREATE INDEX IF NOT EXISTS idx_user_tool_access_tool ON user_tool_access(tool_id);

-- ====================================
-- 3. SISTEMA DE CURSOS
-- ====================================

-- Cursos
CREATE TABLE IF NOT EXISTS learning_courses (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    title VARCHAR(255) NOT NULL,
    description TEXT,
    difficulty_level VARCHAR(50),
    duration_hours INTEGER,
    thumbnail_url VARCHAR(500),
    content JSONB,
    is_published BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Índices para learning_courses
CREATE INDEX IF NOT EXISTS idx_learning_courses_published ON learning_courses(is_published);
CREATE INDEX IF NOT EXISTS idx_learning_courses_difficulty ON learning_courses(difficulty_level);

-- Unidades de curso
CREATE TABLE IF NOT EXISTS course_units (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    course_id UUID NOT NULL REFERENCES learning_courses(id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    content TEXT,
    "order" INTEGER NOT NULL,
    duration_minutes INTEGER,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Índices para course_units
CREATE INDEX IF NOT EXISTS idx_course_units_course ON course_units(course_id);
CREATE INDEX IF NOT EXISTS idx_course_units_order ON course_units(course_id, "order");

-- Recursos de curso
CREATE TABLE IF NOT EXISTS course_resources (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    course_id UUID REFERENCES learning_courses(id) ON DELETE CASCADE,
    unit_id UUID REFERENCES course_units(id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL,
    resource_type VARCHAR(50),
    url VARCHAR(500),
    file_path VARCHAR(500),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Índices para course_resources
CREATE INDEX IF NOT EXISTS idx_course_resources_course ON course_resources(course_id);
CREATE INDEX IF NOT EXISTS idx_course_resources_unit ON course_resources(unit_id);

-- Inscripciones a cursos
CREATE TABLE IF NOT EXISTS course_enrollments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    course_id UUID NOT NULL REFERENCES learning_courses(id) ON DELETE CASCADE,
    enrolled_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    completed_at TIMESTAMP WITH TIME ZONE,
    progress_percentage NUMERIC(5,2) DEFAULT 0.00,
    last_accessed TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, course_id)
);

-- Índices para course_enrollments
CREATE INDEX IF NOT EXISTS idx_course_enrollments_user ON course_enrollments(user_id);
CREATE INDEX IF NOT EXISTS idx_course_enrollments_course ON course_enrollments(course_id);

-- Progreso de usuario en cursos
CREATE TABLE IF NOT EXISTS user_course_progress (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    course_id UUID NOT NULL REFERENCES learning_courses(id) ON DELETE CASCADE,
    completed_units JSONB DEFAULT '[]'::jsonb,
    current_unit_id UUID,
    progress_percentage NUMERIC(5,2) DEFAULT 0.00,
    last_accessed TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    started_at TIMESTAMP WITH TIME ZONE,
    completed_at TIMESTAMP WITH TIME ZONE,
    UNIQUE(user_id, course_id)
);

-- Índices para user_course_progress
CREATE INDEX IF NOT EXISTS idx_user_course_progress_user ON user_course_progress(user_id);
CREATE INDEX IF NOT EXISTS idx_user_course_progress_course ON user_course_progress(course_id);

-- Progreso de usuario en unidades
CREATE TABLE IF NOT EXISTS user_unit_progress (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    unit_id UUID NOT NULL REFERENCES course_units(id) ON DELETE CASCADE,
    completed BOOLEAN DEFAULT false,
    completed_at TIMESTAMP WITH TIME ZONE,
    time_spent_minutes INTEGER DEFAULT 0,
    UNIQUE(user_id, unit_id)
);

-- Índices para user_unit_progress
CREATE INDEX IF NOT EXISTS idx_user_unit_progress_user ON user_unit_progress(user_id);
CREATE INDEX IF NOT EXISTS idx_user_unit_progress_unit ON user_unit_progress(unit_id);

-- ====================================
-- 4. PROYECTOS DE USUARIOS
-- ====================================

CREATE TABLE IF NOT EXISTS user_projects (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    status VARCHAR(50) DEFAULT 'active',
    repository_url VARCHAR(500),
    demo_url VARCHAR(500),
    technologies JSONB DEFAULT '[]'::jsonb,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Índices para user_projects
CREATE INDEX IF NOT EXISTS idx_user_projects_user ON user_projects(user_id);
CREATE INDEX IF NOT EXISTS idx_user_projects_status ON user_projects(status);

-- ====================================
-- 5. SERVICIOS Y CONTACTO
-- ====================================

-- Servicios ofrecidos
CREATE TABLE IF NOT EXISTS services (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    description TEXT,
    icon_name VARCHAR(100),
    category VARCHAR(100),
    price_range VARCHAR(100),
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Índices para services
CREATE INDEX IF NOT EXISTS idx_services_category ON services(category);
CREATE INDEX IF NOT EXISTS idx_services_is_active ON services(is_active);

-- Mensajes de contacto
CREATE TABLE IF NOT EXISTS contact_messages (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL,
    subject VARCHAR(255),
    message TEXT NOT NULL,
    ip_address VARCHAR(45),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    read_at TIMESTAMP WITH TIME ZONE
);

-- Índices para contact_messages
CREATE INDEX IF NOT EXISTS idx_contact_messages_email ON contact_messages(email);
CREATE INDEX IF NOT EXISTS idx_contact_messages_created ON contact_messages(created_at DESC);

-- Solicitudes de consultoría
CREATE TABLE IF NOT EXISTS consultancy_requests (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL,
    phone VARCHAR(50),
    company VARCHAR(255),
    project_type VARCHAR(100),
    budget_range VARCHAR(100),
    timeline VARCHAR(100),
    description TEXT NOT NULL,
    ip_address VARCHAR(45),
    status VARCHAR(50) DEFAULT 'pending',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Índices para consultancy_requests
CREATE INDEX IF NOT EXISTS idx_consultancy_requests_email ON consultancy_requests(email);
CREATE INDEX IF NOT EXISTS idx_consultancy_requests_status ON consultancy_requests(status);
CREATE INDEX IF NOT EXISTS idx_consultancy_requests_created ON consultancy_requests(created_at DESC);

-- ====================================
-- 6. INSERTAR DATOS INICIALES
-- ====================================

-- Secciones del Campus (Dashboard, Cursos, Herramientas)
INSERT INTO campus_sections (id, title, description, icon_name, order_index, is_active) VALUES
    (uuid_generate_v4(), 'Dashboard', 'Panel principal con resumen de tu actividad y progreso', 'layout-dashboard', 1, true),
    (uuid_generate_v4(), 'Cursos', 'Accede a todos tus cursos activos y continúa tu aprendizaje', 'book-open', 2, true),
    (uuid_generate_v4(), 'Herramientas', 'Utiliza nuestras herramientas de desarrollo', 'tool', 3, true)
ON CONFLICT (id) DO NOTHING;

-- Curso 1: Fundamentos de Desarrollo Web
INSERT INTO learning_courses (id, title, description, difficulty_level, duration_hours, thumbnail_url, content, is_published) VALUES
(
    uuid_generate_v4(),
    'Fundamentos de Desarrollo Web',
    'Aprende los conceptos básicos de HTML, CSS y JavaScript para crear tus primeras páginas web. Este curso está diseñado para principiantes sin experiencia previa en programación.',
    'principiante',
    40,
    '/assets/courses/web-fundamentals.jpg',
    '{"overview": "Curso completo de desarrollo web desde cero", "requirements": ["Computadora con navegador web", "Editor de texto"], "objectives": ["Crear páginas web con HTML5", "Estilizar con CSS3", "Programar con JavaScript básico", "Publicar tu primer sitio web"]}'::jsonb,
    true
)
ON CONFLICT (id) DO NOTHING;

-- Obtener el ID del curso anterior para las unidades
DO $$
DECLARE
    web_course_id UUID;
BEGIN
    SELECT id INTO web_course_id FROM learning_courses WHERE title = 'Fundamentos de Desarrollo Web' LIMIT 1;

    IF web_course_id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM course_units WHERE course_id = web_course_id) THEN
        INSERT INTO course_units (course_id, title, description, content, "order", duration_minutes) VALUES
        (web_course_id, 'Introducción al Desarrollo Web', 'Conceptos básicos, herramientas necesarias y configuración del entorno de desarrollo', 'Bienvenido al mundo del desarrollo web...', 1, 45),
        (web_course_id, 'HTML5: Estructura de Contenido', 'Aprende a crear la estructura de páginas web con HTML5 semántico', 'HTML es el lenguaje de marcado que estructura el contenido...', 2, 90),
        (web_course_id, 'CSS3: Diseño y Estilizado', 'Domina CSS para crear diseños atractivos y responsivos', 'CSS (Cascading Style Sheets) controla la presentación...', 3, 120),
        (web_course_id, 'JavaScript: Programación Básica', 'Fundamentos de programación con JavaScript', 'JavaScript añade interactividad a tus páginas web...', 4, 150),
        (web_course_id, 'Proyecto Final: Tu Primer Sitio Web', 'Aplica todo lo aprendido en un proyecto completo', 'Es hora de crear tu primer sitio web profesional...', 5, 180);

        INSERT INTO course_resources (course_id, title, resource_type, url) VALUES
        (web_course_id, 'Guía de referencia HTML', 'pdf', 'https://developer.mozilla.org/es/docs/Web/HTML'),
        (web_course_id, 'Cheat Sheet CSS', 'pdf', 'https://developer.mozilla.org/es/docs/Web/CSS'),
        (web_course_id, 'JavaScript para principiantes', 'video', 'https://www.youtube.com/watch?v=example');
    END IF;
END $$;

-- Curso 2: Python para Principiantes
INSERT INTO learning_courses (id, title, description, difficulty_level, duration_hours, thumbnail_url, content, is_published) VALUES
(
    uuid_generate_v4(),
    'Python para Principiantes',
    'Inicia tu viaje en la programación con Python, uno de los lenguajes más populares y versátiles. Aprende desde variables hasta programación orientada a objetos.',
    'principiante',
    35,
    '/assets/courses/python-basics.jpg',
    '{"overview": "Curso completo de Python desde cero", "requirements": ["Python 3.x instalado", "Editor de código"], "objectives": ["Entender la sintaxis de Python", "Trabajar con estructuras de datos", "Programación orientada a objetos", "Crear proyectos reales"]}'::jsonb,
    true
)
ON CONFLICT (id) DO NOTHING;

DO $$
DECLARE
    python_course_id UUID;
BEGIN
    SELECT id INTO python_course_id FROM learning_courses WHERE title = 'Python para Principiantes' LIMIT 1;

    IF python_course_id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM course_units WHERE course_id = python_course_id) THEN
        INSERT INTO course_units (course_id, title, description, content, "order", duration_minutes) VALUES
        (python_course_id, 'Introducción a Python', 'Historia, instalación y primer programa', '¡Bienvenido a Python! Comenzaremos instalando...', 1, 40),
        (python_course_id, 'Variables y Tipos de Datos', 'Aprende a trabajar con diferentes tipos de datos', 'En Python, las variables son contenedores...', 2, 60),
        (python_course_id, 'Estructuras de Control', 'If, elif, else, loops y más', 'Las estructuras de control permiten tomar decisiones...', 3, 90),
        (python_course_id, 'Funciones y Módulos', 'Organiza tu código de forma eficiente', 'Las funciones son bloques reutilizables de código...', 4, 80),
        (python_course_id, 'Programación Orientada a Objetos', 'Clases, objetos, herencia y más', 'POO es un paradigma fundamental en Python...', 5, 100),
        (python_course_id, 'Proyecto: Aplicación de Consola', 'Crea una aplicación completa en Python', 'Pondremos en práctica todo lo aprendido...', 6, 120);

        INSERT INTO course_resources (course_id, title, resource_type, url) VALUES
        (python_course_id, 'Documentación oficial de Python', 'link', 'https://docs.python.org/es/3/'),
        (python_course_id, 'Ejercicios de práctica', 'pdf', '/resources/python-exercises.pdf'),
        (python_course_id, 'Proyecto ejemplo completo', 'github', 'https://github.com/vexus/python-example-project');
    END IF;
END $$;

-- Curso 3: Git y GitHub
INSERT INTO learning_courses (id, title, description, difficulty_level, duration_hours, thumbnail_url, content, is_published) VALUES
(
    uuid_generate_v4(),
    'Git y GitHub: Control de Versiones',
    'Domina Git y GitHub para gestionar tus proyectos de forma profesional. Aprende a colaborar en equipo y mantén un historial de cambios de tu código.',
    'intermedio',
    20,
    '/assets/courses/git-github.jpg',
    '{"overview": "Control de versiones profesional con Git", "requirements": ["Git instalado", "Cuenta en GitHub"], "objectives": ["Usar Git en proyectos reales", "Colaborar con GitHub", "Gestionar ramas y conflictos", "Buenas prácticas de commits"]}'::jsonb,
    true
)
ON CONFLICT (id) DO NOTHING;

DO $$
DECLARE
    git_course_id UUID;
BEGIN
    SELECT id INTO git_course_id FROM learning_courses WHERE title = 'Git y GitHub: Control de Versiones' LIMIT 1;

    IF git_course_id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM course_units WHERE course_id = git_course_id) THEN
        INSERT INTO course_units (course_id, title, description, content, "order", duration_minutes) VALUES
        (git_course_id, 'Introducción a Git', 'Qué es Git y por qué es importante', 'Git es el sistema de control de versiones...', 1, 30),
        (git_course_id, 'Comandos Básicos de Git', 'Add, commit, push, pull y más', 'Los comandos fundamentales que usarás diariamente...', 2, 60),
        (git_course_id, 'Trabajando con Ramas', 'Branches, merge y resolución de conflictos', 'Las ramas permiten trabajar en features paralelas...', 3, 90),
        (git_course_id, 'GitHub: Colaboración en Equipo', 'Pull requests, issues y proyectos', 'GitHub es la plataforma de colaboración...', 4, 80),
        (git_course_id, 'Flujos de Trabajo Profesionales', 'Git Flow, GitHub Flow y buenas prácticas', 'Los equipos profesionales siguen metodologías...', 5, 60);
    END IF;
END $$;

-- Herramientas de Desarrollo
INSERT INTO campus_tools (id, name, description, icon_name, url, category, is_active, requires_authentication) VALUES
(uuid_generate_v4(), 'Editor de Código Online', 'Editor de código en línea con soporte para HTML, CSS, JavaScript y preview en tiempo real', 'code', '/tools/code-editor', 'desarrollo', true, false),
(uuid_generate_v4(), 'Terminal Interactiva', 'Terminal web para practicar comandos de Linux y Git', 'terminal', '/tools/terminal', 'desarrollo', true, true),
(uuid_generate_v4(), 'Playground Python', 'Ejecuta código Python directamente en el navegador', 'python', '/tools/python-playground', 'desarrollo', true, false),
(uuid_generate_v4(), 'SQL Playground', 'Practica consultas SQL con bases de datos de ejemplo', 'database', '/tools/sql-playground', 'desarrollo', true, true),
(uuid_generate_v4(), 'Generador de Paletas de Colores', 'Crea paletas de colores profesionales para tus proyectos', 'palette', '/tools/color-palette', 'diseño', true, false),
(uuid_generate_v4(), 'Generador de Gradientes CSS', 'Genera gradientes CSS personalizados con preview en vivo', 'gradient', '/tools/css-gradient', 'diseño', true, false),
(uuid_generate_v4(), 'RegEx Tester', 'Prueba y depura expresiones regulares', 'regex', '/tools/regex-tester', 'desarrollo', true, false),
(uuid_generate_v4(), 'API Tester', 'Prueba endpoints de APIs REST', 'api', '/tools/api-tester', 'desarrollo', true, true)
ON CONFLICT (id) DO NOTHING;

-- Servicios ofrecidos
INSERT INTO services (id, name, description, icon_name, category, price_range, is_active) VALUES
(uuid_generate_v4(), 'Desarrollo Web Personalizado', 'Creamos sitios web a medida para tu negocio o proyecto', 'globe', 'web', '$500 - $5000', true),
(uuid_generate_v4(), 'Aplicaciones Móviles', 'Desarrollamos apps nativas e híbridas para iOS y Android', 'smartphone', 'mobile', '$2000 - $15000', true),
(uuid_generate_v4(), 'Consultoría Tecnológica', 'Asesoramiento experto en tecnología y arquitectura de software', 'lightbulb', 'consultoria', '$100/hora', true),
(uuid_generate_v4(), 'Diseño UI/UX', 'Diseño de interfaces centradas en el usuario', 'palette', 'diseño', '$300 - $3000', true)
ON CONFLICT (id) DO NOTHING;

-- ====================================
-- 7. FUNCIONES Y TRIGGERS
-- ====================================

-- Función para actualizar updated_at automáticamente
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Triggers para updated_at
DROP TRIGGER IF EXISTS update_users_updated_at ON users;
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_learning_courses_updated_at ON learning_courses;
CREATE TRIGGER update_learning_courses_updated_at BEFORE UPDATE ON learning_courses
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_services_updated_at ON services;
CREATE TRIGGER update_services_updated_at BEFORE UPDATE ON services
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_user_projects_updated_at ON user_projects;
CREATE TRIGGER update_user_projects_updated_at BEFORE UPDATE ON user_projects
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_consultancy_requests_updated_at ON consultancy_requests;
CREATE TRIGGER update_consultancy_requests_updated_at BEFORE UPDATE ON consultancy_requests
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ====================================
-- 8. MENSAJE FINAL
-- ====================================

DO $$
DECLARE
    course_count INTEGER;
    tool_count INTEGER;
    section_count INTEGER;
    table_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO course_count FROM learning_courses;
    SELECT COUNT(*) INTO tool_count FROM campus_tools;
    SELECT COUNT(*) INTO section_count FROM campus_sections;
    SELECT COUNT(*) INTO table_count FROM information_schema.tables WHERE table_schema = 'public' AND table_type = 'BASE TABLE';

    RAISE NOTICE '';
    RAISE NOTICE '====================================';
    RAISE NOTICE '✅ Base de datos Vexus inicializada correctamente';
    RAISE NOTICE '====================================';
    RAISE NOTICE '📊 Total de tablas creadas: %', table_count;
    RAISE NOTICE '📚 Total de cursos: %', course_count;
    RAISE NOTICE '🛠️ Total de herramientas: %', tool_count;
    RAISE NOTICE '📋 Total de secciones: %', section_count;
    RAISE NOTICE '';
    RAISE NOTICE '🚀 La base de datos está lista para producción';
    RAISE NOTICE '';
END $$;
