#!/bin/sh

read -r -d '' HELP <<-'EOF'
Create a list of new names for the color images in DIR. 

A color file like 

* 0030_000076+MB365UV_CCD_CCC-RC0905.tif

Will be give a new name of:

* 0030_000076_PSH_color.tif

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
   echo "Usage: $cmd [-h] DIR"
   echo ""
   echo "OPTIONS"
   echo ""
   echo "   -h             Display help message"
   echo "   -v             Display Spindle version"
   echo ""
}

### CONSTANTS

### VARIABLES

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
DIR=`package_dir $1`
if [ $? -ne 0 ]; then
  error "Error finding directory"
fi

### HARVEST METADATA
# change to the package dir

file_list=$tmp.1
# get all non-hidden files
find $DIR -type f -name \*_CCD_CCC-\*.tif | sort > $file_list
file_count=`wc -l $file_list | awk '{ print $1 }' | sed 's/ *//g'`
# get the page directory name

copy_script=$tmp.2
: > $copy_script
while read file
do
  base=`basename $file`
  dir=`dirname $file`
  ext=`getExtension $base`
  sequence=`echo $base | awk -F '+' '{ print $1 }'`
  if valid_shot_sequence $sequence
  then
    newname=${sequence}_PSH_color.${ext}
    if grep "${newname}$" $copy_script 
    then
      error_no_exit "Duplicate new file name: ${newname}"
      error_no_exit "    Original name: ${file}"
      error "Quitting; please correct above error and retry"
    else
      echo "mv -v $file $dir/$newname" >> $copy_script
    fi
  else
    warning "Not a valid shot sequence file name ${file}"
  fi
done < $file_list

dir_base=`basename $DIR`
command_file=$dir_base-`date +%F`.sh
cp $copy_script $command_file
message "Wrote $command_file"
message "Sample: "
head $command_file
echo "..."
message "To rename all files, run:"
message ""
message "           sh $command_file"
message ""
warning "Running the above command is destructive; it will rename, *not copy*, all files"

### EXIT
# http://stackoverflow.com/questions/430078/shell-script-templates
rm -f $tmp.?
trap 0
exit 0



