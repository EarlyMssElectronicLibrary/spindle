# Spindle: Sinai Palimpsests Project Image Delivery scripts

This is Spindle, a set of scripts for the preparation and delivery of 
repository images.

# Delivery of processed images

Processed image delivery preparation has the following steps:

* Verification of correct file name formats -- `verify_filenames.sh`

* Verification of the presence of expected metadata -- `verify_delivery.sh`

* Creation of checksum lists for all files -- `create_checksums.sh`

* Final verification for delivery -- `verify_delivery.sh`

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
