#!/bin/bash

set -e

./pipeline/tasks/generate-settings.sh

cd acceptance-test || echo "missing input resource: acceptance-test"

APP_URI=https://${APP_HOST}.${APP_DOMAIN}

echo "Running acceptance tests against ${APP_URI}"
mvn test -DRestAssured.baseURI=${APP_URI} -DRestAssured.port=${APP_PORT:-"80"}
