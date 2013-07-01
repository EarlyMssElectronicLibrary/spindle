#!/bin/sh

read -r -d '' HELP <<-'EOF'
For the input CAPTURE_DIR locate the md5s_v2.txt file and create and md5s.txt
file. If an existing md5s.txt file is found, this script will back it up.

Format of md5s_v2.txt file:

    0054_000081+MB365UV_001.dng;100890321;2013-05-20 17:04:49 +0200;cde31091283c72c9f1a903763e3f1c44
    0054_000081+MB455RB_002.dng;100890341;2013-05-20 17:09:56 +0200;9e542105efd8f327ccc7aadab45b3c38

Format of md5s.txt file:

    cde31091283c72c9f1a903763e3f1c44  0054_000081+MB365UV_001.dng
    54fb0e653f16e5bfd786cb4823fb0699  0054_000081+MB700IR_008.dng

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
find $CAPTURE_DIR -type d -name "[0-9][0-9][0-9][0-9]_[0-9][0-9][0-9][0-9][0-9][0-9]" > $dir_list
cat $dir_list
count=0
total=`wc -l $dir_list | awk '{ print $1 }'`
date_cmd="date +%FT%T%z"
tstamp=`date +%FT%H%M%z`
report_count $count $total 0
while read dir
do
  md5_file=$dir/md5s.txt
  v2_file=$dir/md5s_v2.txt

  # back up any existing md5s.txt file
  if [ -f $dir/md5s.txt ]; then
    cp $md5_file $md5_file.$tstamp
    warning "Backed up md5s.txt"
    warning "     from $md5_file"
    warning "       to $md5_file.$tstamp"
  fi

  if [ -f $v2_file ]; then
    # 0054_000081+MB365UV_001.dng;100890321;2013-05-20 17:04:49 +0200;cde31091283c72c9f1a903763e3f1c44
    # cde31091283c72c9f1a903763e3f1c44  0054_000081+MB365UV_001.dng
    awk -F ';' '{ print $4  "  " $1 }' $v2_file
  else
    error_no_exit "File not found: $v2_file"
  fi

  # COUNT AND REPORT
  count=$(( $count + 1 ))
  report_count $count $total 1
done < $dir_list


### EXIT
# http://stackoverflow.com/questions/430078/shell-script-templates
rm -f $tmp.?
trap 0
exit 0


