-- ====================================
-- CORRECCIONES DE SCHEMA VEXUS
-- ====================================
-- Este script corrige las inconsistencias entre el schema y el código

-- 1. Agregar columna 'last_accessed' a course_enrollments
ALTER TABLE course_enrollments
ADD COLUMN IF NOT EXISTS last_accessed TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP;

-- 2. Renombrar 'last_accessed_at' a 'last_accessed' en user_course_progress
ALTER TABLE user_course_progress
RENAME COLUMN last_accessed_at TO last_accessed;

-- 3. Agregar columnas faltantes en user_course_progress
ALTER TABLE user_course_progress
ADD COLUMN IF NOT EXISTS started_at TIMESTAMP WITH TIME ZONE,
ADD COLUMN IF NOT EXISTS completed_at TIMESTAMP WITH TIME ZONE;

-- 4. Renombrar 'is_completed' a 'completed' en user_unit_progress
ALTER TABLE user_unit_progress
RENAME COLUMN is_completed TO completed;

-- 5. Renombrar 'order_index' a 'order' en course_units (comillas necesarias porque 'order' es palabra reservada)
ALTER TABLE course_units
RENAME COLUMN order_index TO "order";

-- 6. Agregar columna 'unit_id' a course_resources (relación con unidad en vez de curso)
ALTER TABLE course_resources
ADD COLUMN IF NOT EXISTS unit_id UUID REFERENCES course_units(id) ON DELETE CASCADE;

-- 7. Actualizar índice de course_units con nuevo nombre de columna
DROP INDEX IF EXISTS idx_course_units_course;
CREATE INDEX IF NOT EXISTS idx_course_units_course ON course_units(course_id, "order");

-- Mensaje de confirmación
DO $$
BEGIN
    RAISE NOTICE 'Schema corregido exitosamente';
END $$;
