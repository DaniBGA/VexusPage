-- Script para actualizar usuarios existentes
-- Ejecutar DESPUÉS de aplicar la migración add_email_verification.sql
--
-- IMPORTANTE: Revisa cuidadosamente qué usuarios quieres marcar como verificados
-- antes de ejecutar este script.

-- ============================================
-- OPCIÓN 1: Ver usuarios que necesitan verificación
-- ============================================
-- Ejecuta esto primero para ver qué usuarios existen
SELECT
    id,
    name,
    email,
    created_at,
    email_verified,
    is_active
FROM users
WHERE email_verified = false
ORDER BY created_at DESC;


-- ============================================
-- OPCIÓN 2: Marcar TODOS los usuarios existentes como verificados
-- ============================================
-- ⚠️ CUIDADO: Solo usa esto si confías en que todos los emails son válidos
-- Útil para usuarios que se registraron ANTES de implementar la verificación

-- Descomentar para ejecutar:
-- UPDATE users
-- SET email_verified = true
-- WHERE email_verified = false;


-- ============================================
-- OPCIÓN 3: Marcar usuarios específicos como verificados
-- ============================================
-- Recomendado: Verifica manualmente cada usuario

-- Ejemplo: Marcar un usuario específico
-- UPDATE users
-- SET email_verified = true
-- WHERE email = 'usuario@ejemplo.com';

-- Ejemplo: Marcar múltiples usuarios
-- UPDATE users
-- SET email_verified = true
-- WHERE email IN (
--     'usuario1@ejemplo.com',
--     'usuario2@ejemplo.com',
--     'usuario3@ejemplo.com'
-- );


-- ============================================
-- OPCIÓN 4: Marcar usuarios creados antes de cierta fecha
-- ============================================
-- Útil si implementaste la verificación en una fecha específica
-- Los usuarios creados antes de esa fecha son marcados como verificados

-- Ejemplo: Usuarios creados antes del 25 de octubre de 2025
-- UPDATE users
-- SET email_verified = true
-- WHERE created_at < '2025-10-25 00:00:00'
--   AND email_verified = false;


-- ============================================
-- VERIFICACIÓN: Ver el resultado
-- ============================================
-- Ejecuta esto DESPUÉS de actualizar para confirmar los cambios

SELECT
    COUNT(*) as total_usuarios,
    SUM(CASE WHEN email_verified = true THEN 1 ELSE 0 END) as verificados,
    SUM(CASE WHEN email_verified = false THEN 1 ELSE 0 END) as sin_verificar
FROM users;


-- ============================================
-- LIMPIEZA (Opcional)
-- ============================================
-- Si hay tokens antiguos que quedaron huérfanos, puedes limpiarlos

-- Ver tokens expirados
SELECT
    id,
    email,
    email_verification_token_expires
FROM users
WHERE email_verification_token IS NOT NULL
  AND email_verification_token_expires < CURRENT_TIMESTAMP;

-- Limpiar tokens expirados
-- UPDATE users
-- SET email_verification_token = NULL,
--     email_verification_token_expires = NULL
-- WHERE email_verification_token IS NOT NULL
--   AND email_verification_token_expires < CURRENT_TIMESTAMP;
