#!/bin/bash

set -eu # fail if it finds unbound variables

if [ ! -d artifact ]; then
  echo "artifact folder does not exist"
  exit 1
fi
if [ ! -d manifest ]; then
  mkdir manifest-to-deploy
fi

cp artifact/* manifest
APP_PATH=`ls manifest`

cd manifest
echo "Writing manifest.yml to [manifest/manifest.yml]"
set +x
cat > manifest.yml <<EOF
---
applications:
- name: ${APP_NAME}
  host: ${APP_HOST}
  path: ${APP_PATH}
EOF

cat manifest.yml

set -x
