#!/bin/sh

read -r -d '' HELP <<-'EOF'

Add metadata to each TIFF and JPEG in `PACKAGE_DIR/data`.

This script will add the following metadata tags

    IPTC Source                        - required
    IPTC Object name                   - required
    IPTC Keywords
        - Resolution (PPI)               - required
        - Postion                        - required
    EXIF Creator                       - required
    AP DAT Bits Per Sample             - required
    AP DAT File Processing             - required
    AP DAT File Processing Rotation    - required
    AP DAT Joining Different Parts Of  - required
    AP DAT Joining Same Parts of Folio - required
    AP DAT Processing Comments         - optional
    AP DAT Processing Program          - required
    AP DAT Software Version            - required; `See DAT_Processing Program`
    AP DAT Type of Contrast Adjustment - required
    AP DAT Type of Image Processing    - required
    AP ID Parent File                  - required


EOF
# functions
SHOT_SEQ_PATTERN="^[0-9][0-9][0-9][0-9]_[0-9][0-9][0-9][0-9][0-9][0-9]$"
valid_shot_sequence() {
  echo "$1" | grep "$SHOT_SEQ_PATTERN" > /dev/null
}

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
   echo "Usage: $cmd [-h] PACKAGE_DIR"
   echo ""
   echo "OPTIONS"
   echo ""
   echo "   -h             Display help message"
   echo "   -v             Display Spindle version"
   echo ""
}

### CONSTANTS

### VARIABLES
IN_DIR=
OUT_DIR=

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
# the PACKAGE_DIR
PACKAGE_DIR=$1
if dir_exists $PACKAGE_DIR
then
  message "Using PACKAGE_DIR $PACKAGE_DIR"
else
  error "PACKAGE_DIR not found"  
fi

# The DATA_DIR
DATA_DIR=$PACKAGE_DIR/data
if dir_exists $DATA_DIR ; then
  message "Using DATA_DIR: $DATA_DIR"
else
  error "DATA_DIR not found"
fi


# Extract the following from <PACKAGE_DIR>/data/<SHOT_SEQ>_uv_exif.txt
#    IPTC Source                        - required
#    IPTC Object name                   - required
#    IPTC Keywords
#        - Resolution (PPI)             - required
#        - Postion                      - required

# Get EXIF creator from ?

# Get the following as described
#
# AP DAT Bits Per Sample - '8'
# AP DAT Samples Per Pixel - '3'
# AP DAT File Processing - Get from Ken
# AP DAT File Processing Rotation - Get from UV EXIF
# AP DAT Joining Different Parts Of Folio - 'false'
# AP DAT Joining Same Parts of Folio - 'true'
# AP DAT Processing Comments - [blank]
# AP DAT Processing Program - Get from Ken (color file header?)
# AP DAT Software Version - Get from Ken (color file header?)
# AP DAT Type of Contrast Adjustment - Get from Ken
# AP DAT Type of Image Processing - Get from Ken
# AP ID Parent File - Get from Ken (color file header?)



### EXIT
# http://stackoverflow.com/questions/430078/shell-script-templates
rm -f $tmp.?
trap 0
exit 0
