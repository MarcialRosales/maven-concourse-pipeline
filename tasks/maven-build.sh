#!/bin/bash

<<<<<<< HEAD
set -ex
=======
# input folders:
# version : contains a file called number with the current version
# source-code : contains the source code

# output folders:
# build: contains the built jar

set -e
>>>>>>> 20_deploy_and_verify

source ./pipeline/tasks/common.sh

VERSION=$(build_version "./version" "number" "./source-code" $BRANCH)
echo "Version to build: ${VERSION}"

echo "Generating maven settings.xml"
./pipeline/tasks/generate-settings.sh

cd source-code

echo "Setting maven with version to build"
mvn versions:set -DnewVersion=${VERSION}

<<<<<<< HEAD
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
=======
echo "Building artifact ..."
mvn verify ${MAVEN_ARGS}

echo "Copying artifact to ./build "
cp target/*.jar ../build
>>>>>>> 20_deploy_and_verify
