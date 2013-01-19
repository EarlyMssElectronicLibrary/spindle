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
For an INPUT_DIR of the correct structure, verify its integrity. INPUT_DIR must
contain at its root a 'data' directory and a manifest file 'manifest-md5s.txt';
thus,
      .
      ├── data
      │   ├── dir1
      │   │   ├── file1.tif
      │   │   ├── ...
      │   └── dir2
      │       ├── ...
      └── manifest-md5s.txt

This command will verify the following:

  * each file listed in the manifest exists
  * each file in the 'data' occurs in the manifest
  * each file in 'data' matches its manifest checkum

The manifest file must have one checksum on each line. Each line should be the
digest, followed by one space, two spaces, or one space and an asterisk,
followed by the path to the file. Thus:

      44943bbb7d369448027783b67fa579e1 data/dir1/file1.tif
      8f55980b0490ec47c20ccd0677b2ab1d data/dir2/file4.jpg
      ...

Note that there the data file path does not begin with a dot './data/...'.

Be aware that different MD5 commands produce different ouptput formats. The
above was produced using Mac OS command 'md5' with the '-r' option (reverse),
'md5 -r ARG'. Normal Mac OS 'md5' output is atypical and is not valid:

      # THIS FORMAT IS NOT VALID:
      MD5 (data/dir1/file1.tif) = 44943bbb7d369448027783b67fa579e1

GNU md5sum and GNU coreutils 'gmd5sum' produce output with two spaces. 

      $ gmd5sum data/dir1/file1.tif 
      44943bbb7d369448027783b67fa579e1  data/dir1/file1.tif

The second space is will be an '*' when the -b/--binary option is used:

      $ gmd5sum -b data/dir1/file1.tif 
      44943bbb7d369448027783b67fa579e1 *data/dir1/file1.tif
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
   echo "Usage: $cmd [-h] [INPUT_DIR]"
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
logfile=LOG_${cmd}.log

log() {
    echo "`date +%Y-%m-%dT%H:%M:%S` [$cmd] $1" >> $logfile
}

error_file=ERROR_${cmd}.log

log_error() {
  echo "`date +%Y-%m-%dT%H:%M:%S` [$cmd] $1" >> $error_file
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
# first, find an MD5 command
MD5_CMD=
if which md5sum >/dev/null 2>&1 ; then
  MD5_CMD=`which md5sum`
elif which gmd5sum >/dev/null 2>&1 ; then
  MD5_CMD=`which gmd5sum`
elif which md5 >/dev/null 2>&1 ; then
  MD5_CMD=`which md5`
else
  error "MD5 command not found; looked for gmd5sum, md5sum, md5"
fi
message "Using MD5 command: $MD5_CMD"

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

# make sure the manifest exists
if [ ! -f $INPUT_DIR/$MANIFEST_FILE ]; then
  error "No manifest found in $INPUT_DIR"
fi

# make sure the md5 file is a valid format
valid_format="[0-9a-zA-Z][0-9a-zA-Z][0-9a-zA-Z][0-9a-zA-Z][0-9a-zA-Z][0-9a-zA-Z][0-9a-zA-Z][0-9a-zA-Z][0-9a-zA-Z][0-9a-zA-Z][0-9a-zA-Z][0-9a-zA-Z][0-9a-zA-Z][0-9a-zA-Z][0-9a-zA-Z][0-9a-zA-Z][0-9a-zA-Z][0-9a-zA-Z][0-9a-zA-Z][0-9a-zA-Z][0-9a-zA-Z][0-9a-zA-Z][0-9a-zA-Z][0-9a-zA-Z][0-9a-zA-Z][0-9a-zA-Z][0-9a-zA-Z][0-9a-zA-Z][0-9a-zA-Z][0-9a-zA-Z][0-9a-zA-Z][0-9a-zA-Z] [ *]\?[0-9a-zA-Z_/.-][0-9a-zA-Z_/.-]*"
if grep "^MD5" $INPUT_DIR/$MANIFEST_FILE > /dev/null 2>&1 ; then
  error_no_exit "This looks like a Mac OS md5 command file; please use 'md5 -r'"
  error "manifest file format not valid"
elif grep -v "$valid_format" $INPUT_DIR/$MANIFEST_FILE >/dev/null 2>&1 ; then
  error "manifest file format not valid"
fi

### VERIFY MANIFEST
# change to the input dir
if [ "$INPUT_DIR" != "." ]; then
  cd $INPUT_DIR
fi

# clean up the logs
if [ -f $logfile ]; then
  message "Deleting previous log file `pwd`/$logfile"
  rm $logfile
fi
if [ -f $error_file ]; then
  message "Deleting previous error file `pwd`/$error_file"
  rm $error_file
fi

### VERIFY FILE LISTS
# make sure all 'data' files listed in manifest
data_files=$tmp.1
find data -type f | sort > $data_files
file_width=`awk '{ if (length($1) > max) { max = length($1) } } END { print max }' $data_files`

manifest_files=$tmp.2
awk '{ print $2 }' $MANIFEST_FILE | sed 's/\*//' | sort > $manifest_files
diff_file=$tmp.3

# run diff
diff $data_files $manifest_files > $diff_file
# if diff errors out, then something's not right; dig out the differences
if [ $? -ne 0 ]; then
  error_no_exit "Manifest does not match directory contents"

  NOT_LISTED=`grep "^<" $diff_file | sed 's/<//'`
  for file in $NOT_LISTED
  do
    msg="`printf "%-${file_width}s" $file` NOT IN MANIFEST"
    log_error "$msg"
    error_no_exit "$msg"
  done

  NOT_FOUND=`grep "^>" $diff_file | sed 's/>//'`
  for file in $NOT_FOUND
  do
    msg="`printf "%-${file_width}s" $file` NO SUCH FILE"
    log_error "$msg"
    error_no_exit "$msg"
  done
  message "Errors logged to `pwd`/$error_file"
  fail "MANIFEST LIST DOES NOT MATCH data DIRECTORY CONTENTS"
fi

### VERIFY THE CHECKSUMS
# see if we can find md5sum or gmd5sum

if echo "$MD5_CMD" | grep "md5sum" >/dev/null 2>&1 ; then
  message "Checking $INPUT_DIR/$MANIFEST_FILE with $MD5_CMD"
  # run the command
  $MD5_CMD -c $MANIFEST_FILE
  if [ $? -eq 0 ]; then
    log "ALL VALID"
    message "Completion logged to `pwd`/$logfile"
    success "data is valid"
  else
    log_error "ERRORS FOUND"
    message "Errors logged to `pwd`/$error_file"
    fail "ERRORS FOUND"
  fi
fi

# if we got this far, we have to use md5 and check each entry individually 
bad_checksum=
while read file
do
  line=`$MD5_CMD -r $file`
  sum=`echo $line | awk '{ print $1 }'`
  path=`echo $line | sed 's/\*//' | awk '{ print $2 }'`
  if grep "$sum [* ]\?$path" $MANIFEST_FILE >/dev/null 2>&1 ; then
    echo "$file: OK"
  else
    echo "$file: FAILED"
    bad_checksum="$bad_checksum $file"
  fi
done < $data_files

if [ -n "$bad_checksum" ]; then
  log_error "ERRORS FOUND"
  message "Errors logged to `pwd`/$error_file"
  fail "ERRORS FOUND"
else
  log "ALL VALID"
  message "Completion logged to `pwd`/$logfile"
  success "data is valid"
fi

### EXIT
# http://stackoverflow.com/questions/430078/shell-script-templates
rm -f $tmp.?
trap 0
exit 0
