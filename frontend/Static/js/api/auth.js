// Servicios de autenticación
import { apiClient } from './client.js';
import { Storage } from '../utils/storage.js';
import CONFIG from '../config.js';

export const AuthService = {
    async login(email, password) {
        try {
            const response = await fetch(`${CONFIG.API_BASE_URL}/auth/login`, {
                method: 'POST',
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
                return { success: false, message: data.message || 'Credenciales incorrectas' };
            }
        } catch (error) {
            return { success: false, message: error.message || 'Error de conexión' };
        }
    },


    async register(name, email, password) {
        try {
            const response = await apiClient.post('/auth/register', { name, email, password });
            return { success: true, message: response.message };
        } catch (error) {
            console.error('Registration failed:', error);
            return { success: false, message: error.message };
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