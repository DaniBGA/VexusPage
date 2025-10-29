-- ====================================
-- VEXUS CAMPUS - DATOS INICIALES (VERSIÓN CORREGIDA)
-- ====================================
-- Script para insertar dashboard, cursos y herramientas del campus
-- Esta versión verifica y corrige la estructura antes de insertar datos

-- ====================================
-- 0. VERIFICAR Y CORREGIR ESTRUCTURA
-- ====================================

-- La tabla course_units ya tiene la columna 'order' (no necesita modificación)

-- Agregar columna order_index si no existe en campus_sections
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_name = 'campus_sections' AND column_name = 'order_index'
    ) THEN
        ALTER TABLE campus_sections ADD COLUMN order_index INTEGER;
        RAISE NOTICE '✓ Columna order_index agregada a campus_sections';
    END IF;
END $$;

-- ====================================
-- 1. SECCIONES DEL CAMPUS (DASHBOARD)
-- ====================================

-- Limpiar datos existentes (opcional - comentar si quieres mantener datos previos)
-- DELETE FROM campus_sections;

INSERT INTO campus_sections (id, title, description, icon_name, order_index, is_active) VALUES
    (uuid_generate_v4(), 'Mis Cursos', 'Accede a todos tus cursos activos y continúa tu aprendizaje', 'book-open', 1, true),
    (uuid_generate_v4(), 'Proyectos', 'Gestiona tus proyectos y portafolio de desarrollo', 'code', 2, true),
    (uuid_generate_v4(), 'Herramientas', 'Utiliza nuestras herramientas de desarrollo', 'tool', 3, true),
    (uuid_generate_v4(), 'Recursos', 'Documentación, guías y material de apoyo', 'book', 4, true),
    (uuid_generate_v4(), 'Comunidad', 'Conecta con otros estudiantes y mentores', 'users', 5, true)
ON CONFLICT (id) DO NOTHING;

-- ====================================
-- 2. CURSOS INICIALES
-- ====================================

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

    -- Verificar si ya existen unidades para este curso
    IF NOT EXISTS (SELECT 1 FROM course_units WHERE course_id = web_course_id) THEN
        -- Unidades del curso de Fundamentos Web
        INSERT INTO course_units (course_id, title, description, content, "order", duration_minutes) VALUES
        (web_course_id, 'Introducción al Desarrollo Web', 'Conceptos básicos, herramientas necesarias y configuración del entorno de desarrollo', 'Bienvenido al mundo del desarrollo web...', 1, 45),
        (web_course_id, 'HTML5: Estructura de Contenido', 'Aprende a crear la estructura de páginas web con HTML5 semántico', 'HTML es el lenguaje de marcado que estructura el contenido...', 2, 90),
        (web_course_id, 'CSS3: Diseño y Estilizado', 'Domina CSS para crear diseños atractivos y responsivos', 'CSS (Cascading Style Sheets) controla la presentación...', 3, 120),
        (web_course_id, 'JavaScript: Programación Básica', 'Fundamentos de programación con JavaScript', 'JavaScript añade interactividad a tus páginas web...', 4, 150),
        (web_course_id, 'Proyecto Final: Tu Primer Sitio Web', 'Aplica todo lo aprendido en un proyecto completo', 'Es hora de crear tu primer sitio web profesional...', 5, 180);

        -- Recursos del curso
        INSERT INTO course_resources (course_id, title, resource_type, url) VALUES
        (web_course_id, 'Guía de referencia HTML', 'pdf', 'https://developer.mozilla.org/es/docs/Web/HTML'),
        (web_course_id, 'Cheat Sheet CSS', 'pdf', 'https://developer.mozilla.org/es/docs/Web/CSS'),
        (web_course_id, 'JavaScript para principiantes', 'video', 'https://www.youtube.com/watch?v=example');

        RAISE NOTICE '✓ Curso "Fundamentos de Desarrollo Web" creado con unidades y recursos';
    ELSE
        RAISE NOTICE '⊘ Curso "Fundamentos de Desarrollo Web" ya existe, saltando...';
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

-- Unidades para el curso de Python
DO $$
DECLARE
    python_course_id UUID;
BEGIN
    SELECT id INTO python_course_id FROM learning_courses WHERE title = 'Python para Principiantes' LIMIT 1;

    IF NOT EXISTS (SELECT 1 FROM course_units WHERE course_id = python_course_id) THEN
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

        RAISE NOTICE '✓ Curso "Python para Principiantes" creado con unidades y recursos';
    ELSE
        RAISE NOTICE '⊘ Curso "Python para Principiantes" ya existe, saltando...';
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

    IF NOT EXISTS (SELECT 1 FROM course_units WHERE course_id = git_course_id) THEN
        INSERT INTO course_units (course_id, title, description, content, "order", duration_minutes) VALUES
        (git_course_id, 'Introducción a Git', 'Qué es Git y por qué es importante', 'Git es el sistema de control de versiones...', 1, 30),
        (git_course_id, 'Comandos Básicos de Git', 'Add, commit, push, pull y más', 'Los comandos fundamentales que usarás diariamente...', 2, 60),
        (git_course_id, 'Trabajando con Ramas', 'Branches, merge y resolución de conflictos', 'Las ramas permiten trabajar en features paralelas...', 3, 90),
        (git_course_id, 'GitHub: Colaboración en Equipo', 'Pull requests, issues y proyectos', 'GitHub es la plataforma de colaboración...', 4, 80),
        (git_course_id, 'Flujos de Trabajo Profesionales', 'Git Flow, GitHub Flow y buenas prácticas', 'Los equipos profesionales siguen metodologías...', 5, 60);

        RAISE NOTICE '✓ Curso "Git y GitHub" creado con unidades';
    ELSE
        RAISE NOTICE '⊘ Curso "Git y GitHub" ya existe, saltando...';
    END IF;
END $$;

-- Curso 4: Bases de Datos con PostgreSQL
INSERT INTO learning_courses (id, title, description, difficulty_level, duration_hours, thumbnail_url, content, is_published) VALUES
(
    uuid_generate_v4(),
    'Bases de Datos con PostgreSQL',
    'Aprende a diseñar, crear y gestionar bases de datos relacionales con PostgreSQL, uno de los sistemas de bases de datos más potentes del mercado.',
    'intermedio',
    30,
    '/assets/courses/postgresql.jpg',
    '{"overview": "Domina PostgreSQL desde cero", "requirements": ["PostgreSQL instalado", "Conocimientos básicos de SQL"], "objectives": ["Diseñar bases de datos eficientes", "Escribir consultas SQL complejas", "Optimizar rendimiento", "Gestionar usuarios y permisos"]}'::jsonb,
    true
)
ON CONFLICT (id) DO NOTHING;

DO $$
DECLARE
    db_course_id UUID;
BEGIN
    SELECT id INTO db_course_id FROM learning_courses WHERE title = 'Bases de Datos con PostgreSQL' LIMIT 1;

    IF NOT EXISTS (SELECT 1 FROM course_units WHERE course_id = db_course_id) THEN
        INSERT INTO course_units (course_id, title, description, content, "order", duration_minutes) VALUES
        (db_course_id, 'Introducción a Bases de Datos', 'Conceptos fundamentales y teoría relacional', 'Las bases de datos organizan información...', 1, 45),
        (db_course_id, 'SQL Básico', 'SELECT, INSERT, UPDATE, DELETE', 'El lenguaje SQL es la forma de comunicarnos...', 2, 90),
        (db_course_id, 'Diseño de Tablas y Relaciones', 'Normalización, claves primarias y foráneas', 'Un buen diseño es crucial para el éxito...', 3, 100),
        (db_course_id, 'Consultas Avanzadas', 'Joins, subconsultas y funciones', 'Las consultas complejas permiten extraer...', 4, 120),
        (db_course_id, 'Optimización y Performance', 'Índices, explain y mejores prácticas', 'Una base de datos rápida es fundamental...', 5, 90);

        RAISE NOTICE '✓ Curso "Bases de Datos con PostgreSQL" creado con unidades';
    ELSE
        RAISE NOTICE '⊘ Curso "Bases de Datos con PostgreSQL" ya existe, saltando...';
    END IF;
END $$;

-- Curso 5: React.js Moderno
INSERT INTO learning_courses (id, title, description, difficulty_level, duration_hours, thumbnail_url, content, is_published) VALUES
(
    uuid_generate_v4(),
    'React.js: Desarrollo de Aplicaciones Modernas',
    'Construye aplicaciones web interactivas y escalables con React, la biblioteca de JavaScript más popular. Aprende hooks, componentes y gestión de estado.',
    'avanzado',
    50,
    '/assets/courses/react-modern.jpg',
    '{"overview": "React desde cero hasta nivel avanzado", "requirements": ["JavaScript ES6+", "Node.js instalado", "Conocimientos de HTML/CSS"], "objectives": ["Crear componentes reutilizables", "Manejar estado con hooks", "Consumir APIs", "Desplegar aplicaciones React"]}'::jsonb,
    true
)
ON CONFLICT (id) DO NOTHING;

DO $$
DECLARE
    react_course_id UUID;
BEGIN
    SELECT id INTO react_course_id FROM learning_courses WHERE title = 'React.js: Desarrollo de Aplicaciones Modernas' LIMIT 1;

    IF NOT EXISTS (SELECT 1 FROM course_units WHERE course_id = react_course_id) THEN
        INSERT INTO course_units (course_id, title, description, content, "order", duration_minutes) VALUES
        (react_course_id, 'Fundamentos de React', 'JSX, componentes y props', 'React revolucionó el desarrollo web...', 1, 90),
        (react_course_id, 'React Hooks', 'useState, useEffect y hooks personalizados', 'Los hooks son la forma moderna de React...', 2, 120),
        (react_course_id, 'Gestión de Estado', 'Context API y Redux', 'Manejar el estado en aplicaciones grandes...', 3, 150),
        (react_course_id, 'Routing y Navegación', 'React Router y navegación SPA', 'Las aplicaciones de una sola página...', 4, 100),
        (react_course_id, 'Consumo de APIs', 'Fetch, axios y manejo de datos', 'Conectar con backends y APIs externas...', 5, 110),
        (react_course_id, 'Proyecto Final: Dashboard Completo', 'Aplicación real con todas las features', 'Crearemos un dashboard profesional...', 6, 240);

        RAISE NOTICE '✓ Curso "React.js" creado con unidades';
    ELSE
        RAISE NOTICE '⊘ Curso "React.js" ya existe, saltando...';
    END IF;
END $$;

-- ====================================
-- 3. HERRAMIENTAS DEL CAMPUS
-- ====================================

-- Herramientas de Desarrollo
INSERT INTO campus_tools (id, name, description, icon_name, url, category, is_active, requires_authentication) VALUES
(
    uuid_generate_v4(),
    'Editor de Código Online',
    'Editor de código en línea con soporte para HTML, CSS, JavaScript y preview en tiempo real',
    'code',
    '/tools/code-editor',
    'desarrollo',
    true,
    false
),
(
    uuid_generate_v4(),
    'Terminal Interactiva',
    'Terminal web para practicar comandos de Linux y Git',
    'terminal',
    '/tools/terminal',
    'desarrollo',
    true,
    true
),
(
    uuid_generate_v4(),
    'Playground Python',
    'Ejecuta código Python directamente en el navegador',
    'python',
    '/tools/python-playground',
    'desarrollo',
    true,
    false
),
(
    uuid_generate_v4(),
    'SQL Playground',
    'Practica consultas SQL con bases de datos de ejemplo',
    'database',
    '/tools/sql-playground',
    'desarrollo',
    true,
    true
)
ON CONFLICT (id) DO NOTHING;

-- Herramientas de Diseño
INSERT INTO campus_tools (id, name, description, icon_name, url, category, is_active, requires_authentication) VALUES
(
    uuid_generate_v4(),
    'Generador de Paletas de Colores',
    'Crea paletas de colores profesionales para tus proyectos',
    'palette',
    '/tools/color-palette',
    'diseño',
    true,
    false
),
(
    uuid_generate_v4(),
    'Generador de Gradientes CSS',
    'Genera gradientes CSS personalizados con preview en vivo',
    'gradient',
    '/tools/css-gradient',
    'diseño',
    true,
    false
),
(
    uuid_generate_v4(),
    'Optimizador de Imágenes',
    'Comprime y optimiza imágenes para web',
    'image',
    '/tools/image-optimizer',
    'diseño',
    true,
    true
)
ON CONFLICT (id) DO NOTHING;

-- Herramientas de Productividad
INSERT INTO campus_tools (id, name, description, icon_name, url, category, is_active, requires_authentication) VALUES
(
    uuid_generate_v4(),
    'Pomodoro Timer',
    'Técnica Pomodoro para mejorar tu productividad',
    'clock',
    '/tools/pomodoro',
    'productividad',
    true,
    false
),
(
    uuid_generate_v4(),
    'Conversor de Formatos',
    'Convierte entre JSON, YAML, XML y otros formatos',
    'convert',
    '/tools/format-converter',
    'utilidades',
    true,
    false
),
(
    uuid_generate_v4(),
    'Generador de README',
    'Crea archivos README profesionales para tus proyectos',
    'file-text',
    '/tools/readme-generator',
    'utilidades',
    true,
    true
),
(
    uuid_generate_v4(),
    'RegEx Tester',
    'Prueba y depura expresiones regulares',
    'regex',
    '/tools/regex-tester',
    'desarrollo',
    true,
    false
),
(
    uuid_generate_v4(),
    'API Tester',
    'Prueba endpoints de APIs REST',
    'api',
    '/tools/api-tester',
    'desarrollo',
    true,
    true
)
ON CONFLICT (id) DO NOTHING;

-- Herramientas de Aprendizaje
INSERT INTO campus_tools (id, name, description, icon_name, url, category, is_active, requires_authentication) VALUES
(
    uuid_generate_v4(),
    'Flashcards de Programación',
    'Repasa conceptos clave con tarjetas de estudio',
    'cards',
    '/tools/flashcards',
    'aprendizaje',
    true,
    true
),
(
    uuid_generate_v4(),
    'Quiz Interactivo',
    'Pon a prueba tus conocimientos con quizzes',
    'quiz',
    '/tools/quiz',
    'aprendizaje',
    true,
    true
),
(
    uuid_generate_v4(),
    'Biblioteca de Recursos',
    'Acceso a documentación, tutoriales y guías',
    'library',
    '/tools/library',
    'aprendizaje',
    true,
    false
)
ON CONFLICT (id) DO NOTHING;

-- ====================================
-- 4. DATOS DE EJEMPLO ADICIONALES
-- ====================================

-- Insertar algunos servicios de ejemplo
INSERT INTO services (id, name, description, icon_name, category, price_range, is_active) VALUES
(
    uuid_generate_v4(),
    'Desarrollo Web Personalizado',
    'Creamos sitios web a medida para tu negocio o proyecto',
    'globe',
    'web',
    '$500 - $5000',
    true
),
(
    uuid_generate_v4(),
    'Aplicaciones Móviles',
    'Desarrollamos apps nativas e híbridas para iOS y Android',
    'smartphone',
    'mobile',
    '$2000 - $15000',
    true
),
(
    uuid_generate_v4(),
    'Consultoría Tecnológica',
    'Asesoramiento experto en tecnología y arquitectura de software',
    'lightbulb',
    'consultoria',
    '$100/hora',
    true
),
(
    uuid_generate_v4(),
    'Diseño UI/UX',
    'Diseño de interfaces centradas en el usuario',
    'palette',
    'diseño',
    '$300 - $3000',
    true
)
ON CONFLICT (id) DO NOTHING;

-- ====================================
-- MENSAJE FINAL
-- ====================================

DO $$
DECLARE
    course_count INTEGER;
    tool_count INTEGER;
    section_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO course_count FROM learning_courses;
    SELECT COUNT(*) INTO tool_count FROM campus_tools;
    SELECT COUNT(*) INTO section_count FROM campus_sections;

    RAISE NOTICE '';
    RAISE NOTICE '====================================';
    RAISE NOTICE '✅ Datos del Campus Vexus insertados correctamente';
    RAISE NOTICE '====================================';
    RAISE NOTICE '📚 Total de cursos: %', course_count;
    RAISE NOTICE '🛠️ Total de herramientas: %', tool_count;
    RAISE NOTICE '📊 Total de secciones: %', section_count;
    RAISE NOTICE '';
    RAISE NOTICE 'Para explorar los datos:';
    RAISE NOTICE '  SELECT title, difficulty_level FROM learning_courses;';
    RAISE NOTICE '  SELECT name, category FROM campus_tools;';
    RAISE NOTICE '  SELECT title FROM campus_sections ORDER BY order_index;';
    RAISE NOTICE '';
END $$;
