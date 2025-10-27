-- ====================================
-- CORRECCIONES DE SCHEMA VEXUS (VERSIÓN SEGURA)
-- ====================================
-- Este script corrige las inconsistencias de forma segura (no falla si ya está aplicado)

-- 1. Agregar columna 'last_accessed' a course_enrollments
ALTER TABLE course_enrollments
ADD COLUMN IF NOT EXISTS last_accessed TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP;

-- 2. Renombrar 'last_accessed_at' a 'last_accessed' en user_course_progress (solo si existe)
DO $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_name = 'user_course_progress'
        AND column_name = 'last_accessed_at'
    ) THEN
        ALTER TABLE user_course_progress RENAME COLUMN last_accessed_at TO last_accessed;
    END IF;
END $$;

-- 2b. Si no existe last_accessed, crearla
ALTER TABLE user_course_progress
ADD COLUMN IF NOT EXISTS last_accessed TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP;

-- 3. Agregar columnas faltantes en user_course_progress
ALTER TABLE user_course_progress
ADD COLUMN IF NOT EXISTS started_at TIMESTAMP WITH TIME ZONE,
ADD COLUMN IF NOT EXISTS completed_at TIMESTAMP WITH TIME ZONE;

-- 4. Renombrar 'is_completed' a 'completed' en user_unit_progress (solo si existe)
DO $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_name = 'user_unit_progress'
        AND column_name = 'is_completed'
    ) THEN
        ALTER TABLE user_unit_progress RENAME COLUMN is_completed TO completed;
    END IF;
END $$;

-- 4b. Si no existe 'completed', crearla
ALTER TABLE user_unit_progress
ADD COLUMN IF NOT EXISTS completed BOOLEAN DEFAULT false;

-- 5. Renombrar 'order_index' a 'order' en course_units (solo si existe)
DO $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_name = 'course_units'
        AND column_name = 'order_index'
    ) THEN
        ALTER TABLE course_units RENAME COLUMN order_index TO "order";
    END IF;
END $$;

-- 5b. Si no existe 'order', crearla
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_name = 'course_units'
        AND column_name = 'order'
    ) THEN
        ALTER TABLE course_units ADD COLUMN "order" INTEGER NOT NULL DEFAULT 0;
    END IF;
END $$;

-- 6. Agregar columna 'unit_id' a course_resources
ALTER TABLE course_resources
ADD COLUMN IF NOT EXISTS unit_id UUID REFERENCES course_units(id) ON DELETE CASCADE;

-- 7. Actualizar índice de course_units con nuevo nombre de columna
DROP INDEX IF EXISTS idx_course_units_course;
CREATE INDEX IF NOT EXISTS idx_course_units_course ON course_units(course_id, "order");

-- Mensaje de confirmación
DO $$
BEGIN
    RAISE NOTICE 'Schema corregido exitosamente (versión segura)';
END $$;
