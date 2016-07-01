#!/bin/bash

git clone git@github.com:overturetool/documentation.git doc
doc=`readlink -f doc`
git clone git@github.com:overturetool/overturetool.github.io.git web
web=`readlink -f web`


cd $doc
# Merge editing into master
git checkout master
git merge origin/editing

# Generate web-ready versions of the exmaples
cd $doc/examples
mvn

#Update exmaples on the website
cd $web/download/examples
rm -r Examples-VDM*.zip VDM*
mv ${doc}/examples/target/Examples-VDM*.zip ${doc}/examples/target/Web/VDM* .

cd $web
git add download/examples
git commit -m "updated examples"

echo "To apply the changes run the following"
echo "cd ${web} && git push origin master"
echo "cd ${doc} && git push origin master"
