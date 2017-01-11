# Build and Verify

## Purpose
We are going to use the `pipeline.yml` of this branch in order to build our [app1](https://github.com/MarcialRosales/maven-concourse-pipeline-app1). This pipeline is very simply right now and the goal
is just to compile the source code using maven and verify it using Junit. Nothing more.

## Pipeline explained
If we open the `pipeline.yml` we will see the following items:
- a **git resource** `source-code-resource` which is the source code of the application we want to build
- another **git resource** `pipeline-resource` which is contains the actual pipeline and all its jobs and tasks
- a **job** `job-build-and-verify` which will check out the source code, also the pipeline and it will invoke a task
called `build-and-verify`. As we know, this task is implemented in a file which is part of the pipeline project.

```
---
resources:
- name: source-code-resource
  type: git
  source:
    uri: {{source-code-resource-uri}}
- name: pipeline-resource
  type: git
  source:
    uri: {{pipeline-resource-uri}}
    branch: {{pipeline-resource-branch}}

jobs:
- name: job-build-and-verify
  plan:
  - get: source-code-resource
    trigger: true
  - get: pipeline-resource
  - task: build-and-verify
    file: pipeline-resource/tasks/maven-build.yml
    input_mapping: {source-code: source-code-resource, pipeline: pipeline-resource}
```

We want to use this same pipeline to build any application, therefore we have externalized the URI of our application
 and also the URI of the pipeline project. We are going to create a so called `credentials.yml` file with those URIs under https://github.com/MarcialRosales/maven-concourse-pipeline-app1/credentials.yml :

```
source-code-resource-uri: https://github.com/MarcialRosales/maven-concourse-pipeline-app1
pipeline-resource-uri: https://github.com/MarcialRosales/maven-concourse-pipeline
pipeline-resource-branch: 01_build_and_verify
```

We are ready to launch our first pipeline in Concourse. If you have not logged in yet with *Concourse* thru *fly* it is time to do it. If you don't know check out [here](https://github.com/MarcialRosales/maven-concourse-pipeline#00---set-up-concourse).

## Run it!

We are going to set our pipeline (let's give it the name `build-and-verify`) against our concourse `plan1`. The `pipeline.yml` is in the sibling project `maven-concourse-pipeline`. And we inject our `credentials` file.
```
maven-concourse-pipeline-app1$ fly -t plan1 sp -p build-and-verify -c ../maven-concourse-pipeline/pipeline.yml -l credentials.yml
```
Concourse prints out the final pipeline with the resolved credentials. See that the URIs are now pointing to the URIs we defined in our `credentials.yml` file.

```
resources:
  resource source-code-resource has been added:
    name: source-code-resource
    type: git
    source:
      uri: https://github.com/MarcialRosales/maven-concourse-pipeline-app1

  resource pipeline-resource has been added:
    name: pipeline-resource
    type: git
    source:
      branch: 01_build_and_verify
      uri: https://github.com/MarcialRosales/maven-concourse-pipeline

jobs:
  job job-build-and-verify has been added:
    name: job-build-and-verify
    plan:
    - get: source-code-resource
      trigger: true
    - get: pipeline-resource
    - task: build-and-verify
      file: pipeline-resource/tasks/maven-build.yml
      input_mapping:
        pipeline: pipeline-resource
        source-code: source-code-resource
```

We can check out in *Concourse* console our pipeline, which is is still paused. When we first set a pipeline, *Concourse* creates it in a *paused* state.

![Pipeline](pipeline1.png)

To unpause, we can click in **play** button in the UI or by invoking this command `fly -t plan1 unpause-pipeline -p build-and-verify`.

As soon as we unpause it, *Concourse* will start the pipeline. We can track our pipeline via *fly* too:
```
$fly -t plan1 builds
id  pipeline/job                           build  status   start                     end  duration
1   build-and-verify/job-build-and-verify  1      started  2017-01-11@19:57:49+0100  n/a  2m0s+
```
And we can check out what is going on with the build by invoking this other command:
```
$ fly -t plan1 watch -j build-and-verify/job-build-and-verify
```
This is very useful because sometimes the build takes a long time to start because *Concourse* is pulling Docker images.

Eventually, *Concourse* downloads all the required docker images and invokes our `maven-build.yml` task. This task will take a long time to run because we will see that Maven is downloading all the dependencies from central repo over the internet.

And finally, *Concourse* successfully builds our application.

![Successful job](pipeline2.png)

The screenshot tells us in a very concise manner all we need to know about our pipeline:
- the build job number **1** was successful (because its green background color)
- when it started and finished and the duration
- the input resources and their versions. We required 2 git resources, the actual app and the pipeline.
- and it did not produce any output.
