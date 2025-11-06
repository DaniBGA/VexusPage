// Configuración de producción
// Backend en Render
const CONFIG = {
    API_BASE_URL: 'https://vexuspage.onrender.com/api/v1',
    FRONTEND_URL: 'https://www.grupovexus.com',  // URL del frontend en producción
    TOKEN_KEY: 'vexusToken',
    USER_KEY: 'vexusUser',
    REQUEST_TIMEOUT: 30000,
    ENVIRONMENT: 'production',
    DEBUG: false
};

export default CONFIG;