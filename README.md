realasking.APBC
===============

Automatic Photo Border Creator (APBC) version 1.0

Author:realasking
E-mail: realasking@mdbbs.org
Blog:   http://realasking.github.io

Brief introduction

This package helps you to add borders with exif information, watermarks automatically,
and you can also use it to resize your photo to a regular size for developing.
In order to use this package, bash，imagemagick，bc，exiv2 and exiftool should been
installed first.

These scripts are written for personal use only, no support or warranty will be provided.
But if you had some suggestions or found any bug, please let me know.

Installation and configuration

1.Copy photo_exif.sh、photo_exif_DSLR.sh and photo_pre_for_print.sh to one of your
directory which has been specified in your $PATH variable. Don't forget to add execute 
permissions.

2.Edit photo_exif.sh and photo_exif_DSLR.sh，change Machine="Panasonic DMC-ZS8" or 
Machine="Olympus E-pl1" to your camera model.

3.Edit WFONT="/usr/local/share/fonts/u/urw_chancery_l_medium_italic.ttf" to a font which
you wanted to be used in watermarks.

4.Edit FONT="文泉驿点阵正黑" to a font name for add exif information to borders.

5.Change fact_watermark_font_width will adjust the size of watermarks.

6.Change fact_author_place will adjust the position on border to print author name.

Usage

1.Add borders with exif information and watermarks automatically

Running the command below if you are using a compact digital camera:

$photo_exif.sh photo_name new_width author directory_for_saving_processed_photos

If you are using a DSLR or EVIL, please use photo_exif_DSLR.sh.

2.Resize a photo to regular size for developing and add borders and watermarks at the same time

Running the command below:

$photo_pre_for_print.sh photo_name author model directory_for_saving_processed_photos camera_type

You can use 3R, 3D, 4R, 4D, 5R, 6R, 8R, 1366 as your choosing model, camera_type could be DC or DSLR.

