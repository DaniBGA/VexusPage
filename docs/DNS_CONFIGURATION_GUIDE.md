# Guía de Configuración DNS para grupovexus.com

## Problema Actual

El dominio `grupovexus.com` no tiene registros DNS configurados, lo que impide que apunte a tu hosting en Neatech.

```
Error: DNS record for grupovexus.com doesn't exist
```

## Solución paso a paso

### Paso 1: Identificar tu registrador de dominios

¿Dónde compraste/registraste el dominio `grupovexus.com`?

- [ ] GoDaddy
- [ ] Namecheap
- [ ] Google Domains
- [ ] Hostinger
- [ ] Otro: __________

**Cómo saber:** Revisa tu correo electrónico en busca de "grupovexus.com registration" o "domain purchase".

### Paso 2: Contactar a Neatech

**Necesitas preguntarle a Neatech qué configuración DNS requieren.**

**Email/mensaje para Neatech:**

```
Asunto: Configuración DNS para grupovexus.com

Hola,

Necesito configurar mi dominio grupovexus.com para que apunte a mi
hosting con ustedes. ¿Qué registros DNS debo configurar?

Por favor, indíquenme:
1. ¿Debo usar registros A/CNAME o cambiar los nameservers?
2. ¿Cuál es la IP o el CNAME de su servidor?
3. ¿Tienen alguna guía de configuración DNS?

También, ¿proporcionan algún subdominio temporal mientras se propaga
el DNS? (ej: grupovexus.neatech.com)

Gracias,
[Tu nombre]
```

### Paso 3: Configurar DNS según la respuesta de Neatech

#### Opción A: Registros A y CNAME (más común)

Si Neatech te proporciona algo como:

```
IP del servidor: 123.45.67.89
CNAME: hosting.neatech.com
```

Entonces configura estos registros en tu registrador:

| Tipo  | Nombre | Valor                | TTL  |
|-------|--------|----------------------|------|
| A     | @      | 123.45.67.89         | 3600 |
| CNAME | www    | grupovexus.com       | 3600 |

**Explicación:**
- `@` = dominio raíz (grupovexus.com)
- `www` = subdominio www (www.grupovexus.com)
- TTL = tiempo de vida del registro (3600 segundos = 1 hora)

#### Opción B: Cambiar Nameservers

Si Neatech te proporciona nameservers:

```
ns1.neatech.com
ns2.neatech.com
```

Entonces cambia los nameservers de tu dominio a estos.

---

## Guías específicas por registrador

### 🌐 GoDaddy

1. Inicia sesión en [godaddy.com](https://godaddy.com)
2. Ve a **My Products** (Mis Productos)
3. Busca `grupovexus.com` y click en **DNS**
4. Scroll hasta **DNS Records** (Registros DNS)

**Para registros A/CNAME:**
- Click en **Add** (Agregar)
- Selecciona el tipo de registro (A o CNAME)
- Ingresa el nombre (`@` o `www`)
- Ingresa el valor (IP o dominio)
- Click en **Save**

**Para cambiar nameservers:**
- Ve a la pestaña **Nameservers**
- Click en **Change Nameservers**
- Selecciona **Custom**
- Ingresa los nameservers de Neatech
- Click en **Save**

**Tiempo de propagación:** 24-48 horas

---

### 🔵 Namecheap

1. Inicia sesión en [namecheap.com](https://namecheap.com)
2. Ve a **Domain List** (Lista de dominios)
3. Click en **Manage** junto a `grupovexus.com`

**Para registros A/CNAME:**
- Ve a **Advanced DNS**
- Click en **Add New Record**
- Selecciona el tipo (A Record o CNAME)
- Ingresa el host (`@` o `www`)
- Ingresa el valor (IP o dominio)
- Click en el checkmark (✓) para guardar

**Para cambiar nameservers:**
- Ve a la pestaña **Domain**
- En **Nameservers**, selecciona **Custom DNS**
- Ingresa los nameservers de Neatech
- Click en el checkmark (✓)

**Tiempo de propagación:** 30 minutos - 48 horas

---

### 🔴 Google Domains / Google Cloud DNS

1. Inicia sesión en [domains.google.com](https://domains.google.com)
2. Click en `grupovexus.com`
3. Ve a **DNS** en el menú lateral

**Para registros A/CNAME:**
- Scroll hasta **Custom records**
- Click en **Manage custom records**
- Click en **Create new record**
- Ingresa el hostname (`@` o `www`)
- Selecciona el tipo (A o CNAME)
- Ingresa el valor
- Click en **Add**

**Para cambiar nameservers:**
- Ve a **Name servers**
- Click en **Use custom name servers**
- Ingresa los nameservers de Neatech
- Click en **Save**

**Tiempo de propagación:** 15 minutos - 24 horas

---

### 🟡 Hostinger

1. Inicia sesión en [hostinger.com](https://hostinger.com)
2. Ve a **Dominios**
3. Click en **Gestionar** junto a `grupovexus.com`

**Para registros A/CNAME:**
- Ve a **Zona DNS**
- Click en **Agregar registro**
- Selecciona el tipo (A o CNAME)
- Ingresa el nombre (`@` o `www`)
- Ingresa el contenido (IP o dominio)
- Click en **Agregar registro**

**Para cambiar nameservers:**
- Ve a **Servidores de nombres**
- Click en **Cambiar servidores de nombres**
- Ingresa los nameservers de Neatech
- Click en **Guardar**

**Tiempo de propagación:** 24-48 horas

---

## Paso 4: Verificar la propagación DNS

Después de configurar el DNS, debes esperar a que se propague. Esto puede tomar:
- Mínimo: 15 minutos
- Promedio: 2-6 horas
- Máximo: 48 horas

### Herramientas para verificar:

#### Desde la terminal:

```bash
# Verificar si el dominio tiene IP
nslookup grupovexus.com

# Verificar registros A
nslookup -type=A grupovexus.com

# Verificar registros CNAME
nslookup -type=CNAME www.grupovexus.com
```

#### Desde el navegador:

1. [DNS Checker](https://dnschecker.org/)
   - Ingresa: `grupovexus.com`
   - Verifica que muestre la IP correcta

2. [What's My DNS](https://www.whatsmydns.net/)
   - Ingresa: `grupovexus.com`
   - Verifica la propagación global

3. [DNS Propagation Checker](https://www.dnspropagation.net/)
   - Ingresa: `grupovexus.com`
   - Verifica en múltiples ubicaciones

---

## Paso 5: Actualizar CORS si usas subdominio temporal

Si Neatech te proporciona un subdominio temporal (ej: `grupovexus.neatech.com`), necesitas actualizar el CORS:

### Opción 1: Actualizar directamente en Render Dashboard

1. Ve a [Render Dashboard](https://dashboard.render.com/)
2. Selecciona `vexus-backend`
3. Ve a **Environment**
4. Busca `ALLOWED_ORIGINS`
5. Agrega el subdominio temporal:
   ```
   https://grupovexus.com,https://www.grupovexus.com,https://grupovexus.neatech.com,http://localhost:3000
   ```
6. Click en **Save Changes**

### Opción 2: Actualizar render.yaml y hacer push

Edita el archivo `render.yaml`:

```yaml
- key: ALLOWED_ORIGINS
  value: https://grupovexus.com,https://www.grupovexus.com,https://grupovexus.neatech.com,http://localhost:3000
```

Luego:

```bash
git add render.yaml
git commit -m "Update: Add temporary Neatech subdomain to CORS"
git push origin main
```

---

## Configuración típica recomendada

Cuando tengas la información de Neatech, esta es una configuración típica:

### DNS Records:

```
# Dominio principal
Tipo: A
Nombre: @
Valor: [IP de Neatech]
TTL: 3600

# Subdominio www
Tipo: CNAME
Nombre: www
Valor: grupovexus.com
TTL: 3600
```

### SSL/HTTPS:

- Asegúrate de que Neatech tenga SSL habilitado
- Verifica que el certificado sea válido para `grupovexus.com` y `www.grupovexus.com`

---

## Checklist final

Una vez configurado el DNS, verifica:

- [ ] `nslookup grupovexus.com` devuelve una IP
- [ ] `https://grupovexus.com` carga tu sitio
- [ ] `https://www.grupovexus.com` funciona
- [ ] El certificado SSL está activo (candado verde)
- [ ] La consola del navegador no muestra errores de CORS
- [ ] Los botones y formularios funcionan correctamente

---

## Troubleshooting

### Problema: "DNS no se propaga después de 48 horas"

**Soluciones:**
1. Verifica que los registros estén correctos (sin espacios, sin errores tipográficos)
2. Contacta al soporte de tu registrador
3. Verifica que el dominio no esté expirado
4. Limpia el caché DNS de tu computadora:
   ```bash
   # Windows
   ipconfig /flushdns

   # macOS
   sudo dscacheutil -flushcache

   # Linux
   sudo systemd-resolve --flush-caches
   ```

### Problema: "El sitio carga pero sin estilos"

**Soluciones:**
1. Verifica que todos los archivos estén en las rutas correctas
2. Abre la consola del navegador (F12) y busca errores 404
3. Verifica que las rutas sean relativas y no absolutas

### Problema: "Error de CORS"

**Soluciones:**
1. Verifica que `ALLOWED_ORIGINS` en Render incluya tu dominio
2. Asegúrate de usar HTTPS en todos lados
3. Verifica que el backend esté respondiendo:
   ```bash
   curl https://vexuspage.onrender.com/health
   ```

---

## Resumen de pasos

1. ✅ Identificar tu registrador de dominios
2. ⏳ Contactar a Neatech para obtener configuración DNS
3. ⏳ Configurar DNS en tu registrador
4. ⏳ Esperar propagación (2-48 horas)
5. ⏳ Subir archivos del frontend a Neatech
6. ⏳ Verificar que todo funcione

**Estado actual:** Necesitas la información DNS de Neatech para continuar.

---

## Contacto

Si tienes problemas:
- **Registrador de dominios:** Contacta su soporte técnico
- **Neatech:** Contacta su soporte para configuración DNS
- **Render:** [Render Dashboard](https://dashboard.render.com/) para logs del backend
