
import CONFIG from './config.js';
import { AuthService } from './api/auth.js';
import { DataService } from './api/services.js';
import { Navigation } from './ui/navigation.js';
import { ModalManager } from './ui/modal.js';
import { Animations } from './ui/animations.js';
import { ThemeCustomizer } from './utils/theme-customizer.js';
import { Icons } from './utils/icons.js';
import { showLoading, hideLoading, showConnectionStatus } from './utils/helpers.js';

// Notificación visual
function showNotification(message, type = 'info') {
    let container = document.getElementById('notificationContainer');
    if (!container) {
        container = document.createElement('div');
        container.id = 'notificationContainer';
        document.body.appendChild(container);
    }
    const notif = document.createElement('div');
    notif.className = `notification ${type}`;
    notif.textContent = message;
    container.appendChild(notif);
    setTimeout(() => {
        notif.style.opacity = '0';
        setTimeout(() => container.removeChild(notif), 400);
    }, 3500);
}

class App {
    constructor() {
        this.init();
    }

    async init() {
        // Inicializar componentes UI
        Navigation.init();
        Animations.init();
        ThemeCustomizer.init();

        // Verificar conexión
        await this.testConnection();

        // Inicializar formularios
        this.initForms();

        // Hacer funciones globales para el HTML
        this.exposeGlobalFunctions();
    }

    async testConnection() {
        try {
            const response = await fetch('https://www.grupovexus.com/health');
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

        const getDefaultIcon = (type) => {
            switch(type) {
                case 'dashboard': return Icons.dashboard;
                case 'learning': return Icons.book;
                case 'tools': return Icons.tools;
                default: return Icons.dashboard;
            }
        };

        campusGrid.innerHTML = sections.map(section => `
            <div class="campus-card ${section.section_type}-card blur-when-logged-out">
                <div class="card-icon">${section.icon || getDefaultIcon(section.section_type)}</div>
                <h3>${section.name}</h3>
                <p>${section.description}</p>
                <button class="campus-btn" onclick="app.redirectTo('${section.section_type}')">
                    ${section.section_type === 'dashboard' ? 'Acceder' :
                      section.section_type === 'learning' ? 'Comenzar' : 'Explorar'}
                </button>
                <div class="login-overlay" onclick="app.openLoginFromCampus()">
                    <div class="overlay-content">
                        <span class="lock-icon">${Icons.lock}</span>
                        <p>Inicia sesión para acceder</p>
                    </div>
                </div>
            </div>
        `).join('');
    }

    openLoginFromCampus() {
        ModalManager.open('loginModal');
        showNotification('Por favor, inicia sesión para acceder al Campus', 'info');
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

        // Consultancy Form
        const consultancyForm = document.getElementById('consultancyForm');
        if (consultancyForm) {
            consultancyForm.addEventListener('submit', async (e) => {
                e.preventDefault();
                await this.handleConsultancy(e.target);
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
                showNotification('¡Bienvenido! Sesión iniciada correctamente.', 'success');
                Navigation.updateLoginButton(); // <-- Esto actualiza el botón
                // window.location.reload(); // Solo recarga si es necesario
            } else {
                // Verificar si el email no está verificado
                if (response.emailNotVerified) {
                    showNotification(response.message, 'warning');
                    // Mostrar opción para reenviar email de verificación
                    this.showResendVerificationOption(email);
                } else {
                    showNotification(response.message, 'error');
                }
            }
        } catch (error) {
            showNotification('Error inesperado. Inténtalo más tarde.', 'error');
        } finally {
            submitBtn.disabled = false;
            submitBtn.textContent = 'Iniciar Sesión';
        }
    }

    showResendVerificationOption(email) {
        // Crear notificación especial con botón para reenviar verificación
        let container = document.getElementById('notificationContainer');
        if (!container) {
            container = document.createElement('div');
            container.id = 'notificationContainer';
            document.body.appendChild(container);
        }

        const notif = document.createElement('div');
        notif.className = 'notification warning verification-notice';
        notif.innerHTML = `
            <div style="margin-bottom: 10px;">Tu email no ha sido verificado.</div>
            <button onclick="app.resendVerificationEmail('${email}')"
                    style="background: #d4af37; color: #0a0a0a; border: none; padding: 8px 16px;
                           border-radius: 4px; cursor: pointer; font-weight: 600; margin-top: 8px;">
                Reenviar Email de Verificación
            </button>
        `;
        container.appendChild(notif);

        setTimeout(() => {
            notif.style.opacity = '0';
            setTimeout(() => container.removeChild(notif), 400);
        }, 8000); // Más tiempo para que el usuario pueda leer y hacer clic
    }

    async resendVerificationEmail(email) {
        showLoading();
        try {
            const result = await AuthService.resendVerification(email);
            if (result.success) {
                if (result.alreadyVerified) {
                    showNotification('Tu email ya está verificado. Puedes iniciar sesión.', 'info');
                } else {
                    showNotification('Email de verificación enviado. Revisa tu bandeja de entrada.', 'success');
                }
            } else {
                showNotification(result.message || 'Error al reenviar el email.', 'error');
            }
        } catch (error) {
            showNotification('Error al reenviar el email. Inténtalo más tarde.', 'error');
        } finally {
            hideLoading();
        }
    }


    async handleRegister(form) {
        const name = form.name.value;
        const email = form.email.value;
        const password = form.password.value;
        const confirmPassword = form.confirmPassword.value;
        const submitBtn = form.querySelector('.btn-submit');  // Era .login-submit

        if (password !== confirmPassword) {
            showNotification('Las contraseñas no coinciden.', 'error');
            return;
        }

        submitBtn.disabled = true;
        submitBtn.textContent = 'Creando Cuenta...';

        try {
            const response = await AuthService.register(name, email, password);

            if (response.success) {
                // Mostrar mensaje según el estado del email
                let successMessage;
                if (response.emailSent === 'sent') {
                    successMessage = '¡Cuenta creada! 📧 Email de verificación enviado. Por favor revisa tu bandeja de entrada.';
                } else if (response.emailSent === 'failed') {
                    successMessage = '¡Cuenta creada! ⚠️ No se pudo enviar el email. Puedes reenviarlo desde tu perfil.';
                } else {
                    successMessage = '¡Cuenta creada! Se enviará un email de verificación a tu correo.';
                }

                showNotification(successMessage, 'success');

                // Mostrar mensaje adicional en el modal
                this.showEmailVerificationMessage(email);

                // Cambiar al modal de login después de un momento
                setTimeout(() => {
                    ModalManager.switchModal('registerModal', 'loginModal');
                }, 3000);
            } else {
                showNotification('Error al crear la cuenta: ' + response.message, 'error');
            }
        } catch (error) {
            showNotification('Error al conectar con el servidor. Inténtalo más tarde.', 'error');
        } finally {
            submitBtn.disabled = false;
            submitBtn.textContent = 'Crear Cuenta';
        }
    }

    showEmailVerificationMessage(email) {
        let container = document.getElementById('notificationContainer');
        if (!container) {
            container = document.createElement('div');
            container.id = 'notificationContainer';
            document.body.appendChild(container);
        }

        const notif = document.createElement('div');
        notif.className = 'notification info verification-notice';
        notif.innerHTML = `
            <div style="margin-bottom: 5px; font-weight: 600;">📧 Verifica tu email</div>
            <div style="font-size: 14px;">
                Hemos enviado un enlace de verificación a <strong>${email}</strong>.
                Por favor revisa tu bandeja de entrada y haz clic en el enlace para activar tu cuenta.
            </div>
        `;
        container.appendChild(notif);

        setTimeout(() => {
            notif.style.opacity = '0';
            setTimeout(() => container.removeChild(notif), 400);
        }, 6000);
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
            showNotification('¡Mensaje enviado exitosamente!', 'success');
            ModalManager.close('contactModal');
            form.reset();
        } catch (error) {
            showNotification('Error al enviar el mensaje. Inténtalo más tarde.', 'error');
        } finally {
            submitBtn.disabled = false;
            submitBtn.textContent = 'Enviar Mensaje';
        }
    }

    async handleConsultancy(form) {
        const consultancyData = {
            name: form.name.value,
            email: form.email.value,
            query: form.query.value,
            to: 'grupovexus@gmail.com',
            subject: 'Consulta de Consultoría/Desarrollo Web'
        };

        const submitBtn = form.querySelector('.btn-primary');
        const originalText = submitBtn.innerHTML;
        submitBtn.disabled = true;
        submitBtn.innerHTML = '<svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"></circle><path d="M12 6v6l4 2"></path></svg> Enviando...';

        try {
            // Enviar email a grupovexus@gmail.com
            await DataService.sendConsultancyEmail(consultancyData);

            showNotification('¡Consulta enviada exitosamente! Te contactaremos pronto.', 'success');
            ModalManager.close('consultancyModal');
            form.reset();
        } catch (error) {
            console.error('Error al enviar consulta:', error);
            showNotification('Error al enviar la consulta. Por favor intenta más tarde.', 'error');
        } finally {
            submitBtn.disabled = false;
            submitBtn.innerHTML = originalText;
        }
    }

    async redirectTo(section) {
        if (!AuthService.isAuthenticated()) {
            showNotification('Por favor, inicia sesión para acceder a esta función', 'error');
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
                    showNotification('Función en desarrollo...', 'info');
            }
        } catch (error) {
            showNotification('Error al cargar la sección. Inténtalo más tarde.', 'error');
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
                <span class="modal-close" onclick="this.parentElement.parentElement.remove()">&times;</span>
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
                <span class="modal-close" onclick="this.parentElement.parentElement.remove()">&times;</span>
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
                                <button onclick="window.location.href='pages/course-view.html?id=${course.id}'" style="width: 100%; background: linear-gradient(135deg, #8B4513 0%, #A0522D 100%); color: white; padding: 0.8rem; border: none; border-radius: 8px; cursor: pointer; display: flex; align-items: center; justify-content: center; gap: 0.5rem;">
                                    ${Icons.book} Ver Curso
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
                <span class="modal-close" onclick="this.parentElement.parentElement.remove()">&times;</span>
                <div class="modal-header">
                    <h2>Herramientas</h2>
                    <p>Suite completa de herramientas</p>
                </div>
                <div class="tools-content" style="padding: 2rem;">
                    <div class="tools-grid" style="display: grid; grid-template-columns: repeat(auto-fit, minmax(250px, 1fr)); gap: 1.5rem;">
                        ${tools.map(tool => `
                            <div class="tool-card" style="background: #1a1a1a; padding: 1.5rem; border-radius: 15px; border: 1px solid #333; text-align: center;">
                                <div style="margin-bottom: 1rem; color: var(--color-primary);">${tool.icon || Icons.tools}</div>
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

    async showAdminPanel() {
        const user = AuthService.getCurrentUser();

        if (!user || user.role !== 'admin') {
            showNotification(`Acceso denegado. Se requiere rol de administrador.\nRol actual: ${user?.role || 'no definido'}`, 'error');
            return;
        }

        const token = localStorage.getItem(CONFIG.TOKEN_KEY);

        if (!token) {
            showNotification('No se encontró el token de autenticación. Por favor, inicia sesión nuevamente.', 'error');
            AuthService.logout();
            return;
        }

        try {
            showLoading();

            const response = await fetch(`${CONFIG.API_BASE_URL}/courses/admin/all`, {
                headers: {
                    'Authorization': `Bearer ${token}`,
                    'Content-Type': 'application/json'
                }
            });

            if (response.status === 401) {
                showNotification('Sesión expirada o no autorizada. Por favor, verifica que tu usuario tenga rol de administrador en la base de datos.', 'error');
                AuthService.logout();
                return;
            }

            if (!response.ok) {
                const errorData = await response.json().catch(() => ({}));
                throw new Error(errorData.detail || 'Failed to fetch courses');
            }

            const courses = await response.json();

            const modal = document.createElement('div');
            modal.className = 'modal';
            modal.id = 'adminModal';
            modal.style.display = 'block';
            modal.innerHTML = `
                <div class="modal-content" style="max-width: 1200px; max-height: 90vh; overflow-y: auto;">
                    <span class="modal-close" onclick="document.getElementById('adminModal').remove()">&times;</span>
                    <div class="modal-header">
                        <h2>Panel de Administrador</h2>
                        <p>Gestiona cursos y contenido</p>
                    </div>
                    <div class="admin-content" style="padding: 2rem;">
                        <button onclick="app.showCreateCourseForm()" style="background: linear-gradient(135deg, #8B4513 0%, #A0522D 100%); color: white; padding: 1rem 2rem; border: none; border-radius: 8px; cursor: pointer; margin-bottom: 2rem; font-weight: 600;">
                            + Agregar Nuevo Curso
                        </button>

                        <h3 style="color: #8B4513; margin-bottom: 1rem;">Cursos Existentes</h3>
                        <div class="admin-courses-grid" style="display: grid; gap: 1rem;">
                            ${courses.length > 0 ? courses.map(course => `
                                <div class="admin-course-card" style="background: #1a1a1a; padding: 1.5rem; border-radius: 10px; border: 1px solid #333; display: grid; grid-template-columns: 1fr auto; gap: 1rem; align-items: start;">
                                    <div>
                                        <h4 style="color: #8B4513; margin-bottom: 0.5rem;">${course.title}</h4>
                                        <p style="color: #c0c0c0; margin-bottom: 0.5rem; font-size: 0.9rem;">${course.description}</p>
                                        <div style="display: flex; gap: 1rem; margin-top: 0.5rem;">
                                            <span style="background: #333; color: #8B4513; padding: 0.3rem 0.8rem; border-radius: 5px; font-size: 0.8rem;">${course.difficulty_level}</span>
                                            <span style="color: #888; font-size: 0.9rem;">${course.duration_hours}h</span>
                                        </div>
                                    </div>
                                    <div style="display: flex; gap: 0.5rem; flex-direction: column;">
                                        <button onclick="window.location.href='pages/course-editor-improved.html?id=${course.id}'" style="background: #2563eb; color: white; padding: 0.5rem 1rem; border: none; border-radius: 5px; cursor: pointer; display: flex; align-items: center; gap: 0.5rem;">
                                            ${Icons.edit} Editar Contenido
                                        </button>
                                        <button onclick="app.deleteCourse('${course.id}')" style="background: #dc2626; color: white; padding: 0.5rem 1rem; border: none; border-radius: 5px; cursor: pointer; display: flex; align-items: center; gap: 0.5rem;">
                                            ${Icons.trash} Eliminar
                                        </button>
                                    </div>
                                </div>
                            `).join('') : '<p style="color: #888;">No hay cursos creados todavía</p>'}
                        </div>
                    </div>
                </div>
            `;
            document.body.appendChild(modal);
        } catch (error) {
            console.error('Error loading admin panel:', error);
            showNotification('Error al cargar el panel de administrador', 'error');
        } finally {
            hideLoading();
        }
    }

    showCreateCourseForm() {
        const existingForm = document.getElementById('courseFormModal');
        if (existingForm) existingForm.remove();

        const modal = document.createElement('div');
        modal.className = 'modal';
        modal.id = 'courseFormModal';
        modal.style.display = 'block';
        modal.innerHTML = `
            <div class="modal-content" style="max-width: 600px;">
                <span class="modal-close" onclick="document.getElementById('courseFormModal').remove()">&times;</span>
                <div class="modal-header">
                    <h2>Crear Nuevo Curso</h2>
                    <p>Completa los datos del curso</p>
                </div>
                <form id="createCourseForm" class="modal-form" style="padding: 2rem;">
                    <div class="form-group">
                        <label for="courseTitle">Título del Curso</label>
                        <input type="text" id="courseTitle" name="title" required>
                    </div>
                    <div class="form-group">
                        <label for="courseDescription">Descripción</label>
                        <textarea id="courseDescription" name="description" required rows="3"></textarea>
                    </div>
                    <div class="form-group">
                        <label for="courseContent">Contenido</label>
                        <textarea id="courseContent" name="content" required rows="6"></textarea>
                    </div>
                    <div class="form-group">
                        <label for="courseDifficulty">Nivel de Dificultad</label>
                        <select id="courseDifficulty" name="difficulty_level" required>
                            <option value="beginner">Principiante</option>
                            <option value="intermediate">Intermedio</option>
                            <option value="advanced">Avanzado</option>
                        </select>
                    </div>
                    <div class="form-group">
                        <label for="courseDuration">Duración (horas)</label>
                        <input type="number" id="courseDuration" name="duration_hours" required min="1">
                    </div>
                    <button type="submit" class="btn-submit">Crear Curso</button>
                </form>
            </div>
        `;
        document.body.appendChild(modal);

        document.getElementById('createCourseForm').addEventListener('submit', async (e) => {
            e.preventDefault();
            await this.createCourse(e.target);
        });
    }

    async createCourse(form) {
        const courseData = {
            title: form.title.value,
            description: form.description.value,
            content: form.content.value,
            difficulty_level: form.difficulty_level.value,
            duration_hours: parseInt(form.duration_hours.value)
        };

        const submitBtn = form.querySelector('.btn-submit');
        submitBtn.disabled = true;
        submitBtn.textContent = 'Creando...';

        try {
            const response = await fetch(`${CONFIG.API_BASE_URL}/courses/admin/create`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                    'Authorization': `Bearer ${localStorage.getItem(CONFIG.TOKEN_KEY)}`
                },
                body: JSON.stringify(courseData)
            });

            if (!response.ok) {
                const error = await response.json();
                throw new Error(error.detail || 'Error al crear curso');
            }

            showNotification('¡Curso creado exitosamente!', 'success');
            document.getElementById('courseFormModal').remove();
            document.getElementById('adminModal').remove();
            this.showAdminPanel();
        } catch (error) {
            showNotification('Error al crear curso: ' + error.message, 'error');
        } finally {
            submitBtn.disabled = false;
            submitBtn.textContent = 'Crear Curso';
        }
    }

    async deleteCourse(courseId) {
        if (!confirm('¿Estás seguro de que deseas eliminar este curso?')) return;

        try {
            showLoading();
            const response = await fetch(`${CONFIG.API_BASE_URL}/courses/admin/${courseId}`, {
                method: 'DELETE',
                headers: {
                    'Authorization': `Bearer ${localStorage.getItem(CONFIG.TOKEN_KEY)}`
                }
            });

            if (!response.ok) throw new Error('Failed to delete course');

            showNotification('Curso eliminado exitosamente', 'success');
            document.getElementById('adminModal').remove();
            this.showAdminPanel();
        } catch (error) {
            showNotification('Error al eliminar curso: ' + error.message, 'error');
        } finally {
            hideLoading();
        }
    }

    exposeGlobalFunctions() {
        // Exponer funciones para el HTML
        window.app = this;
        window.showNotification = showNotification;
        window.openModal = (id) => ModalManager.open(id);
        window.closeModal = (id) => ModalManager.close(id);
        window.switchToRegister = () => ModalManager.switchModal('loginModal', 'registerModal');
        window.switchToLogin = () => ModalManager.switchModal('registerModal', 'loginModal');
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
// Fin del archivo