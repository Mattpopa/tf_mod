#!/bin/bash

cat > index.html <<EOF
<h1>___</h1>
<p>${db_address}</p>
<p>${db_port}</p>
EOF

nohup busybox httpd -f -p "${server_port}" &
