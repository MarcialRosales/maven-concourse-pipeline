#!/bin/bash

# input folders:
# version : contains a file called number with the current version
# source-code : contains the source code

# output folders:
# build: contains the built jar

set -e

source ./pipeline/tasks/common.sh

VERSION=$(build_version ./version number ./source_code $BRANCH)

./pipeline/tasks/generate-settings.sh

cd source-code || echo "missing input resource: source-code"

mvn versions:set -DnewVersion=$(VERSION)

echo "Building version ${VERSION} using MAVEN_OPTS: ${MAVEN_OPTS}"

mvn verify ${MAVEN_ARGS}

echo "Publishing artifact from target to ${build} "
cp target/*.jar ../build

ls ../build
