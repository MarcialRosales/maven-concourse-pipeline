# Release Versioned Artifacts

## Purpose

Up until now we have built our application and deployed it to our maven repository but without bothering with version numbers. We always building the same hard-coded version define in the `pom.xml`.


Pipeline sequence:
- pipeline triggers due to a commit on `maven-concourse-pipeline-app1` with version `e053f37c0fdd805b212815ee09def24c80c2d59f`.
- pipeline checks out version with value  0.0.1
- job builds-and-verifies:
  - sets maven version to 0.0.1-e053f37c0fdd805b212815ee09def24c80c2d59f
  - produces the app1-0.0.1-e053f37c0fdd805b212815ee09def24c80c2d59f.jar
  - installs jar to snapshot maven repo
- job deploy-and-verifies:
  - triggered by new jar in snapshot maven repo
  - produces the manifest for app: which target environment? how much memory/disk? or number of instances? what services does it need?
  - deploys jar with manifest
  - runs acceptance tests
  - if tests are successful, it installs to the release maven repo but with a different version. It we need to increment the rc.#, e.g. if the last version 0.0.1-rc.1, it will be 0.0.1-rc.2.
  - shall it also create a tag in github?

As we produce more solid versions, the rc.# goes up.

We are now happy and we need to make a release:
-   


## Set up
We inherit the set up from the step `02_use_corporate_maven_repo` which gives us *Concourse* and *JFrog*.

If we haven't launched our infrastucture yet, we can do it now:
`nohup docker-compose up & `



## Pipeline explained

We are going to introduce a new *Concourse* resource called [semver](https://github.com/concourse/semver-resource) to properly manage artifact's versions.



## Let's run the pipeline

Once again, we are going to set the pipeline from our application's folder (i.e. `maven-concourse-pipeline-app1`).
```
maven-concourse-pipeline-app1$ curl https://raw.githubusercontent.com/MarcialRosales/maven-concourse-pipeline/04_release_versioned_artifact/pipeline.yml --output pipeline.yml
maven-concourse-pipeline-app1$ fly -t plan1 sp -p deploy-artifact -c pipeline.yml -l credentials.yml
```
