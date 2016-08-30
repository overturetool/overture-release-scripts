# Release Scripts for Overture

This repository contains several scripts that automate parts of the Overture release process.

## Description of scripts

### Generate the release notes

`github-fetch-milestone-issues.py`: Script for generating release notes for *closed* milestones. The template files `ReleaseNotes-template.md` and `ReleaseNotes-template-abbrev.md` must exist in the folder where the script is. If you are releasing Overture you may want to execute this script from `<overture-root>/documentation/releasenotes`.

### Update the website examples

`update-examples.sh`: Checks out the Overture standard examples, including the website, and adds the examples to the web site. After the script has been executed, the user must manually push the changes to the examples and website repositories. The instructions are provided by the script.

### Perform the release

`perform-release.sh` Performs a Maven release with tycho mode enabled by the `With-IDE` profile. This script can be run in interactive mode, i.e. it stops before pushing/releasing. Alternatively, one can perform an automated release by setting the environment variable `batchmode=release`. Before this script is executed, the release version and the new development version must be specified in the `overture.release.properties` file, which is located in the root of the tool repository. This file must be edited and comitted before running the script. Run script as `./perform-release.sh`.

In order to run this script you will need GPG set up as well as a login to access [Sonatype](http://oss.sonatype.org). For details, see the instructions in the [release notes](https://github.com/overturetool/overture/wiki/Release-Process).

_Note that_: The script is currently *not* checking out `master` and merging the corresponding release tag. When that's done trigger the `overture-master` build job on the overture.au.dk build server in order to release the IDE. 

#### Hint

If the `maven-gpg-plugin` is complaining that it "Cannot obtain passphrase in batch mode" you may want to supply your passphrase via your local settings (stored in the`settings.xml` file in the `.m2` folder). An example of how this can be done is shown below.

```XML
<settings xmlns="http://maven.apache.org/SETTINGS/1.0.0"
          xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
          xsi:schemaLocation="http://maven.apache.org/SETTINGS/1.0.0 http://maven.apache.org/xsd/settings-1.0.0.xsd">
  <!--  Sonatype entries omitted  -->
  <profiles>
    <profile>
      <id>default</id>
      <activation>
        <activeByDefault>true</activeByDefault>
      </activation>
      <properties>
        <gpg.passphrase>your-passphrase</gpg.passphrase>
      </properties>
    </profile>
  </profiles>
</settings>

```

### Utility scripts (optional)

`git-set-private-key.sh`: Utility script to configure git to use a specific private key. Use as `$(./git-set-private-key.sh ~/.ssh/id_rsa_custom)`
