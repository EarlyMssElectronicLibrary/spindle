#!/bin/sh

read -r -d '' HELP <<-'EOF'
For an INPUT_DIR of the correct structure, verify its integrity. INPUT_DIR must
contain at its root a 'data' directory and a manifest file 'manifest-md5s.txt';
thus,
      .
      ├── data
      │   ├── dir1
      │   │   ├── file1.tif
      │   │   ├── ...
      │   └── dir2
      │       ├── ...
      └── manifest-md5s.txt

This command will verify the following:

  * each file listed in the manifest exists
  * each file in the 'data' occurs in the manifest
  * each file in 'data' matches its manifest checkum

The manifest file must have the following structure.

      44943bbb7d369448027783b67fa579e1 data/dir1/file1.tif
      8f55980b0490ec47c20ccd0677b2ab1d data/dir2/file4.jpg
      ...

Note that there the data file path does not begin with a dot './data/...'.

Be aware that different MD5 commands produce different ouptput formats. The
only allowable variation is the number of spaces between the checksum and the
file path. The above was produced using Mac OS 'md5' with the '-r' (reverse)
option: 'md5 -r ARG'.  Normal Mac OS 'md5' output is atypical:

      MD5 (data/dir1/file1.tif) = 44943bbb7d369448027783b67fa579e1

GNU md5sum and GNU coreutils 'gmd5sum' produce output with two spaces. 

      $ gmd5sum data/dir1/file1.tif 
      44943bbb7d369448027783b67fa579e1  data/dir1/file1.tif

The second space is for a '*' when the -b/--binary option is used:

      $ gmd5sum -b data/dir1/file1.tif 
      44943bbb7d369448027783b67fa579e1 *data/dir1/file1.tif
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

usage() {
   echo "Usage: $cmd {-h|-d IMAGE_DIR|DIR_LIST}"
   echo ""
   echo "OPTIONS"
   echo ""
   echo "   -h             Display help message"
   echo ""
}

help() {
  echo "$HELP"
  echo ""
}

message() {
  echo "$cmd: INFO    - $1"
}

error_no_exit() {
  echo "$cmd: ERROR   - $1" 1>&2
}

error() {
  echo "$cmd: ERROR   - $1" 1>&2
  echo ""
  usage
  exit 1
}

warning() {
  echo "$cmd: WARNING - $1" 1>&2
}

### LOGGING
logfile=${LOGFILE:LOG_${cmd}}.log

log() {
    echo "`date +%Y-%m-%dT%H:%M:%S` [$cmd] $1" >> $LOG
}

### CONSTANTS
# the name of the manifest in each dir
MANIFEST_FILE=manifest-md5s.txt
# image file extensions
FILE_TYPES="jpg JPG jpeg JPEG tiff TIFF tif TIF"

### VARIABLES
# the input dir
INPUT_DIR=
# the data directory
DATA_DIR=

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

# make sure the manifest exists
if [ ! -f $INPUT_DIR/$MANIFEST_FILE ]; then
  error "No manifest found in $INPUT_DIR"
fi

exit

### get the WORKING_LIST
if [ -n "$IMAGE_DIR" ]; then
  if [ ! -d "$IMAGE_DIR" ]; then
    error "Option IMAGE_DIR is not a directory: '$IMAGE_DIR'"
  fi
  WORKING_LIST=$tmp.1
  echo "$IMAGE_DIR" > $WORKING_LIST
  if [ -n "$DIR_LIST" ]; then
    warning "Found IMAGE_DIR '$IMAGE_DIR' ignoring DIR_LIST '$DIR_LIST'"
  fi
elif [ -n "$DIR_LIST" ]; then
    if [ ! -f $DIR_LIST ]; then
      error "Directory listing not found: $DIR_LIST"
    fi
    WORKING_LIST=$DIR_LIST
else
  error "Please provide a DIR_LIST or IMAGE_DIR"
fi

# CHECK THE DIRECTORY LISTING
message "Checking directories"
BAD_DIRS=
CHECKSUM_FILES=
while read dir
do
  if [ ! -d $dir ]; then
    BAD_DIRS="$BAD_DIRS $dir"
  elif [ -f "$dir/$MANIFEST_FILE" ]; then
    CHECKSUM_FILES="$CHECKSUM_FILES $dir/$MANIFEST_FILE"
  fi
done < $WORKING_LIST
dir=


if [ -n "$BAD_DIRS" -o -n "$CHECKSUM_FILES" ]; then
  error_no_exit "The following errors were found:"
  for dir in $BAD_DIRS
  do
    error_no_exit "Not a valid diretory: $dir"
  done
  for file in $CHECKSUM_FILES
  do
    error_no_exit "Checksum file exists: $file"
  done
  error "Please correct directory listing"
fi
dir=
file=

### CREATE MANIFESTS
message "Writing manifests"
while read dir
do
  $(cd $dir
  for file in `ls *.tif *.tiff *.jpg *.jpeg 2>/dev/null`
  do
    md5 -r $file >> $MANIFEST_FILE
  done
  )
  manifest=$dir/$MANIFEST_FILE
  if [ -f $manifest ]; then
    if [ -s $manifest ]; then
      size=`wc -l $manifest | awk '{ print $1 }'`
      message "  $manifest ($size entries)"
      size=
    else
      warning "  EMPTY FILE $manifest"
    fi
  else
    warning "FILE NOT CREATED: $manifest"
  fi
  manifest=
done < $WORKING_LIST
dir=

### EXIT
# http://stackoverflow.com/questions/430078/shell-script-templates
rm -f $tmp.?
trap 0
exit 0
