#!/bin/sh

# delete the manifest files created by testing scripts
MANIFEST_FILE=manifest-md5s.txt

while read dir
do
  echo "rm $dir/$MANIFEST_FILE"
  rm $dir/$MANIFEST_FILE
done < `dirname $0`/dir_list_valid.txt
