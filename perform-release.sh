#!/bin/bash

set -e

MVN_SETTINGS_PATH=${1-~/.m2/settings.xml}

git checkout development

unset RELEASE_VER
unset NEW_DEV_VER

release_properties_path=overture.release.properties
echo "Checking for ${release_properties_path}"
if [ -e "$release_properties_path" ]; then
  echo "File exists: ${release_properties_path}"
  export RELEASE_VER=$(head -n 1 $release_properties_path | tail -1 | cut -d'=' -f2)
  export NEW_DEV_VER=$(head -n 2 $release_properties_path | tail -1 | cut -d'=' -f2)
else
  echo "No release version information available!"
  exit 1
fi

# remove all spaces in version numbers
export RELEASE_VER=${RELEASE_VER// }
export NEW_DEV_VER=${NEW_DEV_VER// }

echo "Fetch current version"

VERSION=`mvn -q -Dexec.executable="echo" -Dexec.args='${project.version}' --non-recursive org.codehaus.mojo:exec-maven-plugin:1.3.1:exec`


echo "Current version  : ${VERSION}"
echo "Next dev version : ${NEW_DEV_VER}"
echo "Release version  : ${RELEASE_VER}"

echo 
echo "Removing release properties"
git rm $release_properties_path
git commit -m "Removing ${release_properties_path}. Release=${RELEASE_VER}, next dev=${NEW_DEV_VER}"



echo "Cleaning old release artefacts"
mvn -Dmaven.repo.local=repository release:clean -q

echo "Prepare new release -DpushChanges=false"

mvn -Dmaven.repo.local=repository --batch-mode release:prepare -DreleaseVersion=${RELEASE_VER} -DdevelopmentVersion=${NEW_DEV_VER} -DpushChanges=false -q -s $MVN_SETTINGS_PATH
# > prepare.log

echo "The changes just done locally by 'release:prepare' do not change the IDE versions, so this will be fixed now"

git checkout Release/$RELEASE_VER

#fix the pom:
echo "Patch the ide/pom.xml with new parent version ${RELEASE_VER}, and old self version ${VERSION}"

sed -i{} "s|<version>${VERSION}</version>|<version>${RELEASE_VER}</version>|" ide/pom.xml
sed -i{} "s|</parent>|</parent><version>${VERSION}</version>|" ide/pom.xml

echo "Tycho-versions set-version to: ${RELEASE_VER}"
mvn -Dmaven.repo.local=repository -Dtycho.mode=maven tycho-versions:set-version -DnewVersion=${RELEASE_VER} -f ide/pom.xml -q

echo "Add,commit, and squash commit for ide/* changes"
git add -u
git commit -m "Bump ide/ to version ${RELEASE_VER}"

# squash the last two commits
git reset --soft HEAD~2 && git commit -m"$(git log --format=%B --reverse HEAD..HEAD@{1})"

echo "Reset tag: Release/${RELEASE-VER} to here"
# get last tag message

RTAGMSG=`git cat-file -p $(git rev-parse $(git tag -l | tail -n1)) | tail -n +6`

git tag -d Release/$RELEASE_VER
git tag -a Release/$RELEASE_VER -m "${RTAGMSG}"

# release tag modification completed

echo 
echo "Release tag fixed"
echo 
echo "Now do the same change for development with version ${NEW_DEV_VER}"

# now fix development
echo "Checkout the release tag as detached HEAD"
git checkout Release/$RELEASE_VER
echo "Pick last development commit: [maven-release-plugin] prepare for next development iteration'"
git cherry-pick development

#fix the pom:
echo "Patch the ide/pom.xml with new parent version ${NEW_DEV_VER}, and self version ${RELEASE_VER}"

sed -i{} "s|<version>${RELEASE_VER}</version>|<version>${NEW_DEV_VER}</version>|" ide/pom.xml
sed -i{} "s|</parent>|</parent><version>${RELEASE_VER}</version>|" ide/pom.xml

mvn -Dmaven.repo.local=repository -Dtycho.mode=maven tycho-versions:set-version -DnewVersion=${NEW_DEV_VER} -f ide/pom.xml -q

echo "Add,commit, and squash commit for ide/* changes"
git add -u
git commit -m "Bump ide/ to version ${NEW_DEV_VER}"

# squash the last two commits
git reset --soft HEAD~2 && git commit -m"$(git log --format=%B --reverse HEAD..HEAD@{1})"


#get sha for detached head
SHADEV=`git rev-parse HEAD`

echo "Checkout development"

git checkout development 
echo "Nuke last two commits in development"
git reset --hard HEAD^^
echo "Rebase the corrected detached HEAD on top of development"
git rebase $SHADEV


## all branches/tags are now fixed using tycho set version
echo 
echo "Git modifications required are now performed"
echo " - fixed development"
echo " - fixed Release/${RELEASE_VER}"


# perform the release
exit

read -p "Do you want to proceed with releasing the tag: Release/${RELEASE_VER}? (y/n?)" -n 1 -r
echo    # (optional) move to a new line
if [[ $REPLY =~ ^[Yy]$ ]]
then
    echo "Git push --follow-tags"
    git push --follow-tags
    echo "Perform release with profile 'With-IDE'"
	mvn -Dmaven.repo.local=repository --batch-mode release:perform -PWith-IDE -q -s $MVN_SETTINGS_PATH
	# > release.log
else
	echo "Review local changed and manually run: 'git push --follow-tags && mvn -Dmaven.repo.local=repository release:perform' to release"
fi


echo 
echo Done.