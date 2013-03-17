#!/bin/sh


read -r -d '' HELP <<-'EOF'
Confirm image data INPUT_DIR is ready for delivery. INPUT_DIR defaults to '.'.

For an INPUT_DIR of the correct structure, verify that it is ready for
delivery. INPUT_DIR must contain at its root a 'data' directory. and a manifest
file 'manifest-md5s.txt'; thus,

      .
      ├── LOG_verify_filenames.log
      ├── LOG_verify_metadata.log
      ├── data
      │   ├── 0015_000013_DJK_ICA_01_2.jpeg
      │   ├── 0015_000013_DJK_ICA_01_2.tif
      │   ├── ...
      │   ├── 0015_000013_DJK_ICA_04_RGB.jpeg
      │   └── 0015_000013_DJK_ICA_04_RGB.tif
      └── manifest-md5s.txt

To be valid for delivery a directory must have the following:

 * a LOG_verify_filenames.log file, the last line of which contains "ALL VALID"
 * a LOG_verify_metadata.log file, the last line of which contains "ALL VALID"
 * a manifest-md5s.txt file that is newer than the log files, and all files in
   the data directory
 * addtionally, the list of files in the manifest must match the list of files
   in the data directory *exactly*

The directory MUST NOT contain any of the following:

 * an ERROR_verify_filenames.log file
 * an ERROR_verify_metadata.log file
 * any other ERROR log file

To ensure data retains its integrity for delivery, it is recommended you tar
all data into a single archive:

   $ cd INPUT_DIR
   $ cd ..
   $ tar cf INPUT_DIR.tar INPUT_DIR/**

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
export SPINDLE_COMMAND=$cmd
source `dirname $0`/spindle_functions

usage() {
   echo "Usage: $cmd [-h] [INPUT_DIR]"
   echo ""
   echo "OPTIONS"
   echo ""
   echo "   -h             Display help message"
   echo ""
}

### CONSTANTS
# the name of the manifest in each dir
MANIFEST_FILE=manifest-md5s.txt

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
# grab input directoy and confirm it exists
INPUT_DIR=$1
if [ -z "$INPUT_DIR" ]; then
  message "No INPUT_DIR provided. Using '.'"
  INPUT_DIR=.
elif [ ! -d $INPUT_DIR ]; then
  error "INPUT_DIR not found: $INPUT_DIR"
fi

# make sure there's a data directory in INPUT_DIR
DATA_DIR=$INPUT_DIR/data
if [ ! -d $DATA_DIR ]; then
  error "Data directory not found: $DATA_DIR"
fi

# TODO Check for ERROR files
# TODO Check for LOG_verify_filenames.log
# TODO Check for LOG_verify_metadata.log
# TODO Check manifest-md5s.txt date
# TODO Check manifest-md5s.txt file lists
# TODO confirm all data files younger than logs and manifest

### EXIT
# http://stackoverflow.com/questions/430078/shell-script-templates
rm -f $tmp.?
trap 0
exit 0

