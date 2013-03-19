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
   echo "Usage: $cmd [-h] INPUT_DIR"
   echo ""
   echo "OPTIONS"
   echo ""
   echo "   -R             Run in Receipt mode"
   echo "   -h             Display help message"
   echo "   -v             Display Spindle version"
   echo ""
}


### CONSTANTS
# the name of the manifest in each dir
# image file extensions
FILE_TYPES="jpg JPG jpeg JPEG tiff TIFF tif TIF"
STANDARD_EXTS="jpg tif"
this_dir=`dirname $0`
this_dir=`(cd $this_dir; pwd)`
VERIFY_METADATA=$this_dir/verify_metadata

### VARIABLES
# the input dir
INPUT_DIR=
# the data directory
DATA_DIR=
DELIVERY_LOG=DLVRY_metadata.log
RECEIPT_LOG=RECPT_metadata.log
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
while getopts ":hvR" opt; do
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
if [ $? -ne 0 ]; then
  error "Error finding input directory"
fi
message "INPUT_DIR is $INPUT_DIR"

# make sure there's a data directory in INPUT_DIR
DATA_DIR=`data_dir $INPUT_DIR`
if [ $? -ne 0 ]; then
  error "Error finding data directory"
fi

# change to the input dir
if [ "$INPUT_DIR" != "." ]; then
  cd $INPUT_DIR
fi

### VERIFY METADATA
file_list=$tmp.2
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
  find data -type f | sort > $file_list
fi

file_width=`awk '{ if (length($1) > max) { max = length($1) } } END { print max }' $file_list`
skipped=$tmp.3
metadata_file_tmp=$tmp.4
metadata_file=$tmp.5
results=$tmp.6

if [ "$RECEIPT_MODE" ]; then
  export logfile=$RECEIPT_LOG
else
  export logfile=$DELIVERY_LOG
fi

total=`wc -l $file_list | awk '{ print $1 }'`
checked=$total
count=0
while read file
do
  report_count $count $total 100
  ext=`echo $file | awk -F'.' '{ print $NF }'`
  if grep "$ext" $file_types >/dev/null 2>&1 ; then
    $VERIFY_METADATA $file > $results
    exit_status=$?
    while read line
    do
      if [ $exit_status -eq $? ]; then
        log_valid $logfile "$line"
      else
        log_invalid $logfile "$line"
      fi
    done < $results
    exit_status=
    : > $results
  else
    # FILE DOESN'T HAVE THE RIGHT EXTESION; SKIP IT
    checked=$(( $checked - 1 ))
    warning "`printf "%-${file_width}s" $file` UKNOWN FILE TYPE" 
  fi
  # # always unset the error_flag to 
  # error_flag=
  count=$(( $count + 1 ))
done < $file_list
report_count $count $total 0

message "$checked of $total files were checked"
if [ $total -ne $checked ]; then
  num=$(( $total - $checked ))
  warning "$num of $total files were SKIPPED"
fi

good=`grep "^VALID" $logfile | awk '{ print $3 }' | sort | uniq | wc -l`
good=`echo $good | sed 's! *!!g'`

if [ $good -ne $checked ]; then
  num=$(( $checked - $good ))
  msg="$num of $checked checked files had metadata errors"
  warning "$msg"
  log "$msg"
  log "ERRORS_FOUND"
  fail "ERRORS_FOUND see `pwd`/$logfile"
else
  message "0 of $total files had metadata errors"
fi

log "ALL_VALID"
message "Completion logged to `pwd`/$logfile"
success "$good of $checked files had no errors"


### EXIT
# http://stackoverflow.com/questions/430078/shell-script-templates
rm -f $tmp.?
trap 0
exit 0
