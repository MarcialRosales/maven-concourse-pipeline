#!/bin/bash

set -e

./pipeline/tasks/generate-settings.sh

cd source-code || echo "missing input resource: source-code"

echo "Using MAVEN_OPTS: ${MAVEN_OPTS}"

mvn verify ${MAVEN_ARGS}

echo "ls ../build"
ls -l ../build

echo "ls target"
ls -l target

echo "copy from target to ../build"
cp target/*.jar ../build

echo "ls ../build"
ls -l ../build
