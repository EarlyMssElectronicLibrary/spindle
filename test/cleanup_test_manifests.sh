#!/bin/sh

# delete the manifest files created by testing scripts
MANIFEST_FILE=manifest-md5s.txt

echo "removing test checksum files"
while read dir
do
  manifest=`dirname $0`/../$dir/$MANIFEST_FILE
  if [ -f $manifest ]; then
    rm -v $manifest
  else
    echo "not found $manifest"
  fi
done < `dirname $0`/dir_list_valid.txt
