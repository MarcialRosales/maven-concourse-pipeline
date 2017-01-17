# Deploy Built Artifact to Pivotal Cloud Foundry and Verify

## Purpose

The purpose of this step is to take the latest *built artifact* from a Maven repository *JFrog* and deploy it to *Cloud Foundry*, verify that it passes a set of acceptance tests, and promote it as a release candidate to Maven.

## Set up
We inherit the set up from the step `02_use_corporate_maven_repo` which gives us *Concourse* and *JFrog*.

If we haven't launched our infrastucture yet, we can do it now:
`nohup docker-compose up & `

However, we need an account in *Cloud Foundry* where to push our application. For this demonstration project, we are going to use *Pivotal Web Service*. If you don't have a *PWS* account go to [https://run.pivotal.io/](https://run.pivotal.io/) and set up a free demo account. Once you have an account we will add the following credentials to our application's `credentials.yml` file.
```
# Deployment to Cloud Foundry
cf-api: https://api.run.pivotal.io
cf-username: ###  
cf-password: ###
cf-org: pivotal-emea-cso
cf-space: mrosales
```

## Pipeline explained

We are going to introduce a new *Concourse* resource called [cf-resource](https://github.com/concourse/cf-resource) to deploy our application's artifact (jar) to *Cloud Foundry*.

### Declare pcf-resource as a cf resource
We don't need to declare `cf` as a `resource-type` because it is one of the resource-types that *Concourse* recognizes out of the box. But we still need to declare a `cf` resource and configure it with our *Cloud Foundry* account details.

**Note: We are building the entire pipeline from dev to prod in a single pipeline file. This is not the only way of doing it. You can certainly have one pipeline for development and a separate one for production**

```
resources:
  ....
- name: pcf-resource
  type: cf
  source:
    api: {{cf-api}}
    username: {{cf-username}}
    password: {{cf-password}}
    organization: {{cf-org}}
    space: {{cf-space}}
    skip_cert_check: false
   ....
```

These are the actual values comes from the variables we defined earlier in the `credentials.yml`.

### Add a new job that deploys the built artifact to *Cloud Foundry* as soon as a new version is available

We need to add a new job different to the one we had before that we called `job-build-and-verify`. The purpose of that job was just to build an artifact and to push it to a maven repository if the unit tests passed. Once that artifact is ready in the maven repo, we can trigger other jobs like the one we are about to add. Our job, `job-deploy-to-pcf` will take the latest artifact from the maven repo and push it to the configured *Cloud Foundry* account whose details are in the `credentials.yml`.

```
jobs:
   ...
- name: job-deploy-to-pcf
  plan:
  - get: artifact-resource
    trigger: true
  - get: pipeline-resource
  - task: generate-manifest
    file: pipeline-resource/tasks/generate-manifest.yml
    input_mapping: {pipeline: pipeline-resource, artifact: artifact-resource}
    params:
      APP_NAME: {{cf-app-name}}
      APP_HOST: {{cf-app-host}}
  - put: pcf-resource
    params:
      manifest: manifest/manifest.yml
    ...
```

We have configured this job to trigger as soon as a new artifact becomes available (see the `trigger: true` attribute in the `- get: artifact-resource`). Before we can push the artifact (our jar) we need to generate a `manifest.yml` file and we have created a task for that called `generate-manifest`. And like with any other task, they reside in the pipeline repository, that is why we need `- get: pipeline-resource`.  The task produces a folder called `manifest` which has the `manifest.yml` and the actual artifact. See the 2 parameters we are passing to the task: `APP_NAME` and `APP_HOST`. Our task uses these 2 parameters to produce the corresponding `manifest.yml`.


## Let's run the pipeline

Once again, we are going to set the pipeline from our application's folder (i.e. `maven-concourse-pipeline-app1`).
```
maven-concourse-pipeline-app1$ curl https://raw.githubusercontent.com/MarcialRosales/maven-concourse-pipeline/20_push_to_pcf/pipeline.yml --output pipeline.yml
maven-concourse-pipeline-app1$ fly -t plan1 sp -p push-to-pcf -c pipeline.yml -l credentials.yml
```
