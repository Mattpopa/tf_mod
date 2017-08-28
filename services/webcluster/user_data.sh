#!/bin/bash

cat > index.html <<EOF
<h1>___</h1>
<p>s: ${db_address}</p>
<p>ss: ${db_port}</p>
EOF

nohup busybox httpd -f -p "${server_port}" &
