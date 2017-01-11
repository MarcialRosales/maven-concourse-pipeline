# maven-concourse-pipeline

Learn to use https://concourse.ci to build a pipeline for java/maven projects.

* [00 - Set up concourse (locally)]
* [01 - Compile & Verify]
* [02 - Use corporate Maven Repository]

## Credits

https://github.com/starkandwayne/concourse-tutorial.


## Tutorial

We have built a step by step tutorial on how to build a standard Continuous Integration pipeline to build java applications.
We will dedicate a branch to perform each step. The main or master branch is dedicated to the chapter 00 where we set up Concourse.

### 00 - Set up Concourse

We are going to launch Concourse using *Docker compose*. On this `master` branch
 we have a `docker-compose.yml` file and a `keys` folder with all the required ssh keys.

Make sure you are in the master branch (`git checkout master`) and you must have [Docker](https://docs.docker.com/engine/installation/)
and [Docker compose](https://docs.docker.com/compose/install/) installed too.

To launch concourse we run `docker-compose up` which by default reads the file `docker-compose.yml`. On this file we have declared the 3 containers we need to run Concourse: the **database**, the **web-server** which gives us the nice Concourse front-end and the **worker** container where concourse executes the tasks.

**Note: Running via docker-machine** : *If you are running concourse via docker-machine (not natively) make sure you set up the environment variable CONCOURSE_EXTERNAL_URL before running `docker-compose up`*.

```
CONCOURSE_EXTERNAL_URL=`echo $DOCKER_HOST | sed s/tcp/http/ | sed s/2376/8080/` nohup docker-compose up
```
We can open the `CONCOURSE_EXTERNAL_URL` in our browser. The default credentials are concourse:changeme


### 01 - Compile & Verify

Do `git checkout 01_build_and_verify`

### 02 - Use corporate Maven Repository

Do `git checkout 02_use_corporate_maven_repo`
