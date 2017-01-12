#!/bin/bash

set -eu # fail if it finds unbound variables

if [ ! -d artifact-to-deploy ]; then
  echo "folder artifact-to-deploy must exist";
  exit 1
fi
if [ ! -d manifest-to-deploy ]; then
  mkdir manifest-to-deploy
fi

cd artifact-to-deploy
APP_PATH=`ls`
cd ..

cd manifest-to-deploy
echo "Writing manifest.yml to [manifest-to-deploy/manifest.yml]"
set +x
cat > manifest.yml <<EOF
---
applications:
- name: ${APP_NAME}
  host: ${APP_HOST}
  path: ${APP_PATH}

EOF

cat manifest.yml
cp ../artifact-to-deploy/* .

set -x
