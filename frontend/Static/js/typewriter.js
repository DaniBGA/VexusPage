/**
 * Efecto Typewriter para el título principal
 */

class Typewriter {
    constructor(element, phrases, options = {}) {
        this.element = element;
        this.phrases = phrases;
        this.currentPhraseIndex = 0;
        this.currentCharIndex = 0;
        this.isDeleting = false;

        // Opciones configurables
        this.typingSpeed = options.typingSpeed || 100;     // Velocidad de escritura (ms)
        this.deletingSpeed = options.deletingSpeed || 50;  // Velocidad de borrado (ms)
        this.pauseAfterType = options.pauseAfterType || 2000; // Pausa después de escribir (ms)
        this.pauseAfterDelete = options.pauseAfterDelete || 500; // Pausa después de borrar (ms)

        this.init();
    }

    init() {
        // Iniciar la animación
        this.type();
    }

    type() {
        const currentPhrase = this.phrases[this.currentPhraseIndex];

        if (this.isDeleting) {
            // Borrar caracteres
            this.currentCharIndex--;
            this.element.textContent = currentPhrase.substring(0, this.currentCharIndex);

            if (this.currentCharIndex === 0) {
                // Terminó de borrar, cambiar a la siguiente frase
                this.isDeleting = false;
                this.currentPhraseIndex = (this.currentPhraseIndex + 1) % this.phrases.length;
                setTimeout(() => this.type(), this.pauseAfterDelete);
                return;
            }
        } else {
            // Escribir caracteres
            this.currentCharIndex++;
            this.element.textContent = currentPhrase.substring(0, this.currentCharIndex);

            if (this.currentCharIndex === currentPhrase.length) {
                // Terminó de escribir, esperar y luego borrar
                this.isDeleting = true;
                setTimeout(() => this.type(), this.pauseAfterType);
                return;
            }
        }

        // Continuar escribiendo o borrando
        const speed = this.isDeleting ? this.deletingSpeed : this.typingSpeed;
        setTimeout(() => this.type(), speed);
    }
}

// Inicializar el typewriter cuando el DOM esté listo
document.addEventListener('DOMContentLoaded', () => {
    const typewriterElement = document.getElementById('typewriter-text');

    if (typewriterElement) {
        // Frases que se van a mostrar
        const phrases = [
            'Tecnología Simple. Patrimonio Fuerte.',
            'Gestión Digital. Eficiencia Real.',
            'Innovación Accesible. Soluciones Simples.',
            'Plataforma Confiable. Control Total.'
        ];

        // Inicializar el efecto typewriter
        new Typewriter(typewriterElement, phrases, {
            typingSpeed: 100,
            deletingSpeed: 50,
            pauseAfterType: 2000,
            pauseAfterDelete: 500
        });
    }
});
