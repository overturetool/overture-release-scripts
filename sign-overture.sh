#!/bin/bash
set -e

filename=$(basename "$1")
extension="${filename##*.}"
filename="${filename%.*}"

tmpFolderName=`basename $filename`
rm -rf $tmpFolderName
mkdir $tmpFolderName
unzip -q $1 -d $tmpFolderName

d=`find $tmpFolderName -type d -print | head -n 1`

BLUE="$(tput setaf 4)"
BLACK="$(tput sgr0)"
YELLOW="$(tput setaf 3)"
RED="$(tput setaf 1)"
GREEN="$(tput setaf 2)"

app=`find "$d" -name "*.app" -print | head -n 1`

echo identities
security find-identity -p codesigning -v

echo ""
echo signing "$app"
codesign --deep --force --verbose --sign "Developer ID Application: Aarhus University (QP7836JDJP)" $app 2>&1 | sed "s/replacing existing signature/${YELLOW}replacing existing signature${BLACK}/g" | sed "s/signed app/${GREEN}signed app${BLACK}/g" | sed "s/invalid/${RED}invalid${BLACK}/g"


# This will often pass, even if Gatekeeper fails.
echo ""
echo "Verifying signatures..."
codesign --verify --deep --display --verbose=4 $app 2>&1 | grep 'Authority\|Signature' | sed "s/Aarhus University/${GREEN}Aarhus University${BLACK}/g"


BLUE="$(tput setaf 4)"
BLACK="$(tput sgr0)"
# This is what really counts and what the user will see.
echo ""
echo "Veriyfing Gatekeeper acceptance..."
spctl --ignore-cache --no-cache --assess --type execute --verbose=4 $app 2>&1 | sed "s/accepted/${GREEN}accepted${BLACK}/g" | sed "s/rejected/${RED}rejected${BLACK}/g"
#echo -e `sed 's/accepted/\033[0;32maccepted\033[m/g' $out`

# Thanks to http://jbavari.github.io/blog/2015/08/14/codesigning-electron-applications/
echo ""
zn=`basename $d`.zip
echo Zipping...
find $d -name '*.DS_Store' -type f -delete
cd $d
cd ..
zip -FS -q --symlinks -r $zn `basename $d` -x "*.DS_Store" -o

echo ""
unzip -l $zn | awk -F/ '{if (NF<4) print }'

echo ""
echo Signing zip
codesign  --verbose --sign "Developer ID Application: Aarhus University (QP7836JDJP)" $zn 2>&1 | sed "s/signed/${GREEN}signed${BLACK}/g"

echo ""
echo Verifying signatures for zip
codesign --verify --display --verbose=4 $zn  2>&1  | sed "s/Aarhus University/${GREEN}Aarhus University${BLACK}/g" | grep 'Authority\|Signature' 
