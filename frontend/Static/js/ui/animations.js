// Animaciones y efectos
export const Animations = {
    init() {
        this.setupParallax();
        this.setupObservers();
        this.setupScrollAnimations();
    },

    setupParallax() {
        const hero = document.querySelector('.hero');
        let ticking = false;

        const updateParallax = () => {
            const scrolled = window.pageYOffset;

            if (window.innerWidth >= 1024) {
                if (hero && scrolled < hero.offsetHeight) {
                    hero.style.transform = `translateY(${scrolled * -0.2}px)`;
                } else if (hero) {
                    hero.style.transform = 'translateY(0)';
                }
            } else {
                if (hero) {
                    hero.style.transform = 'translateY(0)';
                }
            }

            ticking = false;
        };

        window.addEventListener('scroll', () => {
            if (!ticking) {
                requestAnimationFrame(updateParallax);
                ticking = true;
            }
        });
    },

    setupObservers() {
        const observerOptions = {
            threshold: 0.3,
            rootMargin: '0px 0px -50px 0px'
        };

        const cardsObserver = new IntersectionObserver((entries) => {
            entries.forEach(entry => {
                if (entry.isIntersecting) {
                    entry.target.style.opacity = '1';
                    entry.target.style.transform = 'translateY(0)';
                }
            });
        }, observerOptions);

        const cards = document.querySelectorAll('.card');
        cards.forEach((card, index) => {
            card.style.opacity = '0';
            card.style.transform = 'translateY(30px)';
            card.style.transition = `opacity 0.6s ease ${index * 0.1}s, transform 0.6s ease ${index * 0.1}s`;
            cardsObserver.observe(card);
        });

        // Efecto parallax más avanzado para tarjetas de servicio
        this.setupServiceCardsParallax();
    },

    setupServiceCardsParallax() {
        // Esperar a que el DOM esté completamente cargado
        const initParallax = () => {
            const serviceCards = document.querySelectorAll('.service-unit-card');
            
            if (serviceCards.length === 0) {
                return;
            }

            const observerOptions = {
                threshold: 0.05,
                rootMargin: '0px'
            };

            const parallaxObserver = new IntersectionObserver((entries) => {
                entries.forEach(entry => {
                    if (entry.isIntersecting) {
                        entry.target.classList.add('parallax-active');
                    }
                });
            }, observerOptions);

            serviceCards.forEach(card => {
                parallaxObserver.observe(card);
            });

            // Agregar efecto parallax al scroll
            let ticking = false;
            
            const updateCardParallax = () => {
                const activeCards = document.querySelectorAll('.service-unit-card.parallax-active');
                
                activeCards.forEach((card, index) => {
                    const rect = card.getBoundingClientRect();
                    const windowHeight = window.innerHeight;
                    const cardCenter = rect.top + rect.height / 2;
                    const windowCenter = windowHeight / 2;
                    
                    // Calcular qué tan lejos está la carta del centro de la pantalla
                    // Valores: -1 (arriba) a 1 (abajo), 0 = centrado
                    const distanceFromCenter = (cardCenter - windowCenter) / windowCenter;
                    
                    // Solo aplicar parallax cuando la carta está visible
                    if (rect.top < windowHeight && rect.bottom > 0) {
                        // Carta izquierda (índice 0) - se mueve desde izquierda
                        // Carta derecha (índice 1) - se mueve desde derecha
                        const isLeftCard = index === 0;
                        
                        // Cuando distanceFromCenter > 0: carta está abajo del centro
                        // Cuando distanceFromCenter < 0: carta está arriba del centro
                        // Cuando distanceFromCenter = 0: carta está centrada
                        
                        // Movimiento horizontal: desde los lados hacia el centro
                        const maxOffset = 150; // píxeles máximos de desplazamiento
                        let moveX;
                        
                        if (isLeftCard) {
                            // Carta izquierda: empieza desde la izquierda (-150px) y va a 0
                            moveX = -maxOffset * Math.max(0, distanceFromCenter);
                        } else {
                            // Carta derecha: empieza desde la derecha (150px) y va a 0
                            moveX = maxOffset * Math.max(0, distanceFromCenter);
                        }
                        
                        // Limitar el movimiento
                        moveX = Math.max(Math.min(moveX, maxOffset), -maxOffset);
                        
                        // Calcular opacidad: 0 cuando está en maxOffset, 1 cuando está centrada (0)
                        // distanceFromCenter va de 1 (abajo) a -1 (arriba)
                        // Cuando está abajo (distanceFromCenter = 1), opacity = 0
                        // Cuando está centrado (distanceFromCenter = 0), opacity = 1
                        const opacity = 1 - Math.max(0, Math.min(1, distanceFromCenter));
                        
                        card.style.setProperty('--parallax-x', `${moveX}px`);
                        card.style.setProperty('--parallax-y', '0px');
                        card.style.setProperty('--parallax-opacity', opacity);
                    }
                });
                
                ticking = false;
            };

            window.addEventListener('scroll', () => {
                if (!ticking && window.innerWidth >= 768) {
                    requestAnimationFrame(updateCardParallax);
                    ticking = true;
                }
            });

            // Ejecutar una vez al inicio para posicionar correctamente
            updateCardParallax();
        };

        // Si el DOM ya está cargado, inicializar inmediatamente
        if (document.readyState === 'loading') {
            document.addEventListener('DOMContentLoaded', initParallax);
        } else {
            initParallax();
        }
    },

    setupScrollAnimations() {
        const observerOptions = {
            threshold: 0.15,
            rootMargin: '0px 0px -100px 0px'
        };

        const scrollObserver = new IntersectionObserver((entries) => {
            entries.forEach(entry => {
                if (entry.isIntersecting) {
                    entry.target.classList.add('is-visible');
                }
            });
        }, observerOptions);

        // Animar títulos de sección
        const sectionTitles = document.querySelectorAll('.section-title');
        sectionTitles.forEach(title => {
            title.classList.add('scroll-animate');
            scrollObserver.observe(title);
        });

        // Animar subtítulos
        const sectionSubtitles = document.querySelectorAll('.section-subtitle');
        sectionSubtitles.forEach(subtitle => {
            subtitle.classList.add('scroll-animate');
            scrollObserver.observe(subtitle);
        });

        // Animar tarjetas de campus con efecto escalonado
        const campusCards = document.querySelectorAll('.campus-card');
        campusCards.forEach((card, index) => {
            card.classList.add('scroll-animate-scale');
            card.style.transitionDelay = `${index * 0.1}s`;
            scrollObserver.observe(card);
        });

        // Animar contenido "sobre nosotros"
        const aboutText = document.querySelectorAll('.about-text h3, .about-text p');
        aboutText.forEach((element, index) => {
            const animClass = index % 2 === 0 ? 'scroll-animate-left' : 'scroll-animate-right';
            element.classList.add(animClass);
            element.style.transitionDelay = `${index * 0.1}s`;
            scrollObserver.observe(element);
        });

        // Animar grid de servicios
        const servicesGrid = document.querySelector('.cards-grid');
        if (servicesGrid) {
            servicesGrid.classList.add('scroll-animate');
            scrollObserver.observe(servicesGrid);
        }

        // Animar campus grid
        const campusGrid = document.querySelector('.campus-grid');
        if (campusGrid) {
            campusGrid.classList.add('scroll-animate');
            scrollObserver.observe(campusGrid);
        }

        // Animar contenido del hero
        const heroContent = document.querySelector('.hero-content');
        if (heroContent) {
            heroContent.classList.add('scroll-animate');
            scrollObserver.observe(heroContent);
        }

        // Animar botones CTA
        const ctaButtons = document.querySelectorAll('.cta-button');
        ctaButtons.forEach(button => {
            button.classList.add('scroll-animate-scale');
            scrollObserver.observe(button);
        });
    },

    animateCounter(element, target) {
        let current = 0;
        const hasPercent = element.textContent.includes('%');
        const hasPlus = element.textContent.includes('+');

        const increment = target / 60;

        const timer = setInterval(() => {
            current += increment;
            if (current >= target) {
                let suffix = hasPercent ? '%' : (hasPlus ? '+' : '');
                element.textContent = target + suffix;
                clearInterval(timer);
            } else {
                let suffix = hasPercent ? '%' : (hasPlus ? '+' : '');
                element.textContent = Math.floor(current) + suffix;
            }
        }, 16);
    }
};