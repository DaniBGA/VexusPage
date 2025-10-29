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

console.log('=== VERIFICACIONES INICIALES ===');
console.log('Course ID from URL:', currentCourseId);
console.log('Full URL:', window.location.href);

if (!currentCourseId) {
    console.error('No se encontró ID de curso en la URL');
    showNotification('No se especificó un curso', 'error');
    setTimeout(() => window.location.href = '../index.html', 1500);
    throw new Error('No course ID');
}

// Verificar autenticación
const isAuth = AuthService.isAuthenticated();
console.log('Usuario autenticado:', isAuth);

if (!isAuth) {
    console.error('Usuario no autenticado');
    showNotification('Debes iniciar sesión para ver los cursos', 'error');
    setTimeout(() => window.location.href = '../index.html', 1500);
    throw new Error('Not authenticated');
}

function showLoading() {
    const overlay = document.getElementById('loadingOverlay');
    overlay.style.display = 'flex';
    overlay.classList.remove('hidden');
    document.body.style.overflow = 'hidden';
}

function hideLoading() {
    const overlay = document.getElementById('loadingOverlay');
    overlay.classList.add('hidden');
    document.body.style.overflow = 'auto';

    // Después de la animación de fade, ocultar completamente
    setTimeout(() => {
        overlay.style.display = 'none';
    }, 800);
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
        console.log('=== INICIANDO CARGA DE CURSO ===');
        console.log('Course ID:', currentCourseId);
        console.log('Token:', localStorage.getItem(CONFIG.TOKEN_KEY) ? 'Existe' : 'No existe');

        showLoading();

        const url = `${CONFIG.API_BASE_URL}/courses/${currentCourseId}/view`;
        console.log('URL:', url);

        const response = await fetch(url, {
            headers: getAuthHeaders()
        });

        console.log('Response status:', response.status);

        if (!response.ok) {
            const errorText = await response.text();
            console.error('Error response:', errorText);
            throw new Error(`Error ${response.status}: ${errorText}`);
        }

        courseData = await response.json();
        console.log('Course data loaded:', courseData);

        displayCourse();
    } catch (error) {
        console.error('Error loading course:', error);
        showNotification(`Error al cargar el curso: ${error.message}`, 'error');
        setTimeout(() => window.location.href = '../index.html', 3000);
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

function getResourceUrl(resource) {
    let resourceUrl = resource.url;

    // Si es un documento del servidor (ruta relativa o sin http)
    if (resource.resource_type === 'document' && !resourceUrl.startsWith('http')) {
        // Extraer solo el nombre del archivo
        const filename = resourceUrl.split('/').pop();
        // Si hay filename, construir la URL de descarga
        if (filename) {
            resourceUrl = `${CONFIG.API_BASE_URL}/courses/download/${filename}`;
        }
    }

    return resourceUrl;
}

// Manejar descarga de recursos
window.downloadResource = async function(originalUrl, resourceType) {
    console.log('=== DESCARGA DE RECURSO ===');
    console.log('URL original:', originalUrl);
    console.log('Tipo:', resourceType);

    if (resourceType === 'document') {
        // La URL debe venir como "/uploads/course_resources/filename.pdf"
        if (!originalUrl || !originalUrl.includes('/')) {
            showNotification('Error: URL de recurso inválida', 'error');
            console.error('URL inválida:', originalUrl);
            return;
        }
        
        const filename = originalUrl.split('/').pop();
        const downloadUrl = `${CONFIG.API_BASE_URL}/courses/download/${filename}`;
        
        console.log('Filename:', filename);
        console.log('Download URL:', downloadUrl);

        try {
            showLoading();
            const token = localStorage.getItem(CONFIG.TOKEN_KEY);
            
            if (!token) {
                showNotification('No estás autenticado', 'error');
                return;
            }

            const response = await fetch(downloadUrl, {
                method: 'GET',
                headers: { 'Authorization': `Bearer ${token}` }
            });

            console.log('Status:', response.status);

            if (!response.ok) {
                const text = await response.text();
                console.error('Error:', text);
                showNotification('Error al descargar el archivo', 'error');
                return;
            }

            const blob = await response.blob();
            const link = document.createElement('a');
            const objectUrl = URL.createObjectURL(blob);
            
            link.href = objectUrl;
            
            // Extraer nombre original del filename
            const parts = filename.split('_');
            const originalName = parts.length >= 3 ? parts.slice(2).join('_') : filename;
            link.download = originalName;
            
            document.body.appendChild(link);
            link.click();
            document.body.removeChild(link);
            URL.revokeObjectURL(objectUrl);

            showNotification('📄 Descarga completada', 'success');

        } catch (error) {
            console.error('Error:', error);
            showNotification('Error: ' + error.message, 'error');
        } finally {
            hideLoading();
        }

    } else {
        // Para videos y links externos
        window.open(originalUrl, '_blank');
    }
};

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

                    ${unit.content ? `<div class="unit-text">${unit.content}</div>` : ''}

                    ${unit.resources && unit.resources.length > 0 ? `
                        <div class="resources-section">
                            <h4 class="resources-title">
                                <span>📎</span>
                                <span>Recursos</span>
                            </h4>
                            ${unit.resources.map(resource => {
                                const isDocument = resource.resource_type === 'document';
                                const icon = isDocument ? '⬇' : '→';
                                return `
                                    <div class="resource-item" onclick="downloadResource('${resource.url}', '${resource.resource_type}')" style="cursor: pointer;">
                                        <span class="resource-icon">${resourceIcons[resource.resource_type] || '📎'}</span>
                                        <div class="resource-info">
                                            <div class="resource-title">${resource.title}</div>
                                            ${resource.description ? `<div class="resource-url">${resource.description}</div>` : ''}
                                        </div>
                                        <span style="color: var(--color-primary);">${icon}</span>
                                    </div>
                                `;
                            }).join('')}
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
