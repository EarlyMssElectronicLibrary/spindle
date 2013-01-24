#!/bin/sh

read -r -d '' HELP <<-'EOF'
Add manifest file to the package.

A package will have the following structure.

      .
      ├── 01_ReadMe.txt
      ├── 02_FileList.txt
      ├── Data
      │   ├── GeoNF-71_001r_15-01
      │   │   ├── GeoNF-71_001r_15-01_KTK_pseudo_WBUVB47-MB625Rd.jpg
      │   │   ├── GeoNF-71_001r_15-01_KTK_pseudo_WBUVB47-VIS.jpg
      │   │   ├── ...
      │   │   └── GeoNF-71_001r_15-01_KTK_sharpie_WBUVR25-MB625Rd.jpg
      │   ├── ...
      │   └── GeoNF-71_008v_15-16
      │       ├── GeoNF-71_008v_15-16_KTK_pseudo_WBUVB47-MB625Rd.jpg
      │       ├── ...
      │       └── GeoNF-71_008v_15-16_KTK_sharpie_WBUVR25-MB625Rd.jpg
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
   echo "Usage: $cmd [-h] INPUT_FILE"
   echo ""
   echo "OPTIONS"
   echo ""
   echo "   -h             Display help message"
   echo ""
}

get_value() {
  file=$1
  var=$2
  line=`grep "^$var" $file 2>&1`
  echo "$line" | sed "s/^$var[	 ][	 ]*//"
}
### VARIABLES
date_cmd="date +%FT%T%z"

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
# first, find an MD5 command
MD5_CMD=
if which md5sum >/dev/null 2>&1 ; then
  MD5_CMD=`which md5sum`
elif which gmd5sum >/dev/null 2>&1 ; then
  MD5_CMD=`which gmd5sum`
elif which md5 >/dev/null 2>&1 ; then
  MD5_CMD="`which md5` -r"
else
  error "MD5 command not found; looked for gmd5sum, md5sum, md5"
fi
message "Using MD5 command: $MD5_CMD"

# grab input file and confirm it exists
INPUT_FILE=$1
if [ -z "$INPUT_FILE" ]; then
  error "Please provide an INPUT_FILE"
elif [ ! -f $INPUT_FILE ]; then
  error "INPUT_FILE not found: $INPUT_FILE"
fi

# find the resource dir; this hold ReadMe file templates
RESOURCE_DIR=`dirname $0`/../data
if [ ! -d $RESOURCE_DIR ]; then
  error "Cannot find resource directory: $RESOURCE_DIR"
fi
README_TEMPLATE=$RESOURCE_DIR/01_ReadMe.md
if [ -f $README_TEMPLATE ]; then
  message "Using ReadMe template: $README_TEMPLATE"
else
  error "Can't find ReadMe template $README_TEMPLATE"
fi

# get the variables
year=`date +%Y`
shelfmark=`get_value $INPUT_FILE "SHELFMARK"`
shelfmark_dir=`echo $shelfmark | sed 's/  */_/g'`
staging_volume=`get_value $INPUT_FILE "STAGING_VOLUME"`
staging_dir=`get_value $INPUT_FILE "STAGING_DIR"`

# make sure the staging volume is there
if ! ls $staging_volume/* >/dev/null ; then
  error "STAGING_VOLUME not found $staging_volume"
fi

staging=$staging_volume/$staging_dir
if [ ! -d $staging ]; then
  error "Staging dir not found: $staging"
fi

package_dir=$staging/$shelfmark_dir
if [ ! -d $package_dir ]; then
  error "Package directory not found: $package_dir"
fi
message "Using manuscript directory: $package_dir"

data_dir=$package_dir/Data
if [ ! -d $data_dir ]; then
  error "Data directory not found: $data_dir"
fi
message "Using Data directory: $data_dir"

# generate manifest
cd $package_dir
manifest_file=manifest-md5s.txt
if [ -f $manifest_file ]; then
  message "Removing old manifest: $manifest_file"
  rm $manifest_file
fi

file_list=$tmp.1
find . ! -name .\* -type f | sed 's!^\./!!' > $file_list
curr=0
total=`wc -l $file_list | awk '{ print $1 }'`
width=`echo $total | wc -c`
date_cmd="date +%FT%T%z"
count=`printf "%${width}d" $curr`
message "$count/$total `$date_cmd`"
while read file
do
  $MD5_CMD $file >> $manifest_file
  curr=$(( $curr + 1))
  count=`printf "%${width}d" $curr`
  message "$count/$total  `$date_cmd`  $file"
done < $file_list
message "$count/$total `$date_cmd` $MANIFEST_FILE complete" 




### EXIT
# http://stackoverflow.com/questions/430078/shell-script-templates
rm -f $tmp.?
trap 0
if [ -s $copy_log ]; then
  message "Log written to $copy_log"
fi
exit 0

