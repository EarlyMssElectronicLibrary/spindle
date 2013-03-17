#!/bin/bash
shunit_helper=`dirname $0`/shunit_helper
PATH=`dirname $0`/../bin:$PATH
FIXTURES=`dirname $0`/fixtures
VERIFY_FILENAME=`dirname $0`/../bin/verify_filename


testVerifyFilename() {
  exec 9<&0 <<EOF
BAD_SHOT_SEQ=00.009  data/0020_00.009_WCB_PCA_RGB_01.jpg
BAD_PROCESSOR=W-B  data/0020_000009_W-B_PCA_RGB_01.jpg
BAD_PROC_TYPE=PC(A  data/0020_000009_WCB_PC(A_RGB_01.jpg
BAD_MODIFIERS=RGB123j-01'  data/0020_000009_WCB_PCA_RGB123j-01'.jpg
BAD_MODIFIERS=RGB123j-01-  data/0020_000009_WCB_PCA_RGB123j-01-.jpg
BAD_PROCESSOR=WCBA  data/0020_000009_WCBA_PCA_RGB_01.jpg
BAD_SHOOT_LIST=0A20  data/0A20_000009_WCB_PCA_RGB_01.jpg
BAD_EXTENSION=jpeg data/0020_000011_KTK_sharpie_WBUVR25-MB625Rd.jpeg
BAD_FILE_TYPE=png data/0020_000011_KTK_sharpie_WBUVR25-MB625Rd.png
BAD_PROC_TYPE=sha'rpie data/0020_000011_KTK_sha'rpie_WBUVR25-MB625Rd.jpg
VALID data/0020_000011_KTK_sharpie_WBUVR25-MB625Rd.jpg
VALID data/0020_000011_WCB_PCA.jpg
VALID data/0020_000011_WCB_PCA_01_2.jpg
EOF
  while read line
  do
    code=`echo "$line" | awk '{ print $1 }'`
    file=`echo "$line" | awk '{ print $2 }'`
    result=`$VERIFY_FILENAME $file | awk '{print $1}'`
    assertEquals "Unexpected code for: $file" $code "$result"
  done
  exec 0<&0 0<&-
}

. $shunit_helper
