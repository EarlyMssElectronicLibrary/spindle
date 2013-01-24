# Sinai Palimpsests Project Digital Release
# README Document for @SHELFMARK@

Authors:

 - Doug Emery
 - Michael Phelps

## PILOT NOTES

Thank you for participating in the Sinai Palimpsests Project's pilot phase.

Please note that, because this is a Pilot, some compromises have been made in
the assembly of this data set. 

While these are first-quality images, they are an arbitrarily selected subset
of the processed data. For any given folio, project scientists generate a
standard set of 28 images, and may generate over 40 images in total.  Of
those possible 40 images, typically only a few are optimally useful for
reading the undertext, but we generate images to cover a range of
permutations and results.  As a part of our Pilot effort we are sharing with
you a selection of the core 28 images that most often render the best
results, these are the nine "KTK" images in each image folder.  We also
include a number of custom processed images.  Our goal in making these
selections is two-fold: to discover the utility of the selected images for
text characterization and to choose a number of images that will provide
ample views for deciphering the text and will also be manageable in its size.
One alternative, one we chose against, would be to provide 28 to 40 or more
images of each folio.

We are interested in your opinion of the image quality and of the number of
images provided, whether (as Goldilocks would put it) it is too big, too
small, or just right.

The selected images are in the "core" data and can be found in the 'Data'
folder.  These are supplemented by the remainder of the custom images, which
have been placed in the data set's 'ResearchContrib/Data' directory.
  
Also, please note that there may be inaccuracies in this ReadMe file.

## 1 Sinai Palimpsest: @SHELFMARK@

This data set contains JPEG images of a manuscript imaged under the Sinai
Palimpsests Project.  The purpose of this data set is to provide support for
the characterization of all erased texts of the same language and script found
in a single manuscript.  Please note that typically only palimpsested folios
are imaged, and many palimpsests in the St. Catherine's collection contain
more than undertext language and script.  As such, these images are of only
those folios containing undertexts of the selected language and script, and may
not represent all palimpsest folios from the manuscript.  

## 2 Rights and Conditions of Use

Unless otherwise indicated, all images in this data set are Copyright (c) @YEAR@
St. Catherine's Monastery at Mount Sinai.  All rights reserved. 

No permission is granted to distribute or publish this data set or any of its
contents.

## 3 Intended Audience and Consumers

This data set is intended solely for the use of the party to which it has been
given.  It is designed for scholar use for the identification of palimpsest
undertexts.

## 4 Palimpsest Data Set Purpose

This data set is contains images and supporting information for all palimpsest
folios of a single undertext layer for a single manuscript.  For example, if a
hypothetical manuscript Greek 123 contains Syriac and Greek uncial undertext
layers, a data would contain images of all folios with Syriac undertext or all
folios with Greek uncial undertext.

## 5 Data Set Contents

This data set consists of:

1.  a *core* content set digital images of the subject manuscript: `Data`

2.  a directory for researcher contributed content files, not a part
    of the core data set: `ResearchContrib`

### 5.1 Core Data Content

The core content of images and supporting metadata is the focus of the data
set.  For each folio, a comprehensive set of registered images is provided of
each folio containing the selected undertext layers.

The core data includes:

-   Image data consisting of high-resolution JPEG versions of processed images
    of several types intended to enhance visibility of the under text, and 
    a color _surrogate_ images of each folio

#### 5.1.1 Processing types

The images in this data set may include the following processing types:

- `DJK_ICA_01_2` Grayscale Band of image: RGB image created from an ICA of
  reflective, fluourescent, and transmissive bands. 

- `DJK_ICA_01_RGB` RGB image created from an ICA of reflective, fluourescent,
  and transmissive bands. 

- `KTK_pseudo_WBUVB47-MB625Rd` -- A pseudocolor image combines two processed
  images, one from an ultraviolet separation and the other from a visible
  separation.  The erased text is visible in the UV image and not in the
  visible, so it appears as colored in the pseudocolor image.  The upper text
  appears as gray or black, i.e. without color.  The images are locally
  adjusted in contrast so that all 500x500 pixel regions have the same mean and
  variance.  The UV processed image is put in the red separation of the
  pseudocolor image and the visible image in the other two separations.  For
  this image, the UV image was the WBUVB47 separation and the visible image was
  the MB625Rd separation.

- `KTK_pseudo_WBUVB47-VIS` -- A pseudocolor image combines two processed
  images, one from an ultraviolet separation and the other from a visible
  separation.  The erased text is visible in the UV image and not in the
  visible, so it appears as colored in the pseudocolor image.  The upper text
  appears as gray or black, i.e. without color.  The images are locally
  adjusted in contrast so that all 500x500 pixel regions have the same mean and
  variance.  The UV processed image is put in the red separation of the
  pseudocolor image and the visible image in the other two separations.  For
  this image, the UV image was the WBUVB47 separation and the visible image was
  the MB470LB+MB535Gr+MB625Rd separation.

- `KTK_pseudo_WBUVG61-MB625Rd` -- A pseudocolor image combines two processed
  images, one from an ultraviolet separation and the other from a visible
  separation.  The erased text is visible in the UV image and not in the
  visible, so it appears as colored in the pseudocolor image.  The upper text
  appears as gray or black, i.e. without color.  The images are locally
  adjusted in contrast so that all 500x500 pixel regions have the same mean and
  variance.  The UV processed image is put in the red separation of the
  pseudocolor image and the visible image in the other two separations.  For
  this image, the UV image was the WBUVG61 separation and the visible image was
  the MB625Rd separation.

- `KTK_pseudo_WBUVG61-VIS` -- A pseudocolor image combines two processed
  images, one from an ultraviolet separation and the other from a visible
  separation.  The erased text is visible in the UV image and not in the
  visible, so it appears as colored in the pseudocolor image.  The upper text
  appears as gray or black, i.e. without color.  The images are locally
  adjusted in contrast so that all 500x500 pixel regions have the same mean and
  variance.  The UV processed image is put in the red separation of the
  pseudocolor image and the visible image in the other two separations.  For
  this image, the UV image was the WBUVG61 separation and the visible image was
  the MB470LB+MB535Gr+MB625Rd separation.

- `KTK_pseudo_WBUVR25-MB625Rd` -- A pseudocolor image combines two processed
  images, one from an ultraviolet separation and the other from a visible
  separation.  The erased text is visible in the UV image and not in the
  visible, so it appears as colored in the pseudocolor image.  The upper text
  appears as gray or black, i.e. without color.  The images are locally
  adjusted in contrast so that all 500x500 pixel regions have the same mean and
  variance.  The UV processed image is put in the red separation of the
  pseudocolor image and the visible image in the other two separations.  For
  this image, the UV image was the WBUVR25 separation and the visible image was
  the MB625Rd separation.

- `KTK_pseudo_WBUVR25-VIS` -- A pseudocolor image combines two processed
  images, one from an ultraviolet separation and the other from a visible
  separation.  The erased text is visible in the UV image and not in the
  visible, so it appears as colored in the pseudocolor image.  The upper text
  appears as gray or black, i.e. without color.  The images are locally
  adjusted in contrast so that all 500x500 pixel regions have the same mean and
  variance.  The UV processed image is put in the red separation of the
  pseudocolor image and the visible image in the other two separations.  For
  this image, the UV image was the WBUVR25 separation and the visible image was
  the MB470LB+MB535Gr+MB625Rd separation.

- `KTK_sharpie_WBUVB47-MB625Rd` -- A sharpie image is the difference of the
  locally adjusted UV and visible separations of pseudocolor images.  Because
  the upper text appears the same in both, it tends to disappear, leaving only
  the erased text.  For this image, the UV image was the WBUVB47 separation and
  the visible image was the MB625Rd separation.

- `KTK_sharpie_WBUVG61-MB625Rd` -- A sharpie image is the difference of the
  locally adjusted UV and visible separations of pseudocolor images.  Because
  the upper text appears the same in both, it tends to disappear, leaving only
  the erased text.  For this image, the UV image was the WBUVG61 separation and
  the visible image was the MB625Rd separation.

- `KTK_sharpie_WBUVR25-MB625Rd` -- A sharpie image is the difference of the
  locally adjusted UV and visible separations of pseudocolor images.  Because
  the upper text appears the same in both, it tends to disappear, leaving only
  the erased text.  For this image, the UV image was the WBUVR25 separation and
  the visible image was the MB625Rd separation.

- `PSH_color` - Color image generated using the PhotoShoot application at time 
  of capture, using images of several of the visible wavelengths.

- `RLE_PCA_01` Grayscale band XX of RGB image created from a PCA of normalized
  reflective and blue fluourescent bands. 

- `RLE_PCA_RGB` RGB image created from PCA of reflective and UV fluourescent
  bands. 

- `WCB_PCA_DST_RGB` An RGB image is rendered using 3 component images from
  principal components analysis (PCA). PCA input and output images are
  normalized. As a final step the PCA image is hue shifted by 90 deg. using the
  ImageJ DStretch plugin.

- `WCB_PCA_PSU_DST_RGB` A pseudocolor RGB image is rendered using 2 component
  images from principal components analysis (PCA).The first component fills the
  R channel, while the second fills G and B channels. PCA input and output
  images are normalized. As a final step the pseudocolor image (PSU) has its
  saturation reduced by 1.414 using the ImageJ DStretch plugin (DST).

- `WCB_PCA_PSU_DST_RGB` A pseudocolor RGB image is rendered using 2 component
  images from principal components analysis (PCA).The first component fills the
  R channel, while the second fills G and B channels. PCA input and output
  images are normalized. As a final step the pseudocolor image (PSU) has its
  saturation reduced by 1.414 using the ImageJ DStretch plugin (DST).

- `WCB_PCA_PSU_RGB` A pseudocolor RGB image is rendered using 2 component
  images from principal components analysis (PCA).The first component fills the
  R channel, while the second fills G and B channels. PCA input and output
  images are normalized.

- `WCB_PCA_RGB` An RGB image is rendered using 3 component images from
  principal components analysis (PCA). PCA input and output images are
  normalized.

- `WCB_RGB` An RGB image is rendered using 3 normalized flattened images.

#### 5.1.3 File naming

All file names follow strict naming conventions to facilitate easy
identification of file type and content.

Note the following image file names:

     GrkNF-MG99_005r_20-07_KTK_pseudo_WBUVB47-MB625Rd.jpg
     GrkNF-MG99_005r_20-07_KTK_pseudo_WBUVB47-VIS.jpg
     GrkNF-MG99_005r_20-07_KTK_pseudo_WBUVG61-MB625Rd.jpg
     GrkNF-MG99_005r_20-07_KTK_pseudo_WBUVG61-VIS.jpg
     GrkNF-MG99_005r_20-07_KTK_sharpie_WBUVG61-MB625Rd.jpg
     GrkNF-MG99_005r_20-07_KTK_sharpie_WBUVR25-MB625Rd.jpg
     GrkNF-MG99_005r_20-07_PSH_color.jpg
     GrkNF-MG99_005r_20-07_WCB_PCA_RGB_01.jpg

Each file name has this structure:

`<SHELFMARK>_<FOLIOS><SHOT_SEQ>_<PROCESSOR>_<PROCESSING_TYPE>_<MODIFIERS>.<EXT>`

`SHELFMARK` is an abbreviated form of the imaged manuscript's shelf mark;
here, `GrkNF-MG99` for 'Greek NF MG 99'.

`FOLIOS` represents the folio or folios in the image scene; something like
`005v` or `frgs-1r-2r-3r`. The latter is for an image of multiple fragments
assigned the numbers '1r', '2r', and '3r'.

`SHOT_SEQ` is the database identifier of the shot sequence under which this
folio was imaged. Some folios are imaged more than once, and this number
prevents files of the same folio from having duplicate names.

`PROCESSOR` gives the initials of the party responsible for generating the
processed image. The processors are:

  * WCB: Will Christens-Barry
  * RLE: Roger Easton
  * DJK: Dave Kelbe
  * KTK: Keith Knox
  * PSH: The PhotoShoot application, which controls the camera and generates
    the `color` images at the time of capture

`PROCESSING_TYPE` is a word or code that indicates the method of processing
used of the type of the resulting image; for example, 'sharpie', 'pseudo',
'PCA'.

`MODIFIERS` is an optional field the processor can use to provide more detail
about processing parameters or methods, or to distinguish similarly named files
from one another using serial number '01', '02', etc. Full details of the
processing are provided in a tag in the image header: `DAT_File_Processing` (in
XMP notation, `ap:DAT_File_Processing`).

`EXT` is the file extension, either 'tif' or 'jpg'.

#### 5.1.2 Metadata

Each image is provided with descriptive metadata in its header giving full
details of the processing methods used to generate it.

The metadata for images complies with the Archimedes Palimpsest project
metadata standard, which is provided with this set as documentation. The
metadata provides investigative, data sharing and scientific information
on the images and transitions.

Metadata are data elements about the content, quality, condition, and
other characteristics of the data sets that make up the digital
holdings. Metadata records are produced according to rules and
definitions governing several subtypes:

1.  Identification Information
2.  Spatial Data Reference Information (images and spatial indexes,
    only)
3.  Imaging and Spectral Data Reference Information (images only)
4.  Data Type Information
5.  Data Content Information
6.  Metadata Reference Information

PILOT NOTE: Not all metadata is included with each image.

### 5.2 Contributed Research Files

This Contributed Research data is intended initially to include useful
and specialized images contributed to the project by image scientists.
These are images useful to scholars, but not integrated into the core
data set because, for example, they are not registered to core image
dimensions or they are not accompanied by complete metadata. Over the
life of the data set, this directory may be used to include carefully
vetted contributions that provide critical contributions to the data
set, such as conservation, codicological, and other information.

## 6 How to Use This Data Set

This data set contains supporting documentation to enable discovery of
the data and available access tools. The files named below may be
located by using the file 1\_FileList.txt which accompanies this ReadMe
file.

For General Orientation to the data set, see

-   0\_ReadMe.txt: this file

-   1\_FileIndex.txt: list of files in the data set
