# 📧 GUÍA: Evitar que los emails vayan a SPAM

## 🚨 Problema Actual

Los emails enviados con SendGrid llegan a la carpeta de SPAM porque:

1. ❌ No hay autenticación de dominio (SPF, DKIM, DMARC)
2. ❌ El remitente `grupovexus@gmail.com` no está verificado en SendGrid
3. ❌ SendGrid no está autorizado para enviar desde tu dominio

---

## ✅ SOLUCIÓN RÁPIDA (5 minutos)

### Paso 1: Verificar Single Sender

1. Ve a: https://app.sendgrid.com/settings/sender_auth/senders
2. Click "Create New Sender"
3. Completa:
   ```
   From Name: Vexus
   From Email: noreply@grupovexus.com
   Reply To: grupovexus@gmail.com
   Company: Grupo Vexus
   Address: (tu dirección real)
   City, State, Zip, Country
   ```
4. Click "Create"
5. **Revisa tu email** y click en el link de verificación

### Paso 2: Actualizar .env.production

**Cambiar en el servidor:**
```bash
nano .env.production
```

**Cambiar esta línea:**
```
EMAIL_FROM=noreply@grupovexus.com
```

**O si prefieres:**
```
EMAIL_FROM=info@grupovexus.com
```

### Paso 3: Reiniciar backend

```bash
docker-compose -f docker-compose.prod.yml --env-file .env.production restart backend
```

---

## ✅ SOLUCIÓN PROFESIONAL (15 minutos - RECOMENDADO)

### Domain Authentication (Elimina SPAM al 95%)

1. **Ve a SendGrid:**
   https://app.sendgrid.com/settings/sender_auth

2. **Click "Authenticate Your Domain"**

3. **Selecciona tu DNS provider** (GoDaddy, Cloudflare, etc.)

4. **Ingresa tu dominio:** `grupovexus.com`

5. **SendGrid te dará registros DNS como estos:**

   ```
   Tipo: CNAME
   Nombre: s1._domainkey
   Valor: s1.domainkey.u1234567.wl123.sendgrid.net
   
   Tipo: CNAME
   Nombre: s2._domainkey
   Valor: s2.domainkey.u1234567.wl123.sendgrid.net
   
   Tipo: CNAME  
   Nombre: em1234
   Valor: u1234567.wl123.sendgrid.net
   ```

6. **Agrega estos registros en tu panel DNS:**

   **Si usas Cloudflare:**
   - Ve a: DNS → Add record
   - Copia cada registro exactamente como aparece
   - Proxy status: DNS only (nube gris)

   **Si usas GoDaddy:**
   - Ve a: DNS Management
   - Add → CNAME
   - Pega los valores

   **Si usas AWS Route 53:**
   - Ve a: Hosted zones → grupovexus.com
   - Create record
   - Tipo CNAME, pega valores

7. **Espera 1-2 horas** (máximo 48 horas)

8. **Vuelve a SendGrid y click "Verify"**

9. **Debes ver:** ✅ "Your domain is authenticated"

---

## 📊 Ventajas de Domain Authentication

| Sin autenticación | Con autenticación |
|-------------------|-------------------|
| ❌ Llega a SPAM | ✅ Llega a inbox |
| ❌ Baja confianza | ✅ Alta confianza |
| ❌ Puede ser bloqueado | ✅ Entregabilidad 95%+ |
| ❌ "via sendgrid.net" | ✅ "from grupovexus.com" |

---

## 🧪 Probar después de configurar

1. Envía un email de prueba desde tu sitio
2. Revisa el inbox (no spam)
3. Abre el email
4. Click en "Mostrar original" / "Show original"
5. Busca:
   ```
   DKIM: PASS
   SPF: PASS
   DMARC: PASS
   ```

---

## 💡 Consejos adicionales

1. **Usa un buen asunto:**
   - ❌ "URGENTE!!!" 
   - ✅ "Nueva consulta de Vexus"

2. **Incluye texto plano** (ya lo tienes ✅)

3. **No uses palabras spam:**
   - Evita: GRATIS, DINERO, GANAR, CLICK AQUÍ
   - Usa: consulta, información, contacto

4. **Mantén ratio bajo de quejas:**
   - Si muchos usuarios marcan como spam, SendGrid te penaliza

---

## 🔍 Verificar estado actual

Visita: https://www.mail-tester.com/

1. Copia el email que te dan
2. Envía un email de prueba a ese email
3. Vuelve a la página
4. Te dará un score /10
5. Objetivo: 8/10 o más

---

## 📝 Resumen de pasos

- [ ] Verificar Single Sender en SendGrid
- [ ] Cambiar `EMAIL_FROM=noreply@grupovexus.com` en `.env.production`
- [ ] Reiniciar backend
- [ ] (Opcional pero recomendado) Autenticar dominio completo
- [ ] Probar envío
- [ ] Verificar con mail-tester.com
