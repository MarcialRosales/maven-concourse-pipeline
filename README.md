# Use Corporate Maven Repository

## Purpose

In the previous step (`build and verify`) we managed to build our Java application
and verify it but it was too slow because Maven had to download all the dependencies
from central repo.
The goal of this step is to use a corporate Maven repo.

## Set up
We are going to set up a local Maven Repository with [JFrog](https://www.jfrog.com/).
Once again, we are going to use `docker-compose up` to launch it on port 8081.

We have added **JFrog** container to the existing `docker-compose.yml` that we use to
provision *Concourse*.

```
....
artifactory:
  image: jfrog-docker-registry.bintray.io/artifactory/artifactory-oss:latest
  ports:
    - "8081:8081"
```

Let's launch the Maven repository:
`docker-compose up`
