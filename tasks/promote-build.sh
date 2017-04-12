#!/bin/bash

set -e

source ./pipeline/tasks/common.sh

RELEASE_CANDIDATE_VERSION=$(current_sem_ver "./version" "number")

cd build || echo "missing input resource: build"

BUILD=`ls`
APP_EXTENSION="${BUILD##*.}"
APP_NAME="${BUILD%-*}"

RELEASE_CANDIDATE=$APP_NAME-$RELEASE_CANDIDATE_VERSION.$APP_EXTENSION

echo "Promoting ${BUILD} to ${RELEASE_CANDIDATE}"
cp $BUILD ../release-candidate/$RELEASE_CANDIDATE
