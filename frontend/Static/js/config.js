// Configuración de producción
// Backend en AWS Lightsail (mismo servidor, puerto 8000)
// Version: 20251207-6 - Trailing slashes en endpoints para evitar 307
const CONFIG = {
    API_BASE_URL: 'https://www.grupovexus.com/api/v1',  // URL absoluta con HTTPS para evitar Mixed Content
    FRONTEND_URL: 'https://www.grupovexus.com',  // URL del frontend en producción (HTTPS)
    TOKEN_KEY: 'vexusToken',
    USER_KEY: 'vexusUser',
    REQUEST_TIMEOUT: 30000,
    ENVIRONMENT: 'production',
    DEBUG: false
};

export default CONFIG;