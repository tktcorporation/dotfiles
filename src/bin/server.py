#!/usr/bin/python

import sys

try:

    import SimpleHTTPServer as server
    import SocketServer as socketserver

except ImportError:

    # In Python 3 the 'SimpleHTTPServer'
    # module has been merged into 'http.server'.

    import http.server as server
    import socketserver

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

handler = server.SimpleHTTPRequestHandler
map = handler.extensions_map
port = int(sys.argv[1])

# Set default Content-Type to 'text/plain'.
map[""] = "text/plain"

# Serve everything as UTF-8 (although not technically
# correct, this doesn't break anything for binary files).
for key, value in map.items():
    map[key] = value + "; charset=utf-8"

# Create but don't automatically bind socket
# (the 'allow_reuse_address' option needs to be set first).
httpd = socketserver.ThreadingTCPServer(("localhost", port), handler, False)

# Prevent 'cannot bind to address' errors on restart.
# https://brokenbad.com/address-reuse-in-pythons-socketserver/
httpd.allow_reuse_address = True

# Manually bind socket and start the server.
httpd.server_bind()
httpd.server_activate()
print("Serving content on port: ", port)
httpd.serve_forever()
