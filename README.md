# Deploy Application Reports

## Getting started

What about if we want to look at the surefire reports, or check style, or any source analysis report? Although we can look at what junit test cases failed via the logs produced by the *build-and-test* job, it would be great if we could look at them via the browser.

We are going to rescue *Maven Site plugin* which produces a web site for our application and it includes reports like Surefire.

## Build maven site with Surefire reports

We are going to modify the `pom.xml` so that the maven site only includes the surefire report. By default, maven produces a large site which takes longer to build.

We add the following configuration to the `pom.xml` of our application `maven-concourse-pipeline-app1`:

```
<reporting>
  <plugins>
    <plugin>
      <groupId>org.apache.maven.plugins</groupId>
      <artifactId>maven-project-info-reports-plugin</artifactId>
      <version>2.6</version>
      <reportSets>
        <reportSet>
          <reports><!-- select reports -->
            <report>index</report>

          </reports>
        </reportSet>
      </reportSets>
    </plugin>
    <plugin>
      <groupId>org.apache.maven.plugins</groupId>
      <artifactId>maven-surefire-report-plugin</artifactId>

    </plugin>
  </plugins>
</reporting>
```

 
