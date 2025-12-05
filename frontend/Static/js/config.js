// Configuración de producción
// Backend en AWS Lightsail (mismo servidor, puerto 8000)
const CONFIG = {
    API_BASE_URL: 'https://grupovexus.com/api/v1',  // URL absoluta con HTTPS (sin www para evitar CORS)
    FRONTEND_URL: 'https://grupovexus.com',  // URL del frontend en producción (HTTPS)
    TOKEN_KEY: 'vexusToken',
    USER_KEY: 'vexusUser',
    REQUEST_TIMEOUT: 30000,
    ENVIRONMENT: 'production',
    DEBUG: false
};

export default CONFIG;