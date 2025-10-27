"""
Script para probar el envío de email de contacto
"""
import asyncio
import sys
import io

# Configurar stdout para UTF-8
sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8')

from app.services.email import send_contact_email

async def test_contact_email():
    """Probar envío de email de contacto"""
    print("Probando envio de email de contacto...")

    result = await send_contact_email(
        client_name="Juan Perez (Prueba)",
        client_email="test@example.com",
        message="Este es un mensaje de prueba del formulario de contacto.",
        subject="Prueba de formulario de contacto"
    )

    if result:
        print("Email enviado exitosamente!")
    else:
        print("Error al enviar email")

if __name__ == "__main__":
    asyncio.run(test_contact_email())
