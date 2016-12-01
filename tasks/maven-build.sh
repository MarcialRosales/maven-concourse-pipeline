#!/bin/bash

cd source-code || echo "missing input resource: source-code"

echo "Using MAVEN_OPTS: ${MAVEN_OPTS}"

./mvnw verify ${MAVEN_ARGS}
