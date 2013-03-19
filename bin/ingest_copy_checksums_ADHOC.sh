#!/bin/sh


read -r -d '' HELP <<-'EOF'
For INPUT_DIR, copy all checksums from the manifest-md5s.txt file to the 
repository. For an input DIR with this format, 

      .
      ├── LOG_verify_filenames.log
      ├── LOG_verify_metadata.log
      ├── data
      │   ├── 0015_000013_DJK_ICA_01_2.jpeg
      │   ├── 0015_000013_DJK_ICA_01_2.tif
      │   ├── ...
      │   ├── 0015_000013_DJK_ICA_04_RGB.jpeg
      │   └── 0015_000013_DJK_ICA_04_RGB.tif
      └── manifest-md5s.txt

the manifest will have this format:

      f2dcd448ed22c11ac1f95e86a4c26bca  data/0015_000013_DJK_ICA_01_2.jpg
      8e07f00ba4fc46fd68d57c89c3be3537  data/0015_000013_DJK_ICA_01_2.tif
      ...
      f9528f74c84421e6b936b86b8bac2eb6  data/0015_000013_DJK_ICA_04_RGB.jpg
      077756e27f5528fc097bc0a544b1d8f8  data/0015_000013_DJK_ICA_04_RGB.tif

This script will redistribute checkums to the repository as individual files,
thus:

      .
      └── data
          ├── 0015_000013_DJK_ICA_01_2.jpeg
          ├── 0015_000013_DJK_ICA_01_2.jpeg.md5
          ├── 0015_000013_DJK_ICA_01_2.tif
          ├── 0015_000013_DJK_ICA_01_2.tif.md5
          ├── ...
          ├── 0015_000013_DJK_ICA_04_RGB.jpeg
          ├── 0015_000013_DJK_ICA_04_RGB.jpeg.md5
          ├── 0015_000013_DJK_ICA_04_RGB.tif
          └── 0015_000013_DJK_ICA_04_RGB.tif.md5

Each checksum will be written to reflect the current location of the file,
such that 0015_000013_DJK_ICA_01_2.jpg.md5 would have the following format.

      f2dcd448ed22c11ac1f95e86a4c26bca  0015_000013_DJK_ICA_01_2.jpg

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
   echo "Usage: $cmd [-h] [INPUT_DIR]"
   echo ""
   echo "OPTIONS"
   echo ""
   echo "   -h             Display help message"
   echo "   -v             Display Spindle version"
   echo ""
}

### CONSTANTS
# the list of valid files; don't run without it
VALID_FILES=valid_file_names.txt
VOLUME=/Volumes/EIT_MARGE
REPO_FOLDER=$VOLUME/Repository/Processed
INGEST_LOG=

### VARIABLES
# the input dir
INPUT_DIR=
# the data directory
DATA_DIR=
# files that are missing from the manifest
NOT_LISTED=
# files in the manifest not found in the directory
NOT_FOUND=

### OPTIONS
while getopts ":hv" opt; do
  case $opt in
    h)
      usage 
      version
      help
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

# must have valid file names file to run
if [ ! -f $INPUT_DIR/$VALID_FILES ]; then
  error "Must have $INPUT_DIR/$VALID_FILES"
fi

### INGEST FILES
# change to the input dir
if [ "$INPUT_DIR" != "." ]; then
  cd $INPUT_DIR
fi

# name the ingest log
# get the checksums we need
file_list=$tmp.1
grep "\W${SHOOT_LIST}_${SHOT_SEQ}_${PROCESSOR}_" manifest-md5s.txt | grep -v "\._" > $file_list

curr=0
total=`wc -l $file_list | awk '{ print $1 }'`
width=`echo $total | wc -c`
width=$(( $width - 1 ))
count=`printf "%${width}d" $curr`
date_cmd="date +%FT%T%z"
message "$count/$total  `$date_cmd`"
while read line
do
  checksum=`echo $line | awk '{ print $1 }'`
  file=`echo $line | awk '{ print $2 }' | sed 's/\*//'`
  base=`basename $file`
  shot_seq=`echo $base | awk -F_ '{ print $1 "_" $2 }'`
  dest_dir="$REPO_FOLDER/$shot_seq"
  if [ ! -d $dest_dir ]; then
    error "Destination directory not found $dest_dir"
  fi
  dest_file="$dest_dir/$base.md5"
  if [ -f $dest_file ]; then
    error_no_exit "Attempt to overwrite $dest_file; quitting"
    error "Completed $count/$total  `$date_cmd`"
  fi
  echo "$checksum  $base" > $dest_file
  # COUNT AND REPORT
  curr=$(( $curr + 1 ))
  count=`printf "%${width}d" $curr`
  message "$count/$total  `$date_cmd`  $dest_file"
done < $file_list
success "Completed $count/$total  `$date_cmd`"

### EXIT
# http://stackoverflow.com/questions/430078/shell-script-templates
rm -f $tmp.?
trap 0
exit 0


