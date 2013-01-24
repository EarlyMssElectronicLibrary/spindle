#!/bin/sh
shunit=`dirname $0`/shunit2/src/shunit2
PATH=`dirname $0`/../bin:$PATH
FIXTURES=`dirname $0`/fixtures

# tmp files get names like $tmp.1, $tmp.2
tmp=${TMPDIR:-/tmp}/prog.$$

# suite() {
#   suite_addTest "testBadShootList"
# }
tearDown() {
  rm -f $tmp.?
}

testGoodNames() {
  # we should have a log file LOG_verify_filenames.log
  # the last line of the log should contain: ALL VALID
  archive=$FIXTURES/names_valid
  output=$tmp.1
  verify_filenames.sh $archive > $output 2>&1
  assertEquals "verify_filenames.sh should exit without error" 0 $? 
  log=$archive/LOG_verify_filenames.log
  assertTrue "Missing file $log" "[ -f $log ]"
  assertTrue "Expected log to have ALL VALID" "grep 'ALL VALID' $log >/dev/null"
}

testBadShootList () {
  # there should be a number of errors: 
  # verify_filenames: ERROR   - data/0020_00.009_WCB_PCA_RGB_01.jpg       BAD_SHOT_SEQ
  # verify_filenames: ERROR   - data/0020_000009_W-B_PCA_RGB_01.jpg       BAD_PROCESSOR
  # verify_filenames: ERROR   - data/0020_000009_WCB_PC(A_RGB_01.jpg      BAD_MODIFIERS
  # verify_filenames: ERROR   - data/0020_000009_WCB_PCA_RGB123j-01'.jpg  BAD_MODIFIERS
  # verify_filenames: ERROR   - data/0020_000009_WCBA_PCA_RGB_01.jpg      BAD_PROCESSOR
  # verify_filenames: ERROR   - data/0A20_000009_WCB_PCA_RGB_01.jpg       BAD_SHOOT_LIST
  archive=$FIXTURES/names_invalid
  output=$tmp.1
  verify_filenames.sh $archive > $output 2>&1
  assertEquals "should error on exit" 1 $?
  bad_shoot_list=`grep "BAD_SHOOT_LIST" $output | awk '{ print $4 }'`
  assertEquals "BAD_SHOOT_LIST" 'data/0A20_000009_WCB_PCA_RGB_01.jpg' $bad_shoot_list
  
}
testBadModifiers() {
  # there should be a number of errors: 
  # verify_filenames: ERROR   - data/0020_00.009_WCB_PCA_RGB_01.jpg       BAD_SHOT_SEQ
  # verify_filenames: ERROR   - data/0020_000009_W-B_PCA_RGB_01.jpg       BAD_PROCESSOR
  # verify_filenames: ERROR   - data/0020_000009_WCB_PC(A_RGB_01.jpg      BAD_MODIFIERS
  # verify_filenames: ERROR   - data/0020_000009_WCB_PCA_RGB123j-01'.jpg  BAD_MODIFIERS
  # verify_filenames: ERROR   - data/0020_000009_WCBA_PCA_RGB_01.jpg      BAD_PROCESSOR
  # verify_filenames: ERROR   - data/0A20_000009_WCB_PCA_RGB_01.jpg       BAD_SHOOT_LIST
  archive=$FIXTURES/names_invalid
  output=$tmp.1
  verify_filenames.sh $archive > $output 2>&1
  assertEquals "should error on exit" 1 $?
  bad_modifiers=`grep "BAD_MODIFIERS" $output | sed -n '1p' | awk '{ print $4 }'`
  assertEquals "BAD_MODIFIERS" 'data/0020_000009_WCB_PC(A_RGB_01.jpg' $bad_modifiers
  bad_modifiers=`grep "BAD_MODIFIERS" $output | sed -n '2p' | awk '{ print $4 }'`
  assertEquals "BAD_MODIFIERS" "data/0020_000009_WCB_PCA_RGB123j-01'.jpg" $bad_modifiers
}

testBadShotSeq() {
  # there should be a number of errors: 
  # verify_filenames: ERROR   - data/0020_00.009_WCB_PCA_RGB_01.jpg       BAD_SHOT_SEQ
  # verify_filenames: ERROR   - data/0020_000009_W-B_PCA_RGB_01.jpg       BAD_PROCESSOR
  # verify_filenames: ERROR   - data/0020_000009_WCB_PC(A_RGB_01.jpg      BAD_MODIFIERS
  # verify_filenames: ERROR   - data/0020_000009_WCB_PCA_RGB123j-01'.jpg  BAD_MODIFIERS
  # verify_filenames: ERROR   - data/0020_000009_WCBA_PCA_RGB_01.jpg      BAD_PROCESSOR
  # verify_filenames: ERROR   - data/0A20_000009_WCB_PCA_RGB_01.jpg       BAD_SHOOT_LIST
  archive=$FIXTURES/names_invalid
  output=$tmp.1
  verify_filenames.sh $archive > $output 2>&1
  assertEquals "should error on exit" 1 $?
  bad_shot_seq=`grep "BAD_SHOT_SEQ" $output | awk '{ print $4 }'`
  assertEquals "BAD_SHOT_SEQ" "data/0020_00.009_WCB_PCA_RGB_01.jpg" "$bad_shot_seq"
}

testBadProcessor() {
  # there should be a number of errors: 
  # verify_filenames: ERROR   - data/0020_00.009_WCB_PCA_RGB_01.jpg       BAD_SHOT_SEQ
  # verify_filenames: ERROR   - data/0020_000009_W-B_PCA_RGB_01.jpg       BAD_PROCESSOR
  # verify_filenames: ERROR   - data/0020_000009_WCB_PC(A_RGB_01.jpg      BAD_MODIFIERS
  # verify_filenames: ERROR   - data/0020_000009_WCB_PCA_RGB123j-01'.jpg  BAD_MODIFIERS
  # verify_filenames: ERROR   - data/0020_000009_WCBA_PCA_RGB_01.jpg      BAD_PROCESSOR
  # verify_filenames: ERROR   - data/0A20_000009_WCB_PCA_RGB_01.jpg       BAD_SHOOT_LIST
  archive=$FIXTURES/names_invalid
  output=$tmp.1
  verify_filenames.sh $archive > $output 2>&1
  assertEquals "should error on exit" 1 $?
  bad_processor=`grep "BAD_PROCESSOR" $output | sed -n '1p' | awk '{ print $4 }'`
  assertEquals "BAD_PROCESSOR" "data/0020_000009_W-B_PCA_RGB_01.jpg" "$bad_processor"
  bad_processor=`grep "BAD_PROCESSOR" $output | sed -n '2p' | awk '{ print $4 }'`
  assertEquals "BAD_PROCESSOR" "data/0020_000009_WCBA_PCA_RGB_01.jpg" "$bad_processor"
}

. $shunit
