# Release Scripts for Overture

The repo contains set of utility scripts to ease maintenance and the process of releasing the tool.

## Description of scripts

### Generating release notes

`github-fetch-milestone-issues.py`: Script for generating release notes for *closed* milestones. The template files `ReleaseNotes-template.md` and `ReleaseNotes-template-abbrev.md` must exist in the folder where the script is. If you are releasing Overture you may want to execute this script from `<overture-root>/documentation/releasenotes`.

### Update the website examples

`update-examples.sh`: Checks out the Overture standard examples, including the website, and adds the examples to the web site. After the script has been executed, the user must manually push the changes to the examples and website repositories. The instructions are provided by the script.

### Perform the release

`perform-release.sh` Performs a Maven release with tycho mode enabled by the profile `With-IDE`. This script can be run in interactive mode, i.e. it stops before pushing/releasing. Alternatively, one can perform an automated release by setting the environment variable `batchmode=release`. Before this script is executed, the release version and the new development versions must be specified in the `overture.release.properties` file, which is located in the root of the tool repository. This file must be edited and comitted before running the script. Run script as `./perform-release.sh`.

### Utility scripts (optional)

`git-set-private-key.sh`: Utility script to configure git to use a specific private key. Use as `$(./git-set-private-key.sh ~/.ssh/id_rsa_custom)`
