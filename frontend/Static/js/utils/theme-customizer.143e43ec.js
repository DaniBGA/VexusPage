// Sistema de personalización de tema
export const ThemeCustomizer = {
    // Paleta de colores secundarios elegantes que respetan la estética
    colorPalette: [
        { name: 'Caramelo Clásico', value: '#8B4513', gradient: 'linear-gradient(135deg, #8B4513 0%, #A0522D 100%)' },
        { name: 'Rubí Intenso', value: '#C41E3A', gradient: 'linear-gradient(135deg, #C41E3A 0%, #E63946 100%)' },
        { name: 'Esmeralda Profundo', value: '#1B4D3E', gradient: 'linear-gradient(135deg, #1B4D3E 0%, #2D6A4F 100%)' },
        { name: 'Zafiro Imperial', value: '#0F4C81', gradient: 'linear-gradient(135deg, #0F4C81 0%, #1E6AA8 100%)' },
        { name: 'Amatista Elegante', value: '#7B2D8E', gradient: 'linear-gradient(135deg, #7B2D8E 0%, #9B4CAF 100%)' },
        { name: 'Oro Radiante', value: '#D4AF37', gradient: 'linear-gradient(135deg, #D4AF37 0%, #F4C430 100%)' },
        { name: 'Turquesa Vibrante', value: '#118AB2', gradient: 'linear-gradient(135deg, #118AB2 0%, #06AED5 100%)' },
        { name: 'Magenta Eléctrico', value: '#D90368', gradient: 'linear-gradient(135deg, #D90368 0%, #FF006E 100%)' },
        { name: 'Verde Lima', value: '#6A994E', gradient: 'linear-gradient(135deg, #6A994E 0%, #86BB5B 100%)' },
        { name: 'Naranja Fuego', value: '#E76F51', gradient: 'linear-gradient(135deg, #E76F51 0%, #F4A261 100%)' },
        { name: 'Índigo Profundo', value: '#3D405B', gradient: 'linear-gradient(135deg, #3D405B 0%, #4A4E69 100%)' },
        { name: 'Rosa Coral', value: '#F08080', gradient: 'linear-gradient(135deg, #F08080 0%, #FF9999 100%)' }
    ],

    currentTheme: null,

    init() {
        this.loadSavedTheme();
        this.createColorSelector();
        this.applyTheme();
        this.setupMutationObserver();
    },

    setupMutationObserver() {
        // Observar cambios en el DOM para aplicar tema a elementos dinámicos
        const observer = new MutationObserver((mutations) => {
            let shouldUpdate = false;
            mutations.forEach(mutation => {
                if (mutation.addedNodes.length > 0) {
                    mutation.addedNodes.forEach(node => {
                        if (node.nodeType === 1) { // Element node
                            shouldUpdate = true;
                        }
                    });
                }
            });
            if (shouldUpdate) {
                // Pequeño delay para que los elementos se rendericen completamente
                setTimeout(() => this.updateInlineStyles(), 50);
            }
        });

        observer.observe(document.body, {
            childList: true,
            subtree: true
        });
    },

    loadSavedTheme() {
        const saved = localStorage.getItem('vexusTheme');
        if (saved) {
            this.currentTheme = JSON.parse(saved);
        } else {
            // Tema por defecto
            this.currentTheme = this.colorPalette[0];
        }
    },

    saveTheme() {
        localStorage.setItem('vexusTheme', JSON.stringify(this.currentTheme));
    },

    applyTheme() {
        const root = document.documentElement;

        // Calcular una variante más oscura del color
        const darkerValue = this.adjustBrightness(this.currentTheme.value, -15);

        // Aplicar variables CSS
        root.style.setProperty('--color-primary', this.currentTheme.value);
        root.style.setProperty('--color-primary-dark', darkerValue);
        root.style.setProperty('--color-border-primary', this.currentTheme.value);

        // Actualizar sombras con el nuevo color
        const rgb = this.hexToRgb(this.currentTheme.value);
        root.style.setProperty('--shadow-primary', `0 10px 30px rgba(${rgb.r}, ${rgb.g}, ${rgb.b}, 0.3)`);
        root.style.setProperty('--color-primary-rgb', `rgba(${rgb.r}, ${rgb.g}, ${rgb.b}, 0.5)`);

        // Actualizar colores para la animación glow
        root.style.setProperty('--glow-color-start', `rgba(${rgb.r}, ${rgb.g}, ${rgb.b}, 0.3)`);
        root.style.setProperty('--glow-color-end', `rgba(${rgb.r}, ${rgb.g}, ${rgb.b}, 0.6)`);

        // Actualizar color para el brillo de las cards
        root.style.setProperty('--card-shine-color', `rgba(${rgb.r}, ${rgb.g}, ${rgb.b}, 0.1)`);

        // Actualizar elementos inline que usan el color
        this.updateInlineStyles();
    },

    updateInlineStyles() {
        // Actualizar todos los colores hardcodeados al color actual del tema
        const colorHex = this.currentTheme.value;
        const colorHexNoHash = colorHex.substring(1);

        // Buscar todos los elementos con estilos inline
        const allElements = document.querySelectorAll('[style]');
        allElements.forEach(el => {
            let style = el.getAttribute('style');
            if (!style) return;

            // Reemplazar colores principales (8B4513 y A0522D)
            style = style
                .replace(/#8B4513/gi, colorHex)
                .replace(/8B4513/g, colorHexNoHash)
                .replace(/#A0522D/gi, this.adjustBrightness(colorHex, 15));

            // Actualizar gradientes
            style = style.replace(
                /linear-gradient\(135deg,\s*#8B4513\s+0%,\s*#A0522D\s+100%\)/gi,
                this.currentTheme.gradient
            );

            el.setAttribute('style', style);
        });

        // Actualizar elementos de texto que contengan colores CSS
        const styleElements = document.querySelectorAll('style');
        styleElements.forEach(styleEl => {
            if (styleEl.textContent && (styleEl.textContent.includes('8B4513') || styleEl.textContent.includes('A0522D'))) {
                styleEl.textContent = styleEl.textContent
                    .replace(/#8B4513/gi, colorHex)
                    .replace(/#A0522D/gi, this.adjustBrightness(colorHex, 15));
            }
        });
    },

    createColorSelector() {
        const header = document.querySelector('.header .nav');
        if (!header) return;

        // Crear botón de personalización
        const customizeBtn = document.createElement('button');
        customizeBtn.className = 'customize-theme-btn';
        customizeBtn.innerHTML = `
            <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                <path d="M12 2.69l5.66 5.66a8 8 0 1 1-11.31 0z"/>
            </svg>
        `;
        customizeBtn.title = 'Personalizar tema';
        customizeBtn.setAttribute('aria-label', 'Personalizar tema');

        // Crear panel de colores
        const colorPanel = document.createElement('div');
        colorPanel.className = 'color-picker-panel';
        colorPanel.innerHTML = `
            <div class="color-picker-header">
                <h3>Personaliza tu tema</h3>
                <p>Elige tu color secundario favorito</p>
            </div>
            <div class="color-grid">
                ${this.colorPalette.map((color, index) => `
                    <button
                        class="color-option ${this.currentTheme.value === color.value ? 'active' : ''}"
                        data-index="${index}"
                        style="background: ${color.gradient}"
                        title="${color.name}">
                        <span class="color-name">${color.name}</span>
                        <span class="check-icon">
                            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3" stroke-linecap="round" stroke-linejoin="round">
                                <polyline points="20 6 9 17 4 12"></polyline>
                            </svg>
                        </span>
                    </button>
                `).join('')}
            </div>
        `;

        // Toggle panel
        customizeBtn.addEventListener('click', (e) => {
            e.stopPropagation();
            colorPanel.classList.toggle('active');
        });

        // Cerrar al hacer click fuera
        document.addEventListener('click', (e) => {
            if (!colorPanel.contains(e.target) && !customizeBtn.contains(e.target)) {
                colorPanel.classList.remove('active');
            }
        });

        // Seleccionar color
        colorPanel.addEventListener('click', (e) => {
            const colorBtn = e.target.closest('.color-option');
            if (colorBtn) {
                const index = parseInt(colorBtn.dataset.index);
                this.setTheme(index);

                // Actualizar UI
                colorPanel.querySelectorAll('.color-option').forEach(btn => {
                    btn.classList.remove('active');
                });
                colorBtn.classList.add('active');

                // Mostrar notificación
                if (window.showNotification) {
                    window.showNotification(`Tema cambiado a ${this.currentTheme.name}`, 'success');
                }
            }
        });

        // Insertar en el header
        const navLinks = header.querySelector('.nav-links');
        if (navLinks) {
            const customizeContainer = document.createElement('li');
            customizeContainer.className = 'customize-theme-container';
            customizeContainer.appendChild(customizeBtn);
            customizeContainer.appendChild(colorPanel);

            // Insertar antes del botón de login
            const loginItem = navLinks.querySelector('.login-nav-item');
            if (loginItem) {
                navLinks.insertBefore(customizeContainer, loginItem);
            } else {
                navLinks.appendChild(customizeContainer);
            }
        }
    },

    setTheme(index) {
        this.currentTheme = this.colorPalette[index];
        this.saveTheme();
        this.applyTheme();
    },

    // Utilidades de color
    hexToRgb(hex) {
        const result = /^#?([a-f\d]{2})([a-f\d]{2})([a-f\d]{2})$/i.exec(hex);
        return result ? {
            r: parseInt(result[1], 16),
            g: parseInt(result[2], 16),
            b: parseInt(result[3], 16)
        } : { r: 139, g: 69, b: 19 }; // Fallback al color original
    },

    adjustBrightness(hex, percent) {
        const rgb = this.hexToRgb(hex);
        const adjust = (value) => {
            const adjusted = value + (value * percent / 100);
            return Math.max(0, Math.min(255, Math.round(adjusted)));
        };

        const r = adjust(rgb.r).toString(16).padStart(2, '0');
        const g = adjust(rgb.g).toString(16).padStart(2, '0');
        const b = adjust(rgb.b).toString(16).padStart(2, '0');

        return `#${r}${g}${b}`;
    }
};
