#!/bin/bash

# input folders:
# version : contains a file called number with the current version
# source-code : contains the source code

# output folders:
# build: contains the built jar

set -e

source ./pipeline/tasks/common.sh

echo "Generating maven settings.xml"
./pipeline/tasks/generate-settings.sh

echo "Setting version to build: ${VERSION}"
mvn versions:set -DnewVersion=$(VERSION)

echo "Building artifact ..."
cd source-code || echo "missing input resource: source-code"
mvn verify ${MAVEN_ARGS}

echo "Copying artifact to ${build} "
cp target/*.jar ../build

ls ../build
