#!/bin/sh
shunit=`dirname $0`/shunit2/src/shunit2
BIN_DIR=`dirname $0`/../bin
PATH=$BIN_DIR:$PATH
FIXTURES=`dirname $0`/fixtures

setUp(){
  . $BIN_DIR/spindle_functions
}

testFindMD5Command() {
  if which md5sum > /dev/null ; then
    result=`whichMd5`
    result=`basename $result`
    assertEquals 'Command should be md5sum' 'md5sum' "$result"
  elif which gmd5sum > /dev/null ; then
    result=`whichMd5`
    result=`basename $result`
    assertEquals 'Command should be gmd5sum' 'gmd5sum' "$result"
  elif  which md5 > /dev/null ; then
    result=`whichMd5`
    result=`echo "$result" awk -F '/' '{ print $NF }'`
    assertEquals "Command should be 'md5 -r'" 'md5 -r' "$result"
  fi
}


. $shunit
