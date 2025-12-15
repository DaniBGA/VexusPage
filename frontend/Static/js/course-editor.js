// ...existing code...
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
        notif.style.background = 'linear-gradient(135deg, #1E40AF 0%, #1E3A8A 100%)';
        notif.style.border = '2px solid #1E40AF';
    } else {
        notif.style.background = 'linear-gradient(135deg, #1E3A8A 0%, #1E40AF 100%)';
        notif.style.border = '2px solid #1E3A8A';
    }
    notif.style.marginBottom = '0.5rem';
    container.appendChild(notif);
    setTimeout(() => {
        notif.style.opacity = '0';
        setTimeout(() => container.removeChild(notif), 400);
    }, 3500);
}

// Modal de confirmación visual con colores marrón/anaranjado
function showConfirmModal(message) {
    return new Promise(resolve => {
        let modal = document.getElementById('customConfirmModal');
        if (modal) modal.remove();
        modal = document.createElement('div');
        modal.id = 'customConfirmModal';
        modal.style.position = 'fixed';
        modal.style.top = '0';
        modal.style.left = '0';
        modal.style.width = '100vw';
        modal.style.height = '100vh';
        modal.style.background = 'rgba(40, 30, 20, 0.7)';
        modal.style.display = 'flex';
        modal.style.alignItems = 'center';
        modal.style.justifyContent = 'center';
        modal.style.zIndex = '10000';

        const box = document.createElement('div');
        box.style.background = 'linear-gradient(135deg, #1E3A8A 0%, #1E40AF 100%)';
        box.style.color = 'white';
        box.style.padding = '2rem 2.5rem';
        box.style.borderRadius = '16px';
        box.style.boxShadow = '0 8px 32px rgba(139,69,19,0.25)';
        box.style.minWidth = '340px';
        box.style.maxWidth = '90vw';
        box.style.textAlign = 'center';

        const msg = document.createElement('div');
        msg.style.fontSize = '1.1rem';
        msg.style.marginBottom = '1.5rem';
        msg.textContent = message;
        box.appendChild(msg);

        const btnRow = document.createElement('div');
        btnRow.style.display = 'flex';
        btnRow.style.justifyContent = 'center';
        btnRow.style.gap = '1rem';

        const acceptBtn = document.createElement('button');
        acceptBtn.textContent = 'Aceptar';
        acceptBtn.style.background = 'linear-gradient(135deg, #1E40AF 0%, #1E3A8A 100%)';
        acceptBtn.style.color = 'white';
        acceptBtn.style.fontWeight = 'bold';
        acceptBtn.style.border = 'none';
        acceptBtn.style.borderRadius = '8px';
        acceptBtn.style.padding = '0.7rem 2rem';
        acceptBtn.style.fontSize = '1rem';
        acceptBtn.style.cursor = 'pointer';
        acceptBtn.onclick = () => {
            modal.remove();
            resolve(true);
        };

        const cancelBtn = document.createElement('button');
        cancelBtn.textContent = 'Cancelar';
        cancelBtn.style.background = '#2d1a0b';
        cancelBtn.style.color = '#f3e9e0';
        cancelBtn.style.fontWeight = 'bold';
        cancelBtn.style.border = '1px solid #1E40AF';
        cancelBtn.style.borderRadius = '8px';
        cancelBtn.style.padding = '0.7rem 2rem';
        cancelBtn.style.fontSize = '1rem';
        cancelBtn.style.cursor = 'pointer';
        cancelBtn.onclick = () => {
            modal.remove();
            resolve(false);
        };

        btnRow.appendChild(acceptBtn);
        btnRow.appendChild(cancelBtn);
        box.appendChild(btnRow);
        modal.appendChild(box);
        document.body.appendChild(modal);
    });
}
if (!currentCourseId) {

    showNotification('No se especificó un curso para editar', 'error');
}
if (!AuthService.isAuthenticated()) {
    showNotification('Debes iniciar sesión para acceder al editor', 'error');
    window.location.href = '../index.html';
}
if (user.role !== 'admin') {
    showNotification('No tienes permisos para acceder al editor de cursos', 'error');
    window.location.href = '../index.html';
}
import CONFIG from './config.js';
import { AuthService } from './api/auth.js';

let currentCourseId = null;
let currentEditingUnitId = null;

// Obtener el ID del curso desde la URL
const urlParams = new URLSearchParams(window.location.search);
currentCourseId = urlParams.get('id');

if (!currentCourseId) {
    showNotification('No se especificó un curso para editar', 'error');
    window.location.href = '../index.html';
}

// Verificar autenticación y rol de admin
if (!AuthService.isAuthenticated()) {
    showNotification('Debes iniciar sesión para acceder al editor', 'error');
    window.location.href = '../index.html';
}

const user = AuthService.getCurrentUser();
if (user.role !== 'admin') {
    showNotification('No tienes permisos para acceder al editor de cursos', 'error');
    window.location.href = '../index.html';
}

// Funciones de utilidad
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

// Cambiar entre tabs
window.switchTab = function(tabName) {
    // Remover active de todos los tabs
    document.querySelectorAll('.editor-tab').forEach(tab => tab.classList.remove('active'));
    document.querySelectorAll('.tab-content').forEach(content => content.classList.remove('active'));

    // Activar el tab seleccionado
    event.target.classList.add('active');
    document.getElementById(`tab-${tabName}`).classList.add('active');

    if (tabName === 'units') {
        loadUnits();
    }
};

// Cargar información del curso
async function loadCourseInfo() {
    try {
        showLoading();
        const response = await fetch(`${CONFIG.API_BASE_URL}/courses/${currentCourseId}`, {
            headers: getAuthHeaders()
        });

        if (!response.ok) throw new Error('Error al cargar curso');

        const course = await response.json();

        document.getElementById('courseTitle').textContent = course.title;
        document.getElementById('courseDescription').textContent = course.description;

        // Llenar formulario
        document.getElementById('courseInfoTitle').value = course.title;
        document.getElementById('courseInfoDescription').value = course.description;
        document.getElementById('courseInfoContent').value = course.content;
        document.getElementById('courseInfoDifficulty').value = course.difficulty_level;
        document.getElementById('courseInfoDuration').value = course.duration_hours;
    } catch (error) {
    console.error('Error loading course:', error);
    showNotification('Error al cargar el curso', 'error');
    } finally {
        hideLoading();
    }
}

// Guardar información del curso
document.getElementById('courseInfoForm').addEventListener('submit', async (e) => {
    e.preventDefault();

    const formData = {
        title: document.getElementById('courseInfoTitle').value,
        description: document.getElementById('courseInfoDescription').value,
        content: document.getElementById('courseInfoContent').value,
        difficulty_level: document.getElementById('courseInfoDifficulty').value,
        duration_hours: parseInt(document.getElementById('courseInfoDuration').value)
    };

    try {
        showLoading();
        const response = await fetch(`${CONFIG.API_BASE_URL}/courses/admin/${currentCourseId}`, {
            method: 'PUT',
            headers: getAuthHeaders(),
            body: JSON.stringify(formData)
        });

        if (!response.ok) throw new Error('Error al actualizar curso');
    showNotification('✅ Curso actualizado exitosamente', 'success');
        await loadCourseInfo();
    } catch (error) {
    console.error('Error:', error);
    showNotification('Error al actualizar el curso', 'error');
    } finally {
        hideLoading();
    }
});

// Cargar unidades
async function loadUnits() {
    try {
        showLoading();
        const response = await fetch(`${CONFIG.API_BASE_URL}/courses/${currentCourseId}/units`, {
            headers: getAuthHeaders()
        });

        if (!response.ok) throw new Error('Error al cargar unidades');

        const units = await response.json();
        displayUnits(units);
    } catch (error) {
    console.error('Error loading units:', error);
    showNotification('Error al cargar unidades', 'error');
    } finally {
        hideLoading();
    }
}

// Mostrar unidades
function displayUnits(units) {
    const container = document.getElementById('unitsContainer');

    if (units.length === 0) {
        container.innerHTML = `
            <div style="text-align: center; padding: 3rem; color: var(--color-text-secondary);">
                <p style="font-size: 1.2rem;">No hay unidades todavía</p>
                <p>Haz clic en "Agregar Nueva Unidad" para comenzar</p>
            </div>
        `;
        return;
    }

    container.innerHTML = units.map(unit => `
        <div class="unit-card" data-unit-id="${unit.id}">
            <div class="unit-header">
                <div>
                    <span class="unit-number">Unidad ${unit.order + 1}</span>
                    <h3 style="color: var(--color-primary); margin: 0.5rem 0;">${unit.title}</h3>
                    ${unit.description ? `<p style="color: var(--color-text-secondary); margin-bottom: 1rem;">${unit.description}</p>` : ''}
                    <p style="color: var(--color-text); line-height: 1.6;">${unit.content.substring(0, 200)}${unit.content.length > 200 ? '...' : ''}</p>
                </div>
                <div class="unit-actions">
                    <button class="btn-icon btn-edit" onclick="editUnit('${unit.id}')">
                        ✏️ Editar
                    </button>
                    <button class="btn-icon btn-delete" onclick="deleteUnit('${unit.id}')">
                        🗑️ Eliminar
                    </button>
                </div>
            </div>

            <div id="resources-${unit.id}" class="resources-list">
                <h4 style="color: var(--color-primary); font-size: 0.9rem; margin-bottom: 0.5rem;">📎 Recursos</h4>
                <div id="resources-content-${unit.id}">
                    <p style="color: var(--color-text-secondary); font-size: 0.9rem;">Cargando recursos...</p>
                </div>
            </div>
        </div>
    `).join('');

    // Cargar recursos para cada unidad
    units.forEach(unit => loadUnitResources(unit.id));
}

// Cargar recursos de una unidad
async function loadUnitResources(unitId) {
    try {
        const response = await fetch(`${CONFIG.API_BASE_URL}/courses/units/${unitId}/resources`, {
            headers: getAuthHeaders()
        });

        if (!response.ok) throw new Error('Error al cargar recursos');

        const resources = await response.json();
        displayUnitResources(unitId, resources);
    } catch (error) {
        console.error('Error loading resources:', error);
        document.getElementById(`resources-content-${unitId}`).innerHTML = `
            <p style="color: var(--color-text-secondary); font-size: 0.9rem;">Sin recursos</p>
        `;
    }
}

// Mostrar recursos
function displayUnitResources(unitId, resources) {
    const container = document.getElementById(`resources-content-${unitId}`);

    if (resources.length === 0) {
        container.innerHTML = '<p style="color: var(--color-text-secondary); font-size: 0.9rem;">Sin recursos</p>';
        return;
    }

    const icons = {
        'document': '📄',
        'video': '🎥',
        'link': '🔗'
    };

    container.innerHTML = resources.map(resource => `
        <div class="resource-item">
            <div style="display: flex; align-items: center;">
                <span class="resource-icon">${icons[resource.resource_type] || '📎'}</span>
                <div>
                    <strong style="color: var(--color-text);">${resource.title}</strong>
                    <br>
                    <a href="${resource.url}" target="_blank" style="color: var(--color-primary); font-size: 0.85rem;">${resource.url.substring(0, 50)}...</a>
                </div>
            </div>
            <button class="btn-icon btn-delete" style="padding: 0.3rem 0.6rem; font-size: 0.8rem;" onclick="deleteResource('${resource.id}', '${unitId}')">
                🗑️
            </button>
        </div>
    `).join('');
}

// Crear unidad
window.showCreateUnitModal = function() {
    currentEditingUnitId = null;
    document.getElementById('unitModalTitle').textContent = 'Nueva Unidad';
    document.getElementById('unitForm').reset();
    document.getElementById('resourcesSection').style.display = 'none';
    document.getElementById('unitModal').style.display = 'block';
};

// Editar unidad
window.editUnit = async function(unitId) {
    currentEditingUnitId = unitId;

    try {
        showLoading();
        const response = await fetch(`${CONFIG.API_BASE_URL}/courses/${currentCourseId}/units`, {
            headers: getAuthHeaders()
        });

        if (!response.ok) throw new Error('Error al cargar unidad');

        const units = await response.json();
        const unit = units.find(u => u.id === unitId);

        if (!unit) throw new Error('Unidad no encontrada');

        document.getElementById('unitModalTitle').textContent = 'Editar Unidad';
        document.getElementById('unitId').value = unit.id;
        document.getElementById('unitTitle').value = unit.title;
        document.getElementById('unitDescription').value = unit.description || '';
        document.getElementById('unitContent').value = unit.content;
        document.getElementById('unitOrder').value = unit.order;

        // Mostrar sección de recursos
        document.getElementById('resourcesSection').style.display = 'block';
        await loadModalResources(unitId);

        document.getElementById('unitModal').style.display = 'block';
    } catch (error) {
    console.error('Error:', error);
    showNotification('Error al cargar la unidad', 'error');
    } finally {
        hideLoading();
    }
};

// Cargar recursos en el modal
async function loadModalResources(unitId) {
    try {
        const response = await fetch(`${CONFIG.API_BASE_URL}/courses/units/${unitId}/resources`, {
            headers: getAuthHeaders()
        });

        if (!response.ok) throw new Error('Error al cargar recursos');

        const resources = await response.json();

        const container = document.getElementById('resourcesList');
        const icons = {
            'document': '📄',
            'video': '🎥',
            'link': '🔗'
        };

        if (resources.length === 0) {
            container.innerHTML = '<p style="color: var(--color-text-secondary);">Sin recursos</p>';
            return;
        }

        container.innerHTML = resources.map(resource => `
            <div class="resource-item">
                <div style="display: flex; align-items: center;">
                    <span class="resource-icon">${icons[resource.resource_type] || '📎'}</span>
                    <div>
                        <strong>${resource.title}</strong>
                        <br>
                        <small style="color: var(--color-text-secondary);">${resource.url}</small>
                    </div>
                </div>
                <button class="btn-icon btn-delete" style="padding: 0.3rem 0.6rem;" onclick="deleteResourceFromModal('${resource.id}', '${unitId}')">🗑️</button>
            </div>
        `).join('');
    } catch (error) {
        console.error('Error:', error);
    }
}

// Guardar unidad
document.getElementById('unitForm').addEventListener('submit', async (e) => {
    e.preventDefault();

    const unitData = {
        title: document.getElementById('unitTitle').value,
        description: document.getElementById('unitDescription').value,
        content: document.getElementById('unitContent').value,
        order: parseInt(document.getElementById('unitOrder').value)
    };

    try {
        showLoading();

        let response;
        if (currentEditingUnitId) {
            // Actualizar
            response = await fetch(`${CONFIG.API_BASE_URL}/courses/units/${currentEditingUnitId}`, {
                method: 'PUT',
                headers: getAuthHeaders(),
                body: JSON.stringify(unitData)
            });
        } else {
            // Crear
            response = await fetch(`${CONFIG.API_BASE_URL}/courses/${currentCourseId}/units`, {
                method: 'POST',
                headers: getAuthHeaders(),
                body: JSON.stringify(unitData)
            });
        }

        if (!response.ok) throw new Error('Error al guardar unidad');
    showNotification('✅ Unidad guardada exitosamente', 'success');
        closeUnitModal();
        await loadUnits();
    } catch (error) {
    console.error('Error:', error);
    showNotification('Error al guardar la unidad', 'error');
    } finally {
        hideLoading();
    }
});

// Eliminar unidad
window.deleteUnit = async function(unitId) {
    // Visual confirm dialog (replace with your modal implementation)
    // Modal visual personalizado marrón/anaranjado
    const confirmed = await showConfirmModal('¿Estás seguro de eliminar esta unidad? Se eliminarán todos sus recursos.');
    if (!confirmed) return;

    try {
        showLoading();
        const response = await fetch(`${CONFIG.API_BASE_URL}/courses/units/${unitId}`, {
            method: 'DELETE',
            headers: getAuthHeaders()
        });

        if (!response.ok) throw new Error('Error al eliminar unidad');
    showNotification('✅ Unidad eliminada', 'success');
        await loadUnits();
    } catch (error) {
    console.error('Error:', error);
    showNotification('Error al eliminar la unidad', 'error');
    } finally {
        hideLoading();
    }
};

// Mostrar formulario de recurso
window.showAddResourceForm = function() {
    document.getElementById('addResourceForm').style.display = 'block';
};

window.hideAddResourceForm = function() {
    document.getElementById('addResourceForm').style.display = 'none';
    document.getElementById('resourceForm').reset();
};

// Guardar recurso
document.getElementById('resourceForm').addEventListener('submit', async (e) => {
    e.preventDefault();

    if (!currentEditingUnitId) {
    showNotification('Debes guardar la unidad primero', 'error');
        return;
    }

    const resourceData = {
        title: document.getElementById('resourceTitle').value,
        resource_type: document.getElementById('resourceType').value,
        url: document.getElementById('resourceUrl').value,
        description: document.getElementById('resourceDescription').value
    };

    try {
        showLoading();
        const response = await fetch(`${CONFIG.API_BASE_URL}/courses/units/${currentEditingUnitId}/resources`, {
            method: 'POST',
            headers: getAuthHeaders(),
            body: JSON.stringify(resourceData)
        });

        if (!response.ok) throw new Error('Error al guardar recurso');
    showNotification('✅ Recurso agregado', 'success');
        hideAddResourceForm();
        await loadModalResources(currentEditingUnitId);
        await loadUnits();
    } catch (error) {
    console.error('Error:', error);
    showNotification('Error al guardar el recurso', 'error');
    } finally {
        hideLoading();
    }
});

// Eliminar recurso
window.deleteResource = async function(resourceId, unitId) {
    if (!confirm('¿Eliminar este recurso?')) return;

    try {
        showLoading();
        const response = await fetch(`${CONFIG.API_BASE_URL}/courses/resources/${resourceId}`, {
            method: 'DELETE',
            headers: getAuthHeaders()
        });

        if (!response.ok) throw new Error('Error al eliminar recurso');
        showNotification('✅ Recurso eliminado', 'success');
        await loadUnitResources(unitId);
    } catch (error) {
        console.error('Error:', error);
        showNotification('Error al eliminar el recurso', 'error');
    } finally {
        hideLoading();
    }
};

window.deleteResourceFromModal = async function(resourceId, unitId) {
    await deleteResource(resourceId, unitId);
    await loadModalResources(unitId);
};

// Cerrar modal
window.closeUnitModal = function() {
    document.getElementById('unitModal').style.display = 'none';
    document.getElementById('addResourceForm').style.display = 'none';
    currentEditingUnitId = null;
};

// Inicializar
loadCourseInfo();
// Fin del archivo
