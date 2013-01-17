#!/bin/sh

read -r -d '' HELP <<-'EOF'
For an INPUT_DIR of the correct structure, verify all image file names for
correct format. The INPUT dir must contain at its root a 'data' directoy. 
All image files must be within the data diretory. No requirements are made as
to the directory structure in which the files are stored.

      .
      ├── data
      │   ├── Processed_Images
      │   │   ├── 0015_000001_KTK_pseudo_MB365UV-MB625Rd.tif
      │   │   ├── 0015_000001_KTK_pseudo_MB365UV-VIS.tif
      │   │   ├── ...
      │   │   ├── 0020_000018_KTK_txpseudo_WBRBB47-MB625Rd.tif
      │   │   ├── 0020_000018_KTK_txratio_TX940IR-MB940IR.tif
      │   │   └── 0020_000018_KTK_txsharpie_WBRBB47-MB625Rd.tif
      │   └── Processed_Images_JPEG
      │       ├── 0015_000001_KTK_pseudo_MB365UV-MB625Rd.jpg
      │       ├── 0015_000001_KTK_pseudo_MB365UV-VIS.jpg
      │       ├── ...
      │       ├── 0020_000018_KTK_txpseudo_WBRBB47-MB625Rd.jpg
      │       ├── 0020_000018_KTK_txratio_TX940IR-MB940IR.jpg
      │       └── 0020_000018_KTK_txsharpie_WBRBB47-MB625Rd.jpg
      └── manifest-md5s.txt

This command will verify:

 * that all file names have the correct format
 * that all file names have the correct extentions
 
# VALID FILE NAME CHARACTERS

Valid characters are:

      abcdefghijklmnopqrstuvwxyz1234567890_-+

First order fields are divided by underscores: _
Second order fields are divided by dashes: -

For use of the plus sign '+' please see the Data Delivery Recommendations
document.

# VALID FILE NAME FORMAT

The correct file names have these fields:

    <SHOOT_LIST>_<SHOT_SEQ>_<PROCESSOR>_<PROCESSING_TYPE>_<MODIFIERS>.ext

Where:

  * SHOOT_LIST is a 4-digit string, right-padded with zeros: '0009'

  * SHOT_SEQ is a 6-digit string, right-padded with zeros: '000123'

  * PROCESSOR is  3-characer string: 'WCB'

  * PROCESSING_TYPE is string composed of valid file name characters, expect
    the first-order field separator '_' (see below): 'sharpie'

  * MODIFIERS is a string composed of valid file name characters, and may be
    composed of multiple first-order fields: 'WBRBB47-MB625Rd'

Sample:

    0015_000012_KTK_sharpie_MB365UV-MB625Rd.jpg

# VALID EXTENSIONS

Files should have the following extensions:

* TIFF files: lower case '.tif'; not valid: '.TIF .tiff .TIFF'
* JPEG files: lower case '.jpg'; not valid: '.JPG .jpeg .JPEG'


EOF

### TEMPFILES
# From:
#   http://stackoverflow.com/questions/430078/shell-script-templates
# create a default tmp file name
tmp=${TMPDIR:-/tmp}/prog.$$
# delete any existing temp files
trap "rm -f $tmp.?; exit 1" 0 1 2 3 13 15
# then do
#   ...real work that creates temp files $tmp.1, $tmp.2, ...

#### USAGE AND ERRORS
cmd=`basename $0 .sh`

usage() {
   echo "Usage: $cmd {-h|-d IMAGE_DIR|DIR_LIST}"
   echo ""
   echo "OPTIONS"
   echo ""
   echo "   -h             Display help message"
   echo ""
}

help() {
  echo "$HELP"
  echo ""
}

message() {
  echo "$cmd: INFO    - $1"
}

error_no_exit() {
  echo "$cmd: ERROR   - $1" 1>&2
}

error() {
  echo "$cmd: ERROR   - $1" 1>&2
  echo ""
  usage
  exit 1
}

fail() {
  echo "$cmd: INVALID - $1" 1>&2
  exit 2
}

success() {
  echo "$cmd: VALID   - $1" 1>&2
  exit 0
}

warning() {
  echo "$cmd: WARNING - $1" 1>&2
}

### LOGGING
logfile=${LOGFILE:LOG_${cmd}}.log

log() {
    echo "`date +%Y-%m-%dT%H:%M:%S` [$cmd] $1" >> $LOG
}

### CONSTANTS
# the name of the manifest in each dir
MANIFEST_FILE=manifest-md5s.txt
# image file extensions
FILE_TYPES="jpg JPG jpeg JPEG tiff TIFF tif TIF"

### VARIABLES
# the input dir
INPUT_DIR=
# the data directory
DATA_DIR=
# files that are missing from the manifest
NOT_LISTED=
# files in the manifest not found in the directory
NOT_FOUND=

### OPTIONS
while getopts ":hd:" opt; do
  case $opt in
    h)
      usage 
      help
      exit 1
      ;;
    \?)
      echo "ERROR Invalid option: -$OPTARG" >&2
      echo ""
      usage
      exit 1
      ;;
  esac
done

shift $((OPTIND-1))

### THESCRIPT


### EXIT
# http://stackoverflow.com/questions/430078/shell-script-templates
rm -f $tmp.?
trap 0
exit 0
