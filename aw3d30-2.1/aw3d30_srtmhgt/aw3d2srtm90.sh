#!/usr/bin/env bash


INPUT_DIR=./input
OUTPUT_DIR=./output
vrtfile=./input.vrt


[ -d "$OUTPUT_DIR" ] || mkdir -p $OUTPUT_DIR || { echo "error: $OUTPUT_DIR " 1>&2; exit 1; }

gdalbuildvrt -overwrite -srcnodata -9999 -vrtnodata -9999 ${vrtfile} ${INPUT_DIR}/*_DSM.tif

res=`echo 1/1200/2 |bc -l`
for aw3d30 in  ${INPUT_DIR}/*_DSM.tif
do
   [ -f "${aw3d30}" ] || continue
   srtm=`echo ${aw3d30} | awk -F / '{print substr($NF,1,1)substr($NF,3,6)".hgt"}'`

   [ -f "${OUTPUT_DIR}/${srtm}" ] && { echo "skip ${srtm}" 1>&2; continue; }
   xmin=`echo ${aw3d30} | awk -F / 'substr($NF,5,1)=="E"{print substr($NF,6,3)*1} substr($NF,5,1)=="W"{print substr($NF,6,3)*(-1)}'`
   ymin=`echo ${aw3d30} | awk -F / 'substr($NF,1,1)=="N"{print substr($NF,2,3)*1} substr($NF,1,1)=="W"{print substr($NF,2,3)*(-1)}'`
   xmax=`echo ${xmin}+1 | bc`
   ymax=`echo ${ymin}+1 | bc`
   xmin=`echo ${xmin}-${res} | bc`
   ymin=`echo ${ymin}-${res} | bc`
   xmax=`echo ${xmax}+${res} | bc`
   ymax=`echo ${ymax}+${res} | bc`
   gdalwarp -wt Float64 -ot Int16 -te ${xmin} ${ymin} ${xmax} ${ymax} -dstnodata -9999 -ts 1201 1201 -r bilinear ${vrtfile} ${OUTPUT_DIR}/${srtm}-nodata.tif
   gdal_calc.py --NoDataValue=0 --calc="(A > 0) * A" -A ${OUTPUT_DIR}/${srtm}-nodata.tif --outfile=${OUTPUT_DIR}/${srtm}-nodata0.tif
   gdal_translate ${OUTPUT_DIR}/${srtm}-nodata0.tif -a_nodata none -of SRTMHGT ${OUTPUT_DIR}/${srtm}
   rm -f ${OUTPUT_DIR}/${srtm}.tif ${OUTPUT_DIR}/${srtm}-nodata.tif ${OUTPUT_DIR}/${srtm}-nodata0.tif

done

rm $vrtfile
