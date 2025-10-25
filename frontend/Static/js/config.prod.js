// Configuración de producción
// INSTRUCCIONES: Reemplazar API_BASE_URL con la URL real de tu API en producción
const CONFIG = {
    API_BASE_URL: window.location.origin + '/api/v1', // Usa el mismo dominio que el frontend
    TOKEN_KEY: 'vexusToken',
    USER_KEY: 'vexusUser',
    REQUEST_TIMEOUT: 30000
};

export default CONFIG;
