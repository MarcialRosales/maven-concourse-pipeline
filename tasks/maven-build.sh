#!/bin/bash

set -e

env

./pipeline/tasks/generate-settings.sh

cd source-code || echo "missing input resource: source-code"

if [ -e ../version/number ]; then
  VERSION=`cat ../version/number`
  mvn versions:set -DnewVersion=${VERSION}
fi

echo "Building version ${VERSION} using MAVEN_OPTS: ${MAVEN_OPTS}"

mvn verify ${MAVEN_ARGS}

echo "Publishing artifact from target to <output folder: ../build>"
cp target/*.jar ../build

ls ../build
