// Funciones auxiliares
export const showLoading = () => {
    const overlay = document.getElementById('loadingOverlay');
    if (overlay) overlay.style.display = 'flex';
};

export const hideLoading = () => {
    const overlay = document.getElementById('loadingOverlay');
    if (overlay) overlay.style.display = 'none';
};

export const showConnectionStatus = (isConnected, message = '') => {
    const status = document.getElementById('connectionStatus');
    if (!status) return;

    status.style.display = 'block';
    status.style.background = isConnected ? '#28a745' : '#dc3545';
    status.innerHTML = isConnected ? '🟢 Conectado' : '🔴 ' + (message || 'Desconectado');

    if (isConnected) {
        setTimeout(() => {
            status.style.display = 'none';
        }, 3000);
    }
};

export const debounce = (func, wait) => {
    let timeout;
    return function executedFunction(...args) {
        const later = () => {
            clearTimeout(timeout);
            func(...args);
        };
        clearTimeout(timeout);
        timeout = setTimeout(later, wait);
    };
};