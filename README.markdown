# Spindle: Sinai Palimpsests Project Image Delivery scripts

Spindle is a set of scripts for the preparation and delivery of data to 
the Sinai Palimpsests Project repository.

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
  * Because of the proceeding, the `data` directory should contain **only core
    data files**; work product and incidental files should not be included in
    the `data` folder
  * The only allowable extensions are '.tif' and '.jpg' in lower case
    characters; for example, '.tiff', '.TIF', '.jpeg', and '.jpg' will
    invalidate the archive

All the scripts below assume this structure and use it for the creation of 
verification logs and checksum files.

Processed image delivery preparation has the following steps:

* Verification of correct file name formats -- `verify_filenames.sh`
    - Make sure filenames comply with project file naming rules
    - Status: Beta
    - TODO add delivery/receipt behavior

* Verification of the presence of expected metadata -- `verify_metadata.sh`
    - Make sure that file contain required metadata
    - Status: Beta
    - TODO add delivery/receipt behavior

* Creation of checksum lists for all files -- `create_checksums.sh`
    - Generate a manifest for delivered data
    - Status: Beta
    - TODO add delivery/receipt behavior

* Final verification for delivery -- `verify_delivery.sh`
    - Make sure that all the required data is there
    - Status: Beta
    - TODO add delivery/receipt behavior
    - TODO Check for ERROR files
    - TODO Check for `LOG_verify_filenames.log`
    - TODO Check for `LOG_verify_metadata.log`
    - TODO Check manifest-md5s.txt date
    - TODO Check manifest-md5s.txt file lists
    - TODO confirm all data files younger than logs and manifest
    

* Creation of tar archive of data

# Ingest of processed images

The ingest of delivered processed images has the following steps:

* Untarring of data to staging

* Verification of readiness for delivery -- `verify_delivery.sh`

* Verification of checksums for all files -- `verify_checksums.sh`

* Verification of correct file name formats -- `verify_filenames.sh`

* Verification of the presence of expected metadata -- `verify_metadata.sh`

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
                     

