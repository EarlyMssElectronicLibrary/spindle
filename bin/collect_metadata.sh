#!/bin/sh

read -r -d '' HELP <<-'EOF'
Collect metadata for images files in INPUT_DIR to upload to the KatIkon system.

For an INPUT_DIR of the correct structure, collect image file metadata for
upload to KatIkon delivery.  INPUT_DIR must contain at its root a 'data'
directory.  Metadata will be collected for TIFF and JPEG image in the 'data'
directory and its subdirectories.  All other directories will be ignored, and 
images of types other than TIFF and JPEG will also be ignored.

The following illustrates the correct directory structure.

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
export SPINDLE_COMMAND=$cmd
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
# the name of the manifest in each dir
MANIFEST_FILE=manifest-md5s.txt

### VARIABLES
# the input dir
INPUT_DIR=
# the data directory
DATA_DIR=
# JSON_FILE
JSON_FILE=
# FILE_NAME_PATTERN=


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

### HARVEST METADATA
# change to the input dir
if [ "$INPUT_DIR" != "." ]; then
  cd $INPUT_DIR
fi

file_list=$tmp.1
# get all non-hidden files
find data -type f ! -name .\* > $file_list
# get the processor code
processor=`grep  "${SHOOT_LIST}_${SHOT_SEQ}_${PROCESSOR}_.*" $file_list | head -n1`
processor=`basename $processor | awk -F_ '{ print $3 }'`
json_base="${processor}_metadata_`date +%Y%m%d`"
json_tmp=$tmp.2

# get file size in bytes, then make sure we get everything else
exif_opts="-fileSize# -all"

count=0  # which file we're one
chunk=0  # chunk in to json files of 200 images ea.
total=`wc -l $file_list | awk '{ print $1 }'`
# width for printf; make the count line up
width=`echo "$total" | wc -c`
width=$(( $width - 1 ))
# ISO date format YYYY-mm-ddTHH:MM:SS+-OFFSET
date_cmd="date +%FT%T%z"
message "`$date_cmd`  `printf "%${width}d" $count`/$total files read"
while read file
do
  count=$(( $count + 1 ))
  # if json_tmp is empty, then this is the first entry
  if [ ! -s $json_tmp ]; then
    # first file; replace last line "}]" with "},"
    exiftool -j $exif_opts $file | sed '$ s/\]$/,/' >> $json_tmp
  else
    # replace first line "[{" with "{"
    # replace last line "}]" with "},"
    exiftool -j $exif_opts $file | sed -e '$ s/\]$/,/' -e '1 s/^\[//' >> $json_tmp
  fi
  if [ "$(( $count % 200 ))" -eq 0 ]; then
    json_file="${json_base}_`printf "%03d" $chunk`.json"
    # last line should be "}]"; make it so
    sed '$ s/,$/]/' $json_tmp > $json_file
    message "Wrote JSON file to: `pwd`/$json_file"
    message "`$date_cmd`  `printf "%${width}d" $count`/$total files read"
    # empty the temp file
    : > $json_tmp
    chunk=$(( $chunk + 1 ))
  fi
done < $file_list

# if we have any data left over, put it in a file
if [ -s $json_tmp ]; then
  # last line should be "}]"; make it so
  json_file="${json_base}_`printf "%03d" $chunk`.json"
  sed '$ s/,$/]/' $json_tmp > $json_file
  message "Wrote JSON file to: `pwd`/$json_file"
  message "`$date_cmd`  `printf "%${width}d" $count`/$total files read"
fi
  

### EXIT
# http://stackoverflow.com/questions/430078/shell-script-templates
rm -f $tmp.?
trap 0
exit 0


