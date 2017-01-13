#!/bin/bash

set -e

if [ -e ./input-version/number ]; then
  echo "Missing input-version/number file"
  exit 1
fi

VERSION=`cat ./input-version/number`

if [ -e ./source-code/.git/refs/heads/${BRANCH} ]; then
  echo "Missing source-code/.git/refs/heads/${BRANCH} file"
  exit 1
fi

BUILD_NUMBER=`cat ./source-code/.git/refs/heads/${BRANCH}`

VERSION=${VERSION}+${BUILD_NUMBER}

echo "${VERSION}" > ./output-version/number
