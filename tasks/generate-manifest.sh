#!/bin/bash

set -eu # fail if it finds unbound variables

if [ ! -d manifest ]; then
  mkdir manifest-to-deploy
fi

cd manifest
echo "Writing manifest.yml to [manifest/manifest.yml]"
set +x
cat > manifest.yml <<EOF
---
applications:
- name: ${APP_NAME}
  host: ${APP_HOST}

EOF

cat manifest.yml

set -x
