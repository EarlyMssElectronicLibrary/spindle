#!/bin/sh

read -r -d '' HELP <<-'EOF'
For an INPUT_DIR of the correct structure, verify all image file have the
corret metadata.
  
Files are expected to have the following metadata values:

* IPTC Source                        - required
* IPTC Object name                   - required
* IPTC Keywords                      - required
* EXIF Creator                       - required
* AP DAT Bits Per Sample             - required
* AP DAT File Processing             - required
* AP DAT File Processing Rotation    - required
* AP DAT Joining Different Parts Of  - required
* AP DAT Joining Same Parts of Folio - required
* AP DAT Processing Comments         - optional
* AP DAT Processing Program          - required
* AP DAT Software Version            - required; "See DAT_Processing Program"
* AP DAT Type of Contrast Adjustment - required
* AP DAT Type of Image Processing    - required
* AP ID Parent File                  - required


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
   echo "   -v             Display Spindle version"
   echo ""
}

help() {
  echo "$HELP"
  echo ""
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
# file types we'll look at
FILE_TYPES="jpg JPG jpeg JPEG tiff TIFF tif TIF"
file_types=$tmp.1
for x in $FILE_TYPES; do echo $x; done > $file_types
# TAGS
REQUIRED_TAGS="Creator
Source
Keywords
ObjectName
DAT_Bits_Per_Sample
DAT_File_Processing
DAT_File_Processing_Rotation
DAT_Joining_Different_Parts_Of_Folio
DAT_Joining_Same_Parts_of_Folio
DAT_Processing_Program
DAT_Samples_Per_Pixel
DAT_Type_of_Contrast_Adjustment
DAT_Type_of_Image_Processing
ID_Parent_File"

OPTIONAL_TAGS="DAT_Processing_Comments
Contributor"

SW_VERSION_TAG="DAT_Software_Version"
SW_VERSION_LITERAL="See DAT_Processing_Program"

ROTATION_REGEX="^[0-9][0-9]*$"

## METHODS
get_tag_value() {
  filex=$1
  tagx=$2
  grep "$tagx" $filex | awk -F"	" '{ print $2 }'
}

check_numeric() {
  val=$1
  if echo "$val" | grep "^[0-9.][0-9.]*$" > /dev/null 2>&1 ; then
    echo true
  else
    echo false
  fi
}

check_required() {
  file=$1
  for tag in $REQUIRED_TAGS
  do
    if ! grep "$tag" $file > /dev/null 2>&1 ; then
      echo "$tag"
    fi
  done
}

# report required tags are missing
report_required_missing() {
  file=$1
  shift
  tags="$*"
  for tag in $tags
  do
    msg="$file  REQ_MISSING  $tag"
    error_no_exit "$msg"
  done
}

check_optional() {
  file=$1
  for tag in $OPTIONAL_TAGS
  do
    if ! grep "$tag" $file > /dev/null 2>&1 ; then
      echo "$tag"
    fi
  done
}

report_optional_missing() {
  file=$1
  width=$2
  shift 2
  tags="$*"
  for tag in $tags
  do
    warning "`printf "%-${width}s" $file` OPT_MISSING  $tag"
  done
}

### OPTIONS
while getopts ":hv" opt; do
  case $opt in
    h)
      usage 
      version
      help
      exit 1
      ;;
    v)
      version
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

### VERIFY METADATA
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

file_list=$tmp.2
find data -type f > $file_list
file_width=`awk '{ if (length($1) > max) { max = length($1) } } END { print max }' $file_list`
skipped=$tmp.3
metadata_file_tmp=$tmp.4
metadata_file=$tmp.5

curr=0
good=0
fails=
total=`wc -l $file_list | awk '{ print $1 }'`
checked=$total
width=`echo $total | wc -c`
count=`printf "%${width}d" $curr`
while read file
do
  curr=$(( $curr + 1 ))
  ext=`echo $file | awk -F'.' '{ print $NF }'`
  if grep "$ext" $file_types >/dev/null 2>&1 ; then
    if basename $file | grep "^[0-9][0-9][0-9][0-9]" >/dev/null 2>&1 ; then

      # VALID FILES TO CHECK
      exiftool -args $file | while read line
      do
        tag=`echo $line | awk -F'=' '{ print $1 }' | sed 's/^-//'`
        value=`echo $line | sed "s/^-${tag}=//"`
        echo "$tag	$value"
      done > $metadata_file

      # REQUIRED TAGS
      required_missing=`check_required $metadata_file`
      if [ -n "$required_missing" ]; then
        fails="$fails $file"
        report_required_missing $file $required_missing
        error_flag="REQ"
      fi

      # LITERALS
      if ! grep "$SW_VERSION_TAG\s$SW_VERSION_LITERAL" $metadata_file >/dev/null 2>&1 ; then
        msg="$file  $SW_VERSION_TAG should be \"$SW_VERSION_LITERAL\""
        error_no_exit "$msg"
        log_error "$msg"
        error_flag="LIT"
      fi

      # DATA FORMAT
      rotation=`get_tag_value $metadata_file "DAT_File_Processing_Rotation"`
      numeric=`check_numeric "$rotation"`
      if ! $numeric ; then
        msg="$file  DAT_File_Processing_Rotation  NON-NUMERIC: '$rotation'"
        error_no_exit "$msg"
        log_error "$msg"
        error_flag='NUM'
      fi

      # OPTIONAL TAGS
      optional_missing=`check_optional $metadata_file`
      if [ -n "$optional_missing" ]; then
        report_optional_missing $file $file_width $optional_missing
      fi

      # if we've hit no errors, increment the good counter
      if [ "$error_flag" = "" ]; then
        good=$(( $good + 1 ))
      fi
    else
      # FILE HAS A FUNNY NAME; SKIP IT
      checked=$(( $checked - 1 ))
      warning "`printf "%-${file_width}s" $file` UNEXPECTED NAME FORMAT SKIPPED" 
    fi
  else
    # FILE DOESN'T HAVE THE RIGHT EXTESION; SKIP IT
    checked=$(( $checked - 1 ))
    warning "`printf "%-${file_width}s" $file` UKNOWN FILE TYPE" 
  fi
  # always unset the error_flag to 
  error_flag=
done < $file_list

if [ $total -ne $checked ]; then
  num=$(( $total - $checked ))
  warning "$num of $total files were SKIPPED"
fi

message "$good of $checked files had no errors "

if [ $good -ne $checked ]; then
  num=$(( $checked - $good ))
  error_no_exit "$num of $checked files had metadata errors"
  log "ERRORS_FOUND"
  exit 1
fi

log "ALL_VALID"
message "Completion logged to `pwd`/$logfile"
success "$good of $checked files had no errors"


### EXIT
# http://stackoverflow.com/questions/430078/shell-script-templates
rm -f $tmp.?
trap 0
exit 0
