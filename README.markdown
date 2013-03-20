# Spindle: Sinai Palimpsests Project Image Delivery scripts

Spindle is a set of scripts for the preparation and delivery of data to 
the Sinai Palimpsests Project repository and for validating data upon 
its receipt.

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

For delivery preparation all data must be placed in an archive having a `data`
folder, in which are placed all files to ingested. The following examples show
this structure.

      DJK
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

It may be helpful to split large sets of images into smaller packages and 
validate them separately

All the scripts below assume this structure and use it for the creation of 
verification logs and checksum files.

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
                     

