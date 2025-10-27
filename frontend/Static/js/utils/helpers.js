// Funciones auxiliares
export const showLoading = () => {
    const overlay = document.getElementById('loadingOverlay');
    if (overlay) {
        overlay.style.display = 'flex';
        overlay.classList.remove('hidden');
        document.body.style.overflow = 'hidden';
    }
};

export const hideLoading = () => {
    const overlay = document.getElementById('loadingOverlay');
    if (overlay) {
        overlay.classList.add('hidden');
        document.body.style.overflow = 'auto';

        // Después de la animación de fade, ocultar completamente
        setTimeout(() => {
            overlay.style.display = 'none';
        }, 800);
    }
};

export const showConnectionStatus = (isConnected, message = '') => {
    const status = document.getElementById('connectionStatus');
    if (!status) return;

    const connectedIcon = `<svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
        <path d="M5 12.55a11 11 0 0 1 14.08 0"></path>
        <path d="M1.42 9a16 16 0 0 1 21.16 0"></path>
        <path d="M8.53 16.11a6 6 0 0 1 6.95 0"></path>
        <line x1="12" y1="20" x2="12.01" y2="20"></line>
    </svg>`;

    const disconnectedIcon = `<svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
        <line x1="1" y1="1" x2="23" y2="23"></line>
        <path d="M16.72 11.06A10.94 10.94 0 0 1 19 12.55"></path>
        <path d="M5 12.55a10.94 10.94 0 0 1 5.17-2.39"></path>
        <path d="M10.71 5.05A16 16 0 0 1 22.58 9"></path>
        <path d="M1.42 9a15.91 15.91 0 0 1 4.7-2.88"></path>
        <path d="M8.53 16.11a6 6 0 0 1 6.95 0"></path>
        <line x1="12" y1="20" x2="12.01" y2="20"></line>
    </svg>`;

    status.style.display = 'block';
    status.style.background = isConnected ? '#28a745' : '#dc3545';
    status.innerHTML = isConnected
        ? connectedIcon + ' Conectado'
        : disconnectedIcon + ' ' + (message || 'Desconectado');

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