-- Crear tabla para consultas de consultoría
CREATE TABLE IF NOT EXISTS consultancy_requests (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL,
    query TEXT NOT NULL,
    ip_address VARCHAR(45),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(50) DEFAULT 'pending'
);

-- Crear índice para búsquedas rápidas
CREATE INDEX IF NOT EXISTS idx_consultancy_email ON consultancy_requests(email);
CREATE INDEX IF NOT EXISTS idx_consultancy_created_at ON consultancy_requests(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_consultancy_status ON consultancy_requests(status);

-- Comentarios
COMMENT ON TABLE consultancy_requests IS 'Almacena las consultas de consultoría/desarrollo web';
COMMENT ON COLUMN consultancy_requests.id IS 'ID único de la consulta';
COMMENT ON COLUMN consultancy_requests.name IS 'Nombre completo del cliente';
COMMENT ON COLUMN consultancy_requests.email IS 'Email de contacto del cliente';
COMMENT ON COLUMN consultancy_requests.query IS 'Descripción de la consulta';
COMMENT ON COLUMN consultancy_requests.ip_address IS 'Dirección IP del cliente';
COMMENT ON COLUMN consultancy_requests.created_at IS 'Fecha y hora de creación';
COMMENT ON COLUMN consultancy_requests.status IS 'Estado de la consulta (pending, contacted, closed)';
