# Use Corporate Maven Repository

## Purpose

In the previous step (`build and verify`) we managed to build our Java application
and verify it but it was too slow because Maven had to download all the dependencies
from central repo.
The goal of this step is to use a corporate Maven repo.

## Set up
We are going to set up a local Maven Repository with [JFrog](https://www.jfrog.com/).
Once again, we are going to use `docker-compose` to launch it on port 8081.

Let's add **JFrog** container to the existing `docker-compose.yml` that we used to
provision *Concourse*.

```
....
artifactory:
  image: jfrog-docker-registry.bintray.io/artifactory/artifactory-oss:latest
  ports:
    - "8081:8081"
```

And launch it:
`nohup docker-compose up & `

Now we have *Concourse* and *JFrog* containers running: `docker-compose ps`
```
docker-compose ps
                  Name                                 Command               State           Ports
-----------------------------------------------------------------------------------------------------------
mavenconcoursepipeline_artifactory_1        /bin/sh -c /tmp/runArtifac ...   Up      0.0.0.0:8081->8081/tcp
mavenconcoursepipeline_concourse-db_1       /docker-entrypoint.sh postgres   Up      5432/tcp
mavenconcoursepipeline_concourse-web_1      /usr/local/bin/dumb-init / ...   Up      0.0.0.0:8080->8080/tcp
mavenconcoursepipeline_concourse-worker_1   /usr/local/bin/dumb-init / ...   Up
```

## Pipeline explained

The pipeline has not changed much since the last step, `Build and Verify`. We have introduced 2 changes.

**Modify tasks/maven-build.sh and add new script tasks/generate-settings.sh**
We have added the line `./pipeline/tasks/generate-settings.sh` to the file `tasks/maven-build.sh`:
```
#!/bin/bash

set -e

./pipeline/tasks/generate-settings.sh

cd source-code || echo "missing input resource: source-code"

echo "Using MAVEN_OPTS: ${MAVEN_OPTS}"

mvn verify ${MAVEN_ARGS}

```

And we are invoking a brand new script, `tasks/generate-settings.sh`, that generates a standard Maven's `settings.xml` file
with the location of our local Maven repository.

**Modify pipeline.yml to pass maven repo variables required by tasks/generate-settings.sh**
The script `tasks/generate-settings.sh` requires a set of variables to generate Maven's `settings.yml` file. We have modified the `pipeline.yml` so that we can inject those variables:

```
....
- task: build-and-verify
  file: pipeline-resource/tasks/maven-build.yml
  input_mapping: {source-code: source-code-resource, pipeline: pipeline-resource}
  params:
    M2_SETTINGS_REPO_ID : {{m2-settings-repo-id}}
    M2_SETTINGS_REPO_USERNAME : {{m2-settings-repo-username}}
    M2_SETTINGS_REPO_PASSWORD : {{m2-settings-repo-password}}
    M2_SETTINGS_REPO_RELEASE_URI : {{m2-settings-repo-release-uri}}
    M2_SETTINGS_REPO_SNAPSHOT_URI : {{m2-settings-repo-snapshot-uri}}
```

This means that the application must declare those variables in the `credentials.yml` file:

```
source-code-resource-uri: https://github.com/MarcialRosales/maven-concourse-pipeline-app1
source-code-resource-branch: master
pipeline-resource-uri: https://github.com/MarcialRosales/maven-concourse-pipeline
pipeline-resource-branch: 02_use_corporate_maven_repo

m2-settings-repo-id: artifactory
m2-settings-repo-release-uri: http://192.168.99.100:8081/artifactory/libs-release
m2-settings-repo-snapshot-uri: http://192.168.99.100:8081/artifactory/libs-snapshot
m2-settings-repo-username: admin
m2-settings-repo-password: password
```

**Note about Credentials vs Secrets** : So far we have kept the credentials file in git. That was fine because we did not store any sensitive data such as passwords, private keys, etc. We are going to store the username and password of an artifactory server. Because this is a locally provisioned one, it is ok to store them in the `credentials.yml` file.

## Let's run the pipeline

Once again, we are going to set the pipeline from our pipelines's folder.
```
maven-concourse-pipeline$ fly -t plan1 sp -p use-corporate-maven-repo -c pipeline.yml -l credentials.yml
```
**Note: Pause or destroy previous pipelines** : *If you have been following this tutorial step by step, you probably have the previous pipeline `build and verify` active. You probably want to, at least, pause it by running this command*:
`fly -t plan1 pause-pipeline -p build-and-verify`.

As you already know it, the new pipeline `use-corporate-maven-repo` will be paused. Run this command to activate it:
`fly -t plan1 unpause-pipeline -p use-corporate-maven-repo`


After the build completes, we can check out in the logs that it used our local Maven repo:
```
maven-concourse-pipeline-app1$ fly -t plan1 watch -j use-corporate-maven-repo/job-build-and-verify
....
Downloaded: http://192.168.99.100:8081/artifactory/libs-release/asm/asm-util/3.2/asm-util-3.2.jar (36 KB at 24.9 KB/sec)
Downloaded: http://192.168.99.100:8081/artifactory/libs-release/com/google/guava/guava/18.0/guava-18.0.jar (2204 KB at 1259.0 KB/sec)
[INFO] ------------------------------------------------------------------------
[INFO] BUILD SUCCESS
[INFO] ------------------------------------------------------------------------
[INFO] Total time: 01:14 min
[INFO] Finished at: 2017-01-12T10:17:56+00:00
[INFO] Final Memory: 25M/62M
[INFO] ------------------------------------------------------------------------
succeeded
```
