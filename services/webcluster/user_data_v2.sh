#!/bin/bash

cat > index.html << EOF
<h1> o hi </h1>
EOF

nohup busybox httpd -f -p "${server_port}" &
