#!/bin/sh


read -r -d '' HELP <<-'EOF'
Confirm image data INPUT_DIR is ready for delivery. INPUT_DIR defaults to '.'.

For an INPUT_DIR of the correct structure, verify that it is ready for
delivery. INPUT_DIR must contain at its root a 'data' directory. and a manifest
file 'manifest-md5s.txt'; thus,

      .
      ├── DLVRY_filenames.log
      ├── DLVRY_metadata.log
      ├── data
      │   ├── 0015_000013_DJK_ICA_01_2.jpeg
      │   ├── 0015_000013_DJK_ICA_01_2.tif
      │   ├── ...
      │   ├── 0015_000013_DJK_ICA_04_RGB.jpeg
      │   └── 0015_000013_DJK_ICA_04_RGB.tif
      └── manifest-md5s.txt

To be valid for delivery a directory must have the following:

 * a DLVRY_filenames.log file, newer than all files in the data directory, the
   last line of which contains "ALL VALID"
 * a DLVRY_metadata.log file, newer than all files in the data directory, the
   last line of which contains "ALL VALID"
 * a manifest-md5s.txt file, newer than the log files, that lists all files in
   the data directory
 * addtionally, the list of files in the manifest must match the list of files
   in the data directory *exactly*

To ensure data retains its integrity for delivery, it is recommended you tar
all data into a single archive:

   $ cd INPUT_DIR
   $ cd ..
   $ tar cf INPUT_DIR.tar INPUT_DIR/**

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
export SPINDLE_COMMAND=$cmd
source `dirname $0`/spindle_functions

usage() {
   echo "Usage: $cmd [-h] [INPUT_DIR]"
   echo ""
   echo "OPTIONS"
   echo ""
   echo "   -R             Run in Receipt mode"
   echo "   -h             Display help message"
   echo "   -v             Display Spindle version"
   echo ""
}

### CONSTANTS
# the name of the manifest in each dir
MANIFEST_FILE=manifest-md5s.txt

### VARIABLES
# the input dir
INPUT_DIR=
# the data directory
DATA_DIR=
DELIVERY_LOG=DLVRY_package.log
RECEIPT_LOG=RECPT_package.log

# METHODS
check_required() {
  reqd_file=$1
  if [ -f $reqd_file ]; then
    return 0
  else
    message "File not found: `pwd`/$reqd_file"
  fi
  return 1
}

check_uptodate() {
  dir=$1
  qfile=$2
  qlist=`find $dir -type f -newer $qfile`
  if [ -n "$qlist" ]; then
    error_no_exit "Found files newer than `pwd`/$qfile"
    for x in $qlist
    do
      error_no_exit "   - Newer file: $x"
    done
    return 1
  else
    message "Up-to-date: $qfile"
  fi
  return 0
}

### OPTIONS
while getopts ":hvR" opt; do
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
    R)
      RECEIPT_MODE=true
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
INPUT_DIR=`input_dir $1`
if [ $? -ne 0 ]; then
  error "Error finding input directory"
fi
message "INPUT_DIR is $INPUT_DIR"

# make sure there's a data directory in INPUT_DIR
DATA_DIR=`data_dir $INPUT_DIR`
if [ $? -ne 0 ]; then
  error "Error finding data directory"
fi

# change to the input dir
if [ "$INPUT_DIR" != "." ]; then
  cd $INPUT_DIR
fi

if [ "$RECEIPT_MODE" ]; then
  message "Running in RECEIPT_MODE"
  if [ ! -f "$DELIVERY_LOG" ]; then
    error_no_exit "No delivery log found: $DELIVERY_LOG"
    error "Delivery log required when running in RECEIPT_MODE"
  fi
  logfile=$RECEIPT_LOG
else
  message "Running in DELIVERY_MODE"
  if [ -f $DELIVERY_LOG ]; then
    error "DELIVERY MODE: will not overwrite $DELIVERY_LOG"
  else
    message "DELIVERY MODE: creating new log file $DELIVERY_LOG"
    logfile=$DELIVERY_LOG
  fi
fi

# Check DLVRY_filenames.log
filename=DLVRY_filenames.log
if  ! check_required $filename
then
  msg="Missing required file: $filename"
  log_invalid "$msg"
  log "ERRORS_FOUND"
  fail "$msg"
fi
if ! check_uptodate data $filename
then
  msg="Out-of-date: $filename"
  log_invalid "$msg"
  log "ERRORS_FOUND"
  fail "$msg"
fi

# TODO carry logging through all checks
# Check DLVRY_metadata.log
filename=DLVRY_metadata.log
if  ! check_required $filename
then
  fail "Missing required file: $filename"
fi
if ! check_uptodate data $filename
then
  fail "Out-of-date: $filename"
fi

# Check manifest-md5s.txt 
filename=manifest-md5s.txt
if  ! check_required $filename 
then
  fail "Missing required file: $filename"
fi
if ! check_uptodate . $filename
then
  fail "Out-of-date: $filename"
fi

# Compare the manifest list with the file system
if ! check_manifest_files $logfile ; then
  log "ERRORS_FOUND"
  error_no_exit "Manifest does not match data files"
  fail "ERRORS_FOUND; errors written to `pwd`/$logfile"
fi

success ALL_VALID

# TODO Check manifest-md5s.txt file lists
# TODO confirm all data files younger than logs and manifest

### EXIT
# http://stackoverflow.com/questions/430078/shell-script-templates
rm -f $tmp.?
trap 0
exit 0

