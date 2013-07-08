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
find $CAPTURE_DIR -type d -name "[0-9][0-9][0-9][0-9]_[0-9][0-9][0-9][0-9][0-9][0-9]" > $dir_list
# cat $dir_list
count=0
total=`wc -l $dir_list | awk '{ print $1 }'`
tstamp=`date +%Y%m%d-%H%M%z`
date_cmd="date +%FT%T%z"
report_count $count $total 0
while read dir
do
  v2_file=$dir/md5s_v2.txt
  md5s_file=$dir/md5s.txt
  if [ -f $v2_file ]; then
    echo $v2_file
    
    if [ -f $md5s_file ]; then
      md5s_bak=$md5s_file.$tstamp
      warning "Backing up md5s.txt file"
      warning "        from: $md5s_file"
      warning "          to: $md5s_bak"
      cp $md5s_file $md5s_bak
    fi
    awk -F';' '{ print $4 "  " $1 }' $v2_file > $md5s_file
    message "Wrote: $md5s_file"
  else
    warning "Not found: $v2_file"
  fi

  # COUNT AND REPORT
  count=$(( $count + 1 ))
  report_count $count $total 0
done < $dir_list


### EXIT
# http://stackoverflow.com/questions/430078/shell-script-templates
rm -f $tmp.?
trap 0
exit 0


