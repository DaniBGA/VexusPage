-- VEXUS - ESQUEMA DE BASE DE DATOS PARA NEATECH
-- Database: grupovex_db
-- Este archivo está optimizado para ejecutarse en phpPgAdmin de Neatech

-- TABLA: users
CREATE TABLE IF NOT EXISTS users (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name varchar(255) NOT NULL,
  email varchar(255) NOT NULL UNIQUE,
  hashed_password varchar(255) NOT NULL,
  avatar varchar(50) DEFAULT '👤',
  role varchar(50) DEFAULT 'user',
  is_active boolean DEFAULT true,
  email_verified boolean DEFAULT false,
  verification_token varchar(255),
  verification_token_expires timestamptz,
  last_login timestamptz,
  created_at timestamptz DEFAULT CURRENT_TIMESTAMP,
  updated_at timestamptz DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_users_verification_token ON users(verification_token) WHERE verification_token IS NOT NULL;

-- TABLA: user_sessions
CREATE TABLE IF NOT EXISTS user_sessions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  token varchar(500) NOT NULL UNIQUE,
  expires_at timestamptz NOT NULL,
  ip_address inet,
  user_agent text,
  created_at timestamptz DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_user_sessions_user_id ON user_sessions(user_id);
CREATE INDEX IF NOT EXISTS idx_user_sessions_token ON user_sessions(token);
CREATE INDEX IF NOT EXISTS idx_user_sessions_expires_at ON user_sessions(expires_at);

-- TABLA: learning_courses
CREATE TABLE IF NOT EXISTS learning_courses (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  title varchar(255) NOT NULL,
  description text,
  content text,
  difficulty_level varchar(50) DEFAULT 'beginner' CHECK (difficulty_level IN ('beginner', 'intermediate', 'advanced')),
  duration_hours integer DEFAULT 0 CHECK (duration_hours >= 0),
  is_published boolean DEFAULT false,
  created_at timestamptz DEFAULT CURRENT_TIMESTAMP,
  updated_at timestamptz DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_learning_courses_is_published ON learning_courses(is_published);
CREATE INDEX IF NOT EXISTS idx_learning_courses_difficulty_level ON learning_courses(difficulty_level);

-- TABLA: course_units
CREATE TABLE IF NOT EXISTS course_units (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  course_id uuid NOT NULL REFERENCES learning_courses(id) ON DELETE CASCADE,
  title varchar(255) NOT NULL,
  description text,
  content text NOT NULL,
  "order" integer DEFAULT 0 CHECK ("order" >= 0),
  created_at timestamptz DEFAULT CURRENT_TIMESTAMP,
  updated_at timestamptz DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_course_units_course_id ON course_units(course_id);
CREATE INDEX IF NOT EXISTS idx_course_units_order ON course_units(course_id, "order");

-- TABLA: course_resources
CREATE TABLE IF NOT EXISTS course_resources (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  unit_id uuid NOT NULL REFERENCES course_units(id) ON DELETE CASCADE,
  title varchar(255) NOT NULL,
  resource_type varchar(50) NOT NULL CHECK (resource_type IN ('document', 'video', 'link')),
  url text NOT NULL,
  description text,
  created_at timestamptz DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_course_resources_unit_id ON course_resources(unit_id);
CREATE INDEX IF NOT EXISTS idx_course_resources_type ON course_resources(resource_type);

-- TABLA: course_enrollments
CREATE TABLE IF NOT EXISTS course_enrollments (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  course_id uuid NOT NULL REFERENCES learning_courses(id) ON DELETE CASCADE,
  progress_percentage integer DEFAULT 0 CHECK (progress_percentage >= 0 AND progress_percentage <= 100),
  enrolled_at timestamptz DEFAULT CURRENT_TIMESTAMP,
  last_accessed timestamptz DEFAULT CURRENT_TIMESTAMP,
  completed_at timestamptz,
  UNIQUE(user_id, course_id)
);

CREATE INDEX IF NOT EXISTS idx_course_enrollments_user_id ON course_enrollments(user_id);
CREATE INDEX IF NOT EXISTS idx_course_enrollments_course_id ON course_enrollments(course_id);
CREATE INDEX IF NOT EXISTS idx_course_enrollments_completed ON course_enrollments(completed_at) WHERE completed_at IS NOT NULL;

-- TABLA: user_unit_progress
CREATE TABLE IF NOT EXISTS user_unit_progress (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  unit_id uuid NOT NULL REFERENCES course_units(id) ON DELETE CASCADE,
  completed boolean DEFAULT false,
  completed_at timestamptz,
  UNIQUE(user_id, unit_id)
);

CREATE INDEX IF NOT EXISTS idx_user_unit_progress_user_id ON user_unit_progress(user_id);
CREATE INDEX IF NOT EXISTS idx_user_unit_progress_unit_id ON user_unit_progress(unit_id);
CREATE INDEX IF NOT EXISTS idx_user_unit_progress_completed ON user_unit_progress(completed) WHERE completed = true;

-- TABLA: campus_sections
CREATE TABLE IF NOT EXISTS campus_sections (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name varchar(255) NOT NULL,
  description text,
  section_type varchar(100) NOT NULL,
  icon varchar(50),
  is_active boolean DEFAULT true,
  requires_login boolean DEFAULT true,
  created_at timestamptz DEFAULT CURRENT_TIMESTAMP,
  updated_at timestamptz DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_campus_sections_is_active ON campus_sections(is_active);
CREATE INDEX IF NOT EXISTS idx_campus_sections_type ON campus_sections(section_type);

-- TABLA: campus_tools
CREATE TABLE IF NOT EXISTS campus_tools (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name varchar(255) NOT NULL,
  description text,
  tool_type varchar(100) NOT NULL,
  url varchar(500),
  icon varchar(50),
  is_active boolean DEFAULT true,
  created_at timestamptz DEFAULT CURRENT_TIMESTAMP,
  updated_at timestamptz DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_campus_tools_is_active ON campus_tools(is_active);
CREATE INDEX IF NOT EXISTS idx_campus_tools_type ON campus_tools(tool_type);

-- TABLA: services
CREATE TABLE IF NOT EXISTS services (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name varchar(255) NOT NULL,
  description text,
  category varchar(100) NOT NULL,
  icon varchar(50),
  is_active boolean DEFAULT true,
  created_at timestamptz DEFAULT CURRENT_TIMESTAMP,
  updated_at timestamptz DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_services_is_active ON services(is_active);
CREATE INDEX IF NOT EXISTS idx_services_category ON services(category);

-- TABLA: contact_messages
CREATE TABLE IF NOT EXISTS contact_messages (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name varchar(255) NOT NULL,
  email varchar(255) NOT NULL,
  subject varchar(255),
  message text NOT NULL,
  is_read boolean DEFAULT false,
  ip_address inet,
  created_at timestamptz DEFAULT CURRENT_TIMESTAMP,
  responded_at timestamptz
);

CREATE INDEX IF NOT EXISTS idx_contact_messages_is_read ON contact_messages(is_read);
CREATE INDEX IF NOT EXISTS idx_contact_messages_created_at ON contact_messages(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_contact_messages_email ON contact_messages(email);

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

DROP TRIGGER IF EXISTS update_course_units_updated_at ON course_units;
CREATE TRIGGER update_course_units_updated_at BEFORE UPDATE ON course_units
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_campus_sections_updated_at ON campus_sections;
CREATE TRIGGER update_campus_sections_updated_at BEFORE UPDATE ON campus_sections
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_campus_tools_updated_at ON campus_tools;
CREATE TRIGGER update_campus_tools_updated_at BEFORE UPDATE ON campus_tools
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_services_updated_at ON services;
CREATE TRIGGER update_services_updated_at BEFORE UPDATE ON services
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
