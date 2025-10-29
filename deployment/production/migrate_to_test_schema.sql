-- Backup usuarios existentes
CREATE TEMP TABLE users_backup AS 
SELECT id, email, password_hash, name, 
       is_active, email_verified, created_at, updated_at
FROM users;

-- Borrar esquema actual (en orden para evitar errores de FK)
DROP TABLE IF EXISTS user_unit_progress CASCADE;
DROP TABLE IF EXISTS course_enrollments CASCADE;
DROP TABLE IF EXISTS course_resources CASCADE;
DROP TABLE IF EXISTS course_units CASCADE;
DROP TABLE IF EXISTS user_course_progress CASCADE;
DROP TABLE IF EXISTS user_projects CASCADE;
DROP TABLE IF EXISTS user_sessions CASCADE;
DROP TABLE IF EXISTS user_tool_access CASCADE;
DROP TABLE IF EXISTS users CASCADE;
DROP TABLE IF EXISTS campus_sections CASCADE;
DROP TABLE IF EXISTS campus_tools CASCADE;
DROP TABLE IF EXISTS consultancy_requests CASCADE;
DROP TABLE IF EXISTS contact_messages CASCADE;
DROP TABLE IF EXISTS learning_courses CASCADE;
DROP TABLE IF EXISTS services CASCADE;

-- Crear extensiones necesarias
DO $$ 
BEGIN 
    CREATE EXTENSION IF NOT EXISTS pgcrypto SCHEMA public;
    CREATE EXTENSION IF NOT EXISTS "uuid-ossp" SCHEMA public;
EXCEPTION 
    WHEN OTHERS THEN 
        -- If there's an error, try creating without specifying schema
        CREATE EXTENSION IF NOT EXISTS pgcrypto;
        CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
END $$;

-- Función para updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Recrear tablas con el esquema de testing

CREATE TABLE public.campus_sections (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name character varying(255) NOT NULL,
    description text,
    section_type character varying(100) NOT NULL,
    icon character varying(100),
    is_active boolean DEFAULT true,
    requires_login boolean DEFAULT true,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE public.campus_tools (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name character varying(255) NOT NULL,
    description text,
    tool_type character varying(100) NOT NULL,
    url character varying(500),
    icon character varying(100),
    is_active boolean DEFAULT true,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE public.contact_messages (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name character varying(255) NOT NULL,
    email character varying(255) NOT NULL,
    subject character varying(255),
    message text NOT NULL,
    is_read boolean DEFAULT false,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    responded_at timestamp with time zone,
    ip_address inet
);

CREATE TABLE public.learning_courses (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    title character varying(255) NOT NULL,
    description text,
    content text,
    difficulty_level character varying(50) DEFAULT 'beginner'::character varying,
    duration_hours integer DEFAULT 0,
    is_published boolean DEFAULT false,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE public.services (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name character varying(255) NOT NULL,
    description text,
    category character varying(100) NOT NULL,
    icon character varying(100),
    is_active boolean DEFAULT true,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE public.users (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name character varying(255) NOT NULL,
    email character varying(255) NOT NULL,
    hashed_password character varying(255) NOT NULL,
    avatar character varying(255) DEFAULT '👤'::character varying,
    is_active boolean DEFAULT true,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    last_login timestamp with time zone,
    email_verified boolean DEFAULT false,
    role character varying(50) DEFAULT 'user'::character varying,
    verification_token character varying(255),
    verification_token_expires timestamp with time zone
);

CREATE TABLE public.user_sessions (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    token character varying(500) NOT NULL,
    expires_at timestamp with time zone NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    ip_address inet,
    user_agent text
);

CREATE TABLE public.course_units (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    course_id uuid NOT NULL,
    title character varying(255) NOT NULL,
    description text,
    content text NOT NULL,
    "order" integer DEFAULT 0,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE public.course_resources (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    unit_id uuid NOT NULL,
    title character varying(255) NOT NULL,
    resource_type character varying(50) NOT NULL,
    url text NOT NULL,
    description text,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT course_resources_resource_type_check CHECK (((resource_type)::text = ANY ((ARRAY['document'::character varying, 'video'::character varying, 'link'::character varying])::text[])))
);

CREATE TABLE public.course_enrollments (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    course_id uuid NOT NULL,
    enrolled_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    progress_percentage integer DEFAULT 0,
    last_accessed timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    completed_at timestamp without time zone
);

CREATE TABLE public.user_unit_progress (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    unit_id uuid NOT NULL,
    completed boolean DEFAULT false,
    completed_at timestamp without time zone
);

-- Primary Keys
ALTER TABLE ONLY public.campus_sections ADD CONSTRAINT campus_sections_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.campus_tools ADD CONSTRAINT campus_tools_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.contact_messages ADD CONSTRAINT contact_messages_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.learning_courses ADD CONSTRAINT learning_courses_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.services ADD CONSTRAINT services_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.users ADD CONSTRAINT users_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.users ADD CONSTRAINT users_email_key UNIQUE (email);
ALTER TABLE ONLY public.user_sessions ADD CONSTRAINT user_sessions_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.course_units ADD CONSTRAINT course_units_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.course_resources ADD CONSTRAINT course_resources_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.course_enrollments ADD CONSTRAINT course_enrollments_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.course_enrollments ADD CONSTRAINT course_enrollments_user_id_course_id_key UNIQUE (user_id, course_id);
ALTER TABLE ONLY public.user_unit_progress ADD CONSTRAINT user_unit_progress_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.user_unit_progress ADD CONSTRAINT user_unit_progress_user_id_unit_id_key UNIQUE (user_id, unit_id);

-- Foreign Keys
ALTER TABLE ONLY public.user_sessions
    ADD CONSTRAINT user_sessions_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;

ALTER TABLE ONLY public.course_units
    ADD CONSTRAINT course_units_course_id_fkey FOREIGN KEY (course_id) REFERENCES public.learning_courses(id) ON DELETE CASCADE;

ALTER TABLE ONLY public.course_resources
    ADD CONSTRAINT course_resources_unit_id_fkey FOREIGN KEY (unit_id) REFERENCES public.course_units(id) ON DELETE CASCADE;

ALTER TABLE ONLY public.course_enrollments
    ADD CONSTRAINT course_enrollments_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;

ALTER TABLE ONLY public.course_enrollments
    ADD CONSTRAINT course_enrollments_course_id_fkey FOREIGN KEY (course_id) REFERENCES public.learning_courses(id) ON DELETE CASCADE;

ALTER TABLE ONLY public.user_unit_progress
    ADD CONSTRAINT user_unit_progress_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;

ALTER TABLE ONLY public.user_unit_progress
    ADD CONSTRAINT user_unit_progress_unit_id_fkey FOREIGN KEY (unit_id) REFERENCES public.course_units(id) ON DELETE CASCADE;

-- Índices
CREATE INDEX idx_contact_messages_created_at ON public.contact_messages(created_at);
CREATE INDEX idx_contact_messages_is_read ON public.contact_messages(is_read);
CREATE INDEX idx_users_created_at ON public.users(created_at);
CREATE INDEX idx_users_email ON public.users(email);
CREATE INDEX idx_user_sessions_expires_at ON public.user_sessions(expires_at);
CREATE INDEX idx_user_sessions_token ON public.user_sessions(token);
CREATE INDEX idx_user_sessions_user_id ON public.user_sessions(user_id);
CREATE INDEX idx_course_units_course_id ON public.course_units(course_id);
CREATE INDEX idx_course_units_order ON public.course_units("order");
CREATE INDEX idx_course_resources_unit_id ON public.course_resources(unit_id);
CREATE INDEX idx_course_enrollments_user_id ON public.course_enrollments(user_id);
CREATE INDEX idx_course_enrollments_course_id ON public.course_enrollments(course_id);
CREATE INDEX idx_user_unit_progress_user_id ON public.user_unit_progress(user_id);
CREATE INDEX idx_user_unit_progress_unit_id ON public.user_unit_progress(unit_id);

-- Triggers
CREATE TRIGGER update_campus_sections_updated_at BEFORE UPDATE ON public.campus_sections FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();
CREATE TRIGGER update_campus_tools_updated_at BEFORE UPDATE ON public.campus_tools FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();
CREATE TRIGGER update_learning_courses_updated_at BEFORE UPDATE ON public.learning_courses FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();
CREATE TRIGGER update_services_updated_at BEFORE UPDATE ON public.services FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON public.users FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

-- Restaurar usuarios desde el backup
INSERT INTO users (id, name, email, hashed_password, is_active, email_verified, created_at, updated_at)
SELECT id, name, email, password_hash, is_active, email_verified, created_at, updated_at
FROM users_backup;

-- Limpiar tabla temporal
DROP TABLE users_backup;

-- Insertar datos iniciales de ejemplo (opcional, comentado por seguridad)
/*
INSERT INTO learning_courses (title, description, content, difficulty_level, duration_hours, is_published) VALUES
('JavaScript Avanzado', 'Domina JavaScript y sus frameworks modernos', 'Curso avanzado de JavaScript, ES6+, React y Node.js', 'advanced', 40, true),
('UX/UI Design', 'Principios de experiencia de usuario e interfaz', 'Diseño centrado en el usuario, prototipado y testing', 'intermediate', 30, true),
('Fundamentos de Diseño Web', 'Aprende los conceptos básicos del diseño web moderno', 'Curso completo sobre HTML, CSS y principios de diseño', 'beginner', 20, true);
*/