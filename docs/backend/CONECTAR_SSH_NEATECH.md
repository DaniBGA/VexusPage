# 🔐 CONECTAR POR SSH A NEATECH

**Fecha:** 2025-10-31
**Hosting:** Neatech (cPanel)

---

## 📋 RESUMEN

Tienes una carpeta `.ssh` en tu Carpeta principal, lo que significa que **SSH está habilitado** en tu cuenta de Neatech. Esto te permite crear el symlink sin necesidad de contactar a soporte.

---

## 🔑 OBTENER CREDENCIALES SSH

### Opción 1: Desde cPanel

1. Inicia sesión en tu cPanel de Neatech
2. Busca la sección **"SSH Access"** o **"Terminal"**
3. Allí encontrarás:
   - **Host:** Probablemente `grupovexus.com` o `ssh.neatech.com.ar`
   - **Puerto:** 22 (por defecto) o el que te indiquen
   - **Usuario:** `grupovex` (tu usuario de cPanel)
   - **Contraseña:** La misma de cPanel

### Opción 2: Contactar Soporte

Si no encuentras la información en cPanel, contacta a soporte:

```
Asunto: Información de acceso SSH

Hola,

Necesito la información de acceso SSH para mi cuenta:
- Dominio: grupovexus.com
- Usuario: grupovex

Por favor indíquenme:
- Host SSH
- Puerto
- Método de autenticación (password o clave)

Gracias.
```

---

## 💻 CONECTAR DESDE WINDOWS

### Opción A: PowerShell / CMD (Recomendado)

Windows 10/11 ya tiene SSH incluido.

1. Abre **PowerShell** o **CMD**
2. Ejecuta:

```bash
ssh grupovex@grupovexus.com
# O si te indican otro host:
ssh grupovex@ssh.neatech.com.ar
```

3. Si es la primera vez, te pedirá confirmar la huella digital (escribe `yes`)
4. Ingresa tu contraseña de cPanel

### Opción B: PuTTY

1. Descarga [PuTTY](https://www.putty.org/)
2. Instala y abre PuTTY
3. En "Host Name" ingresa: `grupovexus.com` (o el host que te indiquen)
4. Puerto: `22`
5. Click en "Open"
6. Login: `grupovex`
7. Password: [tu contraseña de cPanel]

---

## 🔗 CREAR EL SYMLINK

Una vez conectado por SSH:

### Paso 1: Verificar ubicación actual

```bash
pwd
# Debería mostrar algo como: /home/grupovex
```

### Paso 2: Ir a public_html

```bash
cd web/grupovexus.com/public_html
```

### Paso 3: Verificar que backend existe

```bash
ls -la ../private/backend/
```

Deberías ver:
- `app/` (carpeta)
- `passenger_wsgi.py`
- `.htaccess`
- `requirements.txt`

### Paso 4: Crear symlink

```bash
ln -s ../private/backend api
```

### Paso 5: Verificar que se creó

```bash
ls -lah api
```

Deberías ver algo como:
```
lrwxrwxrwx 1 grupovex grupovex 18 Oct 31 15:30 api -> ../private/backend
```

La `l` al inicio indica que es un symlink.

---

## 📜 SCRIPT AUTOMÁTICO

También puedes usar el script que creamos:

### Paso 1: Subir el script

1. Sube el archivo `crear_symlink.sh` a tu carpeta principal vía File Manager
2. Dale permisos de ejecución

### Paso 2: Conectar por SSH y ejecutar

```bash
# Conectar
ssh grupovex@grupovexus.com

# Dar permisos
chmod +x crear_symlink.sh

# Ejecutar
./crear_symlink.sh
```

El script:
- Verificará que el backend existe
- Creará el symlink automáticamente
- Te mostrará el resultado

---

## ✅ VERIFICAR QUE FUNCIONA

### Desde SSH:

```bash
# Verificar que el symlink existe
ls -lah ~/web/grupovexus.com/public_html/api

# Verificar que apunta al lugar correcto
readlink ~/web/grupovexus.com/public_html/api
# Debería mostrar: ../private/backend
```

### Desde el navegador:

Abre: `https://grupovexus.com/api/v1/health`

Deberías ver:
```json
{
  "status": "healthy",
  "database": "connected",
  "timestamp": "2025-10-31T..."
}
```

---

## 🐛 SOLUCIÓN DE PROBLEMAS

### Error: "Permission denied (publickey)"

**Causa:** El servidor requiere autenticación con clave SSH, no password.

**Solución:**
1. En cPanel → SSH Access → Manage SSH Keys
2. Genera un par de claves
3. Descarga la clave privada
4. Usa la clave para conectar:

```bash
ssh -i ruta/a/clave_privada grupovex@grupovexus.com
```

### Error: "Connection refused"

**Causa:** Puerto incorrecto o SSH no habilitado.

**Solución:**
1. Verifica el puerto (puede ser 2222 en lugar de 22)
2. Contacta a soporte para confirmar que SSH está habilitado

```bash
# Probar con puerto alternativo
ssh -p 2222 grupovex@grupovexus.com
```

### Error: "ln: failed to create symbolic link 'api': File exists"

**Causa:** Ya existe un archivo o carpeta llamado `api`.

**Solución:**
```bash
# Ver qué es
ls -lah api

# Si es un symlink viejo, eliminarlo
rm api

# Si es una carpeta, renombrarla
mv api api_backup

# Luego crear el nuevo symlink
ln -s ../private/backend api
```

---

## 📝 COMANDOS ÚTILES EN SSH

```bash
# Ver directorio actual
pwd

# Listar archivos (incluye ocultos)
ls -lah

# Cambiar de directorio
cd ruta/a/carpeta

# Volver a carpeta principal
cd ~

# Ver contenido de archivo
cat archivo.txt

# Ver logs del backend
tail -f ~/web/grupovexus.com/logs/error_log

# Reiniciar aplicación Passenger
touch ~/web/grupovexus.com/private/backend/tmp/restart.txt

# Salir de SSH
exit
```

---

## 🎯 CHECKLIST COMPLETO

- [ ] Obtener credenciales SSH desde cPanel
- [ ] Conectar por SSH desde Windows (PowerShell/PuTTY)
- [ ] Verificar que estás en la ubicación correcta (`pwd`)
- [ ] Ir a `public_html`: `cd web/grupovexus.com/public_html`
- [ ] Verificar que backend existe: `ls -la ../private/backend/`
- [ ] Crear symlink: `ln -s ../private/backend api`
- [ ] Verificar symlink: `ls -lah api`
- [ ] Probar en navegador: `https://grupovexus.com/api/v1/health`
- [ ] Verificar frontend conecta correctamente

---

## 🔄 ALTERNATIVA: File Manager + Soporte

Si por alguna razón no puedes conectar por SSH, aún puedes:

1. Contactar a soporte de Neatech
2. Pedirles que ejecuten el comando:

```bash
cd /ruta/absoluta/web/grupovexus.com/public_html
ln -s ../private/backend api
```

Usa el mensaje de solicitud que está en [SIN_SUBDOMINIO.md](SIN_SUBDOMINIO.md#solicitud-para-soporte-de-neatech).

---

## 📞 SOPORTE

- **Neatech Support:** Abre un ticket desde cPanel
- **Documentación SSH:** https://www.neatech.com.ar/soporte (si existe)

---

**Última actualización:** 2025-10-31
**Versión:** 1.0.0
**Estado:** ✅ Guía para conectar SSH y crear symlink
