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

   ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz1234567890_-+

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
# image file extensions
FILE_TYPES="jpg JPG jpeg JPEG tiff TIFF tif TIF"
STANDARD_EXTS="jpg tif"

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

### VERIFY FILENAMES
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

file_list=$tmp.1
find data -type f > $file_list
file_width=`awk '{ if (length($1) > max) { max = length($1) } } END { print max }' $file_list`
file_types=$tmp.2
for x in $FILE_TYPES; do echo $x; done > $file_types
standard_exts=$tmp.3
for x in $STANDARD_EXTS; do echo $x; done > $standard_exts

# SHOOT_LIST
VALID_CHARS="[ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz1234567890_+-]"
VALID_FIELD_CHARS="[ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz1234567890+-]"
SHOOT_LIST="[0-9][0-9][0-9][0-9]"
SHOT_SEQ="[0-9][0-9][0-9][0-9][0-9][0-9]"
PROCESSOR="[a-zA-Z][a-zA-Z][a-zA-Z]"

file_shoot_list="^${SHOOT_LIST}_"
file_shot_seq="${file_shoot_list}${SHOT_SEQ}_"
file_processor="${file_shot_seq}${PROCESSOR}_"
file_proc_type="${file_processor}${VALID_FIELD_CHARS}${VALID_FIELD_CHARS}*"
file_modifiers="${file_proc_type}_\?${VALID_CHARS}${VALID_CHARS}*$"

date_cmd="date +%FT%T%z"
bad_file_names=$tmp.4
warnings=$tmp.5
skipped=$tmp.6
curr=0
good=0
total=`wc -l $file_list | awk '{ print $1 }'`
checked=$total
width=`echo $total | wc -c`
count=`printf "%${width}d" $curr`
message "$count/$total `$date_cmd`"
while read file
do
  curr=$(( $curr + 1))
  base=`basename $file`
  # HIDDEN FILES
  if echo $base | grep "^\." >/dev/null 2>&1 ; then
    echo "SKIPPED `printf "%-15s" "HIDDEN_FILE"` $base" >> $skipped
    checked=$(( $checked - 1))
  # REGULAR FILES
  else
    ext=`echo $base | awk -F'.' '{ print $NF }'`
    if grep "^$ext$" $file_types >/dev/null 2>&1 ; then
      if ! grep "^$ext$" $standard_exts >/dev/null 2>&1 ; then
        echo "`printf "%-10s" "NON_STD_EXT"` $base" >> $warnings
      fi

      # THESE WE CHECK
      core=`basename $base ".$ext"`
      if ! echo "$core" | grep "$file_shoot_list" > /dev/null 2>&1 ; then
        echo "`printf "%-${file_width}s" $file`  BAD_SHOOT_LIST" >> $bad_file_names
      elif ! echo "$core" | grep "$file_shot_seq" > /dev/null 2>&1 ; then
        echo "`printf "%-${file_width}s" $file`  BAD_SHOT_SEQ" >> $bad_file_names
      elif ! echo "$core" | grep "$file_processor" > /dev/null 2>&1 ; then
        echo "`printf "%-${file_width}s" $file`  BAD_PROCESSOR" >> $bad_file_names
      elif ! echo "$core" | grep "$file_proc_type" > /dev/null 2>&1 ; then
        echo "`printf "%-${file_width}s" $file`  BAD_PROC_TYPE" >> $bad_file_names
      elif ! echo "$core" | grep "$file_modifiers" > /dev/null 2>&1 ; then
        echo "`printf "%-${file_width}s" $file`  BAD_MODIFIERS" >> $bad_file_names
      else
        good=$(( $good + 1 ))
      fi

    else
      echo "SKIPPED `printf "%-15s" "INVALID_TYPE"` $base" >> $skipped
      checked=$(( $checked - 1 ))
    fi
  fi
  # print count and time every 1000 files
  if [ $(( $curr % 1000 )) -eq 0 ]; then
    count=`printf "%${width}d" $curr`
    message "$count/$total `$date_cmd`"
  fi
done < $file_list
count=`printf "%${width}d" $curr`
message "$count/$total `$date_cmd`"


if [ -s $warnings ]; then
  num=`wc -l $warnings | awk '{ print $1 }'`
  warning "there were $num WARNINGS"
  while read line
  do
    warning "    $line"
  done < $warnings
fi

if [ -s $bad_file_names ]; then
  num=`wc -l $bad_file_names | awk '{ print $1 }'`
  while read line
  do
    error_no_exit "$line"
    log_error "$line"
  done < $bad_file_names
  error_no_exit "$num of $total files had bad names"
fi

if [ -s $skipped ]; then
  num=`wc -l $skipped | awk '{ print $1 }'`
  warning "$num of $total files were SKIPPED"
  while read line
  do
    message "    $line"
  done < $skipped
fi

message "$good of $checked checked files had VALID file names"

if [ -s $bad_file_names ]; then
  message "Errors logged to `pwd`/$error_file"
  exit 2
fi

# leave a timestamp of when this task finish
log "ALL VALID"
message "Completion logged to `pwd`/$logfile"
success "$good of $checked checked files had VALID file names"

### EXIT
# http://stackoverflow.com/questions/430078/shell-script-templates
rm -f $tmp.?
trap 0
exit 0
