.PHONY: all clean

all: contour

clean:
	git clean -fdx

OUTPUTS=-co compress=LZW -of GTiff
NODATA_VALUE=-999

.PHONY: dem2016-zero
dem2016-zero: moi-2016/.unzip
moi-2016/dem_20m-zero.tif:
	cd moi-2016/ && \
		7za x dem_20m.7z.001 && \
		mv dem_20m-wgs84v3.tif dem_20m-zero.tif && \
		mv Penghu_20m-wgs84-v2.tif penghu_20m-zero.tif
	touch $@


.PHONY: penghu-contour
penghu-contour: moi-2016/penghu-contour.pbf
moi-2016/penghu-contour.pbf: moi-2016/penghu_20m-zero.tif
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
		--max-nodes-per-way=0 \
		--simplifyContoursEpsilon=0.00002 \
		--void-range-max=-500 \
		--pbf \
		moi-2016/penghu_20m-zero.tif
	mv penghu_contour* moi-2016/penghu-contour.pbf


.POHNY: dem2018-orig
dem2018-orig: moi-2018/.unzip
moi-2018/DEM_20m.tif:
	cd moi-2018/ && \
		7za x DEM_20m.7z.001
	touch $@


.PHONY: dem2018-wgs84
dem2018-wgs84: moi-2018/DEM_20m-wgs84.tif
moi-2018/DEM_20m-wgs84.tif: moi-2018/DEM_20m.tif
	rm -f $@
	gdalwarp \
		 $(OUTPUTS) \
		-dstnodata $(NODATA_VALUE) \
		-r bilinear \
		-t_srs 'EPSG:4326' \
	  moi-2018/DEM_20m.tif \
	  $@


.PHONY: dem2018-nodata
dem2018-nodata: moi-2018/DEM_20m-nodata.tif
moi-2018/DEM_20m-nodata.tif: moi-2016/dem_20m-zero.tif moi-2018/DEM_20m-wgs84.tif
	rm -f moi-2018/from2016.tif && \
	gdalwarp \
		$(OUTPUTS) \
		-dstnodata $(NODATA_VALUE) \
		-crop_to_cutline \
		-cutline moi-2018/void_area.shp \
		moi-2016/dem_20m-zero.tif \
		moi-2018/from2016.tif
	rm -f $@ && \
	gdal_merge.py \
		$(OUTPUTS) \
		-n $(NODATA_VALUE) -a_nodata $(NODATA_VALUE) \
		moi-2018/DEM_20m-wgs84.tif \
		moi-2018/from2016.tif \
		-o $@


.PHONY: dem2018-zero
dem2018-zero: moi-2018/DEM_20m-zero.tif
moi-2018/DEM_20m-zero.tif: moi-2018/DEM_20m-nodata.tif
	rm -f moi-2018/DEM_20m-nodata0.tif && \
	gdal_calc.py \
		--NoDataValue=0 \
		--calc="(A > 0) * A" \
		-A moi-2018/DEM_20m-nodata.tif \
		--outfile=moi-2018/DEM_20m-nodata0.tif
	rm -f $@ && \
	gdal_translate \
		$(OUTPUTS) \
		-a_nodata none \
		moi-2018/DEM_20m-nodata0.tif \
		moi-2018/DEM_20m-zero.tif


.PHONY: dem-contour
dem-contour: moi-2018/dem-contour.pbf
moi-2018/dem-contour.pbf: moi-2018/DEM_20m-zero.tif
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
		--max-nodes-per-way=0 \
		--simplifyContoursEpsilon=0.00002 \
		--void-range-max=-500 \
		--pbf \
		moi-2018/DEM_20m-zero.tif
	mv dem_contour* moi-2018/dem-contour.pbf


.PHONY: aw3d-orig
aw3d-orig: aw3d30-2.1/.unzip
aw3d30-2.1/.unzip:
	cd aw3d30-2.1/ && \
		7za x aw3d30.7z.001
	touch $@


.PHONY: n3islets-zero
n3islets-zero: aw3d30-2.1/n3islets-zero.tif
aw3d30-2.1/n3islets-zero.tif: aw3d-orig
	rm -f aw3d30-2.1/n3islets-data0.tif && \
	gdalwarp \
		$(OUTPUTS) \
		-crop_to_cutline \
		-cutline aw3d30-2.1/n3islets.shp \
		-dstnodata 0 \
		aw3d30-2.1/N025E122_AVE_DSM.tif \
		aw3d30-2.1/n3islets-data0.tif
	rm -f $@ && \
	gdal_translate \
		$(OUTPUTS) \
		-a_nodata none \
		aw3d30-2.1/n3islets-data0.tif \
		$@


.PHONY: n3islets-contour
n3islets-contour: aw3d30-2.1/n3islets-contour.pbf
aw3d30-2.1/n3islets-contour.pbf: aw3d30-2.1/n3islets-zero.tif
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
		--max-nodes-per-way=0 \
		--simplifyContoursEpsilon=0.000005 \
		--void-range-max=-500 \
		--pbf \
		aw3d30-2.1/n3islets-zero.tif
	mv n3islets_contour* aw3d30-2.1/n3islets-contour.pbf


.PHONY: matsu-zero
matsu-zero: aw3d30-2.1/matsu-zero.tif
aw3d30-2.1/matsu-zero.tif: aw3d-orig
	rm -f aw3d30-2.1/matsu-data0.tif && \
	gdalwarp \
		$(OUTPUTS) \
		-crop_to_cutline \
		-cutline aw3d30-2.1/matsu.shp \
		-dstnodata 0 \
		aw3d30-2.1/N026E119_AVE_DSM.tif \
		aw3d30-2.1/N026E120_AVE_DSM.tif \
		aw3d30-2.1/N025E119_AVE_DSM.tif \
		aw3d30-2.1/matsu-data0.tif
	rm -f $@ && \
	gdal_translate \
		$(OUTPUTS) \
		-a_nodata none \
		aw3d30-2.1/matsu-data0.tif \
		$@


.PHONY: matsu-contour
matsu-contour: aw3d30-2.1/matsu-contour.pbf
aw3d30-2.1/matsu-contour.pbf: aw3d30-2.1/matsu-zero.tif
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
		--max-nodes-per-way=0 \
		--simplifyContoursEpsilon=0.00005 \
		--void-range-max=-500 \
		--pbf \
		aw3d30-2.1/matsu-zero.tif
	mv matsu_contour* aw3d30-2.1/matsu-contour.pbf


.PHONY: wuqiu-zero
wuqiu-zero: aw3d30-2.1/wuqiu-zero.tif
aw3d30-2.1/wuqiu-zero.tif: aw3d-orig
	rm -f aw3d30-2.1/wuqiu-data0.tif && \
	gdalwarp \
		$(OUTPUTS) \
		-crop_to_cutline \
		-cutline aw3d30-2.1/wuqiu.shp \
		-dstnodata 0 \
		aw3d30-2.1/N024E119_AVE_DSM.tif \
		aw3d30-2.1/wuqiu-data0.tif
	rm -f $@ && \
	gdal_translate \
		$(OUTPUTS) \
		-a_nodata none \
		aw3d30-2.1/wuqiu-data0.tif \
		$@


.PHONY: wuqiu-contour
wuqiu-contour: aw3d30-2.1/wuqiu-contour.pbf
aw3d30-2.1/wuqiu-contour.pbf: aw3d30-2.1/wuqiu-zero.tif
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
		--max-nodes-per-way=0 \
		--simplifyContoursEpsilon=0.000005 \
		--void-range-max=-500 \
		--pbf \
		aw3d30-2.1/wuqiu-zero.tif
	mv wuqiu_contour* aw3d30-2.1/wuqiu-contour.pbf


.PHONY: kinmen-zero
kinmen-zero: aw3d30-2.1/kinmen-zero.tif
aw3d30-2.1/kinmen-zero.tif:
	rm -f aw3d30-2.1/kinmen-data0.tif && \
	gdalwarp \
		$(OUTPUTS) \
		-crop_to_cutline \
		-cutline aw3d30-2.1/kinmen.shp \
		-dstnodata 0 \
		aw3d30-2.1/N024E118_AVE_DSM.tif \
		aw3d30-2.1/kinmen-data0.tif
	rm -f $@ && \
	gdal_translate \
		$(OUTPUTS) \
		-a_nodata none \
		aw3d30-2.1/kinmen-data0.tif \
		$@


.PHONY: kinmen-contour
kinmen-contour: aw3d30-2.1/kinmen-contour.pbf
aw3d30-2.1/kinmen-contour.pbf: aw3d30-2.1/kinmen-zero.tif
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
		--max-nodes-per-way=0 \
		--simplifyContoursEpsilon=0.00005 \
		--void-range-max=-500 \
		--pbf \
		aw3d30-2.1/kinmen-zero.tif
	mv kinmen_contour* aw3d30-2.1/kinmen-contour.pbf


.PHONY: taiwan-contour
taiwan-contour: taiwan-contour.pbf
taiwan-contour.pbf: moi-2018/DEM_20m-zero.tif moi-2016/penghu_20m-zero.tif aw3d30-2.1/kinmen-zero.tif aw3d30-2.1/matsu-zero.tif aw3d30-2.1/n3islets-zero.tif aw3d30-2.1/wuqiu-zero.tif
	phyghtmap \
		--step=10 \
		--no-zero-contour \
		--output-prefix=taiwan_contour \
		--line-cat=500,100 \
		--jobs=8 \
		--osm-version=0.6 \
		--start-node-id=7500000000 \
		--start-way-id=4700000000 \
		--max-nodes-per-tile=0 \
		--max-nodes-per-way=0 \
		--simplifyContoursEpsilon=0.00002 \
		--void-range-max=-500 \
		--pbf \
		moi-2018/DEM_20m-zero.tif \
		moi-2016/penghu_20m-zero.tif \
		aw3d30-2.1/kinmen-zero.tif \
		aw3d30-2.1/matsu-zero.tif \
		aw3d30-2.1/n3islets-zero.tif \
		aw3d30-2.1/wuqiu-zero.tif
	mv taiwan_contour* taiwan-contour.pbf
