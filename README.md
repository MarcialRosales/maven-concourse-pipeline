# Release Versioned Artifacts

## Purpose

Up until now we have built our application without bothering with version numbers. We are always building the same hard-coded version defined in the `pom.xml`.
```
  ...
  <groupId>com.example</groupId>
  <artifactId>maven-concourse-pipeline-app1</artifactId>
  <version>0.0.1-SNAPSHOT</version>
  ...
```

Our pipeline should follow the principle of **Build once, Deploy many times**. Which means, we are going to build a jar, and install it to a central maven repository. The *same* jar from the central repository will be deploy to an environment where we run acceptance tests against it. If the application successfully passes all the acceptance tests, the *same* jar is promoted as a release candidate and installed again in a central maven repository but with different a label, or version. And finally, based on some business criteria, one release candidate is promoted to be the final version that either is published to a publicly accessible maven repo or deployed onto the production servers.

Given that the same jar based on the stage on which it is at any given time, it will have a different label or version. For final releases (a.k.a. public releases) we will use the versioning scheme *major*.*minor*.*patch*. For internal releases (or candidate release) we will use *major*.*minor*.*patch*.rc.*release-candidate*. A candidate release is that release that has passed all the quality controls (e.g. acceptance tests passed against the deployed artifact). For builds we will use *major*.*minor*.*patch*.rc.*release-candidate*+*git_ref*, i.e. every git commit has a reference and we use that reference to version our artifact.

An example:

`app1-2.1.2-rc.3+9ad15e9db52613687e8a01bf93ea03d93e74ce5b.jar` is the **3rd** candidate release of **2.1.2** produced from the commit `9ad15e9db52613687e8a01bf93ea03d93e74ce5b`. If we deployed this artifact and it passed all the acceptance tests, we would promote it to `app1-2.1.2-rc.3.jar` and increment the version to `2.1.2-rc.4`. If another commit came thru with reference `e67552684831fabb3210138b17e8fa27dd1620f2`, that build would be `app1-2.1.2-rc.4+e67552684831fabb3210138b17e8fa27dd1620f2.jar`.

## Version management

So far we have talked how we will version our artifacts. Now we talk about where we store those version numbers so that we know what to build next. In Maven, we declare the artifact's version in the `pom.xml`. But we won't do that any more, instead we are going to tell Maven -during build time- what version shall use.

Version numbers will be stored in a versioned control file. It is better to explain it with our own example. We have our application https://github.com/MarcialRosales/maven-concourse-pipeline-app1. It has the `master` branch where we normally keep the latest and greatest version. We will create a branch which will contain a file whose content is the current version of our application.


This is how it works: When we are about to build our application, we check out the `version` branch to know the version. And whenever we want to bump up the version number, we bump it up and commits it back. There is a *Concourse* resource called [sem-ver](https://github.com/concourse/semver-resource) which helps us with the task.

So, we know where versions are stored and how we are going to version each stage of our artifacts.

## Set up
We inherit the set up from the step `02_use_corporate_maven_repo` which gives us *Concourse* and *JFrog*.

If we haven't launched our infrastucture yet, we can do it now:
`nohup docker-compose up & `

We still need to create the `version` branch but we do it in a special way:

```
git checkout --orphan version
git rm --cached -r .
rm -rf *
rm .gitignore .gitmodules
touch README.md
git add .
git commit -m "new branch"
git push origin version
```
(Credit to [Stark and Wayne](https://github.com/starkandwayne/concourse-tutorial/tree/master/20_versions_and_buildnumbers))

## Pipeline explained

### Define the version resource
As we said earlier, we are going to use a new *Concourse* resource called [semver](https://github.com/concourse/semver-resource), so we need to declare it to point to our `version` branch.

```
- name: version-resource
  type: semver
  source:
    driver: git
    initial_version: 0.0.1
    uri: {{source-code-resource-uri}}
    private_key: {{github-private-key}}
    branch: version
    file: version
```
We are using *git* to store the version file whose initial version is `0.0.1` if there is no file yet created. The branch is called `version` and it will be in a repository declared by a variable `source-code-resource-uri`. Makes sense, the branch is in the same repository where our source code lives. Finally, the version file is called `version` however, it is important to know that *Concourse* will make this file available not with that name but with the name `number`, not `version`.

### Update the build-and-verify task to use the version

In the previous version of our pipeline, we only used 2 resources: `source-code-resource` and `pipeline-resource`. Now, we introduce a third one, `version-resource`.
```
jobs:
- name: job-build-and-verify
  serial: true
  plan:
  - get: source-code-resource
    trigger: true
  - get: pipeline-resource
  - get: version-resource
    params: { pre: rc }

```
We have also modified the `maven-build.yml` task so that it takes another input folder called `version`. See that we map the original folder `version-resource` to `version`. This is because our task prefers to use the name `version` for the version folder. Our tasks also expects an additional parameter `BRANCH` which is the branch we are building. We need it to obtain the git commit reference of the branch we are building. (maybe there is a smarter way of doing it).

```
  ....
  - task: build-and-verify
    file: pipeline-resource/tasks/maven-build.yml
    input_mapping: {source-code: source-code-resource, pipeline: pipeline-resource, version: version-resource}
    output_mapping: {build: built-artifact}
    params:
      BRANCH: {{source-code-resource-branch}}
      M2_SETTINGS_REPO_ID : {{repo-id}}
      M2_SETTINGS_REPO_USERNAME : {{repo-username}}
      M2_SETTINGS_REPO_PASSWORD : {{repo-password}}
      M2_SETTINGS_REPO_RELEASE_URI : {{repo-release-uri}}
      M2_SETTINGS_REPO_SNAPSHOT_URI : {{repo-snapshot-uri}}
```

Finally, we modified the `maven-build.sh` to calculate the version number we will use to name our jar. We have implemented a function `build_version` in the `common.sh` file that combines the current version with the git commit reference.

```

source ./pipeline/tasks/common.sh

VERSION=$(build_version "./version" "number" "./source-code" $BRANCH)
echo "Version to build: ${VERSION}"
```


## Let's run the pipeline

Once again, we are going to set the pipeline from our application's folder (i.e. `maven-concourse-pipeline-app1`).
```
maven-concourse-pipeline-app1$ curl https://raw.githubusercontent.com/MarcialRosales/maven-concourse-pipeline/03_release_versioned_artifact/pipeline.yml --output pipeline.yml
maven-concourse-pipeline-app1$ fly -t plan1 sp -p 03_release_versioned_artifact -c pipeline.yml -l credentials.yml
```
