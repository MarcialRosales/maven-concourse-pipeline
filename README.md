# Build and Verify

## Purpose
This is going to be our first pipeline which will compile an application and run Junit tests using Maven. Nothing more.  
The pipeline project is a template or a generic pipeline that we want to use to build any java application. It is important
that we distinguish between our application repository and the actual pipeline's repository. The pipeline repository, where
we are right now, consists of a set of artifacts (`pipeline.yml`, task ymls and bash scripts) that together knows how to
build java applications. The idea is that every java application does not need to build its own pipeline but instead leverage an existing one.


## Pipeline explained
If we open the `pipeline.yml` we will see the following items:
- a **git resource** `source-code-resource` which is the source code of the application we want to build
- another **git resource** `pipeline-resource` which is the actual pipeline and all its jobs and tasks files
- a **job** `job-build-and-verify` which will check out the source code, the pipelines' files and it will invoke a task
called `build-and-verify`.

```
---
resources:
- name: source-code-resource
  type: git
  source:
    uri: {{source-code-resource-uri}}
    branch: {{source-code-resource-branch}}
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

We want to use this same pipeline to build any application, therefore we have to externalize the application's repository
 and pipeline repository, although this last one is not absolutely necessary. If you look at the pipeline above, you will see 3 variables : `{{source-code-resource-uri}}`, `{{pipeline-resource-uri}}` and `{{pipeline-resource-branch}}`. The latter variable
 allows us to configure which branch of the pipeline repository we want to use.

You may be wondering why we need a pipeline repository. The pipeline repository contains the tasks definitions (`*.yml` files) and the scripts associated to the tasks (these can be written in any scripting language, `bash` or `python`, `ruby`). We can perfectly place the task definition and the script inline within the pipeline however that would be considered a bad practice: pipelines becomes bloated and unreadable and we cannot reuse task definitions within the same pipeline or between pipelines.


## Run the pipeline!
We are ready to launch our first pipeline in Concourse. If you have not logged in yet with *Concourse* thru *fly* it is time to do it. If you don't know how, check it out [here](https://github.com/MarcialRosales/maven-concourse-pipeline#00---set-up-concourse).

**If you haven´t already created the concourse-tutorial folder check out README.md in the master branch**

1. `cd concourse-tutorial/maven-concourse-pipeline-app1`
2. Copy the `credentials-template.yml`
  `cp ../maven-concourse-pipeline/credentials-template.yml template.yml`
3. Customize it:
  ```
  source-code-resource-uri: <your_git_repo_url>
  ```
3. Set up the pipeline in Concourse:
  ```
  fly -t plan1 sp -p build-and-verify -c pipeline.yml -l credentials.yml
  ```
  - `fly -t plan1` is saying we want to target the *Concourse* instance we logged in earlier
  - `sp` means `set-pipeline`, it is the actual command
  - `-p build-and-verify` is the name we want to give it to our pipeline.
  - `-c pipeline.yml` is the actual pipeline definition. We don't want to commit this file in our project so we add it to the `.gitignore` file. Remember, this file is in the pipeline repository. `credentials.yml` file.
  - `-l credentials.yml` this is the file that customizes the pipeline for our application. We want to commit this file in our project unless it has sensitive data like usernames or passwords, which is not the case, at least fow now.

When we run that command  `fly -t plan1 sp ...`, *fly* will print out the final pipeline that it will be pushed to *Concourse*. See how it has resolved the variables with the actual values in our `credentials.yml` file.

```
resources:
  resource source-code-resource has been added:
    name: source-code-resource
    type: git
    source:
      branch: master
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

If we go to *Concourse* UI we will see our pipeline like this:

![Pipeline](assets/pipeline1.png)

Pipelines can be either paused or running. Pipelines are paused by default. Run the following command to activate them:
`fly -t plan1 unpause-pipeline -p build-and-verify`.

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
This is very useful because sometimes the build may take a long time to start for various reason. One reason is when *Concourse* has to pull lots of Docker images.

Eventually, *Concourse* downloads all the required docker images and invokes our `maven-build.yml` task. This task will take a long time to run because we will see that Maven is downloading all the dependencies from central repo over the internet.

And finally, *Concourse* successfully builds our application.

![Successful job](assets/pipeline2.png)

The screenshot tells us in a very concise manner all we need to know about our pipeline:
- the build job number **1** was successful (because its green background color)
- when it started and finished and the duration
- the input resources and their versions. We required 2 git resources, the actual app and the pipeline.
- and it did not produce any output.
