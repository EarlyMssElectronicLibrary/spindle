#!/bin/sh

read -r -d '' HELP <<-'EOF'

For the input CAPTURE_DIR find all color imgage and copy them to a `data`
directoy in PACKAGE_DIR. This script will create the `data`  directoy in
PACKAGE_DIR.

This script will also verify each copy using the source md5 checksum  if there
is one. If the file is verified, a temporary md5 file will be  created for it:
`filename.tif.md5`.

If the copy fails verification, the file is removed, and the original file the
script attempts to verify it against the checksum, and reports success or
failure.

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
   echo "Usage: $cmd [OPTIONS] CAPTURE_DIR PACKAGE_DIR"
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
# the package dir
PACKAGE_DIR=$2
if dir_exists $PACKAGE_DIR
then
  message "Using PACKAGE_DIR $PACKAGE_DIR"
else
  error "PACKAGE_DIR not found"  
fi

# CREATE data if needed.
DATA_DIR=$PACKAGE_DIR/data
if [ -d $DATA_DIR ]; then
  message "Copying to $DATA_DIR"
else
  message "Create data directoy: $DATA_DIR"
  if mkdir $DATA_DIR ; then
    error "Error creating $DATA_DIR"
  fi
fi

color_files=$tmp.1
find $CAPTURE_DIR -type f -name "\*_PSC.tif" -o -name "\*+_CCD_CCC\*.tif"  > $color_files
count=0
total=`wc -l $color_files | awk '{ print $1 }'`
date_cmd="date +%FT%T%z"
tstamp=`date +%FT%H%M%z`
report_count $count $total 0
while read file
do
  VALID_COPY=false
  base=`basename $file`
  outfile=$DATA_DIR/$base
  if [ -f $outfile ]; then
    warning "File: exists: $outfile"
    warning "Not coping: $file"
  fi

  if cp $file $PACKAGE_DIR ; then
    message "Added $outfile"
  else
    error_no_exit "Error copying $file"
  fi

  source_dir=`dirname $file`
  md5s_txt=$source_dir/md5s.txt
  if [ -f $md5s_txt ]; then
    checksum=`extract_checksum "$base" $md5s_txt`
    if [ -n  "$checksum" ]; then
      # Usage: file_valid FILE CHECKSUM
      if ! file_valid "$outfile" $checksum ; then
        invalid "removing $outfile"
        rm $outfile
        message "Checking source file: $file"
        if file_valid "$file" $checksum ; then
          VALID "$file"
          echo "$checksum  $base" > ${outfile}.md5
          message "Wrote "${outfile}.md5"
        else
          INVALID "$file"
        fi # if ! file_valid $file (the source)
      fi # if ! file_valid $outfile ;...
    else
      warning "No checksum found for $base in $md5s_txt"
    fi # if [ -n "$checksum"]; ...
  else
    warning "No checksum file found: $md5s_txt"
  fi # if [ -f $md5s_txt ]; ...
  
  # COUNT AND REPORT
  count=$(( $count + 1 ))
  report_count $count $total 1
done < $color_files


### EXIT
# http://stackoverflow.com/questions/430078/shell-script-templates
rm -f $tmp.?
trap 0
exit 0


