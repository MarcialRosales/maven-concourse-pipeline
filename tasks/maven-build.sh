#!/bin/bash

set -ex

./pipeline/tasks/generate-settings.sh

cd source-code || echo "missing input resource: source-code"

echo "Using MAVEN_OPTS: ${MAVEN_OPTS}"

set +e

mvn install

if [[ ! -d target/surefire-reports ]]; then
  exit 1
fi

mvn assembly:single

cp target/* ../target
