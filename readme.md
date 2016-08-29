# Release Scripts for Overture

The repo contains set of utility scripts to ease maintenance and the process of releasing the tool.

Content:
* `git-set-private-key.sh` util script to use git with a specific private key. Use as `$(./git-set-private-key.sh ~/.ssh/id_rsa_custom)`
* `github-fetch-milestone-issues.py` release note generator script based on closed milestones. The following template files must exist `ReleaseNotes-template.md` and `ReleaseNotes-template-abbrev.md`. If you are releasing Overture you may want to execute this script in `<ovt>/documentation/releasenotes`. Finally, make sure you have closed the milestone that the release is based on.
* `update-examples.sh` checks out the overture examples and web site and packs the examples and adds them to the web site.
* `perform-release.sh` performs a maven release for a repo with tycho code enabled by the profile `With-IDE`. It is either interactive stopping before pushing/releasing or if supplied with environment variable `batchmode=release` auto releases. It requires a `overture.release.properties` file with version numbers to be present in the root of the repository.


