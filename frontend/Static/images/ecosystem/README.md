# Carpeta de Logos del Ecosistema Vexus

## Propósito

Esta carpeta contiene los logos de los emprendimientos vinculados al ecosistema Vexus que se muestran en el carrusel de la sección "Sobre Nosotros".

## Formato de Archivos

- **Formato recomendado**: PNG con fondo transparente
- **Tamaño recomendado**: 200x200 píxeles (se ajustará automáticamente a 120x120px)
- **Convención de nombres**: `logo-[nombre-emprendimiento].png`

Ejemplos:
- `logo-consultoria.png`
- `logo-realestate.png`
- `logo-tech-solutions.png`

## Cómo Agregar un Logo

1. Coloca el archivo PNG en esta carpeta
2. Abre `frontend/index.html`
3. Busca la sección del carrusel (línea ~330-390)
4. Reemplaza un `<div class="logo-placeholder">` con:

```html
<img src="Static/images/ecosystem/logo-[nombre].png" alt="Nombre del Emprendimiento" class="logo-image">
```

5. Actualiza el texto `<span class="logo-name">` con el nombre real del emprendimiento
6. **IMPORTANTE**: Recuerda duplicar el logo en la sección duplicada del carrusel para mantener el efecto infinito

## Notas

- Los logos deben ser cuadrados para evitar distorsión
- Usa fondos transparentes para mejor integración visual
- El carrusel pausará la animación cuando el usuario pase el mouse sobre él
- Los logos son responsivos y se ajustan automáticamente en móviles

Para instrucciones detalladas, consulta: [INSTRUCCIONES_ECOSISTEMA.md](../../../INSTRUCCIONES_ECOSISTEMA.md)
