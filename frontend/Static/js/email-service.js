/**
 * Servicio de Email para el Frontend
 * Utiliza el endpoint proxy del backend para enviar emails
 * sin exponer las credenciales de SendGrid
 */

import CONFIG from './config.js';

/**
 * Envía email de verificación a través del proxy del backend
 * @param {string} email - Email del destinatario
 * @param {string} userName - Nombre del usuario
 * @param {string} verificationToken - Token de verificación
 * @returns {Promise<boolean>} - true si se envió exitosamente
 */
export async function sendVerificationEmail(email, userName, verificationToken) {
    try {
        console.log('📧 Enviando email de verificación...');
        
        const response = await fetch(`${CONFIG.API_BASE_URL}/email/send-verification`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({
                email: email,
                user_name: userName,
                verification_token: verificationToken
            })
        });

        const data = await response.json();

        if (response.ok && data.success) {
            console.log('✅ Email enviado exitosamente');
            return true;
        } else {
            console.error('❌ Error al enviar email:', data.detail || 'Unknown error');
            return false;
        }
    } catch (error) {
        console.error('❌ Error de red al enviar email:', error);
        return false;
    }
}

/**
 * Muestra una notificación al usuario sobre el estado del email
 * @param {boolean} success - Si el email se envió exitosamente
 */
export function showEmailNotification(success) {
    const notification = document.createElement('div');
    notification.style.cssText = `
        position: fixed;
        top: 20px;
        right: 20px;
        padding: 15px 20px;
        border-radius: 8px;
        background-color: ${success ? '#4CAF50' : '#f44336'};
        color: white;
        font-family: Arial, sans-serif;
        font-size: 14px;
        box-shadow: 0 4px 6px rgba(0,0,0,0.1);
        z-index: 10000;
        animation: slideIn 0.3s ease-out;
    `;
    
    notification.textContent = success 
        ? '✅ Email de verificación enviado. Por favor revisa tu bandeja de entrada.'
        : '❌ Error al enviar el email. Por favor intenta reenviar desde tu perfil.';
    
    document.body.appendChild(notification);
    
    // Remover después de 5 segundos
    setTimeout(() => {
        notification.style.animation = 'slideOut 0.3s ease-out';
        setTimeout(() => notification.remove(), 300);
    }, 5000);
}

// Agregar animaciones CSS
const style = document.createElement('style');
style.textContent = `
    @keyframes slideIn {
        from {
            transform: translateX(400px);
            opacity: 0;
        }
        to {
            transform: translateX(0);
            opacity: 1;
        }
    }
    
    @keyframes slideOut {
        from {
            transform: translateX(0);
            opacity: 1;
        }
        to {
            transform: translateX(400px);
            opacity: 0;
        }
    }
`;
document.head.appendChild(style);
