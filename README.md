# Build and Verify

We are going to use the `pipeline.yml` of this branch in order to build our [app1](https://github.com/MarcialRosales/maven-concourse-pipeline-app1). This pipeline is very simply right now and the goal
is just to compile the source code using maven and verify it using Junit. Nothing more.

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

We are ready to launch our first pipeline in Concourse. 
