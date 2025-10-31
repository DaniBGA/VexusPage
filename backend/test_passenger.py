"""
Test simple para verificar que Passenger puede ejecutar Python
Subir este archivo como passenger_wsgi.py temporalmente para diagnosticar
"""

def application(environ, start_response):
    """WSGI application simple"""
    status = '200 OK'

    output = b'''
    <html>
    <head><title>Passenger Test</title></head>
    <body>
        <h1>Passenger funciona!</h1>
        <p>Python version: ''' + str(environ.get('PYTHON_VERSION', 'Unknown')).encode() + b'''</p>
        <p>Este es un test basico de Passenger WSGI.</p>
        <hr>
        <h2>Environment:</h2>
        <ul>
    '''

    # Mostrar algunas variables de entorno
    for key in ['REQUEST_METHOD', 'PATH_INFO', 'QUERY_STRING', 'SERVER_NAME']:
        value = environ.get(key, 'N/A')
        output += f'<li><strong>{key}:</strong> {value}</li>'.encode()

    output += b'''
        </ul>
    </body>
    </html>
    '''

    response_headers = [
        ('Content-Type', 'text/html'),
        ('Content-Length', str(len(output)))
    ]

    start_response(status, response_headers)
    return [output]
