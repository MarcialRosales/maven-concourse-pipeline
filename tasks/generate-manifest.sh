#!/bin/bash

set -eu # fail if it finds unbound variables

if [ ! -d artifact ]; then
  echo "artifact folder does not exist"
  exit 1
fi
if [ ! -d manifest ]; then
  echo "manifest folder does not exist"
  exit 1
fi

cp artifact/* manifest

cd manifest
APP_PATH=`ls`

echo "Writing manifest.yml to [manifest/manifest.yml]"
set +x
cat > manifest.yml <<EOF
---
applications:
- name: ${APP_NAME}
  host: ${APP_HOST}
  path: ${APP_PATH}
  domain: ${APP_DOMAIN}
EOF

cat manifest.yml

set -x
