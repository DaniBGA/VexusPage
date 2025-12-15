# 🚀 Guía para Levantar la Página Localmente

## Opción 1: Live Server (Recomendado - Más Fácil)

### Con VS Code:
1. Instalar extensión **Live Server** de Ritwick Dey
2. Abrir la carpeta `frontend` en VS Code
3. Click derecho en `index.html` → **"Open with Live Server"**
4. La página se abrirá automáticamente en `http://localhost:5500`

### Ventajas:
- ✅ Auto-reload cuando guardás cambios
- ✅ No requiere configuración
- ✅ Fácil de usar

---

## Opción 2: Python HTTP Server

### Pasos:
```powershell
# En la carpeta frontend
cd C:\Users\Daniel\Desktop\VexusPage\frontend

# Python 3
python -m http.server 8080

# Python 2 (si tenés)
python -m SimpleHTTPServer 8080
```

### Acceder:
- Abrir navegador en: `http://localhost:8080`

---

## Opción 3: Node.js http-server

### Instalación (solo primera vez):
```powershell
npm install -g http-server
```

### Uso:
```powershell
cd C:\Users\Daniel\Desktop\VexusPage\frontend
http-server -p 8080
```

### Acceder:
- Abrir navegador en: `http://localhost:8080`

---

## Opción 4: PHP Built-in Server

Si tenés PHP instalado:

```powershell
cd C:\Users\Daniel\Desktop\VexusPage\frontend
php -S localhost:8080
```

---

## 🧪 Testing de Cambios

### Checklist de Testing:

1. **Color Zafiro Imperial** ✓
   - [ ] Verificar navbar
   - [ ] Verificar botones (gradientes azules)
   - [ ] Verificar hover effects
   - [ ] Verificar modales si hay

2. **Calendly** ✓
   - [ ] Widget se carga correctamente
   - [ ] Agendar reunión de prueba
   - [ ] Verificar que aparezca alerta: "Le confirmaremos su entrevista via email"

3. **Sección "Sobre Nosotros"** ✓
   - [ ] Verificar que se vea el texto del ecosistema
   - [ ] Confirmar que NO aparece el carrusel

4. **Funcionalidad General** ✓
   - [ ] Formulario de consultoría funciona
   - [ ] Animaciones funcionan
   - [ ] Responsive design (probar en mobile con DevTools)

---

## 🛠️ Troubleshooting

### Problema: CORS Error
**Solución**: Usar Live Server o http-server, NO abrir el archivo directamente (file://)

### Problema: Calendly no carga
**Solución**: Verificar conexión a internet (el widget se carga desde CDN)

### Problema: Estilos no se aplican
**Solución**: 
1. Hard refresh: `Ctrl + Shift + R`
2. Limpiar caché del navegador
3. Abrir en modo incógnito

### Problema: Scripts no funcionan
**Solución**: Abrir DevTools (F12) y revisar la consola por errores

---

## 📝 Notas Importantes

- **Puerto por defecto**: Si el puerto está ocupado, cambiar a otro (ej: 8081, 8082)
- **Cache**: Para ver cambios inmediatos, usar DevTools con cache deshabilitado
- **Backend**: Para testing local sin backend, las funciones de Dashboard/Cursos/Admin mostrarán "Funcionalidad temporalmente deshabilitada"

---

## 🔥 Quick Start (Lo Más Rápido)

```powershell
# 1. Ir a la carpeta
cd C:\Users\Daniel\Desktop\VexusPage\frontend

# 2. Levantar servidor (elige uno)
python -m http.server 8080

# 3. Abrir navegador
start http://localhost:8080
```

---

**¿Problemas?** Revisar la consola del navegador (F12) para ver errores detallados.
