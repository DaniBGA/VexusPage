# 🔧 SSH CONNECTION TROUBLESHOOTING - NEATECH

**Problema:** `ssh: connect to host ns1.neatech.ar port 22: Connection timed out`

---

## 🔍 POSIBLES CAUSAS

### 1. Puerto SSH no es el estándar (22)
Muchos hostings usan puertos alternativos por seguridad:
- Puerto 2222
- Puerto 21098
- Otro puerto personalizado

### 2. SSH no está habilitado en tu plan
La carpeta `.ssh` existe, pero el acceso SSH puede estar deshabilitado.

### 3. Host incorrecto
El host SSH puede ser diferente al dominio principal.

---

## ✅ SOLUCIONES

### Solución 1: Buscar información SSH en cPanel

1. **Ingresa a tu cPanel de Neatech**
   - URL: Probablemente `https://grupovexus.com:2083` o desde panel de Neatech

2. **Busca estas secciones:**
   - **"SSH Access"** o **"Acceso SSH"**
   - **"Terminal"**
   - **"Manage SSH Keys"** o **"Gestionar Claves SSH"**
   - En la sección **"Security"** o **"Seguridad"**

3. **Información que debes encontrar:**
   ```
   SSH Host: [puede ser grupovexus.com, ssh.neatech.com.ar, etc]
   SSH Port: [puede ser 22, 2222, 21098, etc]
   Username: grupovex
   Authentication: Password o SSH Key
   ```

---

### Solución 2: Probar puertos alternativos

Intenta con estos comandos desde PowerShell:

```bash
# Probar puerto 2222 (común en hostings compartidos)
ssh -p 2222 grupovex@grupovexus.com

# Probar puerto 21098 (usado por algunos cPanel)
ssh -p 21098 grupovex@grupovexus.com

# Probar con el dominio del hosting
ssh -p 2222 grupovex@neatech.com.ar

# Probar con la IP del servidor (reemplazar X.X.X.X con tu IP)
ssh -p 2222 grupovex@X.X.X.X
```

Para encontrar la IP de tu servidor:
```bash
ping grupovexus.com
# O desde PowerShell:
Resolve-DnsName grupovexus.com
```

---

### Solución 3: Usar Terminal de cPanel

Si SSH externo no funciona, **cPanel tiene una terminal web integrada**:

1. **Ingresa a cPanel**
2. Busca **"Terminal"** o **"Shell"** en el buscador de cPanel
3. Click en **"Terminal"**
4. Se abrirá una consola directamente en tu navegador
5. Ya estarás en tu carpeta principal (`~`)

**Desde allí puedes crear el symlink:**

```bash
cd web/grupovexus.com/public_html
ln -s ../private/backend api
ls -lah api
```

---

### Solución 4: Contactar a Soporte de Neatech

Si ninguna opción funciona, contacta a soporte:

```
Asunto: Información de acceso SSH

Hola equipo de Neatech,

Necesito acceder por SSH a mi cuenta para configurar mi aplicación.

Detalles de mi cuenta:
- Dominio: grupovexus.com
- Usuario: grupovex

Veo que tengo una carpeta .ssh en mi cuenta, pero no puedo conectar:
- He intentado puerto 22: Connection timed out
- He intentado puerto 2222: Connection timed out

Por favor indíquenme:
1. ¿Está SSH habilitado en mi plan?
2. ¿Cuál es el host SSH correcto?
3. ¿Cuál es el puerto SSH?
4. ¿Necesito usar autenticación con clave o con password?

Alternativamente, ¿pueden crear un symlink por mí?
  FROM: public_html/api
  TO:   ../private/backend

Objetivo: Que https://grupovexus.com/api apunte a mi aplicación Python.

Gracias.
```

---

## 🖥️ ALTERNATIVA: TERMINAL WEB EN cPANEL

**Esta es la solución más probable si SSH externo no funciona.**

### Pasos:

1. **Accede a cPanel** (https://grupovexus.com:2083 o desde panel de Neatech)

2. **Busca "Terminal"**:
   - En el buscador de cPanel escribe: `terminal`
   - O busca en la sección "Advanced" → "Terminal"

3. **Click en "Terminal"**
   - Se abrirá una terminal web en tu navegador
   - Ya estarás conectado como `grupovex`

4. **Verificar ubicación**:
   ```bash
   pwd
   # Debería mostrar: /home/grupovex o similar
   ```

5. **Crear el symlink**:
   ```bash
   # Ir a public_html
   cd web/grupovexus.com/public_html

   # Verificar que backend existe
   ls -la ../private/backend/

   # Crear symlink
   ln -s ../private/backend api

   # Verificar
   ls -lah api
   ```

6. **Verificar en navegador**:
   ```
   https://grupovexus.com/api/v1/health
   ```

---

## 🔧 ALTERNATIVA SIN SSH: Usar File Manager + PHP Script

Si no tienes acceso a terminal, puedes crear un script PHP temporal:

### 1. Crear archivo en public_html/crear_symlink.php

```php
<?php
// crear_symlink.php - Crear symlink para API
// ⚠️ ELIMINAR ESTE ARCHIVO DESPUÉS DE USARLO

$backend = '../private/backend';
$symlink = 'api';

echo "<h2>Crear Symlink para API</h2>";
echo "<p>Backend: $backend</p>";
echo "<p>Symlink: $symlink</p>";
echo "<hr>";

// Verificar que backend existe
if (!is_dir($backend)) {
    echo "<p style='color:red'>❌ Error: Backend no encontrado en $backend</p>";
    exit;
}

// Verificar si symlink ya existe
if (file_exists($symlink)) {
    if (is_link($symlink)) {
        echo "<p style='color:orange'>⚠️ Symlink ya existe: " . readlink($symlink) . "</p>";
        unlink($symlink);
        echo "<p>Symlink anterior eliminado.</p>";
    } else {
        echo "<p style='color:red'>❌ Error: Ya existe un archivo/carpeta llamado 'api'</p>";
        exit;
    }
}

// Crear symlink
if (symlink($backend, $symlink)) {
    echo "<p style='color:green'>✅ Symlink creado exitosamente!</p>";
    echo "<p>Destino: " . readlink($symlink) . "</p>";
    echo "<hr>";
    echo "<p>Verifica que funcione: <a href='https://grupovexus.com/api/v1/health' target='_blank'>https://grupovexus.com/api/v1/health</a></p>";
    echo "<p style='color:red'><strong>⚠️ IMPORTANTE: Elimina este archivo (crear_symlink.php) después de verificar.</strong></p>";
} else {
    echo "<p style='color:red'>❌ Error: No se pudo crear el symlink.</p>";
    echo "<p>Posible causa: Permisos insuficientes o symlinks deshabilitados por el hosting.</p>";
    echo "<p>Contacta a soporte de Neatech.</p>";
}
?>
```

### 2. Acceder al script

Abre en tu navegador:
```
https://grupovexus.com/crear_symlink.php
```

### 3. Eliminar el script después de usarlo

Borra `crear_symlink.php` desde File Manager.

---

## 📊 RESUMEN DE OPCIONES

| Método | Probabilidad | Dificultad |
|--------|--------------|------------|
| **Terminal Web en cPanel** | 🟢 Alta | ⭐ Fácil |
| **SSH con puerto alternativo** | 🟡 Media | ⭐⭐ Media |
| **Script PHP temporal** | 🟢 Alta | ⭐ Fácil |
| **Contactar soporte** | 🟢 Alta | ⭐ Muy fácil |

---

## 🎯 RECOMENDACIÓN

**Prueba en este orden:**

1. ✅ **Terminal Web en cPanel** (más fácil y probable)
2. ✅ **Script PHP** (si no encuentras la terminal)
3. ✅ **Contactar a soporte** (si nada funciona)

---

**Última actualización:** 2025-10-31
**Estado:** ⚠️ Troubleshooting SSH connection issues
