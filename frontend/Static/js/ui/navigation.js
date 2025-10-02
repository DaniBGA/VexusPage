// Gestión de navegación
import { AuthService } from '../api/auth.js';

export const Navigation = {
    init() {
        this.setupMobileMenu();
        this.setupSmoothScroll();
        this.setupHeaderScroll();
        this.updateLoginButton();
    },

    setupMobileMenu() {
        const mobileMenuBtn = document.getElementById('mobileMenuBtn');
        const navLinks = document.getElementById('navLinks');

        if (mobileMenuBtn && navLinks) {
            mobileMenuBtn.addEventListener('click', () => {
                mobileMenuBtn.classList.toggle('active');
                navLinks.classList.toggle('active');
            });

            navLinks.addEventListener('click', (e) => {
                if (e.target.tagName === 'A') {
                    mobileMenuBtn.classList.remove('active');
                    navLinks.classList.remove('active');
                }
            });

            document.addEventListener('click', (e) => {
                if (!mobileMenuBtn.contains(e.target) && !navLinks.contains(e.target)) {
                    mobileMenuBtn.classList.remove('active');
                    navLinks.classList.remove('active');
                }
            });
        }
    },

    setupSmoothScroll() {
        document.querySelectorAll('a[href^="#"]').forEach(anchor => {
            anchor.addEventListener('click', function (e) {
                e.preventDefault();
                const target = document.querySelector(this.getAttribute('href'));
                if (target) {
                    const headerHeight = document.querySelector('header').offsetHeight;
                    const targetPosition = target.offsetTop - headerHeight;
                    
                    window.scrollTo({
                        top: targetPosition,
                        behavior: 'smooth'
                    });
                }
            });
        });
    },

    setupHeaderScroll() {
        let lastScrollTop = 0;
        const header = document.querySelector('header');

        window.addEventListener('scroll', () => {
            const scrollTop = window.pageYOffset || document.documentElement.scrollTop;
            
            if (scrollTop > lastScrollTop && scrollTop > 100) {
                header.style.transform = 'translateY(-100%)';
            } else {
                header.style.transform = 'translateY(0)';
            }
            
            lastScrollTop = scrollTop;
        }, false);
    },

    updateLoginButton() {
        const loginBtn = document.getElementById('loginNavBtn');
        const logoutBtn = document.getElementById('logoutBtn');
        const loginLi = loginBtn ? loginBtn.parentElement : null;
        const logoutLi = logoutBtn ? logoutBtn.parentElement : null;

        if (AuthService.isAuthenticated()) {
            if (loginBtn) loginBtn.style.display = 'none';
            if (loginLi) loginLi.style.display = 'none';
            if (logoutBtn) logoutBtn.style.display = 'flex';
            if (logoutLi) logoutLi.style.display = 'list-item';
        } else {
            if (loginBtn) loginBtn.style.display = 'flex';
            if (loginLi) loginLi.style.display = 'list-item';
            if (logoutBtn) logoutBtn.style.display = 'none';
            if (logoutLi) logoutLi.style.display = 'none';
        }
    },

    showUserMenu(user) {
        if (confirm(`¡Hola ${user.name}! ¿Deseas cerrar sesión?`)) {
            AuthService.logout();
        }
    }
};