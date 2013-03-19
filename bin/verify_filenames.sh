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

 * that all file are of the correct type: JPEG, TIFF, DNG
 * that all file names have the correct extension: 'jpg', 'tif', or 'dng'
 * that all file names have the correct format

In 'Delivery' mode (the default) this script wll generate a log file
`DLVRY_filenames.log`. This file will list all file names found in the `data`
directory, giving:

 - a code VALID for a valid filename, or  BAD_SHOT_SEQ, BAD_SHOOT_LIST,
   BAD_PROCESSOR, BAD_PROC_TYPE, BAD_MODIFIERS, BAD_EXTENSTION, or
   BAD_FILE_TYPE for a file with an error

 - the relative path of the file; e.g.,
   `data/Processed_Images/0015_000012_KTK_sharpie_MB365UV-MB625Rd.jpg`

The last line of the file will be a timestamped message: 'ALL VALID' or 'ERRORS
FOUND'.

In 'Delivery' mode this script will refuse to overwrite the DLVRY_filenames.log
file.

In 'Receipt' mode (using the -R flag) this script will confirm the existence of
the file 'DLVRY_filenames.log', and that its last line contains the text 'ALL
VALID'. It will then confirm that all files in `data` are named correctly, and
the list of files in 'DLVRY_filenames.log' matches the list of file in `data` 
exactly. These last steps ensure against tampering.
 
# VALID FILE NAME CHARACTERS

Valid characters are:

   ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz1234567890_-+

First order fields are divided by underscores: _
Second order fields are divided by dashes: -
Fields may not begin or end with: - or +

For use of the plus sign '+' and dash '-' please see the Data Delivery
Recommendations document.  Note that this is a valid field '..._GOOD-FIELD_...';
while this is not: '..._+BAD-FIELD-_'.

# VALID FILE NAME FORMAT

The correct file names have these fields:

    <SHOOT_LIST>_<SHOT_SEQ>_<PROCESSOR>_<PROCESSING_TYPE>_<MODIFIERS>.ext

Where:

  * SHOOT_LIST is a 4-digit string, right-padded with zeros: '0009'

  * SHOT_SEQ is a 6-digit string, right-padded with zeros: '000123'

  * PROCESSOR is  3-character string: 'WCB'; all characters must be alphabetic

  * PROCESSING_TYPE is string composed of valid file name characters, except
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
trap "rm -f $tmp.?; exit 1" 1 2 3 13 15
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
   echo "   -v             Display Spindle version"
   echo "   -R             Run in Receipt mode"
   echo ""
}

help() {
  echo "$HELP"
  echo ""
}

# usage: validateFilenames LIST_OF_FILES DELIVERY_LOG
# 
# Where LIST_OF_FILES is a file listing all filenames to validate; and DELIVERY_LOG
# is where to log the results. Returns 0 if all files valid; 1 otherwise.
this_dir=`dirname $0`
this_dir=`(cd $this_dir; pwd)`
VALIDATE_FILENAME=$this_dir/verify_filename
if [ ! -x $VALIDATE_FILENAME ]; then
  error "Command not found $VALIDATE_FILENAME"
fi

validateFilenames() {
  files=$1
  working_log=$2
  curr=0
  total=`wc -l $file_list | awk '{ print $1 }'`
  status=0
  message "`printf "%5d" $curr`/$total `$date_cmd`"
  while read file
  do
    curr=$(( $curr + 1))
    # call spindle_function validateFilename()
    result=`$VALIDATE_FILENAME $file`
    code=`echo $result | awk '{ print $1 }'`
    # change the code to 1 if we get a bad file
    if echo "$code" | grep "^BAD_" >/dev/null 2>&1 ; then
      log_invalid $working_log "$result"
      status=1
    else
      log_valid $working_log "$result"
    fi
  done < $file_list
  message "`printf "%5d" $curr`/$total `$date_cmd`"

  return $status
}

### CONSTANTS
### VARIABLES
# the input dir
INPUT_DIR=
# the data directory
DATA_DIR=
DELIVERY_LOG=DLVRY_filenames.log
RECEIPT_LOG=RECPT_filenames.log

### OPTIONS
while getopts ":hvR" opt; do
  case $opt in
    h)
      usage 
      version
      help
      exit 0
      ;;
    v)
      version
      exit 1
      ;;
    R)
      RECEIPT_MODE=true
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
INPUT_DIR=`input_dir $1`
message "INPUT_DIR is $INPUT_DIR"
# make sure there's a data directory in INPUT_DIR
DATA_DIR=`data_dir $INPUT_DIR`

# change to the input dir
if [ "$INPUT_DIR" != "." ]; then
  cd $INPUT_DIR
fi

### VERIFY FILENAMES
file_list=$tmp.1
manifest=manifest-md5s.txt
# check log file
if [ "$RECEIPT_MODE" ]; then
  if [ -f $manifest ]; then
    if ! write_file_list $manifest $file_list ; then
      error "Unable to get file list from $manifest"
    fi
  else
    error "No manifest file found `pwd`/$manifest"
  fi
else
  if [ -f $DELIVERY_LOG ]; then
    error "DELIVERY MODE: will not overwrite $DELIVERY_LOG"
  else
    message "DELIVERY MODE: creating new log file $DELIVERY_LOG"
  fi
fi


logged_files=$tmp.2
date_cmd="date +%FT%T%z"

if [ "$RECEIPT_MODE" ]; then
  message "Running in RECEIPT MODE"
  # double check the file names
  message "Confirming filename validation"
  if validateFilenames $file_list $RECEIPT_LOG ; then
    echo "ALL_VALID" >> $RECEIPT_LOG
    message "ALL_VALID"
  else
    fail "ERRORS_FOUND see `pwd`/$RECEIPT_LOG"
  fi

else
  message "Running in DELIVERY MODE"

  find data -type f | sort > $file_list
  total=`wc -l $file_list | awk '{ print $1 }'`
  if validateFilenames $file_list $DELIVERY_LOG ; then
    echo "ALL_VALID  `$date_cmd`" >> $DELIVERY_LOG
  fi
 

  warnings=$tmp.5
  grep WARNING $DELIVERY_LOG > $warnings
  if [ -s $warnings ]; then
    num=`wc -l $warnings | awk '{ print $1 }'`
    warning "there were $num WARNINGS"
    while read line
    do
      warning "    $line"
    done < $warnings
  fi

  bad_file_names=$tmp.4
  grep "BAD_" $DELIVERY_LOG > $bad_file_names
  if [ -s $bad_file_names ]; then
    num=`wc -l $bad_file_names | awk '{ print $1 }'`
    while read line
    do
      error_no_exit "$line"
    done < $bad_file_names
    error_no_exit "$num of $total files had bad names"
  fi

  good=`grep "^VALID" $DELIVERY_LOG | wc -l`
  message "$good of $total files had VALID file names"

  if [ -s $bad_file_names ]; then
    echo "ERRORS_FOUND" >> $DELIVERY_LOG
    fail "ERRORS_FOUND"
  fi
fi

### EXIT
# http://stackoverflow.com/questions/430078/shell-script-templates
rm -f $tmp.?
trap 0
exit 0
