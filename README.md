# Deploy Surefire Reports

## Getting started

What about if we want to look at the surefire reports? Although we can look at what junit test cases failed via the logs produced by the *build-and-test* job, it would be great if we could look at them via the browser.

We are going to use *Maven Assembly plugin* to produce a `tgz` with all the surefire reports and publish it in *Artifactory*.

## Configure Assembly plugin

We are going to modify the `pom.xml` to include the assembly plugin and add the `src/assembly/surefire.xml` file.

*pom.xml*
```
<build>
  <plugins>
     ...
     <plugin>
       <artifactId>maven-assembly-plugin</artifactId>
       <configuration>
       <descriptors>
           <descriptor>src/assembly/surefire.xml</descriptor>
       </descriptors>
       </configuration>
     </plugin>
  </plugins>
</reporting>
```

*surefire.xml*
```
<assembly xmlns="http://maven.apache.org/ASSEMBLY/2.0.0"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xsi:schemaLocation="http://maven.apache.org/ASSEMBLY/2.0.0 http://maven.apache.org/xsd/assembly-2.0.0.xsd">
  <id>surefire</id>
  <formats>
    <format>tgz</format>
  </formats>
  <includeBaseDirectory>false</includeBaseDirectory>
  <fileSets>
    <fileSet>
      <directory>target/surefire-reports</directory>
    </fileSet>
  </fileSets>

</assembly>
```

# Let's run the pipeline

From `maven-concourse-pipeline-app1` folder we run `concourse-tutorial/maven-concourse-pipeline-app1$ fly -t plan1 sp -p 30_deploy_poject_reports -c ../maven-concourse-pipeline/pipeline.yml -l credentials.yml -l secrets.yml
`
