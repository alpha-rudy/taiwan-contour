-------------------------------------------------------------------
AW3D30 Geotiff to SRTM HGT Converter / Sample Script
-------------------------------------------------------------------

(a) System requirements
This sample script operates with Linux system, and requires "GDAL",
"bash", and "awk".  We also confirmed that the script works on the
following environment except for Linux system.

  Windows10 +  Cygwin 2.8.2 ( https://www.cygwin.com/ )
  Windows10 +  OSgeo4W ( https://trac.osgeo.org/osgeo4w/ )


(b) File list
 aw3d30_srtmhgt.zip
     aw3d2srtm.sh : Script for convert 
     input  : Input folder (AW3D30)  * It contains a sample folder.
     output : Output folder (SRTM HGT)  * It contains a sample folder.


(c) How to use
  1. Saving the Geotiff file of AW3D30 into the input folder. 

  2. Executing the script 
     > bash aw3d2srtm.sh

  3. The "HGT" file is created in output folder. 


(d) Processing flow within the script
  1. Composing the input files within the input folder and merging into
     one  file (vrtfile). 

  2. Performing the resampling to the grid of the SRTM HGT, and subset
     into 1 x 1 degrees Lat/long frame (geotiff). 

  3. The data (geotiff) converts to SRTM HGT. 

(e) Note: Usage of script
To perform resampling of the edge portion of the tile accurately,
you need to input not only the tile you want to convert but also
surrounding tiles.  Please prepare the AW3D30 tile files for larger
areas than your target area.

(f) Disclaimers
Regardless of the reason, JAXA shall not be made liable for any damage
or loss as a result of use of this sample script.


(g) Link
Japan Aerospace Exploration Agency
Earth Observation Research Center
ALOS Global Digital Surface Model "ALOS World 3D - 30m"(AW3D30)
http://www.eorc.jaxa.jp/ALOS/en/aw3d30/
