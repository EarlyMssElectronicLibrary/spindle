#!/bin/sh

read -r -d '' HELP <<-'EOF'
Copy files from repository to staging and prep for delivery.

* Read in instructions:

STAGE_DIR
REPO_VOLUME

MANUSRIPT_NAME

* Prepare directories

  MS_NAME/
    ReadMe.html
    FileList.html
    Data/
      FOLIO_DIR1/
      FOLIO_DIR2/
      ...
    ResearchContrib/

* Copy files under new names

* Add metadata

EOF

### TEMPFILES
# From:
#   http://stackoverflow.com/questions/430078/shell-script-templates
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
JSON_TEMPLATE=`dirname $0`/../data/metadata_template.json
if [ ! -f $JSON_TEMPLATE ]; then 
  error "Cannot find $JSON_TEMPLATE"
fi

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
# grab input file and confirm it exists; 
INPUT_FILE=$1
if [ -z "$INPUT_FILE" ]; then
  error "Please provide an INPUT_FILE"
elif [ ! -f $INPUT_FILE ]; then
  error "INPUT_FILE not found: $INPUT_FILE"
fi

# get the variables
shelfmark=`get_value $INPUT_FILE "SHELFMARK"`
shelfmark_dir=`echo $shelfmark | sed 's/  */_/g'`
staging_volume=`get_value $INPUT_FILE "STAGING_VOLUME"`
staging_dir=`get_value $INPUT_FILE "STAGING_DIR"`
repo_volume=`get_value $INPUT_FILE "REPO_VOLUME"`
repo_dir=`get_value $INPUT_FILE "REPO_DIR"`

# make sure we find the repository
repository=$repo_volume/$repo_dir
if [ -d $repository ]; then 
  message "Using Repository $repository"
else
  error "Repository not found $repository"
fi

# make sure the staging volume is there
if ! ls $staging_volume/* >/dev/null ; then
  error "STAGING_VOLUME not found $staging_volume"
fi

staging=$staging_volume/$staging_dir
if [ ! -d $staging ]; then
  message "Creating STAGING_DIR $staging"
  mkdir -p $staging
fi
copy_log=$staging/${shelfmark_dir}_copy_`date +%Y%m%d-%H%M%S%z`.log

package_dir=$staging/$shelfmark_dir
if [ -d $package_dir ]; then
  warning "Manuscript directory already exists: $package_dir"
else 
  message "Creating manuscript directory $package_dir"
  mkdir $package_dir
fi
message "Using manuscript directory: $package_dir"

data_dir=$package_dir/Data
if [ -d $data_dir ]; then
  warning "Data directory already exists: $data_dir"
else 
  message "Creating Data directory $data_dir"
  mkdir $data_dir
fi
message "Using Data directory: $data_dir"

contrib_dir=$package_dir/ResearchContrib
if [ -d $contrib_dir ]; then
  warning "ResearchContrib directory already exists: $contrib_dir"
else 
  message "Creating ResearchContrib directory $contrib_dir"
  mkdir $contrib_dir
fi
message "Using ResearchContrib directory: $contrib_dir"

contrib_data_dir=$contrib_dir/Data
if [ -d $contrib_data_dir ]; then
  warning "ResearchContrib/Data directory already exists: $contrib_data_dir"
else 
  message "Creating ResearchContrib/Data directory $contrib_data_dir"
  mkdir $contrib_data_dir
fi
message "Using ResearchContrib/Data directory: $contrib_data_dir"

seq_dirs=$tmp.1
grep "^SEQ_DIR" $INPUT_FILE | awk '{ print $2 }' > $seq_dirs
while read seq
do
  seq_dir=$data_dir/$seq
  if [ -d $seq_dir ]; then
    warning "Sequence directory already exists: $seq_dir"
  else 
    message "Creating sequence directory $seq_dir"
    mkdir $seq_dir
  fi
done < $seq_dirs

# copy the files
# PICK source new_name
pick_list=$tmp.2
metadata_tmp=$tmp.3
grep "^PICK" $INPUT_FILE | awk '{ print $2 " " $3 }' > $pick_list
count=0
total=`wc -l $pick_list | awk '{ print $1 }'`
width=6
while read pick
do
  count=$(( $count + 1 ))
  counter=`printf "%${width}d/%d" $count $total`
  source=$repository/`echo $pick | awk '{ print $1 }'`
  dest=$data_dir/`echo $pick | awk '{ print $2 }'`

  if [ -f $dest ]; then
    warning "$counter  `$date_cmd`  CORE DATA FILE EXISTS SKIPPING  `basename $dest`"
  else
    cp -v $source $dest > $copy_log
    message "$counter  `$date_cmd`  CORE DATA `basename $dest`"
    # add the metadata
    sed "s!SOURCE_FILE!${dest}!" $JSON_TEMPLATE > $metadata_tmp
    exiftool -overwrite_original -j=$metadata_tmp $dest
  fi
done < $pick_list

contrib_list=$tmp.4
grep "^CONTRIB" $INPUT_FILE | awk '{ print $2 " " $3 }' > $contrib_list
count=0
total=`wc -l $contrib_list | awk '{ print $1 }'`
width=6
while read contrib
do
  count=$(( $count + 1 ))
  counter=`printf "%${width}d/%d" $count $total`
  source=$repository/`echo $contrib | awk '{ print $1 }'`
  dest=$contrib_data_dir/`echo $contrib | awk '{ print $2 }'`

  dest_dir=`dirname $dest`
  if [ ! -d $dest_dir ]; then
    message "Creating $dest_dir"
    mkdir $dest_dir
  fi

  if [ -f $dest ]; then
    warning "$counter  `$date_cmd`  CONTRIB FILE EXISTS SKIPPING  `basename $dest`"
  else
    cp -v $source $dest > $copy_log
    message "$counter  `$date_cmd`  CONTRIB  `basename $dest`"
    # add the metadata
    sed "s!SOURCE_FILE!${dest}!" $JSON_TEMPLATE > $metadata_tmp
    exiftool -overwrite_original -j=$metadata_tmp $dest
  fi
done < $contrib_list


### EXIT
# http://stackoverflow.com/questions/430078/shell-script-templates
rm -f $tmp.?
trap 0
if [ -s $copy_log ]; then
  message "Log written to $copy_log"
fi
exit 0
