#!/bin/bash
yum update -y
yum install -y python3
echo 'import http.server
import socketserver

PORT = 80
Handler = http.server.SimpleHTTPRequestHandler

httpd = socketserver.TCPServer(("", PORT), Handler)

print("serving at port", PORT)
httpd.serve_forever()' > webserver.py
echo 'Hello, World!' > index.html
nohup python3 webserver.py > out.log &
