#!/bin/bash

set -ex

./pipeline/tasks/generate-settings.sh

cd source-code || echo "missing input resource: source-code"

echo "Using MAVEN_OPTS: ${MAVEN_OPTS}"

set +e

mvn install

status=$?

if [[ ! -d target/surefire-reports ]]; then
  exit $status
fi

mvn assembly:single

cp target/* ../build

ls -l ../build

exit $status
