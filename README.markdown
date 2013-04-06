# Spindle: Sinai Palimpsests Project Image Delivery scripts

Spindle is a set of scripts for the preparation and delivery of data to 
the Sinai Palimpsests Project repository and for validating data upon 
its receipt.

### Software dependencies

Most of these scripts are written in bash.

Metadata scripts rely on Exiftool, version 8.47 or higher

These two programs (Bash and Exiftool) are all that is needed for most
functions.  This is the case for ALL DELIVERY and RECEIPT scripts for preparing
and validating packages.

Scripts for managing the ingestion of data and metadata do rely on other
programs.  The following scripts rely on Ruby 1.9.2 or 1.9.3:

- `bin/prep_metadata`
- `bin/push_metadata`
- `bin/read_metadata.rb`

The script `lab_color_to_rgb_jpeg` relies on ImageMagick. It was written using
ImageMagick version 6.7.6-9; and has not been tested on other versions. It is
anticipated the script will work with ImageMagick v6.7.6-9 or later.

### Installation

Download or clone the repository:

     $ git clone https://postertorn@bitbucket.org/postertorn/spindle.git

or

     $ git clone git@bitbucket.org:postertorn/spindle.git

Add the spindle/bin directory to your path.  In `.bashrc`:

     PATH=$PATH:path/to/spindle/bin
     export $PATH

Use the appropriate method for your shell.

If you're going to do metadata and data ingest, you'll need to set up the
Spindle init.rb for your system.  See `doc/dot_spindle/README` for details.

### Blather you can skip

There are several parts to data handling. Once data has been completed via
capture or processing, it must be compiled into an archive for delivery,
received and verified upon receipt, and added to the project repository for
persistent storage.  At a later point in time, the processed or captured images
will be assembled in to delivery packages.  To ensure data consistency,
quality, integrity, and completeness and to manage and track this data,
certain systems will be put in place.  These systems fall into to two broad
types: package management tools for assembling and verfying the packages, and
systems of logging and record keeping.

The hub for assembling and organizing information about packages of data will
be KatIkon.  When files are received at the repository location and added to
the repository, key information will be added to KatIkon. KatIkon will know
what files are in the repository and will know a good deal about them.  When
files need to assembled for delivery, users will go to KatIkon to select them
images to be delivered.

These scripts focus on the preparation of processed image data for delivery
and the validation of that data upon delivery.  Spindle focuses managing valid
transfers of image data.

# Delivery of processed images

These are the steps and scripts to be used by scientists assembling data
packages for delivery to the repository for storage and redistribution.
They focus on ensuring that prepared data is complete and valid.

## The scripts

There are five basic *package* scripts to use for preparing data:

 1. `deliver` - a master script that runs all the others
 2. `verify_all_filenames` - script to validate all package file names
 3. `verify_all_metadata` - script to validate metadata in all package files
 4. `create_manifest` - script to generate a list of checksums for all package
   files
 5. `verify_package` - script that checks the all other scripts have been run

> Two additional scripts should be of interest. They are:
> 
>  * `verify_filename` - script to validate a single file name
>  * `verify_metadata` - script to validate metadat for a single file

Script #1, `deliver` runs scripts #2-5 and makes sure they have all run
correctly.  All package scripts act on an entire set of data, called a package.
A package has a simple, but specific structure that is described in the
following section.

Each package script has this basic usage:

      $ script_name path/to/package

For example, for a package directory `/home/john/packages/MS22`, thus:

      MS22
      └── data
          ├── 0015_000013_JHS_ICA_01_2.jpg
          ├── 0015_000013_JHS_pseudo.jpg
          ├── ...
          ├── 0015_000013_JHS_ICA_04_RGB.tif
          └── 0015_000013_JHS_pseudo.tif

The `deliver` script invocation would be:

      $ deliver /home/john/packages/MS22

The `deliver` script would then invoke each of script 2-5 above to validate
the contents of the package. 

#### Some general notes

* Each script has a help `-h` option that displays detail information about its
  use.

* Each script returns an exit status: `0` on successful completion; `1`
  otherwise. If any errors are found, exit status `1` is returned.

* Each script generates an *artifact* file of some sort. Verifying scripts
  create a DLVRY_<SOMENAME>.log file. On successful completion, the last line
  of each log will contain `ALL_VALID`, and `ERRORS_FOUND` otherwise.

* Scripts **will not overwrite log files**. The must be deleted manually.

* The `delivere` has `-C` option that can be used to clobber `log` and other
  process artifact files.

## Package structure

All Spindle scripts expect a common directory structure for delivered data.

All files are delivered in a *package* folder, in which there is a `data`
folder.  All files to be dlivered should be in the `data` directory.  The
following examples show this structure.

      MSS_15-13
      └── data
          ├── 0015_000013_DJK_ICA_01_2.jpg
          ├── ...
          └── 0015_000013_DJK_ICA_04_RGB.tif

      KTK
      └── data
          ├── Processed_Images
          │   ├── 0015_000001_KTK_pseudo_MB365UV-MB625Rd.tif
          │   ├── ...
          │   └── 0020_000018_KTK_txsharpie_WBRBB47-MB625Rd.tif
          └── Processed_Images_JPEG
              ├── 0015_000001_KTK_pseudo_MB365UV-MB625Rd.jpg
              ├── ...
              └── 0020_000018_KTK_txsharpie_WBRBB47-MB625Rd.jpg

The package folder may have any name, as long as it contains no spaces.  Large
sets of data can be broken into multiple packages if convenient.

The data folder must be spelled 'data', all in lower case characters.  Within
the `data` directory files may be organized in any fashion. Please note the
following:

  * Only files under the `data` directory will be ingested
  * All files in the `data` directory will be validated and ingested
  * Because of the preceding, the `data` directory should contain **only core
    data files**; work product and incidental files should not be included in
    the `data` folder
  * The only allowable extensions are '.tif' and '.jpg' in lower case
    characters; for example, '.tiff', '.TIF', '.jpeg', and '.jpg' will
    invalidate the package

All scripts that work on a package assume this structure and use it for the
creation of verification logs and checksum files.

All delivery processes can be performed by running the script `deliver`. The
`deliver` script will perform the following steps.

* Verification of correct file name formats -- `verify_all_filenames`
    - Ensure filenames comply with project file naming rules
    - Status: Beta

* Verification of the presence of expected metadata -- `verify_all_metadata`
    - Ensure that file contain required metadata
    - Status: Beta

* Creation of checksum lists for all files -- `create_checksums`
    - Generate a manifest for delivered data
    - Status: Beta

* Final verification for delivery -- `verify_package`
    - Make sure that all the required data is present and valid
    - Status: Beta

* Creation of tar archive of data

# Valid file names

Valid filenames should conform to the following rules.  See the help for
`verify_all_filenames` for details on using the script for validation.

### Valid file name characters

Valid characters are:

   ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz1234567890_-+

First order fields are divided by underscores: _
Second order fields are divided by dashes: -
Fields may not begin or end with: - or +

For use of the plus sign '+' and dash '-' please see the Data Delivery
Recommendations document.  Note that this is a valid field '..._GOOD-FIELD_...';
while this is not: '..._+BAD-FIELD-_'.

### Valid file name format

The correct file names have these fields:

    <SHOOT_LIST>_<SHOT_SEQ>_<PROCESSOR>_<PROCESSING_TYPE>_<MODIFIERS>.ext

Where:

  * SHOOT_LIST is a 4-digit string, right-padded with zeros: '0009'

  * SHOT_SEQ is a 6-digit string, right-padded with zeros: '000123'

  * PROCESSOR is  3-character string: 'WCB'; all characters must be alphabetic

  * PROCESSING_TYPE is string composed of valid file name characters, except
    the first-order field separator '_' (see below): 'sharpie'

  * MODIFIERS is a string composed of valid file name characters, and may be
    composed of multiple first-order fields: 'WBRBB47-MB625Rd'

Sample:

    0015_000012_KTK_sharpie_MB365UV-MB625Rd.jpg

### Valid extensions

Files should have the following extensions:

* TIFF files: lower case '.tif'; not valid: '.TIF .tiff .TIFF'
* JPEG files: lower case '.jpg'; not valid: '.JPG .jpeg .JPEG'

# Valid metadata

Files are expected to have the following metadata values:

* IPTC Source                        - required
* IPTC Object name                   - required
* IPTC Keywords
    - Resolution (PPI)               - required
    - Postion                        - required
* EXIF Creator                       - required
* AP DAT Bits Per Sample             - required
* AP DAT File Processing             - required
* AP DAT File Processing Rotation    - required
* AP DAT Joining Different Parts Of  - required
* AP DAT Joining Same Parts of Folio - required
* AP DAT Processing Comments         - optional
* AP DAT Processing Program          - required
* AP DAT Software Version            - required; `See DAT_Processing Program`
* AP DAT Type of Contrast Adjustment - required
* AP DAT Type of Image Processing    - required
* AP ID Parent File                  - required


# Receipt of processed images

The ingest of delivered processed images has the following steps:

* Untarring of data to staging

* Verification of readiness for delivery -- `verify_package`

* Verification of checksums for all files -- `verify_checksums`

* Verification of correct file name formats -- `verify_filenames`

* Verification of the presence of expected metadata -- `verify_metadata`

# Ingest of processed images

* Collection of metadata for ingest -- `collect_metadata.sh`

* Upload of ingest metadata

* Copying of data to repository -- `ingest_processed.sh`

* Verification of copy -- `ingest_verify_integrity.sh`

# Publication of data to scholars

The creation of a package of files for sharing with scholars. The steps to
creating the data set are. 


* Preparing an input file listing files to select - TBD
  - this will be generated from KatIkon

* Building up the package structure and adding selected files to the package --
  `package_add_data.sh`

* Creating support files and adding documentation to the package --
  `package_document.sh`

* Tarring the publication archive -- `package_archive.sh`

* Creating delivery drives -- `package_delivery.sh`

Publication involves creating an archive of data for scholar presentation

It has this structure:

      Greek_NF_MG_99/
        data/
                     

