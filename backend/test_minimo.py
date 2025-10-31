"""
Test MÍNIMO de WSGI - Solo 10 líneas
Si esto no funciona, Passenger no está habilitado
"""

def application(environ, start_response):
    status = '200 OK'
    output = b'<html><body><h1>PASSENGER FUNCIONA!</h1><p>Este es un test minimo de WSGI.</p></body></html>'
    response_headers = [('Content-Type', 'text/html'), ('Content-Length', str(len(output)))]
    start_response(status, response_headers)
    return [output]
