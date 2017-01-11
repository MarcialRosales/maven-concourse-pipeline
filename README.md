# maven-concourse-pipeline

Learn to use https://concourse.ci to build a pipeline for java/maven projects.

* [00 - Set up concourse (locally)]
* [01 - Compile & Verify]
* [02 - Use corporate Maven Repository]

## Credits

https://github.com/starkandwayne/concourse-tutorial.


## Tutorial

We have built a step by step tutorial where each step is tracked on a separate branch.
 The main or master branch is dedicated to the chapter 00 where we set up Concourse.
 Each chapter is dedicated to task or step of a standard java build pipeline.
The first step will be to compile and run the unit tests (i.e. verify).

### 00 - Set up Concourse

We are going to launch Concourse using *Docker compose*. On this `master` branch
 we have a `docker-compose.yml` file and a `keys` folder with all the required ssh keys.

Make sure you are in the master branch (`git branch master`) and you must have [Docker](https://docs.docker.com/engine/installation/)
and [Docker compose](https://docs.docker.com/compose/install/) installed too.

To launch concourse we run `docker-compose up` which reads the file `docker-compose.yml`. If we open that file we will see that we are launching 3 containers, a **database**, the **web-server** which gives us the nice Concourse front-end and one **worker** container where concourse executes the tasks.

**Running via docker-machine** : *If you are running concourse via docker-machine (not natively) make sure you set up the environment variable CONCOURSE_EXTERNAL_URL before `docker-compose up`*.

```
CONCOURSE_EXTERNAL_URL=`echo $DOCKER_HOST | sed s/tcp/http/ | sed s/2376/8080/` nohup docker-compose up
```
We can go now the `CONCOURSE_EXTERNAL_URL` in our browser.


### 01 - Compile & Verify

### 02 - Use corporate Maven Repository
