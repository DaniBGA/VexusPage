#!/usr/bin/env python3
"""
Script para generar una SECRET_KEY segura para producción
Uso: python generate_secret_key.py
"""
import secrets

def generate_secret_key(length=64):
    """Generar una clave secreta segura"""
    return secrets.token_urlsafe(length)

if __name__ == "__main__":
    print("=" * 70)
    print("GENERADOR DE SECRET_KEY PARA VEXUS")
    print("=" * 70)
    print()
    print("Tu nueva SECRET_KEY segura es:")
    print()
    print(generate_secret_key())
    print()
    print("IMPORTANTE:")
    print("1. Copia esta clave y úsala en tu archivo .env.production")
    print("2. NUNCA compartas esta clave")
    print("3. NUNCA la subas al repositorio")
    print("4. Genera una nueva clave diferente para cada entorno")
    print("=" * 70)
