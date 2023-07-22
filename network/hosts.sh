#!/bin/bash
set -ex
ADDRESS="$(ip -4 addr show $1 | grep -i inet | head -1 |awk '{print $2}' | cut -d/ -f1)"
NETWORK=$(echo $ADDRESS | awk 'BEGIN {FS="."} ; { printf("%s.%s.%s", $1, $2, $3) }')

# Update local dns about other hosts
cat >> /etc/hosts <<EOF
${NETWORK}.2 master-node
${NETWORK}.3 worker-node01
${NETWORK}.4 worker-node02
EOF