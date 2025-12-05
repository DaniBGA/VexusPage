// Sistema de carga de página con progreso real

class PageLoader {
    constructor() {
        this.loadingOverlay = document.getElementById('loadingOverlay');
        this.progressFill = document.getElementById('progressFill');
        this.loadingPercentage = document.getElementById('loadingPercentage');
        this.loadingMessage = document.getElementById('loadingMessage');

        this.progress = 0;
        this.totalResources = 0;
        this.loadedResources = 0;
        this.messages = [
            'Inicializando experiencia...',
            'Cargando recursos visuales...',
            'Preparando componentes...',
            'Conectando con el servidor...',
            'Optimizando rendimiento...',
            'Casi listo...'
        ];
        this.currentMessageIndex = 0;

        this.init();
    }

    init() {
        // Prevenir scroll durante la carga
        document.body.style.overflow = 'hidden';

        // Iniciar carga con tiempo fijo de 5 segundos
        this.startLoading();
        this.updateMessages();
    }

    startLoading() {
        const startTime = Date.now();

        // Fase 1: Carga inicial (0-30%) - 0.5 segundos
        this.animateProgress(30, 500, () => {
            // Fase 2: Recursos principales (30-70%) - 0.7 segundos
            this.animateProgress(70, 700, () => {
                // Fase 3: Finalización (70-100%) - 0.6 segundos
                this.animateProgress(100, 600, () => {
                    // Esperar 200ms para mostrar el 100%
                    setTimeout(() => {
                        this.hideLoader();
                    }, 200);
                });
            });
        });
    }

    trackResourceLoading() {
        // Método deshabilitado - ahora usamos tiempo fijo de 5 segundos
        // Sin monitoreo de recursos para asegurar duración constante
    }

    updateProgressFromResources() {
        // Método deshabilitado - ahora usamos tiempo fijo de 5 segundos
    }

    checkFullyLoaded() {
        // Este método ya no se usa con el tiempo fijo de 5 segundos
        // Mantenido por compatibilidad
    }

    finishLoading() {
        // Este método ya no se usa con el tiempo fijo de 5 segundos
        // Mantenido por compatibilidad
    }

    animateProgress(targetProgress, duration, callback) {
        const startProgress = this.progress;
        const progressDiff = targetProgress - startProgress;
        const startTime = performance.now();

        const animate = (currentTime) => {
            const elapsed = currentTime - startTime;
            const progress = Math.min(elapsed / duration, 1);

            // Easing function (ease-out)
            const easeProgress = 1 - Math.pow(1 - progress, 3);

            const newProgress = startProgress + (progressDiff * easeProgress);
            this.setProgress(newProgress);

            if (progress < 1) {
                requestAnimationFrame(animate);
            } else {
                if (callback) {
                    callback();
                }
            }
        };

        requestAnimationFrame(animate);
    }

    setProgress(percent) {
        this.progress = Math.min(Math.max(percent, 0), 100);

        if (this.progressFill) {
            this.progressFill.style.width = `${this.progress}%`;
        }

        if (this.loadingPercentage) {
            this.loadingPercentage.textContent = `${Math.floor(this.progress)}%`;
        }
    }

    updateMessages() {
        const updateMessage = () => {
            if (this.currentMessageIndex < this.messages.length && this.progress < 95) {
                if (this.loadingMessage) {
                    this.loadingMessage.style.opacity = '0';

                    setTimeout(() => {
                        this.loadingMessage.textContent = this.messages[this.currentMessageIndex];
                        this.loadingMessage.style.opacity = '1';
                        this.currentMessageIndex++;

                        setTimeout(updateMessage, 1200);
                    }, 400);
                }
            }
        };

        setTimeout(updateMessage, 600);
    }

    hideLoader() {
        if (this.loadingOverlay) {
            // FORZAR ocultamiento inmediato y agresivo
            this.loadingOverlay.style.cssText = 'opacity: 0 !important; visibility: hidden !important; pointer-events: none !important; transition: opacity 0.5s ease !important;';

            setTimeout(() => {
                // Remover completamente del DOM después del fade
                this.loadingOverlay.style.display = 'none !important';
                this.loadingOverlay.remove();

                // Restaurar scroll
                document.body.style.overflow = 'auto';
                document.body.style.cssText = '';
                document.body.classList.add('loaded');

                window.dispatchEvent(new CustomEvent('pageFullyLoaded'));
            }, 500);
        }
    }

    // Método público para forzar el cierre (útil para debugging)
    forceHide() {
        this.setProgress(100);
        this.hideLoader();
    }
}

// Inicializar el loader cuando el DOM esté completamente listo
function initPageLoader() {
    if (document.getElementById('loadingOverlay')) {
        window.pageLoader = new PageLoader();
    }
}

// Asegurar que el DOM esté listo antes de inicializar
if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', initPageLoader);
} else {
    initPageLoader();
}

// Hacer disponible globalmente
window.PageLoader = PageLoader;
