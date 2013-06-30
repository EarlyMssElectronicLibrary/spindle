#!/bin/sh

read -r -d '' HELP <<-'EOF'
For the input CAPTURE_DIR locate the md5s_v2.txt file and create and md5s.txt
file. If an existing md5s.txt file is found, this script will back it up.

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
export SPINDLE_COMMAND=`basename $0`
export HELP
source `dirname $0`/spindle_functions

usage() {
   echo "Usage: $cmd [OPTIONS] CAPTURE_DIR"
   echo ""
   echo "OPTIONS"
   echo ""
   echo "   -h             Display help message"
   echo "   -v             Display Spindle version"
   echo ""
}

### CONSTANTS

### VARIABLES
# the package dir
CAPTURE_DIR=

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
# grab package directoy and confirm it exists
CAPTURE_DIR=$1
if dir_exists $CAPTURE_DIR
then
  message "Using CAPTURE_DIR $CAPTURE_DIR"
else
  error "CAPTURE_DIR not found"
fi

dir_list=$tmp.1
count=0
total=`wc -l $dir_list | awk '{ print $1 }'`
date_cmd="date +%FT%T%z"
report_count $count $total 0
while read dir
do

  # COUNT AND REPORT
  count=$(( $count + 1 ))
  report_count $count $total 0 $file
done < $dir_list


### EXIT
# http://stackoverflow.com/questions/430078/shell-script-templates
rm -f $tmp.?
trap 0
exit 0


