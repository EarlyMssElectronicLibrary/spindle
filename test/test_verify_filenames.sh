#!/bin/bash
shunit=`dirname $0`/shunit2/src/shunit2
shunit_helper=`dirname $0`/shunit_helper
PATH=`dirname $0`/../bin:$PATH
FIXTURES=`dirname $0`/fixtures

# tmp files get names like $tmp.1, $tmp.2
tmp=${TMPDIR:-/tmp}/prog.$$

# suite() {
  # suite_addTest "testDeliveryLogFileCreation"
  # suite_addTest "testDeliveryLogFileCheck"
  # suite_addTest "testDeliveryAllValid"
  # suite_addTest "testDeliveryBadFiles"
  # suite_addTest "testReceiptBadLogFile"
  # suite_addTest "testReceiptInconsistentLogFile"
  # suite_addTest "testReceiptOutOfDateLogFile"
  # suite_addTest "testReceiptLoggedFileMismatch"
# }

tearDown() {
  rm -f $tmp.?
}


# DELIVERY_MODE make sure delivery creates a log file DLVRY_filenames.log
testDeliveryLogFileCreation() {
  # we should have a log file LOG_verify_filenames.log
  # the last line of the log should contain: ALL VALID
  archive=$FIXTURES/names_valid
  output=$tmp.1
  verify_all_filenames $archive > $output 2>&1
  assertTrue "File not found DLVRY_filenames.log" "[ -f $archive/DLVRY_filenames.log ]"
  rm -f $archive/DLVRY_filenames.log
}

# in DELIVERY MODE bail if DLVRY_filenames.log found
testDeliveryLogFileCheck() {
  archive=$FIXTURES/names_valid
  logfile=$archive/DLVRY_filenames.log
  # create log file
  touch $logfile
  output=`verify_all_filenames $archive 2>&1`

  assertMatch "Expected overwrite error in $output" "$output" "ERROR.*overwrite"
  # clean up
  rm -f $logfile
}

# DELIVERY_MODE if all names valid; DLVRY_filenames.log should say ALL_VALID
testDeliveryAllValid() {
  # we should have a log file DLVRY_filenames.log
  # the last line of the log should contain: ALL VALID
  archive=$FIXTURES/names_valid
  logfile=$archive/DLVRY_filenames.log
  # verify_all_filenames $archive > $output 2>&1
  verify_all_filenames $archive 2>&1
  assertEquals "verify_all_filenames should exit without error" 0 $? 
  last_line=`sed -n '$p' $logfile`
  assertMatch "Expect last line to contain ALL_VALID: $last_line" "ALL_VALID" $last_line
  rm -f $logfile
}

# DELIVERY_MODE log file test should report all types of errors
testDeliveryBadFiles() {
  expected_errors="BAD_SHOT_SEQ BAD_PROCESSOR BAD_SHOOT_LIST BAD_PROC_TYPE BAD_MODIFIERS BAD_EXTENSION BAD_FILE_TYPE"
  archive=$FIXTURES/names_invalid
  logfile=$archive/DLVRY_filenames.log
  output=`verify_all_filenames $archive 2>&1`
  assertNotEquals "verify_all_filenames should exit with error" 0 $? 
  last_line=`sed -n '$p' $logfile`
  assertMatch "Expect last line to contain ERRORS_FOUND: $last_line" "ERRORS_FOUND" $last_line
  for error in $expected_errors
  do
    count=`grep $error $logfile | wc -l`
    assertTrue "Expected at least one $error; found $count" "[ $count -gt 0 ]"
  done
  assertMatch "$output" "FAIL"
  rm -f $logfile
}



. $shunit_helper
. $shunit
