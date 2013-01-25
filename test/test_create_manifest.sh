#!/bin/sh
shunit=`dirname $0`/shunit2/src/shunit2
PATH=`dirname $0`/../bin:$PATH
FIXTURES=`dirname $0`/fixtures
ARCHIVE=$FIXTURES/needs_manifest

# tmp files get names like $tmp.1, $tmp.2
tmp=${TMPDIR:-/tmp}/prog.$$

# suite() {
#   suite_addTest "testOptMissingMetadata"
# }

tearDown() {
  rm -f $ARCHIVE/manifest-md5s.txt
  rm -f $tmp.?
}

testWriteManifest() {
  file_count=`find $ARCHIVE/data -type f | wc -l`
  create_manifest.sh $ARCHIVE
  actual=`wc -l $ARCHIVE/manifest-md5s.txt | awk '{ print $1 }'`
  assertEquals "Num of checksums should match" $file_count $actual
}

. $shunit
