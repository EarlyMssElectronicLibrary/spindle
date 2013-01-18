#!/bin/sh

# TODO update to use spindle_functions
# TODO export SPINDLE_COMMAND=`basename $0`
# TODO export HELP
# TODO source `dirname $0`/spindle_functions
# TODO delete function 'message'
# TODO delete function 'error_no_exit'
# TODO delete function 'error'
# TODO delete function 'fail'
# TODO delete function 'success'
# TODO delete function 'warning'
# TODO delete function 'help'
# TODO delete function 'log'
# TODO delete function 'log_error'

read -r -d '' HELP <<-'EOF'
Create a checksum manifest for all TIFF and JPEG files found under the 'data'
directory in INPUT_DIR. INPUT_DIR defaults to the current dir if not provided.

The following is a valid directory structure:

      .
      └── data
          ├── dir1
          │   ├── file1.tif
          │   ├── file2.tif
          │   └── file4.jpg
          └── dir2
              ├── file3.jpg
              └── file4.jpg

Running $cmd script will add the file manifest-md5s.txt:

      .
      ├── data
      │   ├── dir1
      │   │   ├── file1.tif
      │   │   ├── file2.tif
      │   │   └── file4.jpg
      │   └── dir2
      │       ├── file3.jpg
      │       └── file4.jpg
      └── manifest-md5s.txt

The manifest file will have the content:

      44943bbb7d369448027783b67fa579e1 data/dir1/file1.tif
      cf2bdfd16d69233f1b725038c2235e37 data/dir1/file2.tif
      f9d56cbbb540b4c6f192a27c9ccb2bb7 data/dir1/file4.jpg
      7b9da80eb03f5b08372aa137c021e6aa data/dir2/file3.jpg
      8f55980b0490ec47c20ccd0677b2ab1d data/dir2/file4.jpg

This script runs the Mac OS command 'md5 -r'. The '-r' option reverses the 
output to conform with more common 'md5' command behavior.
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
   echo "usage: $cmd [-h] [INPUT_DIR]"
   echo ""
   echo "Create a manifest for all image files in INPUT_DIR/data."
   echo "INPUT_DIR defaults to '.'"
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

### THE SCRIPT
# first, find an MD5 command
MD5_CMD=
if which md5sum >/dev/null 2>&1 ; then
  MD5_CMD=`which md5sum`
elif which gmd5sum >/dev/null 2>&1 ; then
  MD5_CMD=`which gmd5sum`
elif which md5 >/dev/null 2>&1 ; then
  MD5_CMD="`which md5` -r"
else
  error "MD5 command not found; looked for gmd5sum, md5sum, md5"
fi
message "Using MD5 command: $MD5_CMD"

# check for valid input
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

# make sure the manifest doesn't already exist
if [ -e $INPUT_DIR/$MANIFEST_FILE ]; then
  error "Manifest already exists: $INPUT_DIR/$MANIFEST_FILE"
fi

# Build the manifest
if [ "$INPUT_DIR" != "." ]; then
  cd $INPUT_DIR
fi

file_list=$tmp.1
find data -type f > $file_list

curr=0
total=`wc -l $file_list | awk '{ print $1 }'`
width=`echo $total | wc -c`
date_cmd="date +%FT%T%z"
count=`printf "%${width}d" $curr`
message "$count/$total `$date_cmd`"
while read file
do
  $MD5_CMD $file >> $MANIFEST_FILE
  curr=$(( $curr + 1))
  count=`printf "%${width}d" $curr`
  message "$count/$total  `$date_cmd`  $file"
done < $file_list
message "$count/$total `$date_cmd` $MANIFEST_FILE complete" 

### EXIT
# http://stackoverflow.com/questions/430078/shell-script-templates
rm -f $tmp.?
trap 0
exit 0
