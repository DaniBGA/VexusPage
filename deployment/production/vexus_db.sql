-- WARNING: This schema is for context only and is not meant to be run.
-- Table order and constraints may not be valid for execution.

CREATE TABLE public.campus_sections (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  title character varying NOT NULL,
  description text,
  icon_name character varying,
  order_index integer NOT NULL,
  is_active boolean DEFAULT true,
  created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT campus_sections_pkey PRIMARY KEY (id)
);
CREATE TABLE public.campus_tools (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  name character varying NOT NULL,
  description text,
  icon_name character varying,
  url character varying,
  category character varying,
  is_active boolean DEFAULT true,
  requires_authentication boolean DEFAULT false,
  created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT campus_tools_pkey PRIMARY KEY (id)
);
CREATE TABLE public.consultancy_requests (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  name character varying NOT NULL,
  email character varying NOT NULL,
  phone character varying,
  company character varying,
  project_type character varying,
  budget_range character varying,
  timeline character varying,
  description text NOT NULL,
  ip_address character varying,
  status character varying DEFAULT 'pending'::character varying,
  created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
  updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT consultancy_requests_pkey PRIMARY KEY (id)
);
CREATE TABLE public.contact_messages (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  name character varying NOT NULL,
  email character varying NOT NULL,
  subject character varying,
  message text NOT NULL,
  ip_address character varying,
  created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
  read_at timestamp with time zone,
  CONSTRAINT contact_messages_pkey PRIMARY KEY (id)
);
CREATE TABLE public.course_enrollments (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  user_id uuid,
  course_id uuid,
  enrolled_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
  completed_at timestamp with time zone,
  progress_percentage numeric DEFAULT 0.00,
  last_accessed timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT course_enrollments_pkey PRIMARY KEY (id),
  CONSTRAINT course_enrollments_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id),
  CONSTRAINT course_enrollments_course_id_fkey FOREIGN KEY (course_id) REFERENCES public.learning_courses(id)
);
CREATE TABLE public.course_resources (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  course_id uuid,
  title character varying NOT NULL,
  resource_type character varying,
  url character varying,
  file_path character varying,
  created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
  unit_id uuid,
  CONSTRAINT course_resources_pkey PRIMARY KEY (id),
  CONSTRAINT course_resources_course_id_fkey FOREIGN KEY (course_id) REFERENCES public.learning_courses(id),
  CONSTRAINT course_resources_unit_id_fkey FOREIGN KEY (unit_id) REFERENCES public.course_units(id)
);
CREATE TABLE public.course_units (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  course_id uuid,
  title character varying NOT NULL,
  description text,
  content text,
  order integer NOT NULL,
  duration_minutes integer,
  created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT course_units_pkey PRIMARY KEY (id),
  CONSTRAINT course_units_course_id_fkey FOREIGN KEY (course_id) REFERENCES public.learning_courses(id)
);
CREATE TABLE public.learning_courses (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  title character varying NOT NULL,
  description text,
  difficulty_level character varying,
  duration_hours integer,
  thumbnail_url character varying,
  content jsonb,
  is_published boolean DEFAULT false,
  created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
  updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT learning_courses_pkey PRIMARY KEY (id)
);
CREATE TABLE public.services (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  name character varying NOT NULL,
  description text,
  icon_name character varying,
  category character varying,
  price_range character varying,
  is_active boolean DEFAULT true,
  created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
  updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT services_pkey PRIMARY KEY (id)
);
CREATE TABLE public.user_course_progress (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  user_id uuid,
  course_id uuid,
  completed_units jsonb DEFAULT '[]'::jsonb,
  current_unit_id uuid,
  progress_percentage numeric DEFAULT 0.00,
  last_accessed timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
  started_at timestamp with time zone,
  completed_at timestamp with time zone,
  CONSTRAINT user_course_progress_pkey PRIMARY KEY (id),
  CONSTRAINT user_course_progress_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id),
  CONSTRAINT user_course_progress_course_id_fkey FOREIGN KEY (course_id) REFERENCES public.learning_courses(id)
);
CREATE TABLE public.user_projects (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  user_id uuid,
  name character varying NOT NULL,
  description text,
  status character varying DEFAULT 'active'::character varying,
  repository_url character varying,
  demo_url character varying,
  technologies jsonb DEFAULT '[]'::jsonb,
  created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
  updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT user_projects_pkey PRIMARY KEY (id),
  CONSTRAINT user_projects_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id)
);
CREATE TABLE public.user_sessions (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  user_id uuid,
  session_token character varying NOT NULL UNIQUE,
  expires_at timestamp with time zone NOT NULL,
  created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
  ip_address character varying,
  user_agent text,
  CONSTRAINT user_sessions_pkey PRIMARY KEY (id),
  CONSTRAINT user_sessions_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id)
);
CREATE TABLE public.user_tool_access (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  user_id uuid,
  tool_id uuid,
  granted_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
  expires_at timestamp with time zone,
  CONSTRAINT user_tool_access_pkey PRIMARY KEY (id),
  CONSTRAINT user_tool_access_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id),
  CONSTRAINT user_tool_access_tool_id_fkey FOREIGN KEY (tool_id) REFERENCES public.campus_tools(id)
);
CREATE TABLE public.user_unit_progress (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  user_id uuid,
  unit_id uuid,
  completed boolean DEFAULT false,
  completed_at timestamp with time zone,
  time_spent_minutes integer DEFAULT 0,
  CONSTRAINT user_unit_progress_pkey PRIMARY KEY (id),
  CONSTRAINT user_unit_progress_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id),
  CONSTRAINT user_unit_progress_unit_id_fkey FOREIGN KEY (unit_id) REFERENCES public.course_units(id)
);
CREATE TABLE public.users (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  email character varying NOT NULL UNIQUE,
  hashed_password character varying NOT NULL,
  full_name character varying NOT NULL,
  is_active boolean DEFAULT false,
  is_verified boolean DEFAULT false,
  verification_token character varying,
  verification_token_expires timestamp with time zone,
  created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
  updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT users_pkey PRIMARY KEY (id)
);