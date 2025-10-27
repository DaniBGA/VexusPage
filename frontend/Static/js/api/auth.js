// Servicios de autenticación
import { apiClient } from './client.js';
import { Storage } from '../utils/storage.js';
import CONFIG from '../config.js';

export const AuthService = {
    async login(email, password) {
        try {
            const response = await fetch(`${CONFIG.API_BASE_URL}/auth/login`, {
                method: 'POST',
                mode: 'cors',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify({ email, password })
            });

            const data = await response.json();

            if (response.ok) {
                if (data.access_token) {
                    Storage.set(CONFIG.TOKEN_KEY, data.access_token);
                    Storage.set(CONFIG.USER_KEY, data.user);
                }
                return { success: true, ...data };
            } else {
                // Manejar error de email no verificado
                if (response.status === 403 && data.detail && data.detail.includes('Email not verified')) {
                    return {
                        success: false,
                        emailNotVerified: true,
                        email: email,
                        message: 'Tu email no ha sido verificado. Por favor revisa tu correo.'
                    };
                }
                return { success: false, message: data.detail || data.message || 'Credenciales incorrectas' };
            }
        } catch (error) {
            return { success: false, message: error.message || 'Error de conexión' };
        }
    },

    async register(name, email, password) {
        try {
            const response = await apiClient.post('/auth/register', { name, email, password });
            return {
                success: true,
                message: response.message,
                emailSent: response.email_sent,
                userId: response.user_id
            };
        } catch (error) {
            console.error('Registration failed:', error);
            return { success: false, message: error.message };
        }
    },

    async verifyEmail(token) {
        try {
            const response = await fetch(`${CONFIG.API_BASE_URL}/auth/verify-email?token=${token}`, {
                method: 'GET',
                mode: 'cors',
                headers: {
                    'Content-Type': 'application/json'
                }
            });

            const data = await response.json();

            if (response.ok) {
                return {
                    success: true,
                    message: data.message,
                    alreadyVerified: data.already_verified || false,
                    email: data.email
                };
            } else {
                return {
                    success: false,
                    message: data.detail || 'Error al verificar el email'
                };
            }
        } catch (error) {
            console.error('Email verification failed:', error);
            return { success: false, message: error.message || 'Error de conexión' };
        }
    },

    async resendVerification(email) {
        try {
            const response = await fetch(`${CONFIG.API_BASE_URL}/auth/resend-verification`, {
                method: 'POST',
                mode: 'cors',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify({ email })
            });

            const data = await response.json();

            if (response.ok) {
                return {
                    success: true,
                    message: data.message,
                    alreadyVerified: data.already_verified || false
                };
            } else {
                return {
                    success: false,
                    message: data.detail || 'Error al reenviar el email de verificación'
                };
            }
        } catch (error) {
            console.error('Resend verification failed:', error);
            return { success: false, message: error.message || 'Error de conexión' };
        }
    },

    async logout() {
        try {
            await apiClient.post('/auth/logout');
        } catch (error) {
            console.error('Logout failed:', error);
        } finally {
            Storage.remove(CONFIG.TOKEN_KEY);
            Storage.remove(CONFIG.USER_KEY);
            window.location.reload();
        }
    },

    getCurrentUser() {
        return Storage.get(CONFIG.USER_KEY);
    },

    isAuthenticated() {
        return !!localStorage.getItem(CONFIG.TOKEN_KEY);
    },

    async verifyToken() {
        try {
            const user = await apiClient.get('/users/me');
            Storage.set(CONFIG.USER_KEY, user);
            return user;
        } catch (error) {
            this.logout();
            return null;
        }
    }
};