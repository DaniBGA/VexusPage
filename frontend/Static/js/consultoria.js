// Consultoría Page - JavaScript functionality

document.addEventListener('DOMContentLoaded', function() {
    // Mobile menu toggle
    const mobileMenuBtn = document.getElementById('mobileMenuBtn');
    const navLinks = document.getElementById('navLinks');

    if (mobileMenuBtn && navLinks) {
        mobileMenuBtn.addEventListener('click', function() {
            navLinks.classList.toggle('active');
            mobileMenuBtn.classList.toggle('active');
        });
    }

    // Carousel functionality
    const carouselTrack = document.getElementById('whatWeDoCarousel');
    const prevBtn = document.querySelector('.carousel-btn-prev');
    const nextBtn = document.querySelector('.carousel-btn-next');
    const trackContainer = document.querySelector('.carousel-track-container');

    if (carouselTrack && prevBtn && nextBtn && trackContainer) {
        const cards = carouselTrack.querySelectorAll('.carousel-card');
        let currentIndex = 0;

        function getCardWidth() {
            if (cards.length > 0) {
                const cardStyle = window.getComputedStyle(cards[0]);
                const cardWidth = cards[0].offsetWidth;
                const gap = parseFloat(window.getComputedStyle(carouselTrack).gap) || 16;
                return cardWidth + gap;
            }
            return 296; // fallback: 280px card + 16px gap
        }

        function updateCarousel() {
            const cardWidth = getCardWidth();
            const containerWidth = trackContainer.offsetWidth;
            const maxIndex = Math.max(0, cards.length - Math.floor(containerWidth / cardWidth));
            
            if (currentIndex < 0) currentIndex = 0;
            if (currentIndex > maxIndex) currentIndex = maxIndex;

            const offset = -currentIndex * cardWidth;
            carouselTrack.style.transform = `translateX(${offset}px)`;
            carouselTrack.style.transition = 'transform 0.3s ease';
        }

        prevBtn.addEventListener('click', function() {
            currentIndex--;
            updateCarousel();
        });

        nextBtn.addEventListener('click', function() {
            currentIndex++;
            updateCarousel();
        });

        // Touch/swipe support for mobile
        let startX = 0;
        let currentX = 0;
        let isDragging = false;

        trackContainer.addEventListener('touchstart', function(e) {
            startX = e.touches[0].clientX;
            isDragging = true;
        });

        trackContainer.addEventListener('touchmove', function(e) {
            if (!isDragging) return;
            currentX = e.touches[0].clientX;
        });

        trackContainer.addEventListener('touchend', function() {
            if (!isDragging) return;
            
            const diff = startX - currentX;
            if (Math.abs(diff) > 50) {
                if (diff > 0) {
                    currentIndex++;
                } else {
                    currentIndex--;
                }
                updateCarousel();
            }
            isDragging = false;
        });

        // Responsive resize
        window.addEventListener('resize', updateCarousel);
        
        // Initial update
        updateCarousel();
    }

    // Smooth scroll for anchor links
    document.querySelectorAll('a[href^="#"]').forEach(anchor => {
        anchor.addEventListener('click', function (e) {
            e.preventDefault();
            const target = document.querySelector(this.getAttribute('href'));
            if (target) {
                target.scrollIntoView({
                    behavior: 'smooth',
                    block: 'start'
                });
            }
        });
    });

    // Intersection Observer for scroll animations
    const observerOptions = {
        threshold: 0.1,
        rootMargin: '0px 0px -100px 0px'
    };

    const observer = new IntersectionObserver(function(entries) {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                entry.target.style.opacity = '1';
                entry.target.style.transform = 'translateY(0)';
            }
        });
    }, observerOptions);

    // Observe all service cards and methodology steps
    document.querySelectorAll('.service-card, .methodology-step, .carousel-card').forEach(el => {
        el.style.opacity = '0';
        el.style.transform = 'translateY(20px)';
        el.style.transition = 'opacity 0.6s ease, transform 0.6s ease';
        observer.observe(el);
    });

    // ==================== LAPTOP ANIMATION ====================
    initLaptopAnimation();
});

function initLaptopAnimation() {
    const typingSpeed = 20;
    const linePause = 150;

    // Código estructurado con tokens para resaltado de sintaxis
    const structuredCode = [
        [ {t: "// Inicializando módulo...", c: "comment"} ],
        [ ],
        [ 
          {t: "import", c: "control"}, {t: " "}, 
          {t: "TensorFlow", c: "class"}, {t: " "}, 
          {t: "from", c: "control"}, {t: " "}, 
          {t: "'@tensorflow/tfjs'", c: "string"}, {t: ";"} 
        ],
        [ ],
        [ 
          {t: "async", c: "keyword"}, {t: " "}, 
          {t: "function", c: "keyword"}, {t: " "}, 
          {t: "train", c: "function"}, {t: "("}, {t: "data", c: "variable"}, {t: ")"}, {t: " "}, {t: "{"} 
        ],
        [ 
          {t: "  "}, {t: "const", c: "keyword"}, {t: " "}, 
          {t: "model", c: "variable"}, {t: " "}, {t: "=", c: "plain"}, {t: " "}, 
          {t: "TensorFlow", c: "class"}, {t: "."}, {t: "sequential", c: "function"}, {t: "();"} 
        ],
        [
          {t: "  "}, {t: "model", c: "variable"}, {t: "."}, {t: "add", c: "function"}, {t: "("},
          {t: "layers", c: "property"}, {t: "."},
          {t: "dense", c: "function"}, {t: "({ "}, 
          {t: "units", c: "property"}, {t: ": "}, {t: "128", c: "number"},
          {t: " }));"}
        ],
        [ ],
        [ {t: "  "}, {t: "// Entrenando...", c: "comment"} ],
        [
          {t: "  "}, {t: "await", c: "keyword"}, {t: " "},
          {t: "model", c: "variable"}, {t: "."}, {t: "fit", c: "function"}, {t: "("},
          {t: "data", c: "variable"}, {t: ");"}
        ],
        [ ],
        [ 
          {t: "  "}, {t: "return", c: "control"}, {t: " "}, {t: "model", c: "variable"}, {t: ";"} 
        ],
        [ {t: "}"} ],
        [ ],
        [ {t: "> Compilando...", c: "comment"}],
        [ {t: "[DONE]", c: "plain"}]
    ];

    const codeDisplay = document.getElementById('code-display');
    const cursor = document.querySelector('.cursor');
    const codeScreen = document.getElementById('code-screen');
    const codeContainer = document.getElementById('code-container');
    const successWrapper = document.getElementById('success-wrapper');

    if (!codeDisplay || !cursor || !codeScreen || !successWrapper || !codeContainer) return;

    let lineIndex = 0;
    let tokenIndex = 0;
    let charIndex = 0;
    let currentSpan = null;

    function typeWriter() {
        if (lineIndex >= structuredCode.length) {
            endAnimation();
            return;
        }

        const currentLineData = structuredCode[lineIndex];

        if (currentLineData.length === 0 || tokenIndex >= currentLineData.length) {
            codeDisplay.appendChild(document.createTextNode('\n'));
            lineIndex++;
            tokenIndex = 0;
            charIndex = 0;
            currentSpan = null;
            scrollToBottom();
            setTimeout(typeWriter, linePause);
            return;
        }

        const currentToken = currentLineData[tokenIndex];

        if (currentSpan === null) {
            currentSpan = document.createElement('span');
            if (currentToken.c) {
                currentSpan.className = `token-${currentToken.c}`;
            }
            codeDisplay.appendChild(currentSpan);
        }

        if (charIndex < currentToken.t.length) {
            currentSpan.textContent += currentToken.t.charAt(charIndex);
            charIndex++;
            scrollToBottom();
            setTimeout(typeWriter, typingSpeed);
        } else {
            charIndex = 0;
            tokenIndex++;
            currentSpan = null;
            typeWriter();
        }
    }

    function scrollToBottom() {
        codeContainer.scrollTop = codeContainer.scrollHeight;
    }

    function endAnimation() {
        cursor.style.display = 'none';
        codeScreen.classList.add('code-finished');

        setTimeout(() => {
            successWrapper.style.display = 'flex';
            setTimeout(() => {
                successWrapper.classList.add('visible');
                successWrapper.classList.add('run-animation');
            }, 50);
        }, 800);
    }

    // Iniciar animación cuando la tarjeta esté visible
    const laptopObserver = new IntersectionObserver((entries) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                setTimeout(typeWriter, 1000);
                laptopObserver.disconnect();
            }
        });
    }, { threshold: 0.3 });

    const laptopWrapper = document.querySelector('.laptop-animation-wrapper');
    if (laptopWrapper) {
        laptopObserver.observe(laptopWrapper);
    }
}

// ==================== DEMO MODAL ====================
const demoModal = document.getElementById('demoModal');
const demoLinks = document.querySelectorAll('.demo-link');
const closeModal = document.getElementById('closeModal');
const closeModalBtn = document.getElementById('closeModalBtn');

if (demoLinks && demoModal && closeModal && closeModalBtn) {
    demoLinks.forEach(link => {
        link.addEventListener('click', function(e) {
            e.preventDefault();
            demoModal.classList.add('show');
            document.body.style.overflow = 'hidden';
        });
    });

    closeModal.addEventListener('click', function() {
        demoModal.classList.remove('show');
        document.body.style.overflow = '';
    });

    closeModalBtn.addEventListener('click', function() {
        demoModal.classList.remove('show');
        document.body.style.overflow = '';
    });

    demoModal.addEventListener('click', function(e) {
        if (e.target === demoModal) {
            demoModal.classList.remove('show');
            document.body.style.overflow = '';
        }
    });
}
