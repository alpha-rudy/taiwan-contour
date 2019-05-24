.DELETE_ON_ERROR:

ifeq ($(shell uname),Darwin)
MD5_CMD := md5 -q $$EXAM_FILE
JMC_CMD := jmc/osx/jmc_cli
SED_CMD := gsed
else
MD5_CMD := md5sum $$EXAM_FILE | cut -d' ' -f1
JMC_CMD := jmc/linux/jmc_cli
SED_CMD := sed
endif

.PHONY: all clean
all: taiwan-contour taiwan-contour-mix taiwan-lite-contour-mix

clean:
	git clean -fdx

OUTPUTS=-co compress=LZW -of GTiff
NODATA_VALUE=-999


moi-2016/penghu-10_100_500-contour.pbf: moi-2016/phDEM_20m-zero.tif
	phyghtmap \
		--step=10 \
		--no-zero-contour \
		--output-prefix=penghu_contour \
		--line-cat=500,100 \
		--jobs=8 \
		--osm-version=0.6 \
		--start-node-id=0 \
		--start-way-id=0 \
		--max-nodes-per-tile=0 \
		--max-nodes-per-way=2000 \
		--simplifyContoursEpsilon=0.00002 \
		--void-range-max=-500 \
		--pbf \
		$^
	mv penghu_contour* $@


moi-2016/penghu-20_100_500-contour.pbf: moi-2016/phDEM_20m-zero.tif
	phyghtmap \
		--step=20 \
		--no-zero-contour \
		--output-prefix=penghu_lite_contour \
		--line-cat=500,100 \
		--jobs=8 \
		--osm-version=0.6 \
		--start-node-id=0 \
		--start-way-id=0 \
		--max-nodes-per-tile=0 \
		--max-nodes-per-way=2000 \
		--simplifyContoursEpsilon=0.00005 \
		--void-range-max=-500 \
		--pbf \
		$^
	mv penghu_lite_contour* $@


moi-2016/dem_20m.tif: moi-2016/.unzip
moi-2016/phDEM_20m_119.tif: moi-2016/.unzip
moi-2016/.unzip: moi-2016/dem_20m.7z.001
	cd moi-2016/ && \
	7za x dem_20m.7z.001
	touch $@


.POHNY: dem2018-orig
dem2018-orig: moi-2018/.unzip
moi-2018/DEM_20m.tif:
	cd moi-2018/ && \
	7za x DEM_20m.7z.001
	touch $@


moi-2016/phDEM_20m-wgs84.tif: moi-2016/phDEM_20m_119.tif
	rm -f $@
	gdalwarp \
		$(OUTPUTS) \
		-dstnodata $(NODATA_VALUE) \
		-r bilinear \
		-t_srs 'EPSG:4326' \
	  $^ \
	  $@


moi-2016/dem_20m-wgs84.tif: moi-2016/dem_20m.tif
	rm -f $@
	gdalwarp \
		$(OUTPUTS) \
		-dstnodata $(NODATA_VALUE) \
		-r bilinear \
		-t_srs 'EPSG:4326' \
	  $^ \
	  $@


.PHONY: dem2018-wgs84
dem2018-wgs84: moi-2018/DEM_20m-wgs84.tif
moi-2018/DEM_20m-wgs84.tif: moi-2018/DEM_20m.tif
	rm -f $@
	gdalwarp \
		$(OUTPUTS) \
		-dstnodata $(NODATA_VALUE) \
		-r bilinear \
		-t_srs 'EPSG:4326' \
	  $^ \
	  $@


moi-2018/from2016.tif: moi-2016/dem_20m-zero.tif
	rm -f $@
	gdalwarp \
		$(OUTPUTS) \
		-dstnodata $(NODATA_VALUE) \
		-crop_to_cutline \
		-cutline moi-2018/void_area.shp \
		$^ \
		$@


moi-2016/phDEM_20m-nodata.tif: moi-2016/phDEM_20m-wgs84.tif
	rm -f $@
	gdal_merge.py \
		$(OUTPUTS) \
		-n $(NODATA_VALUE) -a_nodata $(NODATA_VALUE) \
		$^ \
		-o $@


moi-2016/dem_20m-nodata.tif: moi-2016/dem_20m-wgs84.tif
	rm -f $@
	gdal_merge.py \
		$(OUTPUTS) \
		-n $(NODATA_VALUE) -a_nodata $(NODATA_VALUE) \
		$^ \
		-o $@


.PHONY: dem2018-nodata
dem2018-nodata: moi-2018/DEM_20m-nodata.tif
moi-2018/DEM_20m-nodata.tif: moi-2018/from2016.tif moi-2018/DEM_20m-wgs84.tif
	rm -f $@
	gdal_merge.py \
		$(OUTPUTS) \
		-n $(NODATA_VALUE) -a_nodata $(NODATA_VALUE) \
		$^ \
		-o $@


moi-2016/phDEM_20m-nodata0.tif: moi-2016/phDEM_20m-nodata.tif
	rm -f $@
	gdal_calc.py \
		--NoDataValue=0 \
		--calc="(A > 0) * A" \
		-A $^ \
		--outfile=$@


moi-2016/dem_20m-nodata0.tif: moi-2016/dem_20m-nodata.tif
	rm -f $@
	gdal_calc.py \
		--NoDataValue=0 \
		--calc="(A > 0) * A" \
		-A $^ \
		--outfile=$@


moi-2018/DEM_20m-nodata0.tif: moi-2018/DEM_20m-nodata.tif
	rm -f $@
	gdal_calc.py \
		--NoDataValue=0 \
		--calc="(A > 0) * A" \
		-A $^ \
		--outfile=$@


moi-2016/phDEM_20m-zero.tif: moi-2016/phDEM_20m-nodata0.tif
	rm -f $@
	gdal_translate \
		$(OUTPUTS) \
		-a_nodata none \
		$^ \
		$@


moi-2016/dem_20m-zero.tif: moi-2016/dem_20m-nodata0.tif
	rm -f $@
	gdal_translate \
		$(OUTPUTS) \
		-a_nodata none \
		$^ \
		$@


.PHONY: dem2018-zero
dem2018-zero: moi-2018/DEM_20m-zero.tif
moi-2018/DEM_20m-zero.tif: moi-2018/DEM_20m-nodata0.tif
	rm -f $@
	gdal_translate \
		$(OUTPUTS) \
		-a_nodata none \
		$^ \
		$@


moi-2016/taiwan-10_100_500-contour.pbf: moi-2016/dem_20m-zero.tif
	phyghtmap \
		--step=10 \
		--no-zero-contour \
		--output-prefix=dem_contour \
		--line-cat=500,100 \
		--jobs=8 \
		--osm-version=0.6 \
		--start-node-id=0 \
		--start-way-id=0 \
		--max-nodes-per-tile=0 \
		--max-nodes-per-way=2000 \
		--simplifyContoursEpsilon=0.000002 \
		--void-range-max=-500 \
		--pbf \
		$^
	mv dem_contour* $@


.PHONY: dem2018-contour
dem2018-contour: moi-2018/dem2018-contour.pbf
moi-2018/dem2018-contour.pbf: moi-2018/DEM_20m-zero.tif
	phyghtmap \
		--step=10 \
		--no-zero-contour \
		--output-prefix=dem_contour \
		--line-cat=500,100 \
		--jobs=8 \
		--osm-version=0.6 \
		--start-node-id=0 \
		--start-way-id=0 \
		--max-nodes-per-tile=0 \
		--max-nodes-per-way=2000 \
		--simplifyContoursEpsilon=0.00002 \
		--void-range-max=-500 \
		--pbf \
		$^
	mv dem_contour* $@


moi-2016/penghu-10_50_100_500-contour.pbf: moi-2016/penghu-10_100_500-contour.pbf
	rm -f $@
	python3 tools/elevation_sub.py $< $@


moi-2016/taiwan-10_50_100_500-contour.pbf: moi-2016/taiwan-10_100_500-contour.pbf
	rm -f $@
	python3 tools/elevation_sub.py $< $@


moi-2018/dem2018-contour-sub.pbf: moi-2018/dem2018-contour.pbf
	rm -f $@
	python3 tools/elevation_sub.py $< $@


moi-2016/taiwan-20_100_500-contour.pbf: moi-2016/dem_20m-zero.tif
	phyghtmap \
		--step=20 \
		--no-zero-contour \
		--output-prefix=dem_lite_contour \
		--line-cat=500,100 \
		--jobs=8 \
		--osm-version=0.6 \
		--start-node-id=0 \
		--start-way-id=0 \
		--max-nodes-per-tile=0 \
		--max-nodes-per-way=2000 \
		--simplifyContoursEpsilon=0.000005 \
		--void-range-max=-500 \
		--pbf \
		$^
	mv dem_lite_contour* $@


moi-2018/dem2018-lite-contour.pbf: moi-2018/DEM_20m-zero.tif
	phyghtmap \
		--step=20 \
		--no-zero-contour \
		--output-prefix=dem_lite_contour \
		--line-cat=500,100 \
		--jobs=8 \
		--osm-version=0.6 \
		--start-node-id=0 \
		--start-way-id=0 \
		--max-nodes-per-tile=0 \
		--max-nodes-per-way=2000 \
		--simplifyContoursEpsilon=0.00005 \
		--void-range-max=-500 \
		--pbf \
		$^
	mv dem_lite_contour* $@


.PHONY: aw3d-orig
aw3d-orig: aw3d30/.unzip
aw3d30/.unzip:
	cd aw3d30/ && \
	7za x aw3d30.7z.001
	touch $@


aw3d30/n3islets-data0.tif: aw3d30/.unzip
	rm -f $@
	gdalwarp \
		$(OUTPUTS) \
		-crop_to_cutline \
		-cutline aw3d30/n3islets.shp \
		-dstnodata 0 \
		aw3d30/N025E122_AVE_DSM.tif \
		$@


.PHONY: n3islets-zero
n3islets-zero: aw3d30/n3islets-zero.tif
aw3d30/n3islets-zero.tif: aw3d30/n3islets-data0.tif
	rm -f $@
	gdal_translate \
		$(OUTPUTS) \
		-a_nodata none \
		$^ \
		$@


.PHONY: n3islets-contour
n3islets-contour: aw3d30/n3islets-contour.pbf
aw3d30/n3islets-contour.pbf: aw3d30/n3islets-zero.tif
	phyghtmap \
		--step=10 \
		--no-zero-contour \
		--output-prefix=n3islets_contour \
		--line-cat=500,100 \
		--jobs=8 \
		--osm-version=0.6 \
		--start-node-id=0 \
		--start-way-id=0 \
		--max-nodes-per-tile=0 \
		--max-nodes-per-way=2000 \
		--simplifyContoursEpsilon=0.00005 \
		--void-range-max=-500 \
		--pbf \
		$^
	mv n3islets_contour* $@


.PHONY: n3islets-lite-contour
n3islets-lite-contour: aw3d30/n3islets-lite-contour.pbf
aw3d30/n3islets-lite-contour.pbf: aw3d30/n3islets-zero.tif
	phyghtmap \
		--step=20 \
		--no-zero-contour \
		--output-prefix=n3islets_lite_contour \
		--line-cat=500,100 \
		--jobs=8 \
		--osm-version=0.6 \
		--start-node-id=0 \
		--start-way-id=0 \
		--max-nodes-per-tile=0 \
		--max-nodes-per-way=2000 \
		--simplifyContoursEpsilon=0.000125 \
		--void-range-max=-500 \
		--pbf \
		$^
	mv n3islets_lite_contour* $@


aw3d30/matsu-data0.tif: aw3d30/.unzip
	rm -f $@
	gdalwarp \
		$(OUTPUTS) \
		-crop_to_cutline \
		-cutline aw3d30/matsu.shp \
		-dstnodata 0 \
		aw3d30/N026E119_AVE_DSM.tif \
		aw3d30/N026E120_AVE_DSM.tif \
		aw3d30/N025E119_AVE_DSM.tif \
		$@


.PHONY: matsu-zero
matsu-zero: aw3d30/matsu-zero.tif
aw3d30/matsu-zero.tif: aw3d30/matsu-data0.tif
	rm -f $@
	gdal_translate \
		$(OUTPUTS) \
		-a_nodata none \
		$^ \
		$@


.PHONY: matsu-contour
matsu-contour: aw3d30/matsu-contour.pbf
aw3d30/matsu-contour.pbf: aw3d30/matsu-zero.tif
	phyghtmap \
		--step=10 \
		--no-zero-contour \
		--output-prefix=matsu_contour \
		--line-cat=500,100 \
		--jobs=8 \
		--osm-version=0.6 \
		--start-node-id=0 \
		--start-way-id=0 \
		--max-nodes-per-tile=0 \
		--max-nodes-per-way=2000 \
		--simplifyContoursEpsilon=0.00005 \
		--void-range-max=-500 \
		--pbf \
		$^
	mv matsu_contour* $@


.PHONY: matsu-lite-contour
matsu-lite-contour: aw3d30/matsu-lite-contour.pbf
aw3d30/matsu-lite-contour.pbf: aw3d30/matsu-zero.tif
	phyghtmap \
		--step=20 \
		--no-zero-contour \
		--output-prefix=matsu_lite_contour \
		--line-cat=500,100 \
		--jobs=8 \
		--osm-version=0.6 \
		--start-node-id=0 \
		--start-way-id=0 \
		--max-nodes-per-tile=0 \
		--max-nodes-per-way=2000 \
		--simplifyContoursEpsilon=0.000125 \
		--void-range-max=-500 \
		--pbf \
		$^
	mv matsu_lite_contour* $@


aw3d30/wuqiu-data0.tif: aw3d30/.unzip
	rm -f $@
	gdalwarp \
		$(OUTPUTS) \
		-crop_to_cutline \
		-cutline aw3d30/wuqiu.shp \
		-dstnodata 0 \
		aw3d30/N024E119_AVE_DSM.tif \
		$@


.PHONY: wuqiu-zero
wuqiu-zero: aw3d30/wuqiu-zero.tif
aw3d30/wuqiu-zero.tif: aw3d30/wuqiu-data0.tif
	rm -f $@
	gdal_translate \
		$(OUTPUTS) \
		-a_nodata none \
		aw3d30/wuqiu-data0.tif \
		$@


.PHONY: wuqiu-contour
wuqiu-contour: aw3d30/wuqiu-contour.pbf
aw3d30/wuqiu-contour.pbf: aw3d30/wuqiu-zero.tif
	phyghtmap \
		--step=10 \
		--no-zero-contour \
		--output-prefix=wuqiu_contour \
		--line-cat=500,100 \
		--jobs=8 \
		--osm-version=0.6 \
		--start-node-id=0 \
		--start-way-id=0 \
		--max-nodes-per-tile=0 \
		--max-nodes-per-way=2000 \
		--simplifyContoursEpsilon=0.00005 \
		--void-range-max=-500 \
		--pbf \
		$^
	mv wuqiu_contour* $@


.PHONY: wuqiu-lite-contour
wuqiu-lite-contour: aw3d30/wuqiu-lite-contour.pbf
aw3d30/wuqiu-lite-contour.pbf: aw3d30/wuqiu-zero.tif
	phyghtmap \
		--step=20 \
		--no-zero-contour \
		--output-prefix=wuqiu_lite_contour \
		--line-cat=500,100 \
		--jobs=8 \
		--osm-version=0.6 \
		--start-node-id=0 \
		--start-way-id=0 \
		--max-nodes-per-tile=0 \
		--max-nodes-per-way=2000 \
		--simplifyContoursEpsilon=0.000125 \
		--void-range-max=-500 \
		--pbf \
		$^
	mv wuqiu_lite_contour* $@


aw3d30/kinmen-data0.tif: aw3d30/.unzip
	rm -f $@
	gdalwarp \
		$(OUTPUTS) \
		-crop_to_cutline \
		-cutline aw3d30/kinmen.shp \
		-dstnodata 0 \
		aw3d30/N024E118_AVE_DSM.tif \
		$@


.PHONY: kinmen-zero
kinmen-zero: aw3d30/kinmen-zero.tif
aw3d30/kinmen-zero.tif: aw3d30/kinmen-data0.tif
	rm -f $@
	gdal_translate \
		$(OUTPUTS) \
		-a_nodata none \
		aw3d30/kinmen-data0.tif \
		$@


.PHONY: kinmen-contour
kinmen-contour: aw3d30/kinmen-contour.pbf
aw3d30/kinmen-contour.pbf: aw3d30/kinmen-zero.tif
	phyghtmap \
		--step=10 \
		--no-zero-contour \
		--output-prefix=kinmen_contour \
		--line-cat=500,100 \
		--jobs=8 \
		--osm-version=0.6 \
		--start-node-id=0 \
		--start-way-id=0 \
		--max-nodes-per-tile=0 \
		--max-nodes-per-way=2000 \
		--simplifyContoursEpsilon=0.00005 \
		--void-range-max=-500 \
		--pbf \
		$^
	mv kinmen_contour* $@


.PHONY: kinmen-lite-contour
kinmen-lite-contour: aw3d30/kinmen-lite-contour.pbf
aw3d30/kinmen-lite-contour.pbf: aw3d30/kinmen-zero.tif
	phyghtmap \
		--step=20 \
		--no-zero-contour \
		--output-prefix=kinmen_lite_contour \
		--line-cat=500,100 \
		--jobs=8 \
		--osm-version=0.6 \
		--start-node-id=0 \
		--start-way-id=0 \
		--max-nodes-per-tile=0 \
		--max-nodes-per-way=2000 \
		--simplifyContoursEpsilon=0.000125 \
		--void-range-max=-500 \
		--pbf \
		$^
	mv kinmen_lite_contour* $@


moi-2016/dem_40m-zero.tif: moi-2016/dem_20m-zero.tif
	rm -f $@
	gdalwarp \
		 $(OUTPUTS) \
		-dstnodata $(NODATA_VALUE) \
		-ts 5490 0 \
		-r bilinear \
	  $^ \
	  $@

moi-2016/dem_80m-zero.tif: moi-2016/dem_20m-zero.tif
	rm -f $@
	gdalwarp \
		 $(OUTPUTS) \
		-dstnodata $(NODATA_VALUE) \
		-ts 2745 0 \
		-r bilinear \
	  $^ \
	  $@

moi-2016/dem_160m-zero.tif: moi-2016/dem_20m-zero.tif
	rm -f $@
	gdalwarp \
		 $(OUTPUTS) \
		-dstnodata $(NODATA_VALUE) \
		-ts 1372 0 \
		-r bilinear \
	  $^ \
	  $@

moi-2016/dem_320m-zero.tif: moi-2016/dem_20m-zero.tif
	rm -f $@
	gdalwarp \
		 $(OUTPUTS) \
		-dstnodata $(NODATA_VALUE) \
		-ts 686 0 \
		-r bilinear \
	  $^ \
	  $@

moi-2016/dem_640m-zero.tif: moi-2016/dem_20m-zero.tif
	rm -f $@
	gdalwarp \
		 $(OUTPUTS) \
		-dstnodata $(NODATA_VALUE) \
		-ts 343 0 \
		-r bilinear \
	  $^ \
	  $@


moi-2016/dem_1280m-zero.tif: moi-2016/dem_20m-zero.tif
	rm -f $@
	gdalwarp \
		 $(OUTPUTS) \
		-dstnodata $(NODATA_VALUE) \
		-ts 172 0 \
		-r bilinear \
	  $^ \
	  $@


moi-2018/DEM_40m-zero.tif: moi-2018/DEM_20m-zero.tif
	rm -f $@
	gdalwarp \
		 $(OUTPUTS) \
		-dstnodata $(NODATA_VALUE) \
		-ts 5414 0 \
		-r bilinear \
	  $^ \
	  $@

moi-2018/DEM_80m-zero.tif: moi-2018/DEM_20m-zero.tif
	rm -f $@
	gdalwarp \
		 $(OUTPUTS) \
		-dstnodata $(NODATA_VALUE) \
		-ts 2707 0 \
		-r bilinear \
	  $^ \
	  $@

moi-2018/DEM_160m-zero.tif: moi-2018/DEM_20m-zero.tif
	rm -f $@
	gdalwarp \
		 $(OUTPUTS) \
		-dstnodata $(NODATA_VALUE) \
		-ts 1353 0 \
		-r bilinear \
	  $^ \
	  $@

moi-2018/DEM_320m-zero.tif: moi-2018/DEM_20m-zero.tif
	rm -f $@
	gdalwarp \
		 $(OUTPUTS) \
		-dstnodata $(NODATA_VALUE) \
		-ts 677 0 \
		-r bilinear \
	  $^ \
	  $@

moi-2018/DEM_640m-zero.tif: moi-2018/DEM_20m-zero.tif
	rm -f $@
	gdalwarp \
		 $(OUTPUTS) \
		-dstnodata $(NODATA_VALUE) \
		-ts 338 0 \
		-r bilinear \
	  $^ \
	  $@


moi-2018/DEM_1280m-zero.tif: moi-2018/DEM_20m-zero.tif
	rm -f $@
	gdalwarp \
		 $(OUTPUTS) \
		-dstnodata $(NODATA_VALUE) \
		-ts 169 0 \
		-r bilinear \
	  $^ \
	  $@


moi-2016/taiwan_40m-contour.pbf: moi-2016/dem_40m-zero.tif
	phyghtmap \
		--step=100 \
		--no-zero-contour \
		--output-prefix=dem_40m_contour \
		--line-cat=1000,500 \
		--jobs=8 \
		--osm-version=0.6 \
		--start-node-id=0 \
		--start-way-id=0 \
		--max-nodes-per-tile=0 \
		--max-nodes-per-way=2000 \
		--simplifyContoursEpsilon=0.00005 \
		--void-range-max=-500 \
		$^
	mv dem_40m_contour* $(@:.pbf=.osm)
	$(SED_CMD) -e 's/contour_ext/contour_40m/g' -i $(@:.pbf=.osm)
	osmconvert \
		--out-pbf \
		$(@:.pbf=.osm) \
		-o=$@


moi-2016/taiwan_80m-contour.pbf: moi-2016/dem_80m-zero.tif
	phyghtmap \
		--step=100 \
		--no-zero-contour \
		--output-prefix=dem_80m_contour \
		--line-cat=1000,500 \
		--jobs=8 \
		--osm-version=0.6 \
		--start-node-id=0 \
		--start-way-id=0 \
		--max-nodes-per-tile=0 \
		--max-nodes-per-way=2000 \
		--simplifyContoursEpsilon=0.00005 \
		--void-range-max=-500 \
		$^
	mv dem_80m_contour* $(@:.pbf=.osm)
	$(SED_CMD) -e 's/contour_ext/contour_80m/g' -i $(@:.pbf=.osm)
	osmconvert \
		--out-pbf \
		$(@:.pbf=.osm) \
		-o=$@


moi-2016/taiwan_160m-contour.pbf: moi-2016/dem_160m-zero.tif
	phyghtmap \
		--step=100 \
		--no-zero-contour \
		--output-prefix=dem_160m_contour \
		--line-cat=1000,500 \
		--jobs=8 \
		--osm-version=0.6 \
		--start-node-id=0 \
		--start-way-id=0 \
		--max-nodes-per-tile=0 \
		--max-nodes-per-way=2000 \
		--simplifyContoursEpsilon=0.00005 \
		--void-range-max=-500 \
		$^
	mv dem_160m_contour* $(@:.pbf=.osm)
	$(SED_CMD) -e 's/contour_ext/contour_160m/g' -i $(@:.pbf=.osm)
	osmconvert \
		--out-pbf \
		$(@:.pbf=.osm) \
		-o=$@


moi-2016/taiwan_320m-contour.pbf: moi-2016/dem_320m-zero.tif
	phyghtmap \
		--step=100 \
		--no-zero-contour \
		--output-prefix=dem_320m_contour \
		--line-cat=1000,500 \
		--jobs=8 \
		--osm-version=0.6 \
		--start-node-id=0 \
		--start-way-id=0 \
		--max-nodes-per-tile=0 \
		--max-nodes-per-way=2000 \
		--simplifyContoursEpsilon=0.00005 \
		--void-range-max=-500 \
		$^
	mv dem_320m_contour* $(@:.pbf=.osm)
	$(SED_CMD) -e 's/contour_ext/contour_320m/g' -i $(@:.pbf=.osm)
	osmconvert \
		--out-pbf \
		$(@:.pbf=.osm) \
		-o=$@


moi-2016/taiwan_640m-contour.pbf: moi-2016/dem_640m-zero.tif
	phyghtmap \
		--step=100 \
		--no-zero-contour \
		--output-prefix=dem_640m_contour \
		--line-cat=1000,500 \
		--jobs=8 \
		--osm-version=0.6 \
		--start-node-id=0 \
		--start-way-id=0 \
		--max-nodes-per-tile=0 \
		--max-nodes-per-way=2000 \
		--simplifyContoursEpsilon=0.00005 \
		--void-range-max=-500 \
		$^
	mv dem_640m_contour* $(@:.pbf=.osm)
	$(SED_CMD) -e 's/contour_ext/contour_640m/g' -i $(@:.pbf=.osm)
	osmconvert \
		--out-pbf \
		$(@:.pbf=.osm) \
		-o=$@


moi-2016/taiwan_1280m-contour.pbf: moi-2016/dem_1280m-zero.tif
	phyghtmap \
		--step=100 \
		--no-zero-contour \
		--output-prefix=dem_1280m_contour \
		--line-cat=1000,500 \
		--jobs=8 \
		--osm-version=0.6 \
		--start-node-id=0 \
		--start-way-id=0 \
		--max-nodes-per-tile=0 \
		--max-nodes-per-way=2000 \
		--simplifyContoursEpsilon=0.00005 \
		--void-range-max=-500 \
		$^
	mv dem_1280m_contour* $(@:.pbf=.osm)
	$(SED_CMD) -e 's/contour_ext/contour_1280m/g' -i $(@:.pbf=.osm)
	osmconvert \
		--out-pbf \
		$(@:.pbf=.osm) \
		-o=$@


.PHONY: dem2018_40m-contour
dem2018_40m-contour: moi-2018/dem2018_40m-contour.pbf
moi-2018/dem2018_40m-contour.pbf: moi-2018/DEM_40m-zero.tif
	phyghtmap \
		--step=100 \
		--no-zero-contour \
		--output-prefix=dem_40m_contour \
		--line-cat=1000,500 \
		--jobs=8 \
		--osm-version=0.6 \
		--start-node-id=0 \
		--start-way-id=0 \
		--max-nodes-per-tile=0 \
		--max-nodes-per-way=2000 \
		--simplifyContoursEpsilon=0.00005 \
		--void-range-max=-500 \
		$^
	mv dem_40m_contour* $(@:.pbf=.osm)
	$(SED_CMD) -e 's/contour_ext/contour_40m/g' -i $(@:.pbf=.osm)
	osmconvert \
		--out-pbf \
		$(@:.pbf=.osm) \
		-o=$@


.PHONY: dem2018_80m-contour
dem2018_80m-contour: moi-2018/dem2018_80m-contour.pbf
moi-2018/dem2018_80m-contour.pbf: moi-2018/DEM_80m-zero.tif
	phyghtmap \
		--step=100 \
		--no-zero-contour \
		--output-prefix=dem_80m_contour \
		--line-cat=1000,500 \
		--jobs=8 \
		--osm-version=0.6 \
		--start-node-id=0 \
		--start-way-id=0 \
		--max-nodes-per-tile=0 \
		--max-nodes-per-way=2000 \
		--simplifyContoursEpsilon=0.00005 \
		--void-range-max=-500 \
		$^
	mv dem_80m_contour* $(@:.pbf=.osm)
	$(SED_CMD) -e 's/contour_ext/contour_80m/g' -i $(@:.pbf=.osm)
	osmconvert \
		--out-pbf \
		$(@:.pbf=.osm) \
		-o=$@


.PHONY: dem2018_160m-contour
dem2018_160m-contour: moi-2018/dem2018_160m-contour.pbf
moi-2018/dem2018_160m-contour.pbf: moi-2018/DEM_160m-zero.tif
	phyghtmap \
		--step=100 \
		--no-zero-contour \
		--output-prefix=dem_160m_contour \
		--line-cat=1000,500 \
		--jobs=8 \
		--osm-version=0.6 \
		--start-node-id=0 \
		--start-way-id=0 \
		--max-nodes-per-tile=0 \
		--max-nodes-per-way=2000 \
		--simplifyContoursEpsilon=0.00005 \
		--void-range-max=-500 \
		$^
	mv dem_160m_contour* $(@:.pbf=.osm)
	$(SED_CMD) -e 's/contour_ext/contour_160m/g' -i $(@:.pbf=.osm)
	osmconvert \
		--out-pbf \
		$(@:.pbf=.osm) \
		-o=$@


.PHONY: dem2018_320m-contour
dem2018_320m-contour: moi-2018/dem2018_320m-contour.pbf
moi-2018/dem2018_320m-contour.pbf: moi-2018/DEM_320m-zero.tif
	phyghtmap \
		--step=100 \
		--no-zero-contour \
		--output-prefix=dem_320m_contour \
		--line-cat=1000,500 \
		--jobs=8 \
		--osm-version=0.6 \
		--start-node-id=0 \
		--start-way-id=0 \
		--max-nodes-per-tile=0 \
		--max-nodes-per-way=2000 \
		--simplifyContoursEpsilon=0.00005 \
		--void-range-max=-500 \
		$^
	mv dem_320m_contour* $(@:.pbf=.osm)
	$(SED_CMD) -e 's/contour_ext/contour_320m/g' -i $(@:.pbf=.osm)
	osmconvert \
		--out-pbf \
		$(@:.pbf=.osm) \
		-o=$@


.PHONY: dem2018_640m-contour
dem2018_640m-contour: moi-2018/dem2018_640m-contour.pbf
moi-2018/dem2018_640m-contour.pbf: moi-2018/DEM_640m-zero.tif
	phyghtmap \
		--step=100 \
		--no-zero-contour \
		--output-prefix=dem_640m_contour \
		--line-cat=1000,500 \
		--jobs=8 \
		--osm-version=0.6 \
		--start-node-id=0 \
		--start-way-id=0 \
		--max-nodes-per-tile=0 \
		--max-nodes-per-way=2000 \
		--simplifyContoursEpsilon=0.00005 \
		--void-range-max=-500 \
		$^
	mv dem_640m_contour* $(@:.pbf=.osm)
	$(SED_CMD) -e 's/contour_ext/contour_640m/g' -i $(@:.pbf=.osm)
	osmconvert \
		--out-pbf \
		$(@:.pbf=.osm) \
		-o=$@


.PHONY: dem2018_1280m-contour
dem2018_1280m-contour: moi-2018/dem2018_1280m-contour.pbf
moi-2018/dem2018_1280m-contour.pbf: moi-2018/DEM_1280m-zero.tif
	phyghtmap \
		--step=100 \
		--no-zero-contour \
		--output-prefix=dem_1280m_contour \
		--line-cat=1000,500 \
		--jobs=8 \
		--osm-version=0.6 \
		--start-node-id=0 \
		--start-way-id=0 \
		--max-nodes-per-tile=0 \
		--max-nodes-per-way=2000 \
		--simplifyContoursEpsilon=0.00005 \
		--void-range-max=-500 \
		$^
	mv dem_1280m_contour* $(@:.pbf=.osm)
	$(SED_CMD) -e 's/contour_ext/contour_1280m/g' -i $(@:.pbf=.osm)
	osmconvert \
		--out-pbf \
		$(@:.pbf=.osm) \
		-o=$@


aw3d30/islands-10_50_100_500-contour.pbf: aw3d30/islands-10_100_500-contour.pbf
	rm -f $@
	python3 tools/elevation_sub.py $< $@


aw3d30/islands-10_100_500-contour.pbf: \
  aw3d30/kinmen-contour.pbf \
  aw3d30/matsu-contour.pbf \
  aw3d30/n3islets-contour.pbf \
  aw3d30/wuqiu-contour.pbf
	## kinmen
	osmium renumber \
		-s 1,1,0 \
		aw3d30/kinmen-contour.pbf \
		-Oo $@
	## matsu
	tools/osium-append.sh $@ aw3d30/matsu-contour.pbf
	## n3islets
	tools/osium-append.sh $@ aw3d30/n3islets-contour.pbf
	## wuqiu
	tools/osium-append.sh $@ aw3d30/wuqiu-contour.pbf


aw3d30/islands-20_100_500-contour.pbf: \
  aw3d30/kinmen-lite-contour.pbf \
  aw3d30/matsu-lite-contour.pbf \
  aw3d30/n3islets-lite-contour.pbf \
  aw3d30/wuqiu-lite-contour.pbf
	## kinmen
	osmium renumber \
		-s 1,1,0 \
		aw3d30/kinmen-lite-contour.pbf \
		-Oo $@
	## matsu
	tools/osium-append.sh $@ aw3d30/matsu-lite-contour.pbf
	## n3islets
	tools/osium-append.sh $@ aw3d30/n3islets-lite-contour.pbf
	## wuqiu
	tools/osium-append.sh $@ aw3d30/wuqiu-lite-contour.pbf


moi-2016/marker-contour.pbf: \
  moi-2016/taiwan_40m-contour.pbf \
  moi-2016/taiwan_80m-contour.pbf \
  moi-2016/taiwan_160m-contour.pbf \
  moi-2016/taiwan_320m-contour.pbf \
  moi-2016/taiwan_640m-contour.pbf \
  moi-2016/taiwan_1280m-contour.pbf
	## 40m
	osmium renumber \
		-s 1,1,0 \
		moi-2016/taiwan_40m-contour.pbf \
		-Oo $@
	## 80m
	tools/osium-append.sh $@ moi-2016/taiwan_80m-contour.pbf
	## 160m
	tools/osium-append.sh $@ moi-2016/taiwan_160m-contour.pbf
	## 320m
	tools/osium-append.sh $@ moi-2016/taiwan_320m-contour.pbf
	## 640m
	tools/osium-append.sh $@ moi-2016/taiwan_640m-contour.pbf
	## 1280m
	tools/osium-append.sh $@ moi-2016/taiwan_1280m-contour.pbf


moi-2018/marker-contour.pbf: \
  moi-2018/dem2018_40m-contour.pbf \
  moi-2018/dem2018_80m-contour.pbf \
  moi-2018/dem2018_160m-contour.pbf \
  moi-2018/dem2018_320m-contour.pbf \
  moi-2018/dem2018_640m-contour.pbf \
  moi-2018/dem2018_1280m-contour.pbf
	## 40m
	osmium renumber \
		-s 1,1,0 \
		moi-2018/dem2018_40m-contour.pbf \
		-Oo $@
	## 80m
	tools/osium-append.sh $@ moi-2018/dem2018_80m-contour.pbf
	## 160m
	tools/osium-append.sh $@ moi-2018/dem2018_160m-contour.pbf
	## 320m
	tools/osium-append.sh $@ moi-2018/dem2018_320m-contour.pbf
	## 640m
	tools/osium-append.sh $@ moi-2018/dem2018_640m-contour.pbf
	## 1280m
	tools/osium-append.sh $@ moi-2018/dem2018_1280m-contour.pbf


.PHONY: taiwan-contour
taiwan-contour: taiwan-contour-2016


.PHONY: taiwan-contour-2016
taiwan-contour-2016: ele_taiwan_10_100_500-2016.pbf
ele_taiwan_10_100_500-2016.pbf: \
  moi-2016/taiwan-10_100_500-contour.pbf \
  moi-2016/penghu-10_100_500-contour.pbf \
  aw3d30/islands-10_100_500-contour.pbf
	## taiwan main island
	osmium renumber \
		-s 7000000000,4000000000,0 \
		moi-2016/taiwan-10_100_500-contour.pbf \
		-Oo $@
	## penghu
	tools/osium-append.sh $@ moi-2016/penghu-10_100_500-contour.pbf
	## islands: kinmen, matsu, n3islets, wuqiu
	tools/osium-append.sh $@ aw3d30/islands-10_100_500-contour.pbf


.PHONY: taiwan-contour-2018
taiwan-contour-2018: ele_taiwan_10_100_500-2018.pbf
ele_taiwan_10_100_500-2018.pbf: \
  moi-2018/dem2018-contour.pbf \
  moi-2016/penghu-contour.pbf \
  aw3d30/islands-10_100_500-contour.pbf
	## taiwan main island
	osmium renumber \
		-s 7000000000,4000000000,0 \
		moi-2018/dem2018-contour.pbf \
		-Oo $@
	## penghu
	tools/osium-append.sh $@ moi-2016/penghu-contour.pbf
	## islands: kinmen, matsu, n3islets, wuqiu
	tools/osium-append.sh $@ aw3d30/islands-10_100_500-contour.pbf


.PHONY: taiwan-contour-mix
taiwan-contour-mix: taiwan-contour-mix-2016


.PHONY: taiwan-contour-mix-2016
taiwan-contour-mix-2016: ele_taiwan_10_50_100_500_mix-2016.pbf
ele_taiwan_10_50_100_500_mix-2016.pbf: \
  precompiled/taiwan-sealand.pbf \
  moi-2016/taiwan-10_50_100_500-contour.pbf \
  moi-2016/penghu-10_50_100_500-contour.pbf \
  aw3d30/islands-10_50_100_500-contour.pbf \
  moi-2016/marker-contour.pbf
	## taiwan sea & land
	osmium renumber \
	    -s 7000000000,4000000000,0 \
	    precompiled/taiwan-sealand.pbf \
	    -Oo $@
	## taiwan main island
	tools/osium-append.sh $@ moi-2016/taiwan-10_50_100_500-contour.pbf
	## penghu
	tools/osium-append.sh $@ moi-2016/penghu-10_50_100_500-contour.pbf
	## islands: kinmen, matsu, n3islets, wuqiu
	tools/osium-append.sh $@ aw3d30/islands-10_50_100_500-contour.pbf
	## marker
	tools/osium-append.sh $@ moi-2016/marker-contour.pbf


.PHONY: taiwan-contour-mix-2018
taiwan-contour-mix-2018: ele_taiwan_10_100_500_mix-2018.pbf
ele_taiwan_10_100_500_mix-2018.pbf: \
  precompiled/taiwan-sealand.pbf \
  moi-2018/dem2018-contour-sub.pbf \
  moi-2016/penghu-contour.pbf \
  aw3d30/islands-10_100_500-contour.pbf \
  moi-2018/marker-contour.pbf
	## taiwan sea & land
	osmium renumber \
	    -s 7000000000,4000000000,0 \
	    precompiled/taiwan-sealand.pbf \
	    -Oo $@
	## taiwan main island
	tools/osium-append.sh $@ moi-2018/dem2018-contour-sub.pbf
	## penghu
	tools/osium-append.sh $@ moi-2016/penghu-contour.pbf
	## islands: kinmen, matsu, n3islets, wuqiu
	tools/osium-append.sh $@ aw3d30/islands-10_100_500-contour.pbf
	## marker
	tools/osium-append.sh $@ moi-2018/marker-contour.pbf


.PHONY: taiwan-lite-contour-mix
taiwan-lite-contour-mix: taiwan-lite-contour-mix-2016


.PHONY: taiwan-lite-contour-mix-2016
taiwan-lite-contour-mix-2016: ele_taiwan_20_100_500_mix-2016.pbf
ele_taiwan_20_100_500_mix-2016.pbf: \
  precompiled/taiwan-sealand.pbf \
  moi-2016/taiwan-20_100_500-contour.pbf \
  moi-2016/penghu-20_100_500-contour.pbf \
  aw3d30/islands-20_100_500-contour.pbf \
  moi-2016/marker-contour.pbf
	## taiwan sea & land
	osmium renumber \
	    -s 7000000000,4000000000,0 \
	    precompiled/taiwan-sealand.pbf \
	    -Oo $@
	## taiwan main island
	tools/osium-append.sh $@ moi-2016/taiwan-20_100_500-contour.pbf
	## penghu
	tools/osium-append.sh $@ moi-2016/penghu-20_100_500-contour.pbf
	## islands: kinmen, matsu, n3islets, wuqiu
	tools/osium-append.sh $@ aw3d30/islands-20_100_500-contour.pbf
	## marker
	tools/osium-append.sh $@ moi-2016/marker-contour.pbf


.PHONY: taiwan-lite-contour-mix-2018
taiwan-lite-contour-mix-2018: ele_taiwan_20_100_500_mix-2018.pbf
ele_taiwan_20_100_500_mix-2018.pbf: \
  precompiled/taiwan-sealand.pbf \
  moi-2018/dem2018-lite-contour.pbf \
  moi-2016/penghu-lite-contour.pbf \
  aw3d30/islands-20_100_500-contour.pbf \
  moi-2018/marker-contour.pbf
	## taiwan sea & land
	osmium renumber \
	    -s 7000000000,4000000000,0 \
	    precompiled/taiwan-sealand.pbf \
	    -Oo $@
	## taiwan main island
	tools/osium-append.sh $@ moi-2018/dem2018-lite-contour.pbf
	## penghu
	tools/osium-append.sh $@ moi-2016/penghu-lite-contour.pbf
	## islands: kinmen, matsu, n3islets, wuqiu
	tools/osium-append.sh $@ aw3d30/islands-20_100_500-contour.pbf
	## marker
	tools/osium-append.sh $@ moi-2018/marker-contour.pbf
