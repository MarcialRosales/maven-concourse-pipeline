# Store secrets in Vault
=======

## Purpose
You have probably noticed how painful to have to 2 files to configure the pipeline: `credentials.yml` that we have along with our project in Git and `secrets.yml` which we need to create it when we need it or store it somewhere secure.

We are going to store the secrets in *Vault* and we are going to use *Spruce* to produce a `pipeline.yml` with all our secrets injected into the pipeline.

## Set up

1. Check out this branch
  `concourse-tutorial/maven-concourse-pipeline$ git checkout origin/07_store_secrets_in_vault`
2. Update `concourse-tutorial/maven-concourse-pipeline-app1/credentials.yml` :
  ```
  pipeline-resource-branch: 07_store_secrets_in_vault
  ```
3. Bring down docker-compose : `docker-compose stop`
4. Bring up the new docker-compose which comes with Vault : `docker-compose up`


## Pipeline explained

# Let's run the pipeline

From `maven-concourse-pipeline-app1` folder we run `concourse-tutorial/maven-concourse-pipeline-app1$  `

![pipeline](assets/pipeline.png)
