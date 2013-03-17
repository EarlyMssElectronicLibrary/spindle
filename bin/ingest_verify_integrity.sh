#!/bin/sh

# TODO confirm all checksums copied and identical to delivery
# A problme with this script as now written is that it doesn't 
# guranteee the the checksums in the repo are the local ones, or that
# all files have been copied. This script should guarantee that.
read -r -d '' HELP <<-'EOF'

For INPUT_DIR, verify all files on destination and unchanged.

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
   echo "   -v             Display Spindle version"
   echo ""
}

### CONSTANTS
# the list of valid files; don't run without it
VOLUME=/Volumes/EIT_MARGE
REPO_FOLDER=$VOLUME/Repository/Processed
date_cmd="date +%FT%T%z"
INGEST_VERICATION_LOG=INGEST_VERICATION_`date +%Y%m%d-%H%M%S%z`.log

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
DATA_DIR=`pwd`
INGEST_VERICATION_LOG=$DATA_DIR/$INGEST_VERICATION_LOG
valid_files=$DATA_DIR/$VALID_FILES

# list of files in sequence
seq_files=$tmp.1
# get the list of folders
sequences=`awk -F '/' '{ print $NF }' $valid_files | \
  awk -F_ '{ print $1 "_" $2 }' | sort | uniq`
# name the ingest log

curr=0
total=`wc -l $valid_files | awk '{ print $1 }'`
width=`echo $total | wc -c`
width=$(( $width - 1 ))
count=`printf "%${width}d" $curr`
message "$count/$total `$date_cmd`"
for seq in $sequences
do
  # all the files we're checking
  grep $seq $valid_files > $seq_files
  dest=$REPO_FOLDER/$seq
  cd $dest
  while read file
  do
    curr=$(( $curr + 1 ))
    count=`printf "%${width}d" $curr`
    if md5sum -c  `basename $file`.md5 ; then
      echo "$SPINDLE_COMMAND: OK      -  $file" >> $INGEST_VERICATION_LOG
      message "$count/$total $file  `$date_cmd`  OK"
    else
      echo "$SPINDLE_COMMAND: ERROR   -  $file" >> $INGEST_VERICATION_LOG
      error_no_exit "$count/$total $file  `$date_cmd`  ERROR"
    fi
  done < $seq_files
done

good=`grep OK $INGEST_VERICATION_LOG | wc -l | awk '{ print $1 }'`
if grep ERROR $INGEST_VERICATION_LOG ; then
  error "validation ERRORS found $(( total - $good ))/$total"
elif [ $good -eq $total ]; then 
  success "ALL VALID $good/$total"
else
  warning "NO ERRORS FOUND BUT OK COUNT NOT EXPECTED: $good/$total"
fi

### EXIT
# http://stackoverflow.com/questions/430078/shell-script-templates
rm -f $tmp.?
trap 0
exit 0


