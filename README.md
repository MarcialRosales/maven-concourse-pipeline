# Deploy Artifact

## Purpose

Up until now we have built our application but we have not deploy its artifact to a maven repository
so that others can use it. The goal of this step is to publish our application' jar to the corporate Maven repo
we set up in the previous step.

## Set up
We inherit the set up from the step `02_use_corporate_maven_repo` which gives us *Concourse* and *JFrog*.

We haven't launch our infrastucture, we can do it now:
`nohup docker-compose up & `


## Pipeline explained

We are going to introduce a new *Concourse* resource called [Artifactory Resource](https://github.com/pivotalservices/artifactory-resource) to publish our application's artifact (jar) to *JFrog*.


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

This means that the application must declare those variables in the `credentials.yml` file which in case of the [app1](https://github.com/MarcialRosales/maven-concourse-pipeline-app1) it will look like this:

```
source-code-resource-uri: https://github.com/MarcialRosales/maven-concourse-pipeline-app1
pipeline-resource-uri: https://github.com/MarcialRosales/maven-concourse-pipeline
pipeline-resource-branch: 02_use_corporate_maven_repo

m2-settings-repo-id: artifactory
m2-settings-repo-release-uri: http://192.168.99.100:8081/artifactory/libs-release
m2-settings-repo-snapshot-uri: http://192.168.99.100:8081/artifactory/libs-snapshot
m2-settings-repo-username: admin
m2-settings-repo-password: password
```

## Let's run the pipeline

Once again, we are going to set the pipeline from our application's folder (i.e. `maven-concourse-pipeline-app1`).
```
maven-concourse-pipeline-app1$ curl https://raw.githubusercontent.com/MarcialRosales/maven-concourse-pipeline/02_use_corporate_maven_repo/pipeline.yml --output pipeline.yml
maven-concourse-pipeline-app1$ fly -t plan1 sp -p use-corporate-maven-repo -c pipeline.yml -l credentials.yml
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
