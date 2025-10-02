// Animaciones y efectos
export const Animations = {
    init() {
        this.setupParallax();
        this.setupObservers();
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