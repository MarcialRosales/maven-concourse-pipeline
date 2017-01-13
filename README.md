# Release Versioned Artifacts

## Purpose

Up until now we have built our application and deployed it our maven repository but without bothering with version numbers. We always pushed the same hard-coded version in the `pom.xml`.


## Set up
We inherit the set up from the step `02_use_corporate_maven_repo` which gives us *Concourse* and *JFrog*.

If we haven't launch our infrastucture yet, we can do it now:
`nohup docker-compose up & `


## Pipeline explained

We are going to introduce a new *Concourse* resource called [semver](https://github.com/concourse/semver-resource) to properly manage artifact's versions.



## Let's run the pipeline

Once again, we are going to set the pipeline from our application's folder (i.e. `maven-concourse-pipeline-app1`).
```
maven-concourse-pipeline-app1$ curl https://raw.githubusercontent.com/MarcialRosales/maven-concourse-pipeline/03_deploy_artifact/pipeline.yml --output pipeline.yml
maven-concourse-pipeline-app1$ fly -t plan1 sp -p deploy-artifact -c pipeline.yml -l credentials.yml
```
