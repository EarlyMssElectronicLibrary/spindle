#!/bin/sh

read -r -d '' HELP <<-'EOF'
For INPUT_DIR, copy all files with their checksums to the repository making a
record of what files are copied and where.

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
while getopts ":hd:" opt; do
  case $opt in
    h)
      usage 
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
first_file=`head -n1 $VALID_FILES`
processor=`basename $first_file | awk -F_ '{ print $3 }'`
INGEST_LOG=${processor}_ingest_list_`date +%Y%m%dT%H%M%S%z`.log
:>$INGEST_LOG

curr=0
total=`wc -l $VALID_FILES | awk '{ print $1 }'`
width=`echo $total | wc -c`
width=$(( $width - 1 ))
count=`printf "%${width}d" $curr`
date_cmd="date +%FT%T%z"
message "$count/$total `$date_cmd`"
while read file
do
  base=`basename $file`
  shot_seq=`echo $base | awk -F_ '{ print $1 "_" $2 }'`
  dest=$REPO_FOLDER/$shot_seq
  if [ ! -d $dest ]; then
    mkdir $dest
  fi
  # COPY
  cp -v $file $dest >> $INGEST_LOG
  # copy the checksum
  # grep -F pattern is fixed string
  line=`grep -F "$file" manifest-md5s.txt`
  checksum=`echo $line | awk '{ print $1 }'`
  md5_file=$dest/$base.md5
  if [ -f $md5_file ]; then
    warning "Overwriting existing md5 file $md5_file"
  fi
  echo "$checksum  $base" > $md5_file
  # COUNT AND REPORT
  curr=$(( $curr + 1 ))
  count=`printf "%${width}d" $curr`
  message "$count/$total  `$date_cmd`  $file"
done < $VALID_FILES

### EXIT
# http://stackoverflow.com/questions/430078/shell-script-templates
rm -f $tmp.?
trap 0
exit 0


