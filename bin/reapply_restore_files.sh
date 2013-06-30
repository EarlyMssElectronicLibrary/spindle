#!/bin/sh

read -r -d '' HELP <<-'EOF'

Restore fixed files from IMAGE_DIR to RAWS_DIR.

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

# FUNCTIONS

# Function to clean and mark this package with errors
# 
#  Usage: delivery_failure VALIDATING_FLAG ERRORS_FLAG MESSAGE
#
# Deletes VALIDATING_FLAG; and write MESSAGE to ERRORS_FLAG
delivery_failure() {
  df_validating_flag=$1
  df_errors_flag=$2
  msg="$3"
  rm -f $df_validating_flag
  echo "$msg" > $df_errors_flag
  fail "$msg"
}

# Function to clean up and print a success message
delivery_success() {
  ds_validating_flag=$1
  msg="$2"
  rm -f $ds_validating_flag
  success "$msg"
}

#### USAGE AND ERRORS
cmd=`basename $0 .sh`
export SPINDLE_COMMAND=$cmd
source `dirname $0`/spindle_functions

usage() {
   echo "Usage: $cmd [options] IMAGE_DIR RAWS_DIR"
   echo ""
   echo "OPTIONS"
   echo ""
   echo "   -h             Display help message"
   echo "   -v             Display Spindle version"
   echo ""
}

this_dir=`dirname $0`
this_dir=`(cd $this_dir; pwd)`

### CONSTANTS
### VARIABLES
# the package dir
IMAGE_DIR=`dir_exists $1 IMAGE_DIR`
if [ $? -ne 0 ]; then
  error "Error finding IMAGE_DIR"
fi
# the data directory
RAWS_DIR=`dir_exists $2 RAWS_DIR`
if [ $? -ne 0 ]; then
  error "Error finding RAWS_DIR"
fi

### OPTIONS
while getopts ":hvCT" opt; do
  case $opt in
    h)
      usage 
      version
      help
      exit 0
      ;;
    v)
      version
      exit 0
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

tmp_md5_file=$tmp.1
tmp_check_file=$tmp.2
tstamp=`iso_date`
SEQS=
for x in $IMAGE_DIR/*.dng
do
  seq=`basename "$x" | awk -F+ '{ print $1 }'`
  SEQS="$SEQS $seq"
done
seq=
for seq in $SEQS
do
  # find the destination dir for each sequence
  dest=$RAWS_DIR/$seq
  # backup the md5s_v2.txt file
  md5_file=$dest/md5s_v2.txt
  md5_backup=$md5_file.$tstamp
  cp -v $md5_file $md5_backup

  # copy the new files for this seq and their md5s 
  for file in $IMAGE_DIR/${seq}*.dng
  do
    cp -v $file $dest
    cp -v $file.md5 $dest
    base=`awk '{ print $2 }' $file.md5`
    new_md5=`awk '{ print $1 }' $file.md5`
    old_md5=`grep $base $md5_file | awk -F\; '{ print $4 }'`
    sed "s/$old_md5/$new_md5/" $md5_file > $tmp_md5_file
    if cmp -s $md5_file $tmp_md5_file ; then
      error "MD5 file not changed"
    else
      cp -v $tmp_md5_file $md5_file
    fi
  done

  awk -F\; '{ print $4 "  " $1 }' $md5_file > $tmp_check_file
  
  (
    cd $dest
    md5sum -c $tmp_check_file
  )

done

### EXIT
# http://stackoverflow.com/questions/430078/shell-script-templates
rm -f $tmp.?
trap 0
exit 0





