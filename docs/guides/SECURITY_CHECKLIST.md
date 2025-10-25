# Checklist de Seguridad - Vexus Platform

## Pre-Deployment

### Credenciales y Secrets
- [ ] **SECRET_KEY** generada con `python generate_secret_key.py` (mínimo 64 caracteres)
- [ ] **POSTGRES_PASSWORD** es una contraseña fuerte y única
- [ ] Archivo `.env` o `.env.production` NO está en el repositorio git
- [ ] Archivo `.env` tiene permisos restrictivos (`chmod 600 .env`)
- [ ] Todas las contraseñas por defecto han sido cambiadas

### Configuración de Aplicación
- [ ] `DEBUG=False` en producción
- [ ] `ENVIRONMENT=production` configurado
- [ ] `ALLOWED_ORIGINS` especifica dominios exactos (NO usar `*` en producción)
- [ ] Tokens JWT tienen tiempo de expiración apropiado (30-60 minutos)

### Base de Datos
- [ ] PostgreSQL no expone puerto 5432 externamente (solo localhost o red privada)
- [ ] Usuario de base de datos tiene permisos mínimos necesarios
- [ ] Backups automatizados configurados
- [ ] SSL/TLS habilitado para conexiones a base de datos

## Deployment

### Servidor
- [ ] Sistema operativo actualizado con últimos parches de seguridad
- [ ] Firewall configurado (UFW/iptables) - solo puertos necesarios abiertos
- [ ] SSH configurado con autenticación por clave (deshabilitar password login)
- [ ] Fail2ban o similar instalado para prevenir ataques de fuerza bruta
- [ ] Usuarios no-root para ejecutar aplicaciones

### Web Server (Nginx)
- [ ] HTTPS/SSL configurado con certificados válidos (Let's Encrypt)
- [ ] HTTP redirige automáticamente a HTTPS
- [ ] TLS 1.2+ únicamente (deshabilitar TLS 1.0 y 1.1)
- [ ] Headers de seguridad configurados:
  - [ ] `Strict-Transport-Security`
  - [ ] `X-Frame-Options`
  - [ ] `X-Content-Type-Options`
  - [ ] `X-XSS-Protection`
  - [ ] `Referrer-Policy`
- [ ] Rate limiting configurado
- [ ] Timeouts apropiados configurados

### Docker (si aplica)
- [ ] Contenedores NO corren como root
- [ ] Imágenes base son oficiales y actualizadas
- [ ] Secrets se pasan por variables de entorno (no hardcoded)
- [ ] Volúmenes tienen permisos apropiados
- [ ] Docker socket NO montado en contenedores
- [ ] Health checks configurados

## Post-Deployment

### Monitoreo
- [ ] Logging centralizado configurado
- [ ] Alertas para errores críticos configuradas
- [ ] Health checks monitoreados
- [ ] Monitoreo de uso de recursos (CPU, RAM, disco)
- [ ] Logs de acceso y errores revisados regularmente

### Mantenimiento
- [ ] Plan de actualización de dependencias definido
- [ ] Procedimiento de backup y restore probado
- [ ] Plan de recuperación ante desastres documentado
- [ ] Contactos de emergencia documentados

## Código

### Backend
- [ ] Inputs de usuario son validados y sanitizados
- [ ] Queries SQL usan parámetros (NO concatenación de strings)
- [ ] Passwords hasheados con bcrypt
- [ ] No hay secrets hardcoded en el código
- [ ] Logs NO contienen información sensible (passwords, tokens, etc)
- [ ] Manejo apropiado de errores (no exponer stack traces en producción)
- [ ] Rate limiting implementado en endpoints críticos
- [ ] CORS configurado correctamente

### Frontend
- [ ] API URL configurada para producción
- [ ] No hay API keys o secrets en el código JavaScript
- [ ] Content Security Policy (CSP) configurado
- [ ] Validación de inputs en cliente Y servidor
- [ ] Tokens se almacenan de forma segura (no en localStorage si es posible)

## Compliance

### GDPR / Privacidad
- [ ] Política de privacidad publicada
- [ ] Consentimiento de cookies implementado
- [ ] Datos personales encriptados
- [ ] Procedimiento para eliminación de datos de usuario

### Auditoría
- [ ] Registro de acciones críticas (login, cambios de permisos, etc)
- [ ] Logs inmutables y con timestamp
- [ ] Retención de logs definida

## Pruebas de Seguridad

- [ ] Escaneo de vulnerabilidades de dependencias (`pip audit` o similar)
- [ ] Pruebas de penetración básicas realizadas
- [ ] SQL injection testing
- [ ] XSS testing
- [ ] CSRF protection verificado
- [ ] Authentication/Authorization testing

## Documentación

- [ ] Guía de deployment actualizada
- [ ] Procedimientos de emergencia documentados
- [ ] Contactos de seguridad definidos
- [ ] Política de divulgación de vulnerabilidades publicada

---

## Herramientas Recomendadas

### Escaneo de Dependencias
```bash
# Python
pip install safety
safety check

# O con pip-audit
pip install pip-audit
pip-audit
```

### Escaneo de Secretos en Git
```bash
# Instalar gitleaks
brew install gitleaks  # macOS
# o descargar desde https://github.com/gitleaks/gitleaks

# Escanear repositorio
gitleaks detect --source . --verbose
```

### Test de SSL/TLS
```bash
# SSL Labs
https://www.ssllabs.com/ssltest/

# O con testssl.sh
git clone https://github.com/drwetter/testssl.sh.git
cd testssl.sh
./testssl.sh https://tu-dominio.com
```

---

## En Caso de Incidente de Seguridad

1. **NO PÁNICO** - Documenta todo
2. **Aislar** - Desconectar sistema comprometido
3. **Analizar** - Revisar logs para entender el alcance
4. **Contener** - Cambiar todas las credenciales
5. **Erradicar** - Eliminar el vector de ataque
6. **Recuperar** - Restaurar desde backup limpio
7. **Comunicar** - Notificar a usuarios si es necesario
8. **Aprender** - Post-mortem y actualizar procedimientos

---

**Responsable de Seguridad:** [Nombre]
**Última revisión:** 2025-10-25
**Próxima revisión:** [Fecha]
