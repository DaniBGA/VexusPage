import CONFIG from './config.js';
import { AuthService } from './api/auth.js';

// Notificación visual
function showNotification(message, type = 'info') {
    let container = document.getElementById('notificationContainer');
    if (!container) {
        container = document.createElement('div');
        container.id = 'notificationContainer';
        container.style.position = 'fixed';
        container.style.top = '2rem';
        container.style.right = '2rem';
        container.style.zIndex = '9999';
        container.style.display = 'flex';
        container.style.flexDirection = 'column';
        container.style.gap = '0.5rem';
        document.body.appendChild(container);
    }
    const notif = document.createElement('div');
    notif.textContent = message;
    notif.style.padding = '1rem 2rem';
    notif.style.borderRadius = '8px';
    notif.style.fontWeight = 'bold';
    notif.style.boxShadow = '0 2px 8px rgba(0,0,0,0.15)';
    notif.style.color = 'white';
    if (type === 'error') {
        notif.style.background = '#dc2626';
        notif.style.border = '2px solid #b91c1c';
    } else if (type === 'success') {
        notif.style.background = 'linear-gradient(135deg, #A0522D 0%, #8B4513 100%)';
        notif.style.border = '2px solid #A0522D';
    } else {
        notif.style.background = 'linear-gradient(135deg, #8B4513 0%, #A0522D 100%)';
        notif.style.border = '2px solid #8B4513';
    }
    notif.style.marginBottom = '0.5rem';
    container.appendChild(notif);
    setTimeout(() => {
        notif.style.opacity = '0';
        setTimeout(() => container.removeChild(notif), 400);
    }, 3500);
}

let currentCourseId = null;
let courseData = null;

// Obtener ID del curso desde la URL
const urlParams = new URLSearchParams(window.location.search);
currentCourseId = urlParams.get('id');

if (!currentCourseId) {
    showNotification('No se especificó un curso', 'error');
    setTimeout(() => window.location.href = '../index.html', 1500);
}

// Verificar autenticación
if (!AuthService.isAuthenticated()) {
    showNotification('Debes iniciar sesión para ver los cursos', 'error');
    setTimeout(() => window.location.href = '../index.html', 1500);
}

function showLoading() {
    document.getElementById('loadingOverlay').style.display = 'flex';
}

function hideLoading() {
    document.getElementById('loadingOverlay').style.display = 'none';
}

function getAuthHeaders() {
    return {
        'Authorization': `Bearer ${localStorage.getItem(CONFIG.TOKEN_KEY)}`,
        'Content-Type': 'application/json'
    };
}

// Cargar curso completo
async function loadCourse() {
    try {
        showLoading();
        const response = await fetch(`${CONFIG.API_BASE_URL}/courses/${currentCourseId}/view`, {
            headers: getAuthHeaders()
        });

        if (!response.ok) throw new Error('Error al cargar curso');

        courseData = await response.json();
        displayCourse();
    } catch (error) {
        console.error('Error loading course:', error);
        showNotification('Error al cargar el curso. Verifica que esté publicado y que tengas acceso.', 'error');
        setTimeout(() => window.location.href = '../index.html', 2000);
    } finally {
        hideLoading();
    }
}

// Mostrar información del curso
function displayCourse() {
    const { course, units, progress } = courseData;

    // Header del curso
    document.getElementById('courseTitle').textContent = course.title;
    document.getElementById('courseDescription').textContent = course.description;

    // Metadata
    const difficultyMap = {
        'beginner': 'Principiante',
        'intermediate': 'Intermedio',
        'advanced': 'Avanzado'
    };
    document.getElementById('courseDifficulty').textContent = difficultyMap[course.difficulty_level] || course.difficulty_level;
    document.getElementById('courseDuration').textContent = `${course.duration_hours} horas`;
    document.getElementById('courseUnitsCount').textContent = `${units.length} unidades`;

    // Progreso
    updateProgress(progress);

    // Unidades
    displayUnits(units);
}

// Actualizar barra de progreso
function updateProgress(progress) {
    document.getElementById('progressText').textContent = `${progress}%`;
    document.getElementById('progressBar').style.width = `${progress}%`;
}

// Mostrar unidades
function displayUnits(units) {
    const container = document.getElementById('unitsContainer');

    if (units.length === 0) {
        container.innerHTML = `
            <div style="text-align: center; padding: 3rem; background: var(--color-surface); border-radius: 15px;">
                <p style="color: var(--color-text-secondary); font-size: 1.2rem;">
                    Este curso aún no tiene unidades disponibles.
                </p>
            </div>
        `;
        return;
    }

    const resourceIcons = {
        'document': '📄',
        'video': '🎥',
        'link': '🔗'
    };

    container.innerHTML = units.map((unit, index) => `
        <div class="unit-accordion ${unit.completed ? 'completed' : ''}" id="unit-${unit.id}">
            <div class="unit-header" onclick="toggleUnit('${unit.id}')">
                <div class="unit-title-section">
                    <span class="unit-number">Unidad ${index + 1}</span>
                    <h3 class="unit-title">${unit.title}</h3>
                    ${unit.completed ? '<span class="completion-badge">✓ Completada</span>' : ''}
                </div>
                <span class="unit-chevron">▼</span>
            </div>

            <div class="unit-content">
                <div class="unit-body">
                    ${unit.description ? `
                        <p class="unit-description">${unit.description}</p>
                    ` : ''}

                    <div class="unit-text">${unit.content}</div>

                    ${unit.resources.length > 0 ? `
                        <div class="resources-section">
                            <h4 class="resources-title">
                                <span>📎</span>
                                <span>Recursos</span>
                            </h4>
                            ${unit.resources.map(resource => `
                                <a href="${resource.url}" target="_blank" class="resource-item">
                                    <span class="resource-icon">${resourceIcons[resource.resource_type] || '📎'}</span>
                                    <div class="resource-info">
                                        <div class="resource-title">${resource.title}</div>
                                        ${resource.description ? `<div class="resource-url">${resource.description}</div>` : ''}
                                    </div>
                                    <span style="color: var(--color-primary);">→</span>
                                </a>
                            `).join('')}
                        </div>
                    ` : ''}

                    <button
                        class="complete-button ${unit.completed ? 'completed' : ''}"
                        onclick="${unit.completed ? 'return false' : `markUnitComplete('${unit.id}')`}"
                        ${unit.completed ? 'disabled' : ''}
                    >
                        ${unit.completed ? '✓ Unidad Completada' : '✓ Marcar como Completada'}
                    </button>
                </div>
            </div>
        </div>
    `).join('');
}

// Toggle unidad (abrir/cerrar)
window.toggleUnit = function(unitId) {
    const unit = document.getElementById(`unit-${unitId}`);
    const allUnits = document.querySelectorAll('.unit-accordion');

    // Cerrar todas las demás unidades
    allUnits.forEach(u => {
        if (u.id !== `unit-${unitId}`) {
            u.classList.remove('active');
        }
    });

    // Toggle la unidad actual
    unit.classList.toggle('active');
};

// Marcar unidad como completada
window.markUnitComplete = async function(unitId) {
    try {
        showLoading();
        const response = await fetch(`${CONFIG.API_BASE_URL}/courses/units/${unitId}/complete`, {
            method: 'POST',
            headers: getAuthHeaders()
        });

        if (!response.ok) throw new Error('Error al marcar unidad');

        const result = await response.json();

        // Actualizar progreso global en courseData
        courseData.progress = result.course_progress;

        // Actualizar progreso visual
        updateProgress(result.course_progress);

        // Actualizar estado de completado en courseData
        const unitIndex = courseData.units.findIndex(u => u.id === unitId);
        if (unitIndex !== -1) {
            courseData.units[unitIndex].completed = true;
        }

        // Marcar visualmente la unidad como completada
        const unitElement = document.getElementById(`unit-${unitId}`);
        unitElement.classList.add('completed');

        // Actualizar botón
        const button = unitElement.querySelector('.complete-button');
        button.classList.add('completed');
        button.textContent = '✓ Unidad Completada';
        button.disabled = true;
        button.onclick = null;

        // Agregar badge de completada si no existe
        if (!unitElement.querySelector('.completion-badge')) {
            const titleSection = unitElement.querySelector('.unit-title-section');
            const badge = document.createElement('span');
            badge.className = 'completion-badge';
            badge.innerHTML = '✓ Completada';
            titleSection.appendChild(badge);
        }

        // Mostrar mensaje de felicitación
        if (result.course_progress === 100) {
            setTimeout(() => {
                showNotification('🎉 ¡Felicitaciones! Has completado el curso completo.', 'success');
            }, 500);
        } else {
            // Mensaje sutil
            const notification = document.createElement('div');
            notification.style.cssText = `
                position: fixed;
                top: 20px;
                right: 20px;
                background: linear-gradient(135deg, #22c55e 0%, #16a34a 100%);
                color: white;
                padding: 1rem 1.5rem;
                border-radius: 10px;
                box-shadow: 0 10px 30px rgba(34, 197, 94, 0.3);
                z-index: 10000;
                animation: slideIn 0.3s ease-out;
            `;
            notification.textContent = '✓ Unidad completada';
            document.body.appendChild(notification);

            setTimeout(() => {
                notification.style.animation = 'slideOut 0.3s ease-out';
                setTimeout(() => notification.remove(), 300);
            }, 3000);
        }

    } catch (error) {
        console.error('Error:', error);
        showNotification('Error al marcar la unidad como completada', 'error');
    } finally {
        hideLoading();
    }
};

// Agregar estilos para las animaciones
const style = document.createElement('style');
style.textContent = `
    @keyframes slideIn {
        from {
            transform: translateX(400px);
            opacity: 0;
        }
        to {
            transform: translateX(0);
            opacity: 1;
        }
    }

    @keyframes slideOut {
        from {
            transform: translateX(0);
            opacity: 1;
        }
        to {
            transform: translateX(400px);
            opacity: 0;
        }
    }
`;
document.head.appendChild(style);

// Inicializar
loadCourse();
// Fin del archivo
