--
-- PostgreSQL database dump
--

-- Dumped from database version 17.5
-- Dumped by pg_dump version 17.5

-- Started on 2025-10-05 19:03:55

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 3 (class 3079 OID 16463)
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;


--
-- TOC entry 5088 (class 0 OID 0)
-- Dependencies: 3
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


--
-- TOC entry 2 (class 3079 OID 16452)
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA public;


--
-- TOC entry 5089 (class 0 OID 0)
-- Dependencies: 2
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


--
-- TOC entry 277 (class 1255 OID 16660)
-- Name: update_updated_at_column(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.update_updated_at_column() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.update_updated_at_column() OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 222 (class 1259 OID 16540)
-- Name: campus_sections; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.campus_sections (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    name character varying(255) NOT NULL,
    description text,
    section_type character varying(100) NOT NULL,
    icon character varying(100),
    is_active boolean DEFAULT true,
    requires_login boolean DEFAULT true,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.campus_sections OWNER TO postgres;

--
-- TOC entry 5090 (class 0 OID 0)
-- Dependencies: 222
-- Name: TABLE campus_sections; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.campus_sections IS 'Secciones disponibles en el campus virtual';


--
-- TOC entry 225 (class 1259 OID 16587)
-- Name: campus_tools; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.campus_tools (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    name character varying(255) NOT NULL,
    description text,
    tool_type character varying(100) NOT NULL,
    url character varying(500),
    icon character varying(100),
    is_active boolean DEFAULT true,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.campus_tools OWNER TO postgres;

--
-- TOC entry 5091 (class 0 OID 0)
-- Dependencies: 225
-- Name: TABLE campus_tools; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.campus_tools IS 'Herramientas disponibles en el campus';


--
-- TOC entry 228 (class 1259 OID 16639)
-- Name: contact_messages; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.contact_messages (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    name character varying(255) NOT NULL,
    email character varying(255) NOT NULL,
    subject character varying(255),
    message text NOT NULL,
    is_read boolean DEFAULT false,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    responded_at timestamp with time zone,
    ip_address inet
);


ALTER TABLE public.contact_messages OWNER TO postgres;

--
-- TOC entry 5092 (class 0 OID 0)
-- Dependencies: 228
-- Name: TABLE contact_messages; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.contact_messages IS 'Mensajes de contacto recibidos';


--
-- TOC entry 223 (class 1259 OID 16552)
-- Name: learning_courses; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.learning_courses (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    title character varying(255) NOT NULL,
    description text,
    content text,
    difficulty_level character varying(50) DEFAULT 'beginner'::character varying,
    duration_hours integer DEFAULT 0,
    is_published boolean DEFAULT false,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.learning_courses OWNER TO postgres;

--
-- TOC entry 5093 (class 0 OID 0)
-- Dependencies: 223
-- Name: TABLE learning_courses; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.learning_courses IS 'Cursos de aprendizaje disponibles';


--
-- TOC entry 221 (class 1259 OID 16529)
-- Name: services; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.services (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    name character varying(255) NOT NULL,
    description text,
    category character varying(100) NOT NULL,
    icon character varying(100),
    is_active boolean DEFAULT true,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.services OWNER TO postgres;

--
-- TOC entry 5094 (class 0 OID 0)
-- Dependencies: 221
-- Name: TABLE services; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.services IS 'Servicios ofrecidos por Vexus';


--
-- TOC entry 224 (class 1259 OID 16565)
-- Name: user_course_progress; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.user_course_progress (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    user_id uuid NOT NULL,
    course_id uuid NOT NULL,
    progress_percentage integer DEFAULT 0,
    completed_at timestamp with time zone,
    started_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    last_accessed timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT user_course_progress_progress_percentage_check CHECK (((progress_percentage >= 0) AND (progress_percentage <= 100)))
);


ALTER TABLE public.user_course_progress OWNER TO postgres;

--
-- TOC entry 5095 (class 0 OID 0)
-- Dependencies: 224
-- Name: TABLE user_course_progress; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.user_course_progress IS 'Progreso de usuarios en los cursos';


--
-- TOC entry 219 (class 1259 OID 16500)
-- Name: users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    name character varying(255) NOT NULL,
    email character varying(255) NOT NULL,
    password_hash character varying(255) NOT NULL,
    avatar character varying(255) DEFAULT '👤'::character varying,
    is_active boolean DEFAULT true,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    last_login timestamp with time zone,
    email_verified boolean DEFAULT false,
    email_verification_token character varying(255),
    email_verification_token_expires timestamp with time zone
);


ALTER TABLE public.users OWNER TO postgres;

--
-- TOC entry 5096 (class 0 OID 0)
-- Dependencies: 219
-- Name: TABLE users; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.users IS 'Tabla de usuarios del sistema';


--
-- TOC entry 230 (class 1259 OID 16672)
-- Name: user_learning_progress; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.user_learning_progress AS
 SELECT u.id AS user_id,
    u.name AS user_name,
    lc.id AS course_id,
    lc.title AS course_title,
    lc.difficulty_level,
    lc.duration_hours,
    COALESCE(ucp.progress_percentage, 0) AS progress_percentage,
    ucp.started_at,
    ucp.completed_at,
    ucp.last_accessed
   FROM ((public.users u
     CROSS JOIN public.learning_courses lc)
     LEFT JOIN public.user_course_progress ucp ON (((u.id = ucp.user_id) AND (lc.id = ucp.course_id))))
  WHERE (lc.is_published = true);


ALTER VIEW public.user_learning_progress OWNER TO postgres;

--
-- TOC entry 227 (class 1259 OID 16618)
-- Name: user_projects; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.user_projects (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    user_id uuid NOT NULL,
    service_id uuid,
    name character varying(255) NOT NULL,
    description text,
    status character varying(50) DEFAULT 'pending'::character varying,
    budget numeric(10,2),
    start_date date,
    end_date date,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.user_projects OWNER TO postgres;

--
-- TOC entry 5097 (class 0 OID 0)
-- Dependencies: 227
-- Name: TABLE user_projects; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.user_projects IS 'Proyectos de usuarios';


--
-- TOC entry 220 (class 1259 OID 16515)
-- Name: user_sessions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.user_sessions (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    user_id uuid NOT NULL,
    token character varying(500) NOT NULL,
    expires_at timestamp with time zone NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    ip_address inet,
    user_agent text
);


ALTER TABLE public.user_sessions OWNER TO postgres;

--
-- TOC entry 5098 (class 0 OID 0)
-- Dependencies: 220
-- Name: TABLE user_sessions; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.user_sessions IS 'Sesiones activas de usuarios';


--
-- TOC entry 226 (class 1259 OID 16598)
-- Name: user_tool_access; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.user_tool_access (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    user_id uuid NOT NULL,
    tool_id uuid NOT NULL,
    granted_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    expires_at timestamp with time zone,
    is_active boolean DEFAULT true
);


ALTER TABLE public.user_tool_access OWNER TO postgres;

--
-- TOC entry 229 (class 1259 OID 16667)
-- Name: users_with_session_info; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.users_with_session_info AS
 SELECT u.id,
    u.name,
    u.email,
    u.avatar,
    u.is_active,
    u.created_at,
    u.last_login,
    u.email_verified,
    count(us.id) AS active_sessions
   FROM (public.users u
     LEFT JOIN public.user_sessions us ON (((u.id = us.user_id) AND (us.expires_at > CURRENT_TIMESTAMP))))
  GROUP BY u.id, u.name, u.email, u.avatar, u.is_active, u.created_at, u.last_login, u.email_verified;


ALTER VIEW public.users_with_session_info OWNER TO postgres;

--
-- TOC entry 5076 (class 0 OID 16540)
-- Dependencies: 222
-- Data for Name: campus_sections; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.campus_sections (id, name, description, section_type, icon, is_active, requires_login, created_at, updated_at) FROM stdin;
a6122f66-5557-4adc-b686-0a59c6a416a3	Dashboard	Panel de control personalizado con métricas y análisis detallados de tus proyectos	dashboard	📊	t	t	2025-08-16 18:27:29.884036-03	2025-08-16 18:27:29.884036-03
16a75cbf-180f-4fc3-bfb9-9d6a8c54332d	Aprendizaje	Cursos y recursos para mejorar tus habilidades en diseño y desarrollo web	learning	📚	t	t	2025-08-16 18:27:29.884036-03	2025-08-16 18:27:29.884036-03
b0500999-a751-4df2-a779-71e60a94e95c	Herramientas	Suite completa de herramientas de diseño y desarrollo para profesionales	tools	🛠️	t	t	2025-08-16 18:27:29.884036-03	2025-08-16 18:27:29.884036-03
\.


--
-- TOC entry 5079 (class 0 OID 16587)
-- Dependencies: 225
-- Data for Name: campus_tools; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.campus_tools (id, name, description, tool_type, url, icon, is_active, created_at, updated_at) FROM stdin;
760123e8-c06d-4ef7-a406-ea78491fbc1c	Editor de Código	Editor de código en línea con syntax highlighting	development	/tools/code-editor	💻	t	2025-08-16 18:27:29.884036-03	2025-08-16 18:27:29.884036-03
9675bc3e-6930-4bc8-a477-224c4c7517a6	Paleta de Colores	Generador de paletas de colores para diseño	design	/tools/color-palette	🎨	t	2025-08-16 18:27:29.884036-03	2025-08-16 18:27:29.884036-03
b8d5db67-29d6-427c-b84f-8a789e3dd62d	Optimizador de Imágenes	Herramienta para optimizar imágenes web	development	/tools/image-optimizer	🖼️	t	2025-08-16 18:27:29.884036-03	2025-08-16 18:27:29.884036-03
36afaea5-99e2-4c08-983f-b015e2dc30ee	Analytics Dashboard	Panel de análisis y métricas	analysis	/tools/analytics	📈	t	2025-08-16 18:27:29.884036-03	2025-08-16 18:27:29.884036-03
\.


--
-- TOC entry 5082 (class 0 OID 16639)
-- Dependencies: 228
-- Data for Name: contact_messages; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.contact_messages (id, name, email, subject, message, is_read, created_at, responded_at, ip_address) FROM stdin;
\.


--
-- TOC entry 5077 (class 0 OID 16552)
-- Dependencies: 223
-- Data for Name: learning_courses; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.learning_courses (id, title, description, content, difficulty_level, duration_hours, is_published, created_at, updated_at) FROM stdin;
df40d0de-104d-45ae-9ecb-df1e0a6706b5	Fundamentos de Diseño Web	Aprende los conceptos básicos del diseño web moderno	Curso completo sobre HTML, CSS y principios de diseño	beginner	20	t	2025-08-16 18:27:29.884036-03	2025-08-16 18:27:29.884036-03
6f7a15bf-cbef-44ff-a825-218e1bdc1aea	JavaScript Avanzado	Domina JavaScript y sus frameworks modernos	Curso avanzado de JavaScript, ES6+, React y Node.js	advanced	40	t	2025-08-16 18:27:29.884036-03	2025-08-16 18:27:29.884036-03
51df2da5-fb71-4211-9d7e-852b62259d3e	UX/UI Design	Principios de experiencia de usuario e interfaz	Diseño centrado en el usuario, prototipado y testing	intermediate	30	t	2025-08-16 18:27:29.884036-03	2025-08-16 18:27:29.884036-03
\.


--
-- TOC entry 5075 (class 0 OID 16529)
-- Dependencies: 221
-- Data for Name: services; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.services (id, name, description, category, icon, is_active, created_at, updated_at) FROM stdin;
f96a15bd-6757-4b8c-ad27-485ce687ccfd	Diseño Web	Creamos sitios web modernos y responsivos que combinan funcionalidad con una estética visual impactante. Cada proyecto se adapta perfectamente a las necesidades del cliente.	web_design	🌐	t	2025-08-16 18:27:29.884036-03	2025-08-16 18:27:29.884036-03
90096b22-80dc-46e6-95ae-cce57510d6a4	Identidad Visual	Desarrollamos identidades de marca coherentes y memorables que reflejan la esencia de tu negocio. Desde logotipos hasta guías de estilo completas.	visual_identity	🎨	t	2025-08-16 18:27:29.884036-03	2025-08-16 18:27:29.884036-03
ed390597-1fca-4915-9259-a4662bb6ca4d	Fotografía	Servicios de fotografía profesional con un estilo único que captura la esencia de cada momento. Especializados en retratos y fotografía corporativa.	photography	📸	t	2025-08-16 18:27:29.884036-03	2025-08-16 18:27:29.884036-03
\.


--
-- TOC entry 5078 (class 0 OID 16565)
-- Dependencies: 224
-- Data for Name: user_course_progress; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.user_course_progress (id, user_id, course_id, progress_percentage, completed_at, started_at, last_accessed) FROM stdin;
\.


--
-- TOC entry 5081 (class 0 OID 16618)
-- Dependencies: 227
-- Data for Name: user_projects; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.user_projects (id, user_id, service_id, name, description, status, budget, start_date, end_date, created_at, updated_at) FROM stdin;
\.


--
-- TOC entry 5074 (class 0 OID 16515)
-- Dependencies: 220
-- Data for Name: user_sessions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.user_sessions (id, user_id, token, expires_at, created_at, ip_address, user_agent) FROM stdin;
4203a80f-7522-4d10-ba68-abbd45dcedbf	dcf2e75a-7f13-4cd4-92ff-6731bd60b0e9	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJkY2YyZTc1YS03ZjEzLTRjZDQtOTJmZi02NzMxYmQ2MGIwZTkiLCJleHAiOjE3NTUzODcyNTV9.7DkjlbUQlGfAHTjZoykU9Zi78hHLVEWqoPHSjjMitXw	2025-08-16 23:34:15.11535-03	2025-08-16 20:04:15.115729-03	\N	\N
7f65f3ea-1f4d-4de7-833b-f7a2755065b9	dcf2e75a-7f13-4cd4-92ff-6731bd60b0e9	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJkY2YyZTc1YS03ZjEzLTRjZDQtOTJmZi02NzMxYmQ2MGIwZTkiLCJleHAiOjE3NTU0OTE0OTN9.QARtwnhGjbDZxpuhW6pYF356VKXFv5KSLKLeUDdmUJs	2025-08-18 04:31:33.756559-03	2025-08-18 01:01:33.757077-03	\N	\N
d60e6f78-5366-48d5-a724-efa04faa4d8a	dcf2e75a-7f13-4cd4-92ff-6731bd60b0e9	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJkY2YyZTc1YS03ZjEzLTRjZDQtOTJmZi02NzMxYmQ2MGIwZTkiLCJleHAiOjE3NTU4MTMzNDV9.umZYM7J-d_Fim85qLwyhURHhv3V6hxdrZ8CYrtwNCN4	2025-08-21 21:55:45.696092-03	2025-08-21 18:25:45.69647-03	\N	\N
fa15a259-6aba-4413-9fc8-07794b5c4e10	dcf2e75a-7f13-4cd4-92ff-6731bd60b0e9	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJkY2YyZTc1YS03ZjEzLTRjZDQtOTJmZi02NzMxYmQ2MGIwZTkiLCJleHAiOjE3NTYwNjQ2ODN9.LUtOQr08gWBa_bEQVXdBJT54-gH3fp5thHom4u6MWdE	2025-08-24 19:44:43.059207-03	2025-08-24 16:14:43.05955-03	\N	\N
18de650b-fb4f-417f-aeba-b0d235a86f20	e5a14bb7-c230-43ad-8326-009d79ceaaa3	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJlNWExNGJiNy1jMjMwLTQzYWQtODMyNi0wMDlkNzljZWFhYTMiLCJleHAiOjE3NTkzOTIxMzd9.f4H9yEynxCnKwZaDUcyv8_zuFdZNb27rOYYG6Pxoqc4	2025-10-02 08:02:17.886813-03	2025-10-02 04:32:17.88731-03	\N	\N
ffd66b65-a2a1-4d92-a6f6-be14fa4f1978	e5a14bb7-c230-43ad-8326-009d79ceaaa3	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJlNWExNGJiNy1jMjMwLTQzYWQtODMyNi0wMDlkNzljZWFhYTMiLCJleHAiOjE3NTkzOTIxNjF9.dyc0c-n55KEbWVNWT8FpqHaKrYC1B52p7p0wRslW2SM	2025-10-02 08:02:41.530255-03	2025-10-02 04:32:41.531301-03	\N	\N
556fdf14-e5a1-499e-9090-b9f86e6fa962	e5a14bb7-c230-43ad-8326-009d79ceaaa3	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJlNWExNGJiNy1jMjMwLTQzYWQtODMyNi0wMDlkNzljZWFhYTMiLCJleHAiOjE3NTkzOTIxODF9.Ec4QBoJhoaALRV6NtRN0sCkuv1Q35PcBnGPZCNW6x0I	2025-10-02 08:03:01.313246-03	2025-10-02 04:33:01.314294-03	\N	\N
a91641d2-1d31-4b65-bd60-dba59c6882b6	e5a14bb7-c230-43ad-8326-009d79ceaaa3	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJlNWExNGJiNy1jMjMwLTQzYWQtODMyNi0wMDlkNzljZWFhYTMiLCJleHAiOjE3NTkzOTI4NDh9.pgI86Rf69PYcTym7zaSQHNZyiWf9YI8S-Kx1e4WYCuE	2025-10-02 08:14:08.672166-03	2025-10-02 04:44:08.673035-03	\N	\N
4a92b567-b078-4ae5-ad58-d52742b2db28	e5a14bb7-c230-43ad-8326-009d79ceaaa3	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJlNWExNGJiNy1jMjMwLTQzYWQtODMyNi0wMDlkNzljZWFhYTMiLCJleHAiOjE3NTkzOTI4NzJ9.kl1rjiy-3pPinAdqcsIvGNn878C1dywNpVbpENlt0uo	2025-10-02 08:14:32.609998-03	2025-10-02 04:44:32.611298-03	\N	\N
d2c78226-37ae-411a-ac73-064a2f921208	e5a14bb7-c230-43ad-8326-009d79ceaaa3	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJlNWExNGJiNy1jMjMwLTQzYWQtODMyNi0wMDlkNzljZWFhYTMiLCJleHAiOjE3NTkzOTMzMDd9.CUtbWL0OFgnPaATgbWbo71B7iPWq5xYoJVUum22GRoY	2025-10-02 08:21:47.714364-03	2025-10-02 04:51:47.720893-03	\N	\N
e0c5647d-5a90-44ce-a88d-57c967593d01	e5a14bb7-c230-43ad-8326-009d79ceaaa3	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJlNWExNGJiNy1jMjMwLTQzYWQtODMyNi0wMDlkNzljZWFhYTMiLCJleHAiOjE3NTkzOTMzNzR9.kN2VMVyYZ4XWmLz77LBuvxQj4elUKOw49Cf6lPGeXR0	2025-10-02 08:22:54.687597-03	2025-10-02 04:52:54.689312-03	\N	\N
0c04a8b8-2b83-48e3-b232-a3c6048476f4	e5a14bb7-c230-43ad-8326-009d79ceaaa3	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJlNWExNGJiNy1jMjMwLTQzYWQtODMyNi0wMDlkNzljZWFhYTMiLCJleHAiOjE3NTkzOTMzOTZ9.yk-lJ4WZELqmotZKaTuTDaQsAG85MgioZD4brkHhdkk	2025-10-02 08:23:16.862089-03	2025-10-02 04:53:16.86331-03	\N	\N
080c1b9f-f6e7-4fca-9459-c4ca96cbde2e	e5a14bb7-c230-43ad-8326-009d79ceaaa3	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJlNWExNGJiNy1jMjMwLTQzYWQtODMyNi0wMDlkNzljZWFhYTMiLCJleHAiOjE3NTkzOTM1NDN9.TGO-rd7iEReifngGCHIfctSwv6qSLS-nmaHCHVAuLtY	2025-10-02 08:25:43.256073-03	2025-10-02 04:55:43.257342-03	\N	\N
ab2d1c6b-14c7-48eb-9a98-1953d8baf132	e5a14bb7-c230-43ad-8326-009d79ceaaa3	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJlNWExNGJiNy1jMjMwLTQzYWQtODMyNi0wMDlkNzljZWFhYTMiLCJleHAiOjE3NTkzOTM1OTB9.Lgme-wXiJfy3SMjj5Pr1d1MWVQaKTiGTbl1m-2ksOZY	2025-10-02 08:26:30.042072-03	2025-10-02 04:56:30.043257-03	\N	\N
c6f8df53-4652-43d3-bc20-15b498d4c0a1	e5a14bb7-c230-43ad-8326-009d79ceaaa3	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJlNWExNGJiNy1jMjMwLTQzYWQtODMyNi0wMDlkNzljZWFhYTMiLCJleHAiOjE3NTkzOTM4NjV9.P44nYp_5rFx2rLkSca-fngG89dTa8fsW7EAvsADMGr8	2025-10-02 08:31:05.927587-03	2025-10-02 05:01:05.92866-03	\N	\N
4d9e1eb2-b55b-4656-975f-f6f120904c96	e5a14bb7-c230-43ad-8326-009d79ceaaa3	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJlNWExNGJiNy1jMjMwLTQzYWQtODMyNi0wMDlkNzljZWFhYTMiLCJleHAiOjE3NTkzOTQyMDB9._aTqZaexaIoP4EAGFcguzRukEri2BhqKfHx_Uv_a9RI	2025-10-02 08:36:40.642718-03	2025-10-02 05:06:40.644667-03	\N	\N
447cde31-bc46-4931-bcfc-9638b4cfbee7	e5a14bb7-c230-43ad-8326-009d79ceaaa3	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJlNWExNGJiNy1jMjMwLTQzYWQtODMyNi0wMDlkNzljZWFhYTMiLCJleHAiOjE3NTkzOTQyNjZ9.th63WyTzvSbq3J4N_8FoMjH7gVXiJMc-gBSF1wTPjGM	2025-10-02 08:37:46.60669-03	2025-10-02 05:07:46.607776-03	\N	\N
6e9f8b24-999d-4776-8b13-c6e8a5249c76	e5a14bb7-c230-43ad-8326-009d79ceaaa3	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJlNWExNGJiNy1jMjMwLTQzYWQtODMyNi0wMDlkNzljZWFhYTMiLCJleHAiOjE3NTkzOTQyOTJ9.-ElJtGH40vzGMcygnBW7H1E4E5STYdvaMVoxGx5u2WM	2025-10-02 08:38:12.487974-03	2025-10-02 05:08:12.488992-03	\N	\N
d40f8519-a288-4377-ac0e-a3130afb8ca8	e5a14bb7-c230-43ad-8326-009d79ceaaa3	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJlNWExNGJiNy1jMjMwLTQzYWQtODMyNi0wMDlkNzljZWFhYTMiLCJleHAiOjE3NTkzOTQ5MDl9.m8fa7ePgNdAAFV0H-mut8h_tumI4FeqOQHzntgTHAks	2025-10-02 08:48:29.499299-03	2025-10-02 05:18:29.500522-03	\N	\N
b17b8c5e-af05-4ca4-9235-f0240659fcf7	e44c7d79-9801-4d71-8703-9a9cb24305c6	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJlNDRjN2Q3OS05ODAxLTRkNzEtODcwMy05YTljYjI0MzA1YzYiLCJleHAiOjE3NTk1MjEyODF9.LHf291sIgG3uPopoqoQk1GfeAUvZIuwwJiS7n67YoS8	2025-10-03 19:54:41.229741-03	2025-10-03 16:24:41.230784-03	\N	\N
\.


--
-- TOC entry 5080 (class 0 OID 16598)
-- Dependencies: 226
-- Data for Name: user_tool_access; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.user_tool_access (id, user_id, tool_id, granted_at, expires_at, is_active) FROM stdin;
\.


--
-- TOC entry 5073 (class 0 OID 16500)
-- Dependencies: 219
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (id, name, email, password_hash, avatar, is_active, created_at, updated_at, last_login, email_verified) FROM stdin;
b2193cd7-7943-4dda-981d-fdc7178b04f1	Daniel	danielbanegas.gongora@gmail.com	$2b$12$BYgBvOJPTy359o.laBlaI.c4S.wZiT0F1fx/1zuQ5uQreu8weGQqa	👤	t	2025-08-16 20:43:12.388031-03	2025-08-16 20:44:45.637411-03	2025-08-16 20:44:45.637411-03	f
dcf2e75a-7f13-4cd4-92ff-6731bd60b0e9	Usuario Demo	demo@vexus.com	$2b$12$LQv3c1yduWTxmZmf7H.PXO7Z1.MZqW6K3kKK3K6K3K6K3K6K3K6K3u	👤	t	2025-08-16 18:27:29.884036-03	2025-10-02 03:36:23.855107-03	2025-08-25 15:15:36.141966-03	t
e5a14bb7-c230-43ad-8326-009d79ceaaa3	Test User	test@example.com	$2b$12$JNajQ7SHyYM.dGLfqKCmeeGjk7iLlyj0Mh3xkqFtaYTga.PdvT.5y	👤	t	2025-10-02 04:28:08.738883-03	2025-10-02 05:18:29.498321-03	2025-10-02 05:18:29.498321-03	f
e44c7d79-9801-4d71-8703-9a9cb24305c6	Daniel	dgongorabanegas@alumnos.exa.unicen.edu.ar	$2b$12$9YzmgCcmuzBm1roOaP.AMO9jqCC6vzZ9jqNWZDMyiNX6470cnHTvm	👤	t	2025-10-03 16:20:11.678556-03	2025-10-05 18:36:06.061486-03	2025-10-05 18:36:06.061486-03	f
\.


--
-- TOC entry 4890 (class 2606 OID 16551)
-- Name: campus_sections campus_sections_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.campus_sections
    ADD CONSTRAINT campus_sections_pkey PRIMARY KEY (id);


--
-- TOC entry 4900 (class 2606 OID 16597)
-- Name: campus_tools campus_tools_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.campus_tools
    ADD CONSTRAINT campus_tools_pkey PRIMARY KEY (id);


--
-- TOC entry 4910 (class 2606 OID 16648)
-- Name: contact_messages contact_messages_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.contact_messages
    ADD CONSTRAINT contact_messages_pkey PRIMARY KEY (id);


--
-- TOC entry 4892 (class 2606 OID 16564)
-- Name: learning_courses learning_courses_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.learning_courses
    ADD CONSTRAINT learning_courses_pkey PRIMARY KEY (id);


--
-- TOC entry 4888 (class 2606 OID 16539)
-- Name: services services_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.services
    ADD CONSTRAINT services_pkey PRIMARY KEY (id);


--
-- TOC entry 4896 (class 2606 OID 16574)
-- Name: user_course_progress user_course_progress_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_course_progress
    ADD CONSTRAINT user_course_progress_pkey PRIMARY KEY (id);


--
-- TOC entry 4898 (class 2606 OID 16576)
-- Name: user_course_progress user_course_progress_user_id_course_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_course_progress
    ADD CONSTRAINT user_course_progress_user_id_course_id_key UNIQUE (user_id, course_id);


--
-- TOC entry 4908 (class 2606 OID 16628)
-- Name: user_projects user_projects_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_projects
    ADD CONSTRAINT user_projects_pkey PRIMARY KEY (id);


--
-- TOC entry 4886 (class 2606 OID 16523)
-- Name: user_sessions user_sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_sessions
    ADD CONSTRAINT user_sessions_pkey PRIMARY KEY (id);


--
-- TOC entry 4902 (class 2606 OID 16605)
-- Name: user_tool_access user_tool_access_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_tool_access
    ADD CONSTRAINT user_tool_access_pkey PRIMARY KEY (id);


--
-- TOC entry 4904 (class 2606 OID 16607)
-- Name: user_tool_access user_tool_access_user_id_tool_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_tool_access
    ADD CONSTRAINT user_tool_access_user_id_tool_id_key UNIQUE (user_id, tool_id);


--
-- TOC entry 4879 (class 2606 OID 16514)
-- Name: users users_email_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- TOC entry 4881 (class 2606 OID 16512)
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- TOC entry 4911 (class 1259 OID 16658)
-- Name: idx_contact_messages_created_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_contact_messages_created_at ON public.contact_messages USING btree (created_at);


--
-- TOC entry 4912 (class 1259 OID 16659)
-- Name: idx_contact_messages_is_read; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_contact_messages_is_read ON public.contact_messages USING btree (is_read);


--
-- TOC entry 4893 (class 1259 OID 16655)
-- Name: idx_user_course_progress_course_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_user_course_progress_course_id ON public.user_course_progress USING btree (course_id);


--
-- TOC entry 4894 (class 1259 OID 16654)
-- Name: idx_user_course_progress_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_user_course_progress_user_id ON public.user_course_progress USING btree (user_id);


--
-- TOC entry 4905 (class 1259 OID 16657)
-- Name: idx_user_projects_status; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_user_projects_status ON public.user_projects USING btree (status);


--
-- TOC entry 4906 (class 1259 OID 16656)
-- Name: idx_user_projects_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_user_projects_user_id ON public.user_projects USING btree (user_id);


--
-- TOC entry 4882 (class 1259 OID 16653)
-- Name: idx_user_sessions_expires_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_user_sessions_expires_at ON public.user_sessions USING btree (expires_at);


--
-- TOC entry 4883 (class 1259 OID 16652)
-- Name: idx_user_sessions_token; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_user_sessions_token ON public.user_sessions USING btree (token);


--
-- TOC entry 4884 (class 1259 OID 16651)
-- Name: idx_user_sessions_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_user_sessions_user_id ON public.user_sessions USING btree (user_id);


--
-- TOC entry 4876 (class 1259 OID 16650)
-- Name: idx_users_created_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_users_created_at ON public.users USING btree (created_at);


--
-- TOC entry 4877 (class 1259 OID 16649)
-- Name: idx_users_email; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_users_email ON public.users USING btree (email);


--
-- TOC entry 4878 (class 1259 OID 16651)
-- Name: idx_users_email_verified; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_users_email_verified ON public.users USING btree (email_verified);


--
-- TOC entry 4879 (class 1259 OID 16652)
-- Name: idx_users_email_verification_token; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_users_email_verification_token ON public.users USING btree (email_verification_token) WHERE (email_verification_token IS NOT NULL);


--
-- TOC entry 4922 (class 2620 OID 16663)
-- Name: campus_sections update_campus_sections_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER update_campus_sections_updated_at BEFORE UPDATE ON public.campus_sections FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- TOC entry 4924 (class 2620 OID 16665)
-- Name: campus_tools update_campus_tools_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER update_campus_tools_updated_at BEFORE UPDATE ON public.campus_tools FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- TOC entry 4923 (class 2620 OID 16664)
-- Name: learning_courses update_learning_courses_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER update_learning_courses_updated_at BEFORE UPDATE ON public.learning_courses FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- TOC entry 4921 (class 2620 OID 16662)
-- Name: services update_services_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER update_services_updated_at BEFORE UPDATE ON public.services FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- TOC entry 4925 (class 2620 OID 16666)
-- Name: user_projects update_user_projects_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER update_user_projects_updated_at BEFORE UPDATE ON public.user_projects FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- TOC entry 4920 (class 2620 OID 16661)
-- Name: users update_users_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON public.users FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- TOC entry 4914 (class 2606 OID 16582)
-- Name: user_course_progress user_course_progress_course_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_course_progress
    ADD CONSTRAINT user_course_progress_course_id_fkey FOREIGN KEY (course_id) REFERENCES public.learning_courses(id) ON DELETE CASCADE;


--
-- TOC entry 4915 (class 2606 OID 16577)
-- Name: user_course_progress user_course_progress_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_course_progress
    ADD CONSTRAINT user_course_progress_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- TOC entry 4918 (class 2606 OID 16634)
-- Name: user_projects user_projects_service_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_projects
    ADD CONSTRAINT user_projects_service_id_fkey FOREIGN KEY (service_id) REFERENCES public.services(id) ON DELETE SET NULL;


--
-- TOC entry 4919 (class 2606 OID 16629)
-- Name: user_projects user_projects_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_projects
    ADD CONSTRAINT user_projects_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- TOC entry 4913 (class 2606 OID 16524)
-- Name: user_sessions user_sessions_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_sessions
    ADD CONSTRAINT user_sessions_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- TOC entry 4916 (class 2606 OID 16613)
-- Name: user_tool_access user_tool_access_tool_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_tool_access
    ADD CONSTRAINT user_tool_access_tool_id_fkey FOREIGN KEY (tool_id) REFERENCES public.campus_tools(id) ON DELETE CASCADE;


--
-- TOC entry 4917 (class 2606 OID 16608)
-- Name: user_tool_access user_tool_access_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_tool_access
    ADD CONSTRAINT user_tool_access_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


-- Completed on 2025-10-05 19:03:56

--
-- PostgreSQL database dump complete
--

