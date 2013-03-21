#!/bin/sh
shunit=`dirname $0`/shunit2/src/shunit2
PATH=`dirname $0`/../bin:$PATH
FIXTURES=`dirname $0`/fixtures

# tmp files get names like $tmp.1, $tmp.2
tmp=${TMPDIR:-/tmp}/prog.$$

# suite() {
#   suite_addTest "testOptMissingMetadata"
# }

tearDown() {
  rm -f $tmp.?
}

# verify_metadata: INFO    - Deleting previous error file /Users/doug/code/GIT/spindle/test/metadata/ERROR_verify_metadata.log
# verify_metadata: ERROR   - data/0020_0000010_WCB_PCA_RGB_01.tif  REQ_MISSING  Source
# verify_metadata: ERROR   - data/0020_0000010_WCB_PCA_RGB_01.tif  REQ_MISSING  Keywords
# verify_metadata: ERROR   - data/0020_0000010_WCB_PCA_RGB_01.tif  REQ_MISSING  ObjectName
# verify_metadata: ERROR   - data/0020_0000010_WCB_PCA_RGB_01.tif  REQ_MISSING  DAT_Bits_Per_Sample
# verify_metadata: ERROR   - data/0020_0000010_WCB_PCA_RGB_01.tif  REQ_MISSING  DAT_File_Processing
# verify_metadata: ERROR   - data/0020_0000010_WCB_PCA_RGB_01.tif  REQ_MISSING  DAT_File_Processing_Rotation
# verify_metadata: ERROR   - data/0020_0000010_WCB_PCA_RGB_01.tif  REQ_MISSING  DAT_Joining_Different_Parts_Of_Folio
# verify_metadata: ERROR   - data/0020_0000010_WCB_PCA_RGB_01.tif  REQ_MISSING  DAT_Joining_Same_Parts_of_Folio
# verify_metadata: ERROR   - data/0020_0000010_WCB_PCA_RGB_01.tif  REQ_MISSING  DAT_Processing_Program
# verify_metadata: ERROR   - data/0020_0000010_WCB_PCA_RGB_01.tif  REQ_MISSING  DAT_Samples_Per_Pixel
# verify_metadata: ERROR   - data/0020_0000010_WCB_PCA_RGB_01.tif  REQ_MISSING  DAT_Type_of_Contrast_Adjustment
# verify_metadata: ERROR   - data/0020_0000010_WCB_PCA_RGB_01.tif  REQ_MISSING  DAT_Type_of_Image_Processing
# verify_metadata: ERROR   - data/0020_0000010_WCB_PCA_RGB_01.tif  REQ_MISSING  ID_Parent_File
# verify_metadata: ERROR   - data/0020_0000010_WCB_PCA_RGB_01.tif  DAT_Software_Version should be "See DAT_Processing_Program"
# verify_metadata: ERROR   - data/0020_0000010_WCB_PCA_RGB_01.tif  DAT_File_Processing_Rotation  NON-NUMERIC: ''
# verify_metadata: WARNING - data/0020_0000010_WCB_PCA_RGB_01.tif OPT_MISSING  DAT_Processing_Comments
# verify_metadata: WARNING - data/0020_0000010_WCB_PCA_RGB_01.tif OPT_MISSING  Contributor
# verify_metadata: INFO    - 1 of 2 files had no errors 
# verify_metadata: ERROR   - 1 of 2 files had metadata errors
# verify_metadata: INFO    - Errors logged to /Users/doug/code/GIT/spindle/test/metadata/ERROR_verify_metadata.log

get_req_missing_line() {
  file=$1
  type='MISSING'
  name=$2
  grep "INVALID *${type}=*${name}" $file
}

testReqMissingMetadata() {
  archive=$FIXTURES/metadata 
  test_log=$archive/DLVRY_metadata.log
  rm -f $test_log
  output=$tmp.1
  assertTrue "$archive not found" "[ -d $archive ]"
  verify_all_metadata $archive > $output 2>&1
  assertEquals "should exit with error" 1 $?

  match=`get_req_missing_line $test_log Source`
  assertNotNull "Source should generate an error" "$match"

  match=`get_req_missing_line $test_log Keywords`
  assertNotNull "Keywords should generate an error" "$match"

  match=`get_req_missing_line $test_log ObjectName`
  assertNotNull "ObjectName should generate an error" "$match"

  match=`get_req_missing_line $test_log DAT_Bits_Per_Sample`
  assertNotNull "DAT_Bits_Per_Sample should generate an error" "$match"

  match=`get_req_missing_line $test_log DAT_File_Processing`
  assertNotNull "DAT_File_Processing should generate an error" "$match"

  match=`get_req_missing_line $test_log DAT_File_Processing_Rotation`
  assertNotNull "DAT_File_Processing_Rotation should generate an error" "$match"

  match=`get_req_missing_line $test_log DAT_Joining_Different_Parts_Of_Folio`
  assertNotNull "DAT_Joining_Different_Parts_Of_Folio should generate an error" "$match"

  match=`get_req_missing_line $test_log DAT_Joining_Same_Parts_of_Folio`
  assertNotNull "DAT_Joining_Same_Parts_of_Folio should generate an error" "$match"

  match=`get_req_missing_line $test_log DAT_Processing_Program`
  assertNotNull "DAT_Processing_Program should generate an error" "$match"

  match=`get_req_missing_line $test_log DAT_Samples_Per_Pixel`
  assertNotNull "DAT_Samples_Per_Pixel should generate an error" "$match"

  match=`get_req_missing_line $test_log DAT_Type_of_Contrast_Adjustment`
  assertNotNull "DAT_Type_of_Contrast_Adjustment should generate an error" "$match"

  match=`get_req_missing_line $test_log DAT_Type_of_Image_Processing`
  assertNotNull "DAT_Type_of_Image_Processing should generate an error" "$match"

  match=`get_req_missing_line $test_log ID_Parent_File`
  assertNotNull "ID_Parent_File should generate an error" "$match"

  match=`grep "INVALID *BAD_LITERAL=DAT_Software_Version" $test_log`
  assertNotNull "DAT_Software_Version should generate an error" "$match"

  match=`grep "INVALID *BAD_NUMBER=DAT_File_Processing_Rotation" $test_log`
  assertNotNull "DAT_File_Processing_Rotation should generate an error" "$match"
}

. $shunit
