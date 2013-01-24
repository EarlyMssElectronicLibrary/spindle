=================================================
Syriac Palimpsest Digital Release README Document
=================================================

:Authors: Mike Toth, Siam Bhayro, Doug Emery
:Date: July 9, 2010

.. contents::
..
  1 The Syriac Galen Palimpsest
  2 Rights and Conditions of Use
  3 Intended Audience and Consumers
  4 Digital Project Data Set Purpose
  5 Data Set Contents
    5.1 Core Data Content
    5.2 Documentation
        5.2.1 External Documentation
        5.2.2 Internal Documentation
    5.3 Supporting Functional Files
    5.4 Supplemental Files
    5.5 Contributed Research Files
  6 How to Use This Data Set
    6.1 General Orientation
    6.2 Metadata
    6.2 Computer Access Tools
    6.3 Scientific Information

1 The Syriac Galen Palimpsest
=============================

This manuscript contains an eleventh-century liturgical text that is
very important for the study of the hymns of Byzantine and Melkite
Christianity. The manuscript's value is further increased by the fact
that it is a palimpsest, with an older and very significant
undertext. The undertext dates back to approximately the ninth
century, and contains Syriac translations of Greek medical
texts. Preliminary investigations have identified several leaves from
Galen's major pharmacological treatise, known in Latin as De
Simplicium Medicamentorum Temperamentis et Facultatibus, and in the
Syriac and Arabic traditions as the "Book of Simple Drugs". The
translation seems to be by Sergius of Resh Ayina, the great
sixth-century scholar who was the first to translate the Greek medical
corpus and who laid the foundations for the transmission of Greek
science into the Islamic world. Part of the same text has been
preserved in a British Library manuscript, which is useful for
comparison, but the palimpsest is much larger. For further reading,
see S. Bhayro, "Syriac Medical Terminology: Sergius and Galen's
Pharmacopia" in Aramaic Studies 3 (2005), pp. 147-165.


2 Rights and Conditions of Use
===============================

The Syriac Palimpsest data is released with license for use under
Creative Commons Attribution 3.0 Unported Access Rights. It is
requested that copies of any published articles based on the
information in this data set be sent to The Curator of Manuscripts,
The Walters Art Museum, 600 North Charles Street, Baltimore MD 21201.

3 Intended Audience and Consumers
=================================

The Syriac Palimpsest Digital Product is intended to serve any
interested user or party.  However, its content is focused on serving
the following groups.

 1. Scholars of Greek and mathematics
 2. Application providers
 3. Libraries and archives
 4. Image scientists, and scientists in other disciplines interested
    in the production of the images
 
4 Digital Project Data Set Purpose
==================================

The Syriac Palimpsest Digital Product provides all the digital
information available on the Syriac Palimpsest in a single digital
data set, with a standard structure.  Its purposes are twofold:
 
 1. Serve as the authoritative digital data set of images in a
    standardized format that meets the needs of users, information
    providers, archives and libraries.
 
 2. Offer a standard product sustainable by users to which current or
    future contributors can add additional standardized information
    (e.g. alternate texts, image analyses or conservation
    information).


5 Data Set Contents
====================

This data set consists of:

  1. a *core* content set digital images of the Syriac Palimpsest,
     each with accompanying metadata and checksums

  2. project-generated and third-party documentation of all included
     components

  3. supporting functional files, including XML schemas, and cascading
     style sheet files

  4. supplemental versions of the transcriptions by treatise and work

  5. a directory for researcher contributed content files, not a part
     of the core data set


5.1 Core Data Content
---------------------

The core content of images and supporting metadata is the focus of the
Digital Product.  For each folio, a comprehensive set of registered
images is provided of the palimpsest.

The core data includes:

   * Image data consisting of large 8-bit image files, including
     requantized raw images, processed pseudo-color images. All these
     files include embedded metadata and metadata files.

The following image types are provided:

 * "Pack 8" 8-bit versions of all captured images
 * "Pseudo-color" images for all folios
 * "Sharpie" monochrome versions of the pseudo-color images that show
   the under text with the over-text digital removed for all folios
 * A "color sharpie" image, created by placing the three sharpie
   images generated from the red, green, and blue filter color images
   into the red, green, and blue channels of a single image for all
   but the following folios: 197r-204v, 207v-211r, 222r, 222v, 224r,
   and 225v; in these six cases the color sharpie process did not
   generate useful images
 * A color image generated from five of the visible-light image
   captures for each folio
 * Principal Component Analisys (PCA) images for a select group of
   images
 
For each folio in the palimpsest, the data set provides:

 * All eight-bit raw and processed registered TIFF images for the
   directory's folio
 * An XMP metadata file for each of the TIFF files in the directory
 * An MD5 checksum file for each of the TIFF and XML content files

All file names follow strict naming conventions to facilitate easy
identification of file type and content.

In addition to its images, each content directory provides
preservation information in the form of:

 * Metadata embedded in image files
 * XMP metadata files for each image
 * MD5 checksum data for all TIFF files to ensure their fixity

The metadata for images complies with the Archimedes Palimpsest
project metadata standard, which is provided with this set as
documentation.  The metadata provides investigative, data sharing and
scientific information on the images and transitions.

Metadata are data elements about the content, quality, condition, and
other characteristics of the data sets that make up the digital
holdings. Metadata records are produced according to rules and
definitions governing several subtypes:

 1. Identification Information
 2. Spatial Data Reference Information (images and spatial indexes,
    only)
 3. Imaging and Spectral Data Reference Information (images only)
 4. Data Type Information
 5. Data Content Information
 6. Metadata Reference Information 

5.2 Documentation
-----------------

Documents are provided to fully describe the contents of the data set
and facilitate their use.  There are both *external* and *internal*
documents.  External documents detail data standards, file
specifications, and technologies used by the project, such as the TIFF
specification, MD5 checksum algorithm, and various XML-related
technologies.  Internal documents detail project data standards and
practices, image processing algorithms, and information required to
use the data set not detailed in the external documentation.

5.2.1 External Documentation
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

External documentation includes:

 * CSS 2.1
 * Dublin Core - rfc5013.txt
 * GIF89a
 * ITU Recomendation T81 (JPEG)
 * HTML 4.0
 * MD5 hash - rfc1321.txt
 * PDF 1.7
 * PNG
 * SVG1.1
 * TIFF 6.0
 * XHTML 1.0
 * XML 1.0 
 * XML Schema
 * XSL1.1
 * Unicode
   - Unicode Code charts
   - Unicode specifications and technical reports
 * ZIP file format specification 6.3.2

5.2.2 Internal Documentation
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Internal documentation includes:
 
 * Archie Image Manipulation software documentation
   - Manual
 * File Naming Conventions 
 * Folio Index
 * MD5 How-To
 * Metadata Data Dictionary
 * Metadata Standard

5.3 Supporting Functional Files
-------------------------------

The data set provides supporting files needed to share or work with
the Digital Product content data.  Primarily these files are XML
schema documents used to validate and process transcription, spatial
index, and metadata files in XML format.  The following supporting
file collections are included.

 * Archimedes-Palimpsest: Custom XML schema files for working with
   project metadata XML files and custom mapped transcription formats

 * Dublin-Core: XML schema files for the Dublin Core metadata elements

5.4 Supplemental Files
----------------------

The purpose of the Supplemental material is to provide alternate
presentations of source material used to generate text and other
content supplied with the core data. There are no supplemental files
for the Syriac Palimpsest.

5.5 Contributed Research Files
------------------------------

This Contributed Research data is intended initially to include useful
and specialized images contributed to the project by image scientists.
These are images useful to scholars, but not integrated into the core
data set because, for example, they are not registered to core image
dimensions or they are not accompanied by complete metadata.  Over the
life of the data set, this directory may be used to include carefully
vetted contributions that provide critical contributions to the data
set, such as conservation, codicological, and other information.

6 How to Use This Data Set
==========================

This data set contains supporting documentation to enable discovery of
the data and available access tools.  The files named below may be
located by using the file 1_FileList.txt which accompanies this ReadMe
file.

6.1 General Orientation
-----------------------

For General Orientation to the data set, see

 * 0_ReadMe.txt: this file

 * 1_FileIndex.txt: list of files in the data set

 * FileNamingConventions.txt: a description of naming conventions for
   image, XML, and MD5 files

 * FolioIndex.txt: a list of the Syriac Palimpsest folios by over-text
   folio

 * MD5_README.txt: a brief how-to on using MD5 files to confirm the
   integrity of content files

6.2 Metadata
------------

Metadata information for the images and transcriptions is described in
several supporting documents.

 * Image_Metadata_Standard.pdf: The projects imaging metadata standard
   document.

 * MetadataDataDictionary.txt: A complete dictionary of the metadata
   elements used in all contexts

 * rfc5013.txt: Dublin Core metadata elements

 * DCMI_Metadata_Terms: Dublin Core metadata term specification

6.2 Computer Access Tools
-------------------------

For machine access to the files in this data set the following files
can be used.

 * XML schemas and DTDs for working with content XML files, including
   TEI, DublinCore, and custom schemas created for the data set


6.3 Scientific Information
--------------------------

The included scientific texts provide descriptions of image capture
and processing techniques used to create the data set.

 * Archie_1.0.pdf: Documentation of the Archie 1.0 image manipulation
   software suite

