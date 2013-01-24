#!/bin/sh
shunit=`dirname $0`/shunit2/src/shunit2
PATH=`dirname $0`/../bin:$PATH
FIXTURES=`dirname $0`/fixtures

# tmp files get names like $tmp.1, $tmp.2
tmp=${TMPDIR:-/tmp}/prog.$$

suite() {
  suite_addTest "testOptMissingMetadata"
}

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
  type='REQ_MISSING'
  name=$2
  grep "ERROR.*${type} *${name}" $file
}

testOptMissingMetadata() {
  archive=$FIXTURES/metadata 
  output=$tmp.1
  assertTrue "$archive not found" "[ -d $archive ]"
  verify_metadata.sh $archive > $output 2>&1

  match=`grep "WARNING.*OPT_MISSING\s\+DAT_Processing_Comments" $output`
  assertNotNull "DAT_Processing_Comments should generate a warning" "$match"

  match=`grep "WARNING.*OPT_MISSING\s\+Contributor" $output`
  assertNotNull "Contributor should generate a warning" "$match"
}

testReqMissingMetadata() {
  archive=$FIXTURES/metadata 
  output=$tmp.1
  assertTrue "$archive not found" "[ -d $archive ]"
  verify_metadata.sh $archive > $output 2>&1
  assertEquals "should exit with error" 1 $?

  match=`get_req_missing_line $output Source`
  assertNotNull "Source should generate an error" "$match"

  match=`get_req_missing_line $output Keywords`
  assertNotNull "Keywords should generate an error" "$match"

  match=`get_req_missing_line $output ObjectName`
  assertNotNull "ObjectName should generate an error" "$match"

  match=`get_req_missing_line $output DAT_Bits_Per_Sample`
  assertNotNull "DAT_Bits_Per_Sample should generate an error" "$match"

  match=`get_req_missing_line $output DAT_File_Processing`
  assertNotNull "DAT_File_Processing should generate an error" "$match"

  match=`get_req_missing_line $output DAT_File_Processing_Rotation`
  assertNotNull "DAT_File_Processing_Rotation should generate an error" "$match"

  match=`get_req_missing_line $output DAT_Joining_Different_Parts_Of_Folio`
  assertNotNull "DAT_Joining_Different_Parts_Of_Folio should generate an error" "$match"

  match=`get_req_missing_line $output DAT_Joining_Same_Parts_of_Folio`
  assertNotNull "DAT_Joining_Same_Parts_of_Folio should generate an error" "$match"

  match=`get_req_missing_line $output DAT_Processing_Program`
  assertNotNull "DAT_Processing_Program should generate an error" "$match"

  match=`get_req_missing_line $output DAT_Samples_Per_Pixel`
  assertNotNull "DAT_Samples_Per_Pixel should generate an error" "$match"

  match=`get_req_missing_line $output DAT_Type_of_Contrast_Adjustment`
  assertNotNull "DAT_Type_of_Contrast_Adjustment should generate an error" "$match"

  match=`get_req_missing_line $output DAT_Type_of_Image_Processing`
  assertNotNull "DAT_Type_of_Image_Processing should generate an error" "$match"

  match=`get_req_missing_line $output ID_Parent_File`
  assertNotNull "ID_Parent_File should generate an error" "$match"

  match=`grep "ERROR.*DAT_Software_Version" $output | grep "should be"`
  assertNotNull "DAT_Software_Version should generate an error" "$match"

  match=`grep "ERROR.*DAT_File_Processing_Rotation" $output | grep "NON-NUMERIC"`
  assertNotNull "DAT_File_Processing_Rotation should generate an error" "$match"
}

. $shunit
