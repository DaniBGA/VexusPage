// Utilidades para localStorage
export const Storage = {
    set(key, value) {
        try {
            // Si es un string simple (como un token), guardarlo directamente
            // Si es un objeto, usar JSON.stringify
            const valueToStore = typeof value === 'string' ? value : JSON.stringify(value);
            localStorage.setItem(key, valueToStore);
            return true;
        } catch (error) {
            console.error('Storage set error:', error);
            return false;
        }
    },

    get(key) {
        try {
            const item = localStorage.getItem(key);
            if (!item) return null;

            // Intentar parsear como JSON, si falla, devolver el string tal cual
            try {
                return JSON.parse(item);
            } catch {
                // Si no es JSON válido, es un string simple (como un token)
                return item;
            }
        } catch (error) {
            console.error('Storage get error:', error);
            return null;
        }
    },

    remove(key) {
        try {
            localStorage.removeItem(key);
            return true;
        } catch (error) {
            console.error('Storage remove error:', error);
            return false;
        }
    },

    clear() {
        try {
            localStorage.clear();
            return true;
        } catch (error) {
            console.error('Storage clear error:', error);
            return false;
        }
    }
};