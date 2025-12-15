import CONFIG from './config.js';
import { AuthService } from './api/auth.js';

let currentCourseId = null;
let currentEditingUnitId = null;
let pendingResources = []; // Recursos que se guardarán con la unidad

// Obtener el ID del curso desde la URL
const urlParams = new URLSearchParams(window.location.search);
currentCourseId = urlParams.get('id');

if (!currentCourseId) {
    showNotification('No se especificó un curso para editar', 'error');
    setTimeout(() => window.location.href = '../index.html', 1500);
}

// Verificar autenticación y rol de admin
if (!AuthService.isAuthenticated()) {
    showNotification('Debes iniciar sesión para acceder al editor', 'error');
    setTimeout(() => window.location.href = '../index.html', 1500);
}

const user = AuthService.getCurrentUser();
if (user.role !== 'admin') {
    showNotification('No tienes permisos para acceder al editor de cursos', 'error');
    setTimeout(() => window.location.href = '../index.html', 1500);
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

// ===== DRAG & DROP FUNCTIONALITY =====
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

// Modal de confirmación visual
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

const dropZone = document.getElementById('dropZone');
const fileInput = document.getElementById('fileInput');

// Tabs de tipo de recurso
const resourceTabs = document.querySelectorAll('.resource-type-tab');
const resourceSections = {
    file: document.getElementById('resource-file'),
    video: document.getElementById('resource-video'),
    link: document.getElementById('resource-link')
};

window.switchResourceTab = function(type) {
    resourceTabs.forEach(tab => tab.classList.remove('active'));
    resourceTabs.forEach(tab => {
        if (tab.textContent.toLowerCase().includes(type)) tab.classList.add('active');
    });
    Object.keys(resourceSections).forEach(key => {
        if (key === type) {
            resourceSections[key].classList.add('active');
        } else {
            resourceSections[key].classList.remove('active');
        }
    });
}

// Añadir video por URL
window.addVideoResource = function() {
    const title = document.getElementById('videoTitle').value.trim();
    const url = document.getElementById('videoUrl').value.trim();
    if (!url) return showNotification('Ingresa la URL del video', 'error');
    pendingResources.push({
        title: title || 'Video',
        resource_type: 'video',
        url,
        description: '',
        isNew: true
    });
    document.getElementById('videoTitle').value = '';
    document.getElementById('videoUrl').value = '';
    updateResourcesPreview();
}

// Añadir enlace por URL
window.addLinkResource = function() {
    const title = document.getElementById('linkTitle').value.trim();
    const url = document.getElementById('linkUrl').value.trim();
    const description = document.getElementById('linkDescription').value.trim();
    if (!url) return showNotification('Ingresa la URL del enlace', 'error');
    pendingResources.push({
        title: title || 'Enlace',
        resource_type: 'link',
        url,
        description,
        isNew: true
    });
    document.getElementById('linkTitle').value = '';
    document.getElementById('linkUrl').value = '';
    document.getElementById('linkDescription').value = '';
    updateResourcesPreview();
}

// Inputs para añadir recursos manuales (video y enlace)
const addVideoBtn = document.getElementById('addVideoBtn');
const addLinkBtn = document.getElementById('addLinkBtn');
const videoUrlInput = document.getElementById('videoUrlInput');
const linkUrlInput = document.getElementById('linkUrlInput');

if (addVideoBtn && videoUrlInput) {
    addVideoBtn.addEventListener('click', () => {
        const url = videoUrlInput.value.trim();
        if (!url) return showNotification('Ingresa la URL del video', 'error');
        pendingResources.push({
            title: 'Video',
            resource_type: 'video',
            url,
            description: '',
            isNew: true
        });
        videoUrlInput.value = '';
        updateResourcesPreview();
    });
}

if (addLinkBtn && linkUrlInput) {
    addLinkBtn.addEventListener('click', () => {
        const url = linkUrlInput.value.trim();
        if (!url) return showNotification('Ingresa la URL del enlace', 'error');
        pendingResources.push({
            title: 'Enlace',
            resource_type: 'link',
            url,
            description: '',
            isNew: true
        });
        linkUrlInput.value = '';
        updateResourcesPreview();
    });
}

// Procesa los archivos añadidos y los agrega a pendingResources
function handleFiles(files) {
    if (!files || !files.length) return;
    Array.from(files).forEach(file => {
        pendingResources.push({
            title: file.name,
            resource_type: 'document',
            url: '', // La URL se obtendrá cuando se guarde la unidad
            description: '',
            isNew: true,
            file: file // Guardar el objeto File para subirlo después
        });
    });
    updateResourcesPreview();
}

// Prevenir recarga y comportamiento por defecto en toda la página (solo drop y dragover)
['drop', 'dragover'].forEach(eventName => {
    window.addEventListener(eventName, e => e.preventDefault(), false);
    document.addEventListener(eventName, e => e.preventDefault(), false);
});

// Feedback visual en la zona de drop
['dragenter', 'dragover'].forEach(eventName => {
    dropZone.addEventListener(eventName, () => dropZone.classList.add('dragover'), false);
});
['dragleave', 'drop'].forEach(eventName => {
    dropZone.addEventListener(eventName, () => dropZone.classList.remove('dragover'), false);
});

// Manejar archivos soltados
dropZone.addEventListener('drop', function(e) {
    e.preventDefault();
    e.stopPropagation();
    const files = e.dataTransfer.files;
    if (files.length) {
        showNotification(`Archivo(s) dropeado(s): ${Array.from(files).map(f => f.name).join(', ')}`, 'info');
        handleFiles(files);
    }
}, false);

// Manejar selección manual de archivos
fileInput.addEventListener('change', (e) => {
    handleFiles(e.target.files);
});

// Permitir click en dropZone para abrir el selector
dropZone.addEventListener('click', () => fileInput.click());
// ...existing code...

// Renderiza la vista previa de los recursos pendientes en el modal de unidad
function updateResourcesPreview() {
    const container = document.getElementById('resourcesPreview');
    if (!container) return;
    if (pendingResources.length === 0) {
        container.innerHTML = '<p style="color: var(--color-text-secondary); font-size: 0.9rem;">Sin recursos añadidos</p>';
        return;
    }
    const types = {
        'document': 'Documento',
        'video': 'Video',
        'link': 'Enlace'
    };
    container.innerHTML = pendingResources.map((resource, index) => `
        <div style="background: #222; padding: 0.75rem; border-radius: 8px; margin-bottom: 0.5rem; display: flex; align-items: center; gap: 0.75rem;">
            <span style="font-size: 1.5rem;">${resource.resource_type === 'document' ? '📄' : resource.resource_type === 'video' ? '🎥' : '🔗'}</span>
            <div style="flex: 1;">
                <strong style="color: var(--color-text); font-size: 0.9rem;">${resource.title || '(Sin título)'}</strong>
                <div style="color: var(--color-text-secondary); font-size: 0.8rem;">${types[resource.resource_type] || 'Recurso'}</div>
            </div>
            <button type="button" class="btn-remove-resource" onclick="removeResource(${index})" style="background: none; border: none; color: #ff4d4f; font-size: 1.2rem; cursor: pointer;">🗑️</button>
        </div>
    `).join('');
}

// Permite cambiar el tipo de recurso entre documento, video y enlace
window.switchResourceType = function(index) {
    if (pendingResources[index]) {
        const types = ['document', 'video', 'link'];
        const currentType = pendingResources[index].resource_type;
        const nextType = types[(types.indexOf(currentType) + 1) % types.length];
        pendingResources[index].resource_type = nextType;
        updateResourcesPreview();
    }
}

window.removeResource = function(index) {
    pendingResources.splice(index, 1);
    updateResourcesPreview();
};

// ===== TAB SWITCHING =====

window.switchTab = function(tabName) {
    document.querySelectorAll('.editor-tab').forEach(tab => tab.classList.remove('active'));
    document.querySelectorAll('.tab-content').forEach(content => content.classList.remove('active'));

    // Activar el tab correcto por nombre
    const tabButton = Array.from(document.querySelectorAll('.editor-tab')).find(tab => tab.textContent.includes(tabName === 'units' ? 'Unidades' : 'Información'));
    if (tabButton) tabButton.classList.add('active');
    document.getElementById(`tab-${tabName}`).classList.add('active');

    if (tabName === 'units') {
        loadUnits();
    }
};

// ===== COURSE INFO =====

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

// ===== UNITS =====

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
                <div style="display: flex; gap: 0.5rem;">
                    <button class="btn-icon btn-edit" onclick="editUnit('${unit.id}')">
                        ✏️ Editar
                    </button>
                    <button class="btn-icon btn-delete" onclick="deleteUnit('${unit.id}')">
                        🗑️ Eliminar
                    </button>
                </div>
            </div>

            <div id="resources-${unit.id}" style="margin-top: 1rem; padding-top: 1rem; border-top: 1px solid var(--color-border);">
                <h4 style="color: var(--color-primary); font-size: 0.9rem; margin-bottom: 0.5rem;">📎 Recursos</h4>
                <div id="resources-content-${unit.id}">
                    <p style="color: var(--color-text-secondary); font-size: 0.9rem;">Cargando recursos...</p>
                </div>
            </div>
        </div>
    `).join('');

    units.forEach(unit => loadUnitResources(unit.id));
}

async function loadUnitResources(unitId) {
    try {
        const response = await fetch(`${CONFIG.API_BASE_URL}/courses/units/${unitId}/resources`, {
            headers: getAuthHeaders()
        });

        if (!response.ok) throw new Error('Error al cargar recursos');

        const resources = await response.json();
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
            <div style="background: #1a1a1a; padding: 0.75rem; border-radius: 8px; margin-bottom: 0.5rem; display: flex; align-items: center; gap: 0.75rem;">
                <span style="font-size: 1.5rem;">${icons[resource.resource_type] || '📎'}</span>
                <div style="flex: 1;">
                    <strong style="color: var(--color-text); font-size: 0.9rem;">${resource.title}</strong>
                </div>
            </div>
        `).join('');
    } catch (error) {
        console.error('Error loading resources:', error);
        document.getElementById(`resources-content-${unitId}`).innerHTML = `
            <p style="color: var(--color-text-secondary); font-size: 0.9rem;">Sin recursos</p>
        `;
    }
}

// ===== CREATE/EDIT UNIT =====

window.showCreateUnitModal = function() {
    currentEditingUnitId = null;
    pendingResources = [];
    document.getElementById('unitModalTitle').textContent = 'Nueva Unidad';
    document.getElementById('unitForm').reset();
    updateResourcesPreview();
    document.getElementById('unitModal').style.display = 'block';
};

window.editUnit = async function(unitId) {
    currentEditingUnitId = unitId;
    pendingResources = [];

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

        // Cargar recursos existentes
        await loadExistingResources(unitId);

        document.getElementById('unitModal').style.display = 'block';
    } catch (error) {
        console.error('Error:', error);
        showNotification('Error al cargar la unidad', 'error');
    } finally {
        hideLoading();
    }
};

async function loadExistingResources(unitId) {
    try {
        const response = await fetch(`${CONFIG.API_BASE_URL}/courses/units/${unitId}/resources`, {
            headers: getAuthHeaders()
        });

        if (!response.ok) return;

        const resources = await response.json();
        pendingResources = resources.map(r => ({
            ...r,
            isNew: false
        }));

        updateResourcesPreview();
    } catch (error) {
        console.error('Error loading resources:', error);
    }
}

// ===== SAVE UNIT =====

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

        let unitId;

        if (currentEditingUnitId) {
            // Actualizar unidad
            const response = await fetch(`${CONFIG.API_BASE_URL}/courses/units/${currentEditingUnitId}`, {
                method: 'PUT',
                headers: getAuthHeaders(),
                body: JSON.stringify(unitData)
            });

            if (!response.ok) throw new Error('Error al actualizar unidad');

            unitId = currentEditingUnitId;
        } else {
            // Crear unidad
            const response = await fetch(`${CONFIG.API_BASE_URL}/courses/${currentCourseId}/units`, {
                method: 'POST',
                headers: getAuthHeaders(),
                body: JSON.stringify(unitData)
            });

            if (!response.ok) throw new Error('Error al crear unidad');

            const newUnit = await response.json();
            unitId = newUnit.id;
        }

        // Guardar recursos nuevos
        const newResources = pendingResources.filter(r => r.isNew);

        for (const resource of newResources) {
            let resourceUrl = resource.url;

            // Si el recurso tiene un archivo (file), subirlo primero
            if (resource.file) {
                try {
                    const formData = new FormData();
                    formData.append('file', resource.file);

                    const uploadResponse = await fetch(`${CONFIG.API_BASE_URL}/courses/upload-file`, {
                        method: 'POST',
                        headers: {
                            'Authorization': `Bearer ${localStorage.getItem(CONFIG.TOKEN_KEY)}`
                        },
                        body: formData
                    });

                    if (!uploadResponse.ok) {
                        throw new Error('Error al subir archivo');
                    }

                    const uploadResult = await uploadResponse.json();
                    resourceUrl = uploadResult.url; // Usar la URL devuelta por el servidor
                } catch (error) {
                    console.error('Error al subir archivo:', error);
                    showNotification(`Error al subir "${resource.title}"`, 'error');
                    continue; // Saltar este recurso si falla la subida
                }
            }

            // Crear el recurso con la URL correcta
            await fetch(`${CONFIG.API_BASE_URL}/courses/units/${unitId}/resources`, {
                method: 'POST',
                headers: getAuthHeaders(),
                body: JSON.stringify({
                    title: resource.title,
                    resource_type: resource.resource_type,
                    url: resourceUrl,
                    description: resource.description
                })
            });
        }

    showNotification('✅ Unidad guardada exitosamente con todos sus recursos', 'success');
        closeUnitModal();
        await loadUnits();
    } catch (error) {
        console.error('Error:', error);
        showNotification('Error al guardar la unidad', 'error');
    } finally {
        hideLoading();
    }
});

window.deleteUnit = async function(unitId) {
    // Modal visual personalizado
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

window.closeUnitModal = function() {
    document.getElementById('unitModal').style.display = 'none';
    pendingResources = [];
    currentEditingUnitId = null;
};

// Inicializar
loadCourseInfo();
