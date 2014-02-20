#!/bin/sh
# shunit_helper will source shunit2 code
shunit_helper=`dirname $0`/shunit_helper
BIN_DIR=`dirname $0`/../bin
PATH=$BIN_DIR:$PATH
FIXTURES=`dirname $0`/fixtures
tmp=/tmp/`basename $0 .sh`$$

setUp(){
  . $BIN_DIR/spindle_functions
}

tearDown() {
  rm -f $tmp.?
}

suite() {
  suite_addTest "testNewest"
  # suite_addTest "testCmpActualToLoggedFileMissingFromLog"
  # suite_addTest "testCmpActualToLoggedMatch"
  # suite_addTest "testCmpActualToLoggedExtraLoggedFile"
  # suite_addTest "testFindMD5Command"
  # suite_addTest "testReturnsExpectedFilenameCode"
}

testNewest() {
  time_file1=$tmp.1
  time_file2=$tmp.2
  time_file3=$tmp.3
  touch -t 01010001 $time_file1
  touch -t 01010002 $time_file2
  touch -t 01010003 $time_file3
  n=`newest $time_file1 $time_file2 $time_file3`
  assertEquals $n $time_file3

  n=`newest $time_file1 $time_file3 $time_file2`
  assertEquals $n $time_file3

  n=`newest $time_file3 $time_file2 $time_file1`
  assertEquals $n $time_file3

  n=`newest "" $time_file2 $time_file1`
  assertEquals $n $time_file2  

  n=`newest $time_file3 $time_file2 ""`
  assertEquals $n $time_file3

  n=`newest "" "" $time_file1`
  assertEquals $n $time_file1

  n=`newest "" $time_file2 ""`
  assertEquals $n $time_file2
}

testCmpActualToLoggedFileMissingFromLog() {
  content="file1 file2 file3 file4 file5"
  actual=$tmp.1
  logged=$tmp.2
  for file in $content 
  do
    echo $file >> $actual 
    echo $file >> $logged 
  done
  # add the extra file
  echo file6 >> $actual
  output=`cmpActualToLogged $actual $logged 2>&1`
  assertMatch "$output" "NOT_LOGGED  *file6"
}

testCmpActualToLoggedMatch() {
  content="file1 file2 file3 file4 file5"
  actual=$tmp.1
  logged=$tmp.2
  for file in $content 
  do
    echo $file >> $actual 
    echo $file >> $logged 
  done
  output=`cmpActualToLogged $actual $logged`
  assertEquals "Exit status should be 0" 0 $?
  assertMatch "output should say VALID: $output" "$output" "VALID"
}

testCmpActualToLoggedExtraLoggedFile() {
  content="file1 file2 file3 file4 file5"
  actual=$tmp.1
  logged=$tmp.2
  for file in $content 
  do
    echo $file >> $actual 
    echo $file >> $logged 
  done
  # add the extra file
  echo file6 >> $logged
  output=`cmpActualToLogged $actual $logged 2>&1`
  assertNotEquals "Exit status should not be 0; got $?" 0 $?
  assertMatch "output should say 'NO_SUCH_FILE: $output" "$output" "NO_SUCH_FILE  *file6"
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
    result=`echo "$result" | awk -F '/' '{ print $NF }'`
    assertEquals "Command should be 'md5 -r'" 'md5 -r' "$result"
  fi
}

testReturnsExpectedFilenameCode() {
  exec 9<&0 <<EOF
BAD_SHOT_SEQ=00.009  data/0020_00.009_WCB_PCA_RGB_01.jpg
BAD_PROCESSOR=W-B  data/0020_000009_W-B_PCA_RGB_01.jpg
BAD_PROC_TYPE=PC(A  data/0020_000009_WCB_PC(A_RGB_01.jpg
BAD_MODIFIERS=RGB123j-01'  data/0020_000009_WCB_PCA_RGB123j-01'.jpg
BAD_MODIFIERS=RGB123_-badsection  data/0020_000009_WCB_PCA_RGB123_-badsection.jpg
BAD_PROCESSOR=WCBA  data/0020_000009_WCBA_PCA_RGB_01.jpg
BAD_SHOOT_LIST=0A20  data/0A20_000009_WCB_PCA_RGB_01.jpg
BAD_EXTENSION=jpeg data/0020_000011_KTK_sharpie_WBUVR25-MB625Rd.jpeg
BAD_FILE_TYPE=png data/0020_000011_KTK_sharpie_WBUVR25-MB625Rd.png
BAD_PROC_TYPE=sha'rpie data/0020_000011_KTK_sha'rpie_WBUVR25-MB625Rd.jpg
VALID data/0020_000011_KTK_sharpie_WBUVR25-MB625Rd.jpg
VALID data/0020_000011_KTK_sharpie_WBUVR25-MB625Rd_xyz.jpg
VALID data/0020_000011_WCB_PCA.jpg
EOF
  while read line
  do
    code=`echo "$line" | awk '{ print $1 }'`
    file=`echo "$line" | awk '{ print $NF }'`
    result=`validateFilename $file`
    result_code=`echo $result | awk '{ print $1 }'`
    assertEquals "Unexpected code for: $file" $code $result_code
  done
  exec 0<&0 0<&-
}


# source shunit_helper
. $shunit_helper
