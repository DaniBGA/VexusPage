"""
Diagnóstico completo de Passenger + Python
Renombra este archivo a passenger_wsgi.py para diagnosticar problemas
"""
import sys
import os

def application(environ, start_response):
    status = '200 OK'

    # Información básica
    info = f"""
<!DOCTYPE html>
<html>
<head>
    <title>Diagnóstico Passenger - Vexus API</title>
    <style>
        body {{ font-family: Arial, sans-serif; margin: 20px; background: #f5f5f5; }}
        .container {{ background: white; padding: 20px; border-radius: 8px; max-width: 1000px; margin: 0 auto; }}
        h1 {{ color: #2c3e50; border-bottom: 2px solid #3498db; padding-bottom: 10px; }}
        h2 {{ color: #34495e; margin-top: 30px; }}
        .success {{ color: green; font-weight: bold; }}
        .error {{ color: red; font-weight: bold; }}
        .warning {{ color: orange; font-weight: bold; }}
        table {{ border-collapse: collapse; width: 100%; margin: 10px 0; }}
        th, td {{ border: 1px solid #ddd; padding: 8px; text-align: left; }}
        th {{ background-color: #3498db; color: white; }}
        tr:nth-child(even) {{ background-color: #f2f2f2; }}
        ul {{ list-style-type: none; padding: 0; }}
        li {{ padding: 5px 0; }}
        .check {{ color: green; }}
        .cross {{ color: red; }}
        code {{ background: #ecf0f1; padding: 2px 6px; border-radius: 3px; }}
    </style>
</head>
<body>
    <div class="container">
        <h1>🔍 Diagnóstico Passenger + Python - Vexus API</h1>
        <p><strong>Fecha:</strong> {os.popen('date').read().strip()}</p>

        <h2>✅ Python Information</h2>
        <table>
            <tr><th>Property</th><th>Value</th></tr>
            <tr><td>Python Version</td><td>{sys.version}</td></tr>
            <tr><td>Python Executable</td><td>{sys.executable}</td></tr>
            <tr><td>Platform</td><td>{sys.platform}</td></tr>
        </table>

        <h2>📂 Paths</h2>
        <table>
            <tr><th>Type</th><th>Path</th></tr>
            <tr><td>Current Directory</td><td>{os.getcwd()}</td></tr>
            <tr><td>Script Directory</td><td>{os.path.dirname(__file__) if '__file__' in globals() else 'N/A'}</td></tr>
        </table>

        <h2>🐍 sys.path (Python Module Search Paths)</h2>
        <ul>
    """

    for path in sys.path:
        info += f"<li>• {path}</li>"

    info += """
        </ul>

        <h2>📦 Required Modules Check</h2>
        <table>
            <tr><th>Module</th><th>Status</th><th>Version</th></tr>
    """

    # Módulos requeridos
    required_modules = [
        'dotenv',
        'fastapi',
        'uvicorn',
        'pydantic',
        'asyncpg',
        'sqlalchemy',
        'passlib',
        'python_jose',
        'bcrypt',
        'email_validator',
        'python_multipart'
    ]

    modules_status = []
    for module_name in required_modules:
        try:
            mod = __import__(module_name)
            version = getattr(mod, '__version__', 'Unknown')
            status = f'<span class="check">✓ Installed</span>'
            modules_status.append((module_name, True, version))
        except ImportError:
            status = f'<span class="cross">✗ NOT INSTALLED</span>'
            modules_status.append((module_name, False, 'N/A'))

        info += f"<tr><td><code>{module_name}</code></td><td>{status}</td><td>{version if module_name in [m[0] for m in modules_status if m[1]] else 'N/A'}</td></tr>"

    info += """
        </table>
    """

    # Resumen
    installed_count = sum(1 for m in modules_status if m[1])
    total_count = len(modules_status)

    if installed_count == total_count:
        summary_class = "success"
        summary_text = f"✅ All {total_count} required modules are installed!"
    elif installed_count > 0:
        summary_class = "warning"
        summary_text = f"⚠️ {installed_count}/{total_count} modules installed. Missing {total_count - installed_count} modules."
    else:
        summary_class = "error"
        summary_text = f"❌ No modules installed! All {total_count} modules are missing."

    info += f"""
        <h2>📊 Summary</h2>
        <p class="{summary_class}">{summary_text}</p>
    """

    # Verificar archivos clave
    info += """
        <h2>📄 Key Files Check</h2>
        <table>
            <tr><th>File</th><th>Exists</th><th>Size</th></tr>
    """

    current_dir = os.path.dirname(__file__) if '__file__' in globals() else os.getcwd()
    key_files = [
        '.env',
        'requirements.txt',
        'app/__init__.py',
        'app/main.py',
        'app/config.py',
        'app/core/database.py'
    ]

    for filename in key_files:
        filepath = os.path.join(current_dir, filename)
        if os.path.exists(filepath):
            size = os.path.getsize(filepath)
            status = f'<span class="check">✓ Yes</span>'
            size_str = f'{size} bytes'
        else:
            status = f'<span class="cross">✗ No</span>'
            size_str = 'N/A'

        info += f"<tr><td><code>{filename}</code></td><td>{status}</td><td>{size_str}</td></tr>"

    info += """
        </table>

        <h2>🌍 Environment Variables (sample)</h2>
        <table>
            <tr><th>Variable</th><th>Value (masked)</th></tr>
    """

    # Mostrar algunas env vars (sin exponer secretos)
    env_vars_to_show = ['PATH', 'PYTHONPATH', 'HOME', 'USER', 'LANG']
    for var in env_vars_to_show:
        value = os.environ.get(var, 'Not set')
        info += f"<tr><td><code>{var}</code></td><td>{value[:50]}...</td></tr>"

    info += """
        </table>

        <h2>🔧 Next Steps</h2>
    """

    if installed_count < total_count:
        info += """
        <div class="error">
            <h3>❌ Missing Dependencies Detected!</h3>
            <p>You need to install the missing Python packages. Here's how:</p>

            <h4>Option 1: Via Terminal in cPanel</h4>
            <pre>cd ~/web/grupovexus.com/public_html/API
python3 -m pip install --user -r requirements.txt</pre>

            <h4>Option 2: Contact Neatech Support</h4>
            <p>Ask them to install dependencies from requirements.txt in your API folder.</p>
        </div>
        """
    else:
        info += """
        <div class="success">
            <h3>✅ All dependencies installed!</h3>
            <p>Your Python environment looks good. If you're still getting errors:</p>
            <ol>
                <li>Check that .env file has correct credentials</li>
                <li>Check cPanel error logs for specific errors</li>
                <li>Restore the original passenger_wsgi.py</li>
            </ol>
        </div>
        """

    info += """
        <hr>
        <p><small>This is a diagnostic tool. To run your actual application, restore passenger_wsgi.py to the original version.</small></p>
    </div>
</body>
</html>
    """

    output = info.encode('utf-8')
    response_headers = [
        ('Content-Type', 'text/html; charset=utf-8'),
        ('Content-Length', str(len(output)))
    ]

    start_response(status, response_headers)
    return [output]
