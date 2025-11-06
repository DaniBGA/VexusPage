"""
Test rápido para verificar que el código de email asíncrono funciona correctamente
"""
import asyncio
import sys
import os

# Agregar el path del backend al PYTHONPATH
sys.path.insert(0, os.path.join(os.path.dirname(__file__), 'app'))

async def test_email_import():
    """Verificar que se pueden importar las funciones de email"""
    try:
        from app.services.email import send_verification_email, generate_verification_token
        print("✅ Importación de email.py exitosa")
        
        # Verificar que la función es async
        import inspect
        if inspect.iscoroutinefunction(send_verification_email):
            print("✅ send_verification_email es una función async")
        else:
            print("❌ send_verification_email NO es async")
            return False
        
        # Generar un token de prueba
        token = generate_verification_token()
        print(f"✅ Token generado: {token[:20]}...")
        
        print("\n✅ TODAS LAS PRUEBAS PASARON")
        return True
        
    except Exception as e:
        print(f"❌ Error en las pruebas: {e}")
        import traceback
        traceback.print_exc()
        return False

async def test_auth_import():
    """Verificar que se puede importar el módulo de autenticación"""
    try:
        from app.api.v1.endpoints import auth
        print("✅ Importación de auth.py exitosa")
        
        # Verificar que el router existe
        if hasattr(auth, 'router'):
            print("✅ Router de autenticación encontrado")
        else:
            print("❌ Router no encontrado")
            return False
        
        return True
        
    except Exception as e:
        print(f"❌ Error importando auth: {e}")
        import traceback
        traceback.print_exc()
        return False

async def main():
    """Ejecutar todas las pruebas"""
    print("🧪 Iniciando pruebas del backend refactorizado\n")
    print("=" * 60)
    
    print("\n1️⃣ Probando servicio de email...")
    print("-" * 60)
    email_ok = await test_email_import()
    
    print("\n2️⃣ Probando endpoints de autenticación...")
    print("-" * 60)
    auth_ok = await test_auth_import()
    
    print("\n" + "=" * 60)
    if email_ok and auth_ok:
        print("✅ TODAS LAS PRUEBAS COMPLETADAS CON ÉXITO")
        print("\n📝 Próximos pasos:")
        print("   1. Configurar variables SMTP en Render")
        print("   2. Hacer commit y push de los cambios")
        print("   3. Verificar logs en Render después del deploy")
        return 0
    else:
        print("❌ ALGUNAS PRUEBAS FALLARON")
        return 1

if __name__ == "__main__":
    exit_code = asyncio.run(main())
    sys.exit(exit_code)
