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

VERSION=build_version version number source-code ${BRANCH} 
echo "Setting version to build: ${VERSION}"

cd source-code || echo "missing input resource: source-code"
mvn versions:set -DnewVersion=${VERSION}

echo "Building artifact ..."
mvn verify ${MAVEN_ARGS}

echo "Copying artifact to ${build} "
cp target/*.jar ../build

ls ../build
