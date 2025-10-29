// Gestión de modales
export const ModalManager = {
    open(modalId) {
        const modal = document.getElementById(modalId);
        if (modal) {
            modal.style.display = 'block';
            document.body.style.overflow = 'hidden';
        }
    },

    close(modalId) {
        const modal = document.getElementById(modalId);
        if (modal) {
            modal.style.display = 'none';
            document.body.style.overflow = 'auto';
        }
    },

    closeAll() {
        const modals = document.querySelectorAll('.modal');
        modals.forEach(modal => {
            modal.style.display = 'none';
        });
        document.body.style.overflow = 'auto';
    },

    switchModal(fromModalId, toModalId) {
        this.close(fromModalId);
        this.open(toModalId);
    }
};

// Event listeners para cerrar modales al hacer clic fuera
window.addEventListener('click', (event) => {
    // Solo cerrar si el click es EXACTAMENTE en el modal backdrop,
    // no en sus hijos (modal-content, forms, etc.)
    if (event.target.classList.contains('modal') && event.target === event.currentTarget) {
        // Verificar que no estamos dentro de un formulario o contenido del modal
        const modalContent = event.target.querySelector('.modal-content');
        if (modalContent && !modalContent.contains(event.target)) {
            event.target.style.display = 'none';
            document.body.style.overflow = 'auto';
        }
    }
});