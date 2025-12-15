// ====================================
// FUNCIONES DE DASHBOARD Y CURSOS
// Movidas a future-releases - No se usan actualmente
// ====================================

// Dashboard
async showDashboard() {
    const stats = await DataService.getDashboardStats();
    const projects = await DataService.getProjects();

    const modal = document.createElement('div');
    modal.className = 'modal';
    modal.style.display = 'block';
    modal.innerHTML = `
        <div class="modal-content" style="max-width: 1000px; max-height: 80vh; overflow-y: auto;">
            <span class="modal-close" onclick="this.parentElement.parentElement.remove()">&times;</span>
            <div class="modal-header">
                <h2>Dashboard</h2>
                <p>Tu espacio de trabajo</p>
            </div>
            <div class="dashboard-content" style="padding: 2rem;">
                <div class="stats-grid" style="display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 1rem; margin-bottom: 2rem;">
                    <div class="stat-card" style="background: #1a1a1a; padding: 1.5rem; border-radius: 10px; text-align: center;">
                        <h3 style="color: #1E3A8A;">Proyectos</h3>
                        <p style="font-size: 2rem; font-weight: bold;">${stats.projects_count}</p>
                    </div>
                    <div class="stat-card" style="background: #1a1a1a; padding: 1.5rem; border-radius: 10px; text-align: center;">
                        <h3 style="color: #1E3A8A;">Cursos Completados</h3>
                        <p style="font-size: 2rem; font-weight: bold;">${stats.completed_courses}/${stats.total_courses}</p>
                    </div>
                    <div class="stat-card" style="background: #1a1a1a; padding: 1.5rem; border-radius: 10px; text-align: center;">
                        <h3 style="color: #1E3A8A;">Progreso</h3>
                        <p style="font-size: 2rem; font-weight: bold;">${Math.round(stats.completion_rate)}%</p>
                    </div>
                </div>

                <h3 style="color: #1E3A8A; margin-bottom: 1rem;">Proyectos Recientes</h3>
                <div class="projects-list">
                    ${projects.length > 0 ? projects.slice(0, 3).map(project => `
                        <div style="background: #1a1a1a; padding: 1rem; border-radius: 8px; margin-bottom: 1rem;">
                            <h4>${project.name}</h4>
                            <p style="color: #888; font-size: 0.9rem;">${project.description || 'Sin descripción'}</p>
                            <span style="color: #1E3A8A; font-size: 0.8rem;">${project.status}</span>
                        </div>
                    `).join('') : '<p style="color: #888;">No tienes proyectos aún</p>'}
                </div>
            </div>
        </div>
    `;
    document.body.appendChild(modal);
}

// Learning/Courses
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
                            <h3 style="color: #1E3A8A; margin-bottom: 1rem;">${course.title}</h3>
                            <p style="color: #c0c0c0; margin-bottom: 1rem; font-size: 0.9rem;">${course.description}</p>
                            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 1rem;">
                                <span style="background: #1E3A8A; color: white; padding: 0.3rem 0.8rem; border-radius: 15px; font-size: 0.8rem;">${course.difficulty_level}</span>
                                <span style="color: #888; font-size: 0.9rem;">${course.duration_hours}h</span>
                            </div>
                            <button onclick="window.location.href='pages/course-view.html?id=${course.id}'" style="width: 100%; background: linear-gradient(135deg, #1E3A8A 0%, #1E40AF 100%); color: white; padding: 0.8rem; border: none; border-radius: 8px; cursor: pointer; display: flex; align-items: center; justify-content: center; gap: 0.5rem;">
                                Ver Curso
                            </button>
                        </div>
                    `).join('')}
                </div>
            </div>
        </div>
    `;
    document.body.appendChild(modal);
}

// Tools
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
                <p>Accede a herramientas especializadas</p>
            </div>
            <div class="tools-content" style="padding: 2rem;">
                <div class="tools-grid" style="display: grid; grid-template-columns: repeat(auto-fit, minmax(250px, 1fr)); gap: 1.5rem;">
                    ${tools.map(tool => `
                        <div class="tool-card" style="background: #1a1a1a; padding: 1.5rem; border-radius: 15px; border: 1px solid #333; text-align: center;">
                            <div style="margin-bottom: 1rem; color: var(--color-primary);">${tool.icon || '🛠️'}</div>
                            <h3 style="color: #1E3A8A; margin-bottom: 1rem;">${tool.name}</h3>
                            <p style="color: #c0c0c0; margin-bottom: 1.5rem; font-size: 0.9rem;">${tool.description}</p>
                            <button ${tool.has_access ? '' : 'disabled'}
                                style="background: ${tool.has_access ? 'linear-gradient(135deg, #1E3A8A 0%, #1E40AF 100%)' : '#666'};
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

// Admin Panel
async showAdminPanel() {
    const user = AuthService.getCurrentUser();
    console.log('Admin Panel - Current user:', user);

    if (!user || user.role !== 'admin') {
        console.error('Access denied. User role:', user?.role);
        showNotification(`Acceso denegado. Se requiere rol de administrador.\nRol actual: ${user?.role || 'no definido'}`, 'error');
        return;
    }

    const token = localStorage.getItem(CONFIG.TOKEN_KEY);
    console.log('Token exists:', !!token);

    if (!token) {
        showNotification('No se encontró el token de autenticación. Por favor, inicia sesión nuevamente.', 'error');
        AuthService.logout();
        return;
    }

    try {
        showLoading();
        console.log('Fetching courses from:', `${CONFIG.API_BASE_URL}/courses/admin/all`);

        const response = await fetch(`${CONFIG.API_BASE_URL}/courses/admin/all`, {
            headers: {
                'Authorization': `Bearer ${token}`,
                'Content-Type': 'application/json'
            }
        });

        console.log('Response status:', response.status);

        if (response.status === 401) {
            const errorText = await response.text();
            console.error('401 Error details:', errorText);
            showNotification('Sesión expirada o no autorizada. Por favor, verifica que tu usuario tenga rol de administrador en la base de datos.', 'error');
            AuthService.logout();
            return;
        }

        if (!response.ok) {
            const errorData = await response.json().catch(() => ({}));
            console.error('Error response:', errorData);
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
                    <button onclick="app.showCreateCourseForm()" style="background: linear-gradient(135deg, #1E3A8A 0%, #1E40AF 100%); color: white; padding: 1rem 2rem; border: none; border-radius: 8px; cursor: pointer; margin-bottom: 2rem; font-weight: 600;">
                        + Agregar Nuevo Curso
                    </button>

                    <h3 style="color: #1E3A8A; margin-bottom: 1rem;">Cursos Existentes</h3>
                    <div class="admin-courses-grid" style="display: grid; gap: 1rem;">
                        ${courses.length > 0 ? courses.map(course => `
                            <div class="admin-course-card" style="background: #1a1a1a; padding: 1.5rem; border-radius: 10px; border: 1px solid #333; display: grid; grid-template-columns: 1fr auto; gap: 1rem; align-items: start;">
                                <div>
                                    <h4 style="color: #1E3A8A; margin-bottom: 0.5rem;">${course.title}</h4>
                                    <p style="color: #c0c0c0; margin-bottom: 0.5rem; font-size: 0.9rem;">${course.description}</p>
                                    <div style="display: flex; gap: 1rem; margin-top: 0.5rem;">
                                        <span style="background: #333; color: #1E3A8A; padding: 0.3rem 0.8rem; border-radius: 5px; font-size: 0.8rem;">${course.difficulty_level}</span>
                                        <span style="color: #888; font-size: 0.9rem;">${course.duration_hours}h</span>
                                    </div>
                                </div>
                                <div style="display: flex; gap: 0.5rem; flex-direction: column;">
                                    <button onclick="window.location.href='pages/course-editor-improved.html?id=${course.id}'" style="background: #2563eb; color: white; padding: 0.5rem 1rem; border: none; border-radius: 5px; cursor: pointer; display: flex; align-items: center; gap: 0.5rem;">
                                        Editar Contenido
                                    </button>
                                    <button onclick="app.deleteCourse('${course.id}')" style="background: #dc2626; color: white; padding: 0.5rem 1rem; border: none; border-radius: 5px; cursor: pointer; display: flex; align-items: center; gap: 0.5rem;">
                                        Eliminar
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
