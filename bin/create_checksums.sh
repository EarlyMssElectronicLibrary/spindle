#!/bin/sh

read -r -d '' HELP <<-'EOF'
Create manifests for all TIFF and JPEG files in each directory in DIR_LIST or
the directory passed to the '-d' flag.  Directories are NOT handled
recursively. One manifest will be created for each folder containing files.
Thus a DIR_LIST with this content:

   ./dir1
   ./dir2
   ./dir3
   ...

will generate the following manifest files:

   dir1/
      file1.jpg
      file2.jpg
      manifest-md5s.txt
   dir2/
      file3.jpg
      file4.jpg
      manifest-md5s.txt
   dir3/
      ...

Each manifest-md5s.txt file will look like this:

   9cd129974aeb50cb890a2505161177d0 file1.jpg
   484c05e7dbc10e9c1671d6b7ab7a09fa file2.jpg

This script is written for Mac OSs md5 command and runs md5 with '-r'
option to ensure output of the format above, which is the standard idiom for
md5 checksums. The default output of Mac OSs md5 command is different.
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
   echo "   -d IMAGE_DIR   Directory to create the manifest in. DIR_LIST"
   echo "                  argument will be ignored."
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

### VARIABLES

# a directory of images, arg to -d option
IMAGE_DIR=
# the user DIR_LIST argument; it is ignored if DIR_LIST
DIR_LIST=
# the list file the script uses
WORKING_LIST=
# the name of the manifest in each dir
MANIFEST_FILE=manifest-md5s.txt

### OPTIONS
while getopts ":hd:" opt; do
  case $opt in
    h)
      usage 
      help
      exit 1
      ;;
    d)
      IMAGE_DIR=$OPTARG
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
# grab argument 1; it may be empty; if needed, we check for that below
DIR_LIST=$1

### get the WORKING_LIST
if [ -n "$IMAGE_DIR" ]; then
  if [ ! -d "$IMAGE_DIR" ]; then
    error "Option IMAGE_DIR is not a directory: '$IMAGE_DIR'"
  fi
  WORKING_LIST=$tmp.1
  echo "$IMAGE_DIR" > $WORKING_LIST
  if [ -n "$DIR_LIST" ]; then
    warning "Found IMAGE_DIR '$IMAGE_DIR' ignoring DIR_LIST '$DIR_LIST'"
  fi
elif [ -n "$DIR_LIST" ]; then
    if [ ! -f $DIR_LIST ]; then
      error "Directory listing not found: $DIR_LIST"
    fi
    WORKING_LIST=$DIR_LIST
else
  error "Please provide a DIR_LIST or IMAGE_DIR"
fi

# CHECK THE DIRECTORY LISTING
message "Checking directories"
BAD_DIRS=
CHECKSUM_FILES=
while read dir
do
  if [ ! -d $dir ]; then
    BAD_DIRS="$BAD_DIRS $dir"
  elif [ -f "$dir/$MANIFEST_FILE" ]; then
    CHECKSUM_FILES="$CHECKSUM_FILES $dir/$MANIFEST_FILE"
  fi
done < $WORKING_LIST
dir=


if [ -n "$BAD_DIRS" -o -n "$CHECKSUM_FILES" ]; then
  error_no_exit "The following errors were found:"
  for dir in $BAD_DIRS
  do
    error_no_exit "Not a valid diretory: $dir"
  done
  for file in $CHECKSUM_FILES
  do
    error_no_exit "Checksum file exists: $file"
  done
  error "Please correct directory listing"
fi
dir=
file=

### EXIT
# http://stackoverflow.com/questions/430078/shell-script-templates
rm -f $tmp.?
trap 0
exit 0
