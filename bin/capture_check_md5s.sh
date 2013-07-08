#!/bin/sh

#!/bin/sh

read -r -d '' HELP <<-'EOF'
For the input CAPTURE_DIR find each md5.txt file and check it.

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

tstamp=`date +%Y%m%d-%H%M%z`
log=$CAPTURE_DIR/md5s_check_${tstamp}.log

file_list=$tmp.1
find $CAPTURE_DIR -type f -name md5s.txt > $file_list
# cat $dir_list
count=0
total=`wc -l $file_list | awk '{ print $1 }'`
date_cmd="date +%FT%T%z"
report_count $count $total 0
while read md5_file
do
  message "$md5_file" >> $log
  dir=`dirname $md5_file`
  (
    cd $dir
    md5sum -c md5s.txt >> $log

    )

  # COUNT AND REPORT
  count=$(( $count + 1 ))
  report_count $count $total 0 $file
done < $file_list


### EXIT
# http://stackoverflow.com/questions/430078/shell-script-templates
rm -f $tmp.?
trap 0
exit 0


