# Instrucciones para Personalizar el Carrusel del Ecosistema Vexus

## Ubicación del Carrusel

El carrusel de logos del ecosistema se encuentra en la sección "Sobre Nosotros" de [index.html](index.html), específicamente en las líneas 324-394.

## Cómo Agregar Logos Reales

### 1. Preparar las Imágenes de los Logos

- Coloca los logos de tus emprendimientos en la carpeta `Static/images/ecosystem/`
- Formato recomendado: PNG con fondo transparente
- Tamaño recomendado: 200x200 píxeles (se ajustará automáticamente)
- Nombra los archivos de forma descriptiva: `logo-emprendimiento1.png`, `logo-emprendimiento2.png`, etc.

### 2. Actualizar el HTML

Reemplaza cada `<div class="logo-placeholder">Logo X</div>` con una imagen real:

**ANTES:**
```html
<div class="carousel-item">
    <div class="logo-card">
        <img src="./frontend/Static/images/ecosystem/enigma-investigacion-marca-pregunta-roja-vidrio.png">
        <span class="logo-name">Emprendimiento 1</span>
    </div>
</div>
```

**DESPUÉS:**
```html
<div class="carousel-item">
    <div class="logo-card">
        <img src="Static/images/ecosystem/logo-emprendimiento1.png" alt="Emprendimiento 1" class="logo-image">
        <span class="logo-name">Nombre del Emprendimiento</span>
    </div>
</div>
```

### 3. Agregar Estilos para las Imágenes (Opcional)

Si quieres ajustar el estilo de las imágenes, agrega este CSS en [sections.css](Static/css/layout/sections.css):

```css
.logo-image {
    width: 120px;
    height: 120px;
    object-fit: contain;
    border-radius: var(--radius-md);
}
```

### 4. Navegación del Carrusel con Flechas

El carrusel incluye flechas de navegación en ambos lados que permiten:
- Navegar manualmente entre los logos
- Pausar temporalmente la animación automática (se reanuda después de 3 segundos)
- Desplazarse 200 píxeles por clic (ajustable en el JavaScript)

Para ajustar la velocidad de desplazamiento de las flechas, modifica la variable `scrollAmount` en el JavaScript (línea ~616 de index.html):

```javascript
const scrollAmount = 200; // Aumenta o disminuye el valor
```

## Ajustes Adicionales

### Velocidad del Carrusel

Para ajustar la velocidad de desplazamiento, modifica la animación en [sections.css](Static/css/layout/sections.css) (línea 185):

```css
.carousel-track {
    animation: scroll 30s linear infinite; /* Cambia 30s a más o menos segundos */
}
```

- Más segundos = más lento
- Menos segundos = más rápido

### Cantidad de Logos

El carrusel actual muestra 5 logos duplicados (10 en total para el efecto infinito).

Para agregar más logos:
1. Agrega nuevos `carousel-item` después del logo 5
2. **IMPORTANTE**: Duplica también el nuevo logo después del comentario `<!-- Duplicado para efecto infinito -->`

Ejemplo para agregar un 6to logo:

```html
<!-- Primer conjunto -->
<div class="carousel-item">
    <div class="logo-card">
        <img src="Static/images/ecosystem/logo-6.png" alt="Emprendimiento 6" class="logo-image">
        <span class="logo-name">Emprendimiento 6</span>
    </div>
</div>

<!-- Más abajo, después del comentario de duplicado -->
<div class="carousel-item">
    <div class="logo-card">
        <img src="Static/images/ecosystem/logo-6.png" alt="Emprendimiento 6" class="logo-image">
        <span class="logo-name">Emprendimiento 6</span>
    </div>
</div>
```

### Hacer los Logos Clickeables

Para que cada logo redirija a la página del emprendimiento:

```html
<div class="carousel-item">
    <a href="https://url-del-emprendimiento.com" target="_blank" class="logo-card">
        <img src="Static/images/ecosystem/logo-emprendimiento.png" alt="Nombre" class="logo-image">
        <span class="logo-name">Nombre del Emprendimiento</span>
    </a>
</div>
```

Y actualiza el CSS en [sections.css](Static/css/layout/sections.css):

```css
.logo-card {
    /* ... estilos existentes ... */
    text-decoration: none; /* Quita el subrayado de los links */
}
```

## Responsividad

El carrusel está completamente optimizado para móviles:
- En pantallas pequeñas (< 768px), el carrusel aparece primero, antes del texto
- Los logos se ajustan automáticamente de tamaño
- El botón "Explora nuestro ecosistema" ocupa todo el ancho en móvil

## Solución de Problemas

### El carrusel no se mueve
- Verifica que el CSS de animación esté correctamente cargado
- Asegúrate de que no haya errores en la consola del navegador

### Los logos se ven distorsionados
- Usa imágenes cuadradas (misma altura y ancho)
- Usa PNG con fondo transparente para mejor calidad
- Verifica que el `object-fit: contain` esté aplicado

### El efecto infinito se corta
- Asegúrate de duplicar TODOS los logos después del comentario "Duplicado para efecto infinito"
- La cantidad de logos debe ser exactamente la misma antes y después del duplicado
