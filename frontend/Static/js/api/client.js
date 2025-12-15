// Cliente API base
import CONFIG from '../config.js';
import { Storage } from '../utils/storage.js';

export class APIClient {
    constructor() {
        this.baseURL = CONFIG.API_BASE_URL;
        this.timeout = CONFIG.REQUEST_TIMEOUT;
        
        // FORZAR HTTPS si por alguna razón se cargó HTTP
        if (this.baseURL.startsWith('http://')) {
            console.warn('⚠️ Convirtiendo HTTP a HTTPS en baseURL');
            this.baseURL = this.baseURL.replace('http://', 'https://');
        }
    }

    async request(endpoint, options = {}) {
        const token = Storage.get(CONFIG.TOKEN_KEY);
        
        const config = {
            method: options.method || 'GET',
            headers: {
                'Content-Type': 'application/json',
                ...options.headers
            },
            ...options
        };

        if (token) {
            config.headers['Authorization'] = `Bearer ${token}`;
        }

        try {
            const response = await fetch(`${this.baseURL}${endpoint}`, config);
            
            if (response.status === 401) {
                Storage.remove(CONFIG.TOKEN_KEY);
                Storage.remove(CONFIG.USER_KEY);
                window.location.reload();
                throw new Error('Session expired');
            }

            if (!response.ok) {
                // Try to extract a helpful error message from the response body
                let errorText = response.statusText;
                try {
                    const contentType = response.headers.get('content-type') || '';
                    if (contentType.includes('application/json')) {
                        const errJson = await response.json();
                        errorText = errJson.detail || errJson.message || JSON.stringify(errJson);
                    } else {
                        errorText = await response.text();
                    }
                } catch (e) {
                    // ignore parsing errors and keep statusText
                }

                const err = new Error(`HTTP error! status: ${response.status} - ${errorText}`);
                // Attach useful metadata for callers
                err.status = response.status;
                err.body = errorText;
                throw err;
            }

            return await response.json();
        } catch (error) {
            throw error;
        }
    }

    get(endpoint, options = {}) {
        return this.request(endpoint, { ...options, method: 'GET' });
    }

    post(endpoint, data, options = {}) {
        return this.request(endpoint, {
            ...options,
            method: 'POST',
            body: JSON.stringify(data)
        });
    }

    put(endpoint, data, options = {}) {
        return this.request(endpoint, {
            ...options,
            method: 'PUT',
            body: JSON.stringify(data)
        });
    }

    delete(endpoint, options = {}) {
        return this.request(endpoint, { ...options, method: 'DELETE' });
    }
}

export const apiClient = new APIClient();