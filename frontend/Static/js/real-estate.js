/* ===================================
   REAL ESTATE PAGE - PARALLAX & SCROLL
   =================================== */

(function() {
    'use strict';

    // Estado de scroll
    let scrollPosition = 0;
    let ticking = false;

    // Elementos
    const parallaxBg = document.getElementById('parallaxBg');
    const contentSections = document.querySelectorAll('.content-section');
    const heroSection = document.querySelector('.real-estate-hero');

    /**
     * Inicializa la página
     */
    function init() {
        setupParallax();
        setupScrollAnimations();
        setupMobileMenu();
        
        // Activar primera sección
        if (contentSections.length > 0) {
            contentSections[0].classList.add('active');
        }
    }

    /**
     * Configura el efecto parallax
     */
    function setupParallax() {
        window.addEventListener('scroll', onScroll, { passive: true });
    }

    /**
     * Maneja el evento de scroll con throttling
     */
    function onScroll() {
        scrollPosition = window.pageYOffset;

        if (!ticking) {
            window.requestAnimationFrame(() => {
                updateParallax();
                updateSectionVisibility();
                ticking = false;
            });
            ticking = true;
        }
    }

    /**
     * Actualiza el efecto parallax del background
     */
    function updateParallax() {
        if (!parallaxBg) return;

        const heroHeight = heroSection ? heroSection.offsetHeight : window.innerHeight;
        
        // Solo aplicar parallax mientras estemos en el hero
        if (scrollPosition < heroHeight) {
            // Movimiento más lento del background (0.5 = mitad de velocidad)
            const parallaxSpeed = 0.5;
            const yPos = scrollPosition * parallaxSpeed;
            
            // Aplicar transformación
            parallaxBg.style.transform = `translate3d(0, ${yPos}px, 0)`;
            
            // Fade out gradual del hero
            const opacity = 1 - (scrollPosition / heroHeight);
            heroSection.style.opacity = Math.max(0, opacity);
        } else {
            // Mantener el background fijo cuando pasamos el hero
            parallaxBg.style.transform = `translate3d(0, ${heroHeight * 0.5}px, 0)`;
            if (heroSection) {
                heroSection.style.opacity = 0;
            }
        }
    }

    /**
     * Actualiza la visibilidad de las secciones
     */
    function updateSectionVisibility() {
        const windowHeight = window.innerHeight;
        const triggerPoint = windowHeight * 0.7;

        contentSections.forEach(section => {
            const sectionTop = section.getBoundingClientRect().top;
            
            if (sectionTop < triggerPoint) {
                section.classList.add('active');
            }
        });
    }

    /**
     * Configura las animaciones de scroll
     */
    function setupScrollAnimations() {
        // Smooth scroll para enlaces internos
        document.querySelectorAll('a[href^="#"]').forEach(anchor => {
            anchor.addEventListener('click', function(e) {
                const href = this.getAttribute('href');
                if (href === '#' || href === '') return;
                
                e.preventDefault();
                const target = document.querySelector(href);
                
                if (target) {
                    const offsetTop = target.offsetTop;
                    window.scrollTo({
                        top: offsetTop,
                        behavior: 'smooth'
                    });
                }
            });
        });

        // Observador de intersección para animaciones más suaves
        if ('IntersectionObserver' in window) {
            const observerOptions = {
                threshold: 0.15,
                rootMargin: '0px 0px -100px 0px'
            };

            const observer = new IntersectionObserver((entries) => {
                entries.forEach(entry => {
                    if (entry.isIntersecting) {
                        entry.target.classList.add('active');
                    }
                });
            }, observerOptions);

            contentSections.forEach(section => {
                observer.observe(section);
            });
        }
    }

    /**
     * Configura el menú móvil
     */
    function setupMobileMenu() {
        const mobileMenuBtn = document.getElementById('mobileMenuBtn');
        const navLinks = document.getElementById('navLinks');

        if (mobileMenuBtn && navLinks) {
            mobileMenuBtn.addEventListener('click', () => {
                mobileMenuBtn.classList.toggle('active');
                navLinks.classList.toggle('active');
            });

            // Cerrar menú al hacer click en un enlace
            navLinks.querySelectorAll('a').forEach(link => {
                link.addEventListener('click', () => {
                    mobileMenuBtn.classList.remove('active');
                    navLinks.classList.remove('active');
                });
            });
        }
    }

    /**
     * Maneja el cambio de tamaño de ventana
     */
    function handleResize() {
        // Recalcular parallax en resize
        updateParallax();
        updateSectionVisibility();
    }

    // Debounce para resize
    let resizeTimeout;
    window.addEventListener('resize', () => {
        clearTimeout(resizeTimeout);
        resizeTimeout = setTimeout(handleResize, 250);
    });

    /**
     * Optimización de performance
     */
    function optimizePerformance() {
        // Desactivar parallax en dispositivos móviles o motion reducido
        const isMobile = window.innerWidth < 768;
        const prefersReducedMotion = window.matchMedia('(prefers-reduced-motion: reduce)').matches;

        if (isMobile || prefersReducedMotion) {
            if (parallaxBg) {
                parallaxBg.style.position = 'absolute';
                parallaxBg.style.transform = 'none';
            }
            
            contentSections.forEach(section => {
                section.classList.add('active');
            });
        }
    }

    /**
     * Scroll suave al inicio
     */
    function scrollToTop() {
        window.scrollTo({
            top: 0,
            behavior: 'smooth'
        });
    }

    // Exponer función globalmente si es necesario
    window.realEstateScrollToTop = scrollToTop;

    /**
     * Iniciar cuando el DOM esté listo
     */
    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', init);
    } else {
        init();
    }

    // Optimizar performance después de cargar
    window.addEventListener('load', optimizePerformance);

    /**
     * Cleanup al salir de la página
     */
    window.addEventListener('beforeunload', () => {
        window.removeEventListener('scroll', onScroll);
    });

})();
