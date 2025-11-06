/**
 * Servicio de Email para el Frontend usando EmailJS
 * Envía emails directamente desde el navegador sin exponer credenciales
 */

import CONFIG from './config.js';

// Configuración de EmailJS
const EMAILJS_CONFIG = {
    SERVICE_ID: 'service_80l1ykf',
    TEMPLATE_ID: 'template_cwf419b',
    PUBLIC_KEY: 'k1IUP2nR_rDmKZXcK'
};

// Inicializar EmailJS cuando se cargue el módulo
if (typeof emailjs !== 'undefined') {
    emailjs.init(EMAILJS_CONFIG.PUBLIC_KEY);
    console.log('✅ EmailJS inicializado');
}

/**
 * Envía email de verificación usando EmailJS
 * @param {string} email - Email del destinatario
 * @param {string} userName - Nombre del usuario
 * @param {string} verificationToken - Token de verificación
 * @returns {Promise<boolean>} - true si se envió exitosamente
 */
export async function sendVerificationEmail(email, userName, verificationToken) {
    try {
        console.log('📧 Enviando email de verificación con EmailJS...');
        
        // Verificar que EmailJS esté cargado
        if (typeof emailjs === 'undefined') {
            console.error('❌ EmailJS no está cargado. Asegúrate de incluir el script.');
            return false;
        }

        // Construir el link de verificación
        const verificationLink = `${window.location.origin}/pages/verify-email.html?token=${verificationToken}`;
        
        // Parámetros del template
        const templateParams = {
            user_name: userName,
            to_email: email,
            verification_link: verificationLink
        };

        console.log('📤 Enviando email a:', email);
        console.log('🔗 Link de verificación:', verificationLink);

        // Enviar email usando EmailJS
        const response = await emailjs.send(
            EMAILJS_CONFIG.SERVICE_ID,
            EMAILJS_CONFIG.TEMPLATE_ID,
            templateParams
        );

        console.log('✅ Email enviado exitosamente:', response);
        return true;
        
    } catch (error) {
        console.error('❌ Error al enviar email con EmailJS:', error);
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
