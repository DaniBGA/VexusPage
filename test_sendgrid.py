#!/usr/bin/env python3
"""
Script de prueba para verificar que SendGrid funciona correctamente
Ejecutar: python test_sendgrid.py
"""
import os
from sendgrid import SendGridAPIClient
from sendgrid.helpers.mail import Mail

# IMPORTANTE: Configura estas variables antes de ejecutar
# O mejor aún, usa variables de entorno:
# export SENDGRID_API_KEY="tu-api-key-aqui"
# export FROM_EMAIL="grupovexus@gmail.com"
# export TO_EMAIL="grupovexus@gmail.com"

SENDGRID_API_KEY = os.getenv("SENDGRID_API_KEY", "")
FROM_EMAIL = os.getenv("FROM_EMAIL", "grupovexus@gmail.com")
TO_EMAIL = os.getenv("TO_EMAIL", "grupovexus@gmail.com")

def test_sendgrid():
    """Enviar email de prueba con SendGrid"""
    
    if not SENDGRID_API_KEY:
        print("❌ ERROR: SENDGRID_API_KEY no configurada")
        print("\n💡 Configura la variable de entorno:")
        print('   export SENDGRID_API_KEY="SG.tu-api-key-aqui"')
        print("   O edita el archivo test_sendgrid.py directamente")
        return False
    
    print("=" * 60)
    print("🧪 TEST DE SENDGRID")
    print("=" * 60)
    print(f"📧 From: {FROM_EMAIL}")
    print(f"📧 To: {TO_EMAIL}")
    print(f"🔑 API Key: {SENDGRID_API_KEY[:15]}...{SENDGRID_API_KEY[-4:]}")
    print("=" * 60)
    
    try:
        # Crear mensaje
        message = Mail(
            from_email=FROM_EMAIL,
            to_emails=TO_EMAIL,
            subject='🧪 SendGrid Test - Vexus',
            html_content='<strong>✅ SendGrid está funcionando correctamente!</strong><br><br>Este es un email de prueba desde Vexus.'
        )
        
        print("\n📤 Enviando email de prueba...")
        
        # Enviar usando SendGrid
        sg = SendGridAPIClient(SENDGRID_API_KEY)
        response = sg.send(message)
        
        print("\n" + "=" * 60)
        print("✅ RESPUESTA DE SENDGRID:")
        print("=" * 60)
        print(f"Status Code: {response.status_code}")
        print(f"Body: {response.body}")
        print(f"Headers: {response.headers}")
        print("=" * 60)
        
        if response.status_code in [200, 201, 202]:
            print("\n🎉 ¡EMAIL ENVIADO EXITOSAMENTE!")
            print(f"📬 Revisa tu bandeja de entrada: {TO_EMAIL}")
            print("\n✅ SendGrid está configurado correctamente")
            return True
        else:
            print(f"\n❌ Error: Status code {response.status_code}")
            return False
            
    except Exception as e:
        print("\n" + "=" * 60)
        print("❌ ERROR AL ENVIAR EMAIL:")
        print("=" * 60)
        print(f"Tipo: {type(e).__name__}")
        print(f"Mensaje: {str(e)}")
        print("=" * 60)
        
        # Verificar errores comunes
        if "Unauthorized" in str(e) or "401" in str(e):
            print("\n⚠️ ERROR DE AUTENTICACIÓN:")
            print("   - Verifica que tu API Key sea correcta")
            print("   - Verifica que la API Key tenga permisos de 'Mail Send'")
        elif "Forbidden" in str(e) or "403" in str(e):
            print("\n⚠️ ERROR DE PERMISOS:")
            print("   - Verifica que el email FROM esté verificado en SendGrid")
            print("   - Ve a: https://app.sendgrid.com/settings/sender_auth")
        
        return False

if __name__ == "__main__":
    test_sendgrid()
