# Install Built Artifact to Maven Repo

## Setup

1. Check out this branch
  `concourse-tutorial/maven-concourse-pipeline$ git checkout origin/04_install_built_artifact`
2. Update `concourse-tutorial/maven-concourse-pipeline-app1/credentials.yml` :
  ```
  pipeline-resource-branch: 04_install_built_artifact
  ```

## Purpose

The goal of this step is to install our newly built application' jar to the corporate Maven repo. In the previous step (`03_release_versioned_artifact`) we produced a uniquely versioned artifact.

We are going to install our jars to the same Maven repository we resolve the dependencies.

## Set up
We inherit the set up from the step `03_release_versioned_artifact` which gives us *Concourse* and *JFrog*.

If we haven't launch our infrastucture yet, we can do it now:
`nohup docker-compose up & `


## Pipeline explained

We are going to introduce a new *Concourse* resource called [Artifactory Resource](https://github.com/pivotalservices/artifactory-resource) to publish our application's artifact (jar) to *JFrog*.

### Declare artifactory-resource as resource-type
Because this resource is not one of the out-of-the-box resources that comes with *Concourse* we need to explicitly declare it in the `pipeline.yml`. For convention, we try to group all `resource-types` at the beginning of the pipeline file followed by the `resources` and the `jobs` afterwards.

```
resource_types:
- name: artifactory
  type: docker-image
  source:
    repository: pivotalservices/artifactory-resource
```

### Declare artifactory-repository as resource
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

These are the actual values of those variables in the `credentials.yml`:
```
repo-uri: http://192.168.99.100:8081/artifactory
repo-release-folder: /libs-release-local/com/example/maven-concourse-pipeline-app1
repo-release-regex: maven-concourse-pipeline-app1-(?<version>.*).jar
repo-username: admin
repo-password: password

artifact-to-publish: ./built-artifact/maven-concourse-pipeline-app1-*.jar
```

### Reminder: Copy Maven's produced jar to an output folder
In the previous step (`03_release_versioned_artifact`), the task `maven-build.yml` copies the built jar onto an output folder. If we don't copy the jar to an output folder, we lose it as soon as *Concourse* destroys the container where it ran the task.

### Push produced jar to Maven local repo
And the last change is to modify the job in the `pipeline.yml` so that we install the jar we just copied to the `build-artifact` folder.
You may be wondering why we need the `input_mapping` and `output_mapping` attributes in the `task: build-and-verify`. It is a way to create aliases. When we create a task, we use meaningful names for the input and output folders. For instance, in `maven-build.sh` we used `source-code` for the source code we are building, `version` for the folder which contains the current version, and `pipeline` for the folder with all the tasks. But at the pipeline level, the folder names receive the name of the resource the belong to, e.g. `source-code-resource`, or `pipeline-resource`.

There is a nasty bit on this pipeline which is how we tell the `artifactory-repository` resource which file to push to Maven repo. In *Concourse* we cannot concatenate multiple variables like this: `file: ./built-artifact/{{artifact-id}}-*`. If this expression would have been valid, it would have resolved to `file: ./built-artifact/maven-concourse-pipeline-app1-*` unfortunately *Concourse* produces `file: ./built-artifact/"maven-concourse-pipeline-app1"-*` (see the double quotes around our application?). For this reason, I have to declare the full path in the `credentials.yml` file which is very nasty because we have to reference the folder `built-artifact` which is defined in the pipeline. It is a very ugly solution.

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
concourse-tutorial/maven-concourse-pipeline-app1$ fly -t plan1 sp -p 04_install_built_artifact -c ../maven-concourse-pipeline/pipeline.yml -l credentials.yml -l secrets.yml
```

This is our pipeline:
![Pipeline that builds and deploys to Artifactory](assets/pipeline3.png)

This is a successful job summary:
![Successful build and deploy](assets/pipeline4.png)

See that we have produced an output which matches with our expected versioning scheme: `built-artifact-repository
version	1.0.0-rc.1+5325c1c7de77bc36edc64c66e64f17d058262731`.
And the artifact is available in *Frog* under this url: http://192.168.99.100:8081/artifactory/simple/libs-release-local/com/example/maven-concourse-pipeline-app1/maven-concourse-pipeline-app1-1.0.0-rc.1+5325c1c7de77bc36edc64c66e64f17d058262731.jar
