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

Because this resource is not one of the out-of-the-box resources that comes with *Concourse* we need to explicitly declare it in the `pipeline.yml`. For convention, we try to group all `resource-types` at the beginning of the pipeline file followed by the `resources` and finally we add the `jobs`.

```
resource_types:
- name: artifactory
  type: docker-image
  source:
    repository: pivotalservices/artifactory-resource
```

Once we have the resource-type declared, we can make use of it. This resource type is fully explained [here](https://github.com/pivotalservices/artifactory-resource). We have externalized the actual parameter values to our `credentials.yml` file in our application's repository.

```
- name: artifact-repository
  type: artifactory
  source:
    endpoint: {{repo-uri}}
    repository: {{repo-release-folder}}
    regex: {{repo-release-regex}}
    username: {{repo-username}}
    password: {{repo-password}}
    skip_ssl_verification: true

```

The other change we have to do is to put the built jar onto an `output` folder. For that we are going to modify the task definition file `maven-build.yml` to add these 2 lines. When we add these 2 lines, *Concourse* will create a folder called `build` in the root filesystem of the container where our task runs.

```
outputs:
  - name: build
```

And we add the following lines to the `maven-build.sh` so that it copies the jar into that folder.
```

echo "Publishing artifact from target to <output folder: ../build>"
cp target/*.jar ../build
```

And the last change is to modify the job in the `pipeline.yml` so that we publish to artifactory the jar we copied to the `build` folder.
You maybe be wondering why do we need `input_mapping` and `output_mapping` attributes in the `task: build-and-verify`. It is a way to create aliases. In the task `maven-build.sh` we declared an output folder with the name `build`. However, that `build` folder receives a different name on this `pipeline.yml` file, it is named `built-artifact`. It is the same folder but with has different names depending whether we are within the task or in the pipeline. It is not that important to fully understand why we need it at the moment.

There is a nasty bit on this pipeline which is how we tell the `artifactory-repository` resource which file to push to Maven repo. In *Concourse* we cannot concatenate multiple variables like this: `file: ./built-artifact/{{artifact-id}}-*`. If this expression would have been valid, it would resolve to `file: ./built-artifact/maven-concourse-pipeline-app1-*` however *Concourse* will produce instead this which is wrong: `file: ./built-artifact/"maven-concourse-pipeline-app1"-*`. For this reason, I have to declare the file we want to publish in the `credentials.yml` file which is very nasty because we have to reference the folder `built-artifact` which is defined in the pipeline. It is a very ugly solution.

```
jobs:
- name: job-build-and-verify
  plan:
  - get: source-code-resource
    trigger: true
  - get: pipeline-resource
  - task: build-and-verify
    file: pipeline-resource/tasks/maven-build.yml
    input_mapping: {source-code: source-code-resource, pipeline: pipeline-resource}
    output_mapping: {build: built-artifact}
    params:
      M2_SETTINGS_REPO_ID: {{repo-id}}
      M2_SETTINGS_REPO_USERNAME: {{repo-username}}
      M2_SETTINGS_REPO_PASSWORD: {{repo-password}}
      M2_SETTINGS_REPO_RELEASE_URI: {{repo-release-uri}}
      M2_SETTINGS_REPO_SNAPSHOT_URI: {{repo-snapshot-uri}}
  - put: artifact-repository
    params:
      file: {{artifact-to-publish}}

```

## Let's run the pipeline

Once again, we are going to set the pipeline from our application's folder (i.e. `maven-concourse-pipeline-app1`).
```
maven-concourse-pipeline-app1$ curl https://raw.githubusercontent.com/MarcialRosales/maven-concourse-pipeline/03_deploy_artifact/pipeline.yml --output pipeline.yml
maven-concourse-pipeline-app1$ fly -t plan1 sp -p deploy-artifact -c pipeline.yml -l credentials.yml
```
This is our pipeline:
![Pipeline that builds and deploys to Artifactory](assets/pipeline4.png)

This is a successful job summary:
![Successful build and deploy](assets/pipeline3.png)


This time, the pipeline produced an output resource, `artifact-repository` is the name of the resource, and the version is `0.0.1-SNAPSHOT`. This output resource can easily be the input resource of another pipeline. That is why it is so important that the outcome of a pipeline, like a jar, be an output resource. If we would have used Maven's artifact distribution mechanism, the jar would have also been deployed to our local maven repo but *Concourse* would not know about it.
