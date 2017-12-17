#!/bin/bash

set -u # fail if it finds unbound variables

mkdir -p ${HOME}/.m2/

echo "Writing settings xml to [${HOME}/.m2/settings.xml]"
echo "Repository Id: ${M2_SETTINGS_REPO_ID}"
echo "Repository Username: ${M2_SETTINGS_REPO_USERNAME}"

set +x
cat > ${HOME}/.m2/settings.xml <<EOF

<settings xmlns="http://maven.apache.org/SETTINGS/1.0.0"
      xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
      xsi:schemaLocation="http://maven.apache.org/SETTINGS/1.0.0
                          https://maven.apache.org/xsd/settings-1.0.0.xsd">
<!--
      <mirrors>
          <mirror>
            <id>${M2_SETTINGS_REPO_ID}</id>
            <mirrorOf>*</mirrorOf>
            <url>${M2_SETTINGS_REPO_RELEASE_URI}</url>
            <name>Artifactory</name>
          </mirror>
      </mirrors>
      -->
       <servers>
         <server>
           <id>${M2_SETTINGS_REPO_ID}</id>
           <username>${M2_SETTINGS_REPO_USERNAME}</username>
           <password>${M2_SETTINGS_REPO_PASSWORD}</password>
         </server>
       </servers>

       <profiles>
         <profile>
           <id>artifactory</id>
           <repositories>
               <repository>
                   <id>${M2_SETTINGS_REPO_ID}</id>
                   <name>libs-release</name>
                   <url>${M2_SETTINGS_REPO_RELEASE_URI}</url>
               </repository>
           </repositories>
         </profile>
       </profiles>

       <activeProfiles>
         <activeProfile>artifactory</activeProfile>
       </activeProfiles>

</settings>

EOF
set -x
