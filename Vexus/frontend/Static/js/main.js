// Archivo principal - Orquestador
import CONFIG from './config.js';
import { AuthService } from './api/auth.js';
import { DataService } from './api/services.js';
import { Navigation } from './ui/navigation.js';
import { ModalManager } from './ui/modal.js';
import { Animations } from './ui/animations.js';
import { showLoading, hideLoading, showConnectionStatus } from './utils/helpers.js';

class App {
    constructor() {
        this.init();
    }

    async init() {
        // Inicializar componentes UI
        Navigation.init();
        Animations.init();

        // Verificar conexión
        await this.testConnection();

        // Inicializar formularios
        this.initForms();

        // Hacer funciones globales para el HTML
        this.exposeGlobalFunctions();
    }

    async testConnection() {
        try {
            const response = await fetch(`${CONFIG.API_BASE_URL.replace('/api/v1', '')}/health`);
            if (response.ok) {
                showConnectionStatus(true);
                await this.loadInitialData();
            } else {
                throw new Error('Connection failed');
            }
        } catch (error) {
            console.error('Backend connection failed:', error);
            showConnectionStatus(false, 'Error de conexión');
            this.loadFallbackData();
        }
    }

    async loadInitialData() {
        try {
            showLoading();
            const [services, sections] = await Promise.all([
                DataService.getServices(),
                DataService.getCampusSections()
            ]);
            this.updateServicesSection(services);
            this.updateCampusSection(sections);
        } catch (error) {
            console.error('Failed to load initial data:', error);
        } finally {
            hideLoading();
        }
    }

    loadFallbackData() {
        // Datos de respaldo cuando no hay conexión
        const servicesGrid = document.getElementById('servicesGrid');
        if (servicesGrid) {
            servicesGrid.innerHTML = `
                <div class="card">
                    <h3>Sin conexión</h3>
                    <p>No se pudo conectar con el servidor. Por favor, verifica tu conexión.</p>
                </div>
            `;
        }
    }

    updateServicesSection(services) {
        const servicesGrid = document.getElementById('servicesGrid');
        if (!servicesGrid) return;

        servicesGrid.innerHTML = services.map(service => `
            <div class="card">
                <h3>${service.name}</h3>
                <p>${service.description}</p>
            </div>
        `).join('');
    }

    updateCampusSection(sections) {
        const campusGrid = document.getElementById('campusGrid');
        if (!campusGrid) return;

        campusGrid.innerHTML = sections.map(section => `
            <div class="campus-card ${section.section_type}-card blur-when-logged-out">
                <div class="card-icon">${section.icon || '📊'}</div>
                <h3>${section.name}</h3>
                <p>${section.description}</p>
                <button class="campus-btn" onclick="app.redirectTo('${section.section_type}')">
                    ${section.section_type === 'dashboard' ? 'Acceder' : 
                      section.section_type === 'learning' ? 'Comenzar' : 'Explorar'}
                </button>
                <div class="login-overlay">
                    <div class="overlay-content">
                        <span class="lock-icon">🔒</span>
                        <p>Inicia sesión para acceder</p>
                    </div>
                </div>
            </div>
        `).join('');
    }

    initForms() {
        // Login Form
        const loginForm = document.getElementById('loginForm');
        if (loginForm) {
            loginForm.addEventListener('submit', async (e) => {
                e.preventDefault();
                await this.handleLogin(e.target);
            });
        }

        // Register Form
        const registerForm = document.getElementById('registerForm');
        if (registerForm) {
            registerForm.addEventListener('submit', async (e) => {
                e.preventDefault();
                await this.handleRegister(e.target);
            });
        }

        // Contact Form
        const contactForm = document.getElementById('contactForm');
        if (contactForm) {
            contactForm.addEventListener('submit', async (e) => {
                e.preventDefault();
                await this.handleContact(e.target);
            });
        }
    }

    // main.js o donde manejes el login
    async handleLogin(form) {
        const email = form.email.value;
        const password = form.password.value;
        const submitBtn = form.querySelector('.btn-submit'); // Botón de submit
        
        submitBtn.disabled = true;
        submitBtn.textContent = 'Iniciando Sesión...';

        try {
            const response = await AuthService.login(email, password);

            if (response.success) {
                ModalManager.close('loginModal');
                alert('¡Bienvenido! Sesión iniciada correctamente.');
                Navigation.updateLoginButton(); // <-- Esto actualiza el botón
                // window.location.reload(); // Solo recarga si es necesario
            } else {
                alert(response.message); // Mostrar mensaje específico
            }
        } catch (error) {
            alert('Error inesperado. Inténtalo más tarde.');
        } finally {
            submitBtn.disabled = false;
            submitBtn.textContent = 'Iniciar Sesión';
        }
    }


    async handleRegister(form) {
        const name = form.name.value;
        const email = form.email.value;
        const password = form.password.value;
        const confirmPassword = form.confirmPassword.value;
        const submitBtn = form.querySelector('.btn-submit');  // Era .login-submit
        
        if (password !== confirmPassword) {
            alert('Las contraseñas no coinciden.');
            return;
        }
        
        submitBtn.disabled = true;
        submitBtn.textContent = 'Creando Cuenta...';
        
        try {
            const response = await AuthService.register(name, email, password);
            
            if (response.success) {
                alert('¡Cuenta creada exitosamente! Ahora puedes iniciar sesión.');
                ModalManager.switchModal('registerModal', 'loginModal');
            } else {
                alert('Error al crear la cuenta: ' + response.message);
            }
        } catch (error) {
            alert('Error al conectar con el servidor. Inténtalo más tarde.');
        } finally {
            submitBtn.disabled = false;
            submitBtn.textContent = 'Crear Cuenta';
        }
    }

    async handleContact(form) {
        const message = {
            name: form.name.value,
            email: form.email.value,
            subject: form.subject.value,
            message: form.message.value
        };
        
        const submitBtn = form.querySelector('.btn-submit');  // Era .login-submit
        submitBtn.disabled = true;
        submitBtn.textContent = 'Enviando...';
        
        try {
            await DataService.sendContactMessage(message);
            alert('¡Mensaje enviado exitosamente!');
            ModalManager.close('contactModal');
            form.reset();
        } catch (error) {
            alert('Error al enviar el mensaje. Inténtalo más tarde.');
        } finally {
            submitBtn.disabled = false;
            submitBtn.textContent = 'Enviar Mensaje';
        }
    }

    async redirectTo(section) {
        if (!AuthService.isAuthenticated()) {
            alert('Por favor, inicia sesión para acceder a esta función');
            ModalManager.open('loginModal');
            return;
        }
        
        try {
            showLoading();
            switch(section) {
                case 'dashboard':
                    await this.showDashboard();
                    break;
                case 'learning':
                    await this.showLearning();
                    break;
                case 'tools':
                    await this.showTools();
                    break;
                default:
                    alert('Función en desarrollo...');
            }
        } catch (error) {
            alert('Error al cargar la sección. Inténtalo más tarde.');
            console.error('Redirect error:', error);
        } finally {
            hideLoading();
        }
    }

    async showDashboard() {
        const stats = await DataService.getDashboardStats();
        const projects = await DataService.getProjects();
        
        // Crear y mostrar modal de dashboard
        const modal = document.createElement('div');
        modal.className = 'modal';
        modal.style.display = 'block';
        modal.innerHTML = `
            <div class="modal-content" style="max-width: 800px; max-height: 80vh; overflow-y: auto;">
                <span class="close" onclick="this.parentElement.parentElement.remove()">&times;</span>
                <div class="modal-header">
                    <h2>Dashboard</h2>
                    <p>Tu resumen de actividad</p>
                </div>
                <div class="dashboard-content" style="padding: 2rem;">
                    <div class="stats-grid" style="display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 1rem; margin-bottom: 2rem;">
                        <div class="stat-card" style="background: #1a1a1a; padding: 1.5rem; border-radius: 10px; text-align: center;">
                            <h3 style="color: #8B4513;">Proyectos</h3>
                            <p style="font-size: 2rem; font-weight: bold;">${stats.projects_count}</p>
                        </div>
                        <div class="stat-card" style="background: #1a1a1a; padding: 1.5rem; border-radius: 10px; text-align: center;">
                            <h3 style="color: #8B4513;">Cursos Completados</h3>
                            <p style="font-size: 2rem; font-weight: bold;">${stats.completed_courses}/${stats.total_courses}</p>
                        </div>
                        <div class="stat-card" style="background: #1a1a1a; padding: 1.5rem; border-radius: 10px; text-align: center;">
                            <h3 style="color: #8B4513;">Progreso</h3>
                            <p style="font-size: 2rem; font-weight: bold;">${Math.round(stats.completion_rate)}%</p>
                        </div>
                    </div>
                    
                    <h3 style="color: #8B4513; margin-bottom: 1rem;">Proyectos Recientes</h3>
                    <div class="projects-list">
                        ${projects.length > 0 ? projects.slice(0, 3).map(project => `
                            <div style="background: #1a1a1a; padding: 1rem; border-radius: 8px; margin-bottom: 1rem;">
                                <h4>${project.name}</h4>
                                <p style="color: #888; font-size: 0.9rem;">${project.description || 'Sin descripción'}</p>
                                <span style="color: #8B4513; font-size: 0.8rem;">${project.status}</span>
                            </div>
                        `).join('') : '<p style="color: #888;">No tienes proyectos aún</p>'}
                    </div>
                </div>
            </div>
        `;
        document.body.appendChild(modal);
    }

    async showLearning() {
        const courses = await DataService.getCourses();
        
        const modal = document.createElement('div');
        modal.className = 'modal';
        modal.style.display = 'block';
        modal.innerHTML = `
            <div class="modal-content" style="max-width: 900px; max-height: 80vh; overflow-y: auto;">
                <span class="close" onclick="this.parentElement.parentElement.remove()">&times;</span>
                <div class="modal-header">
                    <h2>Cursos Disponibles</h2>
                    <p>Mejora tus habilidades</p>
                </div>
                <div class="courses-content" style="padding: 2rem;">
                    <div class="courses-grid" style="display: grid; grid-template-columns: repeat(auto-fit, minmax(300px, 1fr)); gap: 1.5rem;">
                        ${courses.map(course => `
                            <div class="course-card" style="background: #1a1a1a; padding: 1.5rem; border-radius: 15px; border: 1px solid #333;">
                                <h3 style="color: #8B4513; margin-bottom: 1rem;">${course.title}</h3>
                                <p style="color: #c0c0c0; margin-bottom: 1rem; font-size: 0.9rem;">${course.description}</p>
                                <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 1rem;">
                                    <span style="background: #8B4513; color: white; padding: 0.3rem 0.8rem; border-radius: 15px; font-size: 0.8rem;">${course.difficulty_level}</span>
                                    <span style="color: #888; font-size: 0.9rem;">${course.duration_hours}h</span>
                                </div>
                                <button onclick="app.startCourse('${course.id}')" style="width: 100%; background: linear-gradient(135deg, #8B4513 0%, #A0522D 100%); color: white; padding: 0.8rem; border: none; border-radius: 8px; cursor: pointer;">
                                    Comenzar Curso
                                </button>
                            </div>
                        `).join('')}
                    </div>
                </div>
            </div>
        `;
        document.body.appendChild(modal);
    }

    async showTools() {
        const tools = await DataService.getTools();
        
        const modal = document.createElement('div');
        modal.className = 'modal';
        modal.style.display = 'block';
        modal.innerHTML = `
            <div class="modal-content" style="max-width: 900px; max-height: 80vh; overflow-y: auto;">
                <span class="close" onclick="this.parentElement.parentElement.remove()">&times;</span>
                <div class="modal-header">
                    <h2>Herramientas</h2>
                    <p>Suite completa de herramientas</p>
                </div>
                <div class="tools-content" style="padding: 2rem;">
                    <div class="tools-grid" style="display: grid; grid-template-columns: repeat(auto-fit, minmax(250px, 1fr)); gap: 1.5rem;">
                        ${tools.map(tool => `
                            <div class="tool-card" style="background: #1a1a1a; padding: 1.5rem; border-radius: 15px; border: 1px solid #333; text-align: center;">
                                <div style="font-size: 2.5rem; margin-bottom: 1rem;">${tool.icon || '🛠️'}</div>
                                <h3 style="color: #8B4513; margin-bottom: 1rem;">${tool.name}</h3>
                                <p style="color: #c0c0c0; margin-bottom: 1.5rem; font-size: 0.9rem;">${tool.description}</p>
                                <button ${tool.has_access ? '' : 'disabled'} 
                                    style="background: ${tool.has_access ? 'linear-gradient(135deg, #8B4513 0%, #A0522D 100%)' : '#666'}; 
                                    color: white; padding: 0.8rem 1.5rem; border: none; border-radius: 8px; cursor: ${tool.has_access ? 'pointer' : 'not-allowed'};">
                                    ${tool.has_access ? 'Abrir Herramienta' : 'Sin Acceso'}
                                </button>
                            </div>
                        `).join('')}
                    </div>
                </div>
            </div>
        `;
        document.body.appendChild(modal);
    }

    startCourse(courseId) {
        alert(`Iniciando curso...\nEsta funcionalidad estará disponible pronto.`);
    }

    exposeGlobalFunctions() {
        // Exponer funciones para el HTML
        window.app = this;
        window.openModal = function(id) {
            document.getElementById(id).style.display = 'block';
        };
        window.closeModal = function(id) {
            document.getElementById(id).style.display = 'none';
        };
        window.switchToRegister = function() {
            closeModal('loginModal');
            openModal('registerModal');
        };
        window.switchToLogin = function() {
            closeModal('registerModal');
            openModal('loginModal');
        };
    }
}

// Inicializar aplicación
const app = new App();

document.addEventListener('DOMContentLoaded', () => {
    const loginBtn = document.getElementById('loginNavBtn');
    if (loginBtn) {
        loginBtn.addEventListener('click', () => {
            openModal('loginModal');
        });
    }

    const logoutBtn = document.getElementById('logoutBtn');
    if (logoutBtn) {
        logoutBtn.addEventListener('click', () => {
            AuthService.logout();
        });
    }

    // Actualiza los botones al cargar la página
    Navigation.updateLoginButton();
});