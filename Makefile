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

OUTPUTS=-ot Float64 -co compress=LZW -of GTiff
NODATA_VALUE=-999
WORKING_TYPE=Float64

GDALWARP_WGS84_OPTIONS = \
	-dstnodata $(NODATA_VALUE) \
	-r bilinear \
	-wt $(WORKING_TYPE) \
	-t_srs 'EPSG:4326'

PHYGHT_OPTIONS = \
	--no-zero-contour \
	--jobs=8 \
	--osm-version=0.6 \
	--start-node-id=1 \
	--start-way-id=1 \
	--max-nodes-per-tile=0 \
	--max-nodes-per-way=2000 \
	--void-range-max=-50


MOI2020_TAIWAN = moi-2020/taiwan_20m

MOI2019_TAIWAN = moi-2019/taiwan_20m
MOI2019_PENGHU = moi-2019/penghu
MOI2019_KINMEN = moi-2019/kinmen

MOI2018_TAIWAN = moi-2018/taiwan_20m


moi-2016/penghu-10_100_500-contour.pbf: moi-2016/phDEM_20m-zero.tif
	phyghtmap \
		--step=10 \
		--output-prefix=penghu_contour \
		--line-cat=500,100 \
		--simplifyContoursEpsilon=0.00001 \
		$(PHYGHT_OPTIONS) \
		--pbf \
		$^
	mv penghu_contour* $@


moi-2016/penghu-20_100_500-contour.pbf: moi-2016/phDEM_20m-zero.tif
	phyghtmap \
		--step=20 \
		--output-prefix=penghu_lite_contour \
		--line-cat=500,100 \
		--simplifyContoursEpsilon=0.00005 \
		$(PHYGHT_OPTIONS) \
		--pbf \
		$^
	mv penghu_lite_contour* $@


moi-2019/penghu-10_100_500-contour.pbf: $(MOI2019_PENGHU)-zero.tif
	phyghtmap \
		--step=10 \
		--output-prefix=penghu_contour \
		--line-cat=500,100 \
		--simplifyContoursEpsilon=0.00001 \
		$(PHYGHT_OPTIONS) \
		--pbf \
		$^
	mv penghu_contour* $@


moi-2019/penghu-20_100_500-contour.pbf: $(MOI2019_PENGHU)-zero.tif
	phyghtmap \
		--step=20 \
		--output-prefix=penghu_lite_contour \
		--line-cat=500,100 \
		--simplifyContoursEpsilon=0.00005 \
		$(PHYGHT_OPTIONS) \
		--pbf \
		$^
	mv penghu_lite_contour* $@


moi-2019/kinmen-10_100_500-contour.pbf: $(MOI2019_KINMEN)-zero.tif
	phyghtmap \
		--step=10 \
		--output-prefix=kinmen_contour \
		--line-cat=500,100 \
		--simplifyContoursEpsilon=0.00001 \
		$(PHYGHT_OPTIONS) \
		--pbf \
		$^
	mv kinmen_contour* $@


moi-2019/kinmen-20_100_500-contour.pbf: $(MOI2019_KINMEN)-zero.tif
	phyghtmap \
		--step=20 \
		--output-prefix=kinmen_lite_contour \
		--line-cat=500,100 \
		--simplifyContoursEpsilon=0.00005 \
		$(PHYGHT_OPTIONS) \
		--pbf \
		$^
	mv kinmen_lite_contour* $@


moi-2016/dem_20m.tif: moi-2016/.unzip
moi-2016/phDEM_20m.tif: moi-2016/.unzip
moi-2016/.unzip: moi-2016/dem_20m.7z.001
	cd moi-2016/ && \
		7za x dem_20m.7z.001 && \
		mv phDEM_20m_119.tif phDEM_20m.tif
	touch $@


$(MOI2018_TAIWAN).tif: moi-2018/.unzip
moi-2018/.unzip:
	cd moi-2018/ && \
		7za x DEM_20m.7z.001 && \
		mv DEM_20m.tif taiwan_20m.tif
	touch $@

$(MOI2019_TAIWAN).tif: moi-2019/.unzip
$(MOI2019_PENGHU).tif: moi-2019/.unzip
$(MOI2019_KINMEN).tif: moi-2019/.unzip
moi-2019/.unzip: moi-2019/DEMg_20m.7z.001
	cd moi-2019/ && \
		7za x DEMg_20m.7z.001 && \
		mv DEMg_geoid2014_20m_20190515.tif taiwan_20m.tif && \
		mv DEMg_20m_PH_20190521.tif penghu.tif && \
		mv DEMg_20m_KM_20190521.tif kinmen.tif
	touch $@


moi-2018/from2016.tif: moi-2016/dem_20m-zero.tif
	rm -f $@
	gdalwarp \
		$(OUTPUTS) \
		-dstnodata $(NODATA_VALUE) \
		-crop_to_cutline \
		-cutline moi-2018/void_area.shp \
		$^ \
		$@


moi-2019/from2016.tif: moi-2016/dem_20m-zero.tif
	rm -f $@
	gdalwarp \
		$(OUTPUTS) \
		-dstnodata $(NODATA_VALUE) \
		-crop_to_cutline \
		-cutline moi-2019/void_area.shp \
		$^ \
		$@


.PHONY: taiwan-contour-mix-2021
taiwan-contour-mix-2021: ele_taiwan_10_100_500_mix-2021.pbf
ele_taiwan_10_100_500_mix-2021.pbf: \
  precompiled/taiwan-sealand.pbf \
  moi-2020/taiwan-10_50_100_500-contour.pbf \
  moi-2019/penghu-10_50_100_500-contour.pbf \
  moi-2019/kinmen-10_50_100_500-contour.pbf \
  aw3d30-3.1/islands_nokinmen-10_50_100_500-contour.pbf \
  moi-2020/marker-contour.pbf
	# combines all dependences
	./tools/combine.sh \
		$@ \
		7000000000 \
		4000000000 \
		$^


.PHONY: taiwan-contour-mix-2020
taiwan-contour-mix-2020: ele_taiwan_10_100_500_mix-2020.pbf
ele_taiwan_10_100_500_mix-2020.pbf: \
  precompiled/taiwan-sealand.pbf \
  moi-2020/taiwan-10_50_100_500-contour.pbf \
  moi-2019/penghu-10_50_100_500-contour.pbf \
  moi-2019/kinmen-10_50_100_500-contour.pbf \
  aw3d30-2.1/islands_nokinmen-10_50_100_500-contour.pbf \
  moi-2020/marker-contour.pbf
	# combines all dependences
	./tools/combine.sh \
		$@ \
		7000000000 \
		4000000000 \
		$^


.PHONY: taiwan-lite-contour-mix-2021
taiwan-lite-contour-mix-2021: ele_taiwan_20_100_500_mix-2021.pbf
ele_taiwan_20_100_500_mix-2021.pbf: \
  precompiled/taiwan-sealand.pbf \
  moi-2020/taiwan-20_100_500-contour.pbf \
  moi-2019/penghu-20_100_500-contour.pbf \
  moi-2019/kinmen-20_100_500-contour.pbf \
  aw3d30-3.1/islands_nokinmen-20_100_500-contour.pbf \
  moi-2020/marker-contour.pbf
	# combines all dependences
	./tools/combine.sh \
		$@ \
		7000000000 \
		4000000000 \
		$^


.PHONY: taiwan-lite-contour-mix-2020
taiwan-lite-contour-mix-2020: ele_taiwan_20_100_500_mix-2020.pbf
ele_taiwan_20_100_500_mix-2020.pbf: \
  precompiled/taiwan-sealand.pbf \
  moi-2020/taiwan-20_100_500-contour.pbf \
  moi-2019/penghu-20_100_500-contour.pbf \
  moi-2019/kinmen-20_100_500-contour.pbf \
  aw3d30-2.1/islands_nokinmen-20_100_500-contour.pbf \
  moi-2020/marker-contour.pbf
	# combines all dependences
	./tools/combine.sh \
		$@ \
		7000000000 \
		4000000000 \
		$^


.PHONY: taiwan-contour-2021
taiwan-contour-2021: ele_taiwan_10_100_500-2021.pbf
ele_taiwan_10_100_500-2021.pbf: \
  moi-2020/taiwan-10_100_500-contour.pbf \
  moi-2019/penghu-10_100_500-contour.pbf \
  moi-2019/kinmen-10_100_500-contour.pbf \
  aw3d30-3.1/islands_nokinmen-10_100_500-contour.pbf
	# combines all dependences
	./tools/combine.sh \
		$@ \
		7000000000 \
		4000000000 \
		$^


.PHONY: taiwan-contour-2020
taiwan-contour-2020: ele_taiwan_10_100_500-2020.pbf
ele_taiwan_10_100_500-2020.pbf: \
  moi-2020/taiwan-10_100_500-contour.pbf \
  moi-2019/penghu-10_100_500-contour.pbf \
  moi-2019/kinmen-10_100_500-contour.pbf \
  aw3d30-2.1/islands_nokinmen-10_100_500-contour.pbf
	# combines all dependences
	./tools/combine.sh \
		$@ \
		7000000000 \
		4000000000 \
		$^


moi-2020/taiwan-10_50_100_500-contour.pbf: moi-2020/taiwan-10_100_500-contour.pbf
	rm -f $@
	python3 tools/elevation_sub.py $< $@


moi-2020/taiwan-20_100_500-contour.pbf: $(MOI2020_TAIWAN)-zero.tif
	phyghtmap \
		--step=20 \
		--output-prefix=dem_lite_contour \
		--line-cat=500,100 \
		--simplifyContoursEpsilon=0.00005 \
		$(PHYGHT_OPTIONS) \
		--pbf \
		$^
	mv dem_lite_contour* $@


moi-2020/taiwan-10_100_500-contour.pbf: $(MOI2020_TAIWAN)_15m-zero.tif
	phyghtmap \
		--step=10 \
		--output-prefix=dem_contour \
		--line-cat=500,100 \
		--simplifyContoursEpsilon=0.00001 \
		$(PHYGHT_OPTIONS) \
		--pbf \
		$^
	mv dem_contour* $@


moi-2020/marker-contour.pbf: \
  moi-2020/taiwan_40m-contour.pbf \
  moi-2020/taiwan_80m-contour.pbf \
  moi-2020/taiwan_160m-contour.pbf \
  moi-2020/taiwan_320m-contour.pbf \
  moi-2020/taiwan_640m-contour.pbf \
  moi-2020/taiwan_1280m-contour.pbf
	# combines all dependences
	./tools/combine.sh \
		$@ \
		1 \
		1 \
		$^


moi-2020/taiwan_40m-contour.pbf: $(MOI2020_TAIWAN)_40m-zero.tif
	phyghtmap \
		--step=100 \
		--output-prefix=dem_40m_contour \
		--line-cat=1000,500 \
		--simplifyContoursEpsilon=0.00005 \
		$(PHYGHT_OPTIONS) \
		$^
	mv dem_40m_contour* $(@:.pbf=.osm)
	$(SED_CMD) -e 's/contour_ext/contour_40m/g' -i $(@:.pbf=.osm)
	osmconvert \
		--out-pbf \
		$(@:.pbf=.osm) \
		-o=$@


moi-2020/taiwan_80m-contour.pbf: $(MOI2020_TAIWAN)_80m-zero.tif
	phyghtmap \
		--step=100 \
		--output-prefix=dem_80m_contour \
		--line-cat=1000,500 \
		--simplifyContoursEpsilon=0.00005 \
		$(PHYGHT_OPTIONS) \
		$^
	mv dem_80m_contour* $(@:.pbf=.osm)
	$(SED_CMD) -e 's/contour_ext/contour_80m/g' -i $(@:.pbf=.osm)
	osmconvert \
		--out-pbf \
		$(@:.pbf=.osm) \
		-o=$@


moi-2020/taiwan_160m-contour.pbf: $(MOI2020_TAIWAN)_160m-zero.tif
	phyghtmap \
		--step=100 \
		--output-prefix=dem_160m_contour \
		--line-cat=1000,500 \
		--simplifyContoursEpsilon=0.00005 \
		$(PHYGHT_OPTIONS) \
		$^
	mv dem_160m_contour* $(@:.pbf=.osm)
	$(SED_CMD) -e 's/contour_ext/contour_160m/g' -i $(@:.pbf=.osm)
	osmconvert \
		--out-pbf \
		$(@:.pbf=.osm) \
		-o=$@


moi-2020/taiwan_320m-contour.pbf: $(MOI2020_TAIWAN)_320m-zero.tif
	phyghtmap \
		--step=100 \
		--output-prefix=dem_320m_contour \
		--line-cat=1000,500 \
		--simplifyContoursEpsilon=0.00005 \
		$(PHYGHT_OPTIONS) \
		$^
	mv dem_320m_contour* $(@:.pbf=.osm)
	$(SED_CMD) -e 's/contour_ext/contour_320m/g' -i $(@:.pbf=.osm)
	osmconvert \
		--out-pbf \
		$(@:.pbf=.osm) \
		-o=$@


moi-2020/taiwan_640m-contour.pbf: $(MOI2020_TAIWAN)_640m-zero.tif
	phyghtmap \
		--step=100 \
		--output-prefix=dem_640m_contour \
		--line-cat=1000,500 \
		--simplifyContoursEpsilon=0.00005 \
		$(PHYGHT_OPTIONS) \
		$^
	mv dem_640m_contour* $(@:.pbf=.osm)
	$(SED_CMD) -e 's/contour_ext/contour_640m/g' -i $(@:.pbf=.osm)
	osmconvert \
		--out-pbf \
		$(@:.pbf=.osm) \
		-o=$@

moi-2020/taiwan_1280m-contour.pbf: $(MOI2020_TAIWAN)_1280m-zero.tif
	phyghtmap \
		--step=100 \
		--output-prefix=dem_1280m_contour \
		--line-cat=1000,500 \
		--simplifyContoursEpsilon=0.00005 \
		$(PHYGHT_OPTIONS) \
		$^
	mv dem_1280m_contour* $(@:.pbf=.osm)
	$(SED_CMD) -e 's/contour_ext/contour_1280m/g' -i $(@:.pbf=.osm)
	osmconvert \
		--out-pbf \
		$(@:.pbf=.osm) \
		-o=$@


$(MOI2020_TAIWAN)_15m-zero.tif: $(MOI2020_TAIWAN)-zero.tif
	rm -f $@
	gdalwarp \
		 $(OUTPUTS) \
		-dstnodata $(NODATA_VALUE) \
		-ts 14435 0 \
		-r bilinear \
		-wt $(WORKING_TYPE) \
	  $^ \
	  $@

$(MOI2020_TAIWAN)_40m-zero.tif: $(MOI2020_TAIWAN)-zero.tif
	rm -f $@
	gdalwarp \
		 $(OUTPUTS) \
		-dstnodata $(NODATA_VALUE) \
		-ts 5413 0 \
		-r bilinear \
		-wt $(WORKING_TYPE) \
	  $^ \
	  $@

$(MOI2020_TAIWAN)_80m-zero.tif: $(MOI2020_TAIWAN)-zero.tif
	rm -f $@
	gdalwarp \
		 $(OUTPUTS) \
		-dstnodata $(NODATA_VALUE) \
		-ts 2707 0 \
		-r bilinear \
		-wt $(WORKING_TYPE) \
	  $^ \
	  $@

$(MOI2020_TAIWAN)_160m-zero.tif: $(MOI2020_TAIWAN)-zero.tif
	rm -f $@
	gdalwarp \
		 $(OUTPUTS) \
		-dstnodata $(NODATA_VALUE) \
		-ts 1353 0 \
		-r bilinear \
		-wt $(WORKING_TYPE) \
	  $^ \
	  $@

$(MOI2020_TAIWAN)_320m-zero.tif: $(MOI2020_TAIWAN)-zero.tif
	rm -f $@
	gdalwarp \
		 $(OUTPUTS) \
		-dstnodata $(NODATA_VALUE) \
		-ts 677 0 \
		-r bilinear \
		-wt $(WORKING_TYPE) \
	  $^ \
	  $@

$(MOI2020_TAIWAN)_640m-zero.tif: $(MOI2020_TAIWAN)-zero.tif
	rm -f $@
	gdalwarp \
		 $(OUTPUTS) \
		-dstnodata $(NODATA_VALUE) \
		-ts 338 0 \
		-r bilinear \
		-wt $(WORKING_TYPE) \
	  $^ \
	  $@


$(MOI2020_TAIWAN)_1280m-zero.tif: $(MOI2020_TAIWAN)-zero.tif
	rm -f $@
	gdalwarp \
		 $(OUTPUTS) \
		-dstnodata $(NODATA_VALUE) \
		-ts 169 0 \
		-r bilinear \
		-wt $(WORKING_TYPE) \
	  $^ \
	  $@

test: $(MOI2020_TAIWAN)-zero.tif $(MOI2019_TAIWAN)-zero.tif $(MOI2019_PENGHU)-zero.tif $(MOI2019_KINMEN)-zero.tif $(MOI2018_TAIWAN)-zero.tif 

aw3d30-2.1/kinmen-zero.tif: aw3d30-2.1/kinmen-nodata0.tif
aw3d30-2.1/wuqiu-zero.tif: aw3d30-2.1/wuqiu-nodata0.tif
aw3d30-3.1/wuqiu-zero.tif: aw3d30-3.1/wuqiu-nodata0.tif
aw3d30-2.1/matsu-zero.tif: aw3d30-2.1/matsu-nodata0.tif
aw3d30-3.1/matsu-zero.tif: aw3d30-3.1/matsu-nodata0.tif
aw3d30-2.1/n3islets-zero.tif: aw3d30-2.1/n3islets-nodata0.tif
aw3d30-3.1/n3islets-zero.tif: aw3d30-3.1/n3islets-nodata0.tif
moi-2016/dem_20m-zero.tif: moi-2016/dem_20m-nodata0.tif
moi-2016/phDEM_20m-zero.tif: moi-2016/phDEM_20m-nodata0.tif
$(MOI2018_TAIWAN)-zero.tif: $(MOI2018_TAIWAN)-nodata0.tif
$(MOI2019_KINMEN)-zero.tif: $(MOI2019_KINMEN)-nodata0.tif
$(MOI2019_PENGHU)-zero.tif: $(MOI2019_PENGHU)-nodata0.tif
$(MOI2019_TAIWAN)-zero.tif: $(MOI2019_TAIWAN)-nodata0.tif
$(MOI2020_TAIWAN)-zero.tif: $(MOI2020_TAIWAN)-nodata0.tif
%-zero.tif: %-nodata0.tif
	rm -f $@
	gdal_translate \
		$(OUTPUTS) \
		-a_nodata none \
		$^ \
		$@


moi-2016/dem_20m-nodata0.tif: moi-2016/dem_20m-nodata.tif
moi-2016/phDEM_20m-nodata0.tif: moi-2016/phDEM_20m-nodata.tif
$(MOI2018_TAIWAN)-nodata0.tif: $(MOI2018_TAIWAN)-nodata.tif
$(MOI2019_KINMEN)-nodata0.tif: $(MOI2019_KINMEN)-nodata.tif
$(MOI2019_PENGHU)-nodata0.tif: $(MOI2019_PENGHU)-nodata.tif
$(MOI2019_TAIWAN)-nodata0.tif: $(MOI2019_TAIWAN)-nodata.tif
$(MOI2020_TAIWAN)-nodata0.tif: $(MOI2020_TAIWAN)-nodata.tif
%-nodata0.tif: %-nodata.tif
	rm -f $@
	gdal_calc.py \
		--NoDataValue=0 \
		--calc="(A > 0) * A" \
		-A $^ \
		--outfile=$@


moi-2016/dem_20m-nodata.tif: moi-2016/dem_20m-wgs84.tif
moi-2016/phDEM_20m-nodata.tif: moi-2016/phDEM_20m-wgs84.tif
$(MOI2018_TAIWAN)-nodata.tif: $(MOI2018_TAIWAN)-wgs84.tif moi-2018/from2016.tif 
$(MOI2019_KINMEN)-nodata.tif: $(MOI2019_KINMEN)-wgs84.tif
$(MOI2019_PENGHU)-nodata.tif: $(MOI2019_PENGHU)-wgs84.tif
$(MOI2019_TAIWAN)-nodata.tif: $(MOI2019_TAIWAN)-wgs84.tif moi-2019/from2016.tif 
$(MOI2020_TAIWAN)-nodata.tif: $(MOI2020_TAIWAN)-wgs84.tif moi-2020/from2016.tif 
%-nodata.tif: %-wgs84.tif
	rm -f $@
	gdal_merge.py \
		$(OUTPUTS) \
		-n $(NODATA_VALUE) -a_nodata $(NODATA_VALUE) \
		$^ \
		-o $@


moi-2016/dem_20m-wgs84.tif: moi-2016/dem_20m.tif
moi-2016/phDEM_20m-wgs84.tif: moi-2016/phDEM_20m.tif
$(MOI2018_TAIWAN)-wgs84.tif: $(MOI2018_TAIWAN).tif
$(MOI2019_KINMEN)-wgs84.tif: $(MOI2019_KINMEN).tif
$(MOI2019_PENGHU)-wgs84.tif: $(MOI2019_PENGHU).tif
$(MOI2019_TAIWAN)-wgs84.tif: $(MOI2019_TAIWAN).tif
$(MOI2020_TAIWAN)-wgs84.tif: $(MOI2020_TAIWAN).tif
%-wgs84.tif: %.tif
	rm -f $@
	gdalwarp \
		$(OUTPUTS) \
		$(GDALWARP_WGS84_OPTIONS) \
	  $^ \
	  $@


moi-2020/from2016.tif: moi-2016/dem_20m-zero.tif
	rm -f $@
	gdalwarp \
		$(OUTPUTS) \
		-dstnodata $(NODATA_VALUE) \
		-crop_to_cutline \
		-cutline moi-2020/void_area.shp \
		$^ \
		$@


$(MOI2020_TAIWAN).tif: moi-2020/.unzip
moi-2020/.unzip: moi-2020/2020dtm20m.7z.001
	cd moi-2020/ && \
		7za x 2020dtm20m.7z.001 && \
		mv 2020dtm20m.tif taiwan_20m.tif
	touch $@


moi-2016/taiwan-10_100_500-contour.pbf: moi-2016/dem_20m-zero.tif
	phyghtmap \
		--step=10 \
		--output-prefix=dem_contour \
		--line-cat=500,100 \
		--simplifyContoursEpsilon=0.000002 \
		$(PHYGHT_OPTIONS) \
		--pbf \
		$^
	mv dem_contour* $@


moi-2018/taiwan-10_100_500-contour.pbf: $(MOI2018_TAIWAN)-zero.tif
	phyghtmap \
		--step=10 \
		--output-prefix=dem_contour \
		--line-cat=500,100 \
		--simplifyContoursEpsilon=0.00001 \
		$(PHYGHT_OPTIONS) \
		--pbf \
		$^
	mv dem_contour* $@


moi-2019/taiwan-10_100_500-contour.pbf: $(MOI2019_TAIWAN)-zero.tif
	phyghtmap \
		--step=10 \
		--output-prefix=dem_contour \
		--line-cat=500,100 \
		--simplifyContoursEpsilon=0.00001 \
		$(PHYGHT_OPTIONS) \
		--pbf \
		$^
	mv dem_contour* $@


moi-2016/penghu-10_50_100_500-contour.pbf: moi-2016/penghu-10_100_500-contour.pbf
	rm -f $@
	python3 tools/elevation_sub.py $< $@


moi-2016/taiwan-10_50_100_500-contour.pbf: moi-2016/taiwan-10_100_500-contour.pbf
	rm -f $@
	python3 tools/elevation_sub.py $< $@


moi-2018/taiwan-10_50_100_500-contour.pbf: moi-2018/taiwan-10_100_500-contour.pbf
	rm -f $@
	python3 tools/elevation_sub.py $< $@


moi-2019/taiwan-10_50_100_500-contour.pbf: moi-2019/taiwan-10_100_500-contour.pbf
	rm -f $@
	python3 tools/elevation_sub.py $< $@


moi-2019/penghu-10_50_100_500-contour.pbf: moi-2019/penghu-10_100_500-contour.pbf
	rm -f $@
	python3 tools/elevation_sub.py $< $@


moi-2019/kinmen-10_50_100_500-contour.pbf: moi-2019/kinmen-10_100_500-contour.pbf
	rm -f $@
	python3 tools/elevation_sub.py $< $@


moi-2016/taiwan-20_100_500-contour.pbf: moi-2016/dem_20m-zero.tif
	phyghtmap \
		--step=20 \
		--output-prefix=dem_lite_contour \
		--line-cat=500,100 \
		--simplifyContoursEpsilon=0.000005 \
		$(PHYGHT_OPTIONS) \
		--pbf \
		$^
	mv dem_lite_contour* $@


moi-2018/taiwan-20_100_500-contour.pbf: $(MOI2018_TAIWAN)-zero.tif
	phyghtmap \
		--step=20 \
		--output-prefix=dem_lite_contour \
		--line-cat=500,100 \
		--simplifyContoursEpsilon=0.00005 \
		$(PHYGHT_OPTIONS) \
		--pbf \
		$^
	mv dem_lite_contour* $@

moi-2019/taiwan-20_100_500-contour.pbf: $(MOI2019_TAIWAN)-zero.tif
	phyghtmap \
		--step=20 \
		--output-prefix=dem_lite_contour \
		--line-cat=500,100 \
		--simplifyContoursEpsilon=0.00005 \
		$(PHYGHT_OPTIONS) \
		--pbf \
		$^
	mv dem_lite_contour* $@


aw3d-orig: aw3d30-3.1/.unzip
aw3d30-3.1/.unzip:
	cd aw3d30-3.1/ && \
	7za x aw3d30-3.1.7z
	touch $@


aw3d30-2.1/.unzip:
	cd aw3d30-2.1/ && \
	7za x aw3d30-2.1.7z.001
	touch $@


aw3d30-3.1/n3islets-nodata0.tif: aw3d30-3.1/.unzip
	rm -f $@
	gdalwarp \
		$(OUTPUTS) \
		-crop_to_cutline \
		-cutline aw3d30-3.1/n3islets.shp \
		-dstnodata 0 \
		aw3d30-3.1/ALPSMLC30_N025E122_DSM.tif \
		$@


aw3d30-2.1/n3islets-nodata0.tif: aw3d30-2.1/.unzip
	rm -f $@
	gdalwarp \
		$(OUTPUTS) \
		-crop_to_cutline \
		-cutline aw3d30-2.1/n3islets.shp \
		-dstnodata 0 \
		aw3d30-2.1/N025E122_AVE_DSM.tif \
		$@


n3islets-contour: aw3d30-3.1/n3islets-10_50_100-contour.pbf
aw3d30-3.1/n3islets-10_50_100-contour.pbf: aw3d30-3.1/n3islets-zero.tif
	phyghtmap \
		--step=10 \
		--output-prefix=n3islets_contour \
		--line-cat=500,100 \
		--simplifyContoursEpsilon=0.000025 \
		$(PHYGHT_OPTIONS) \
		--pbf \
		$^
	mv n3islets_contour* $@


aw3d30-2.1/n3islets-10_50_100-contour.pbf: aw3d30-2.1/n3islets-zero.tif
	phyghtmap \
		--step=10 \
		--output-prefix=n3islets_contour \
		--line-cat=500,100 \
		--simplifyContoursEpsilon=0.000025 \
		$(PHYGHT_OPTIONS) \
		--pbf \
		$^
	mv n3islets_contour* $@


n3islets-lite-contour: aw3d30-3.1/n3islets-20_50_100-contour.pbf
aw3d30-3.1/n3islets-20_50_100-contour.pbf: aw3d30-3.1/n3islets-zero.tif
	phyghtmap \
		--step=20 \
		--output-prefix=n3islets_lite_contour \
		--line-cat=500,100 \
		--simplifyContoursEpsilon=0.000125 \
		$(PHYGHT_OPTIONS) \
		--pbf \
		$^
	mv n3islets_lite_contour* $@


aw3d30-2.1/n3islets-20_50_100-contour.pbf: aw3d30-2.1/n3islets-zero.tif
	phyghtmap \
		--step=20 \
		--output-prefix=n3islets_lite_contour \
		--line-cat=500,100 \
		--simplifyContoursEpsilon=0.000125 \
		$(PHYGHT_OPTIONS) \
		--pbf \
		$^
	mv n3islets_lite_contour* $@


aw3d30-3.1/matsu-nodata0.tif: aw3d30-3.1/.unzip
	rm -f $@
	gdalwarp \
		$(OUTPUTS) \
		-crop_to_cutline \
		-cutline aw3d30-3.1/matsu.shp \
		-dstnodata 0 \
		aw3d30-3.1/ALPSMLC30_N026E119_DSM.tif \
		aw3d30-3.1/ALPSMLC30_N026E120_DSM.tif \
		aw3d30-3.1/ALPSMLC30_N025E119_DSM.tif \
		$@


aw3d30-2.1/matsu-nodata0.tif: aw3d30-2.1/.unzip
	rm -f $@
	gdalwarp \
		$(OUTPUTS) \
		-crop_to_cutline \
		-cutline aw3d30-2.1/matsu.shp \
		-dstnodata 0 \
		aw3d30-2.1/N026E119_AVE_DSM.tif \
		aw3d30-2.1/N026E120_AVE_DSM.tif \
		aw3d30-2.1/N025E119_AVE_DSM.tif \
		$@


matsu-contour: aw3d30-3.1/matsu-10_50_100-contour.pbf
aw3d30-3.1/matsu-10_50_100-contour.pbf: aw3d30-3.1/matsu-zero.tif
	phyghtmap \
		--step=10 \
		--output-prefix=matsu_contour \
		--line-cat=500,100 \
		--simplifyContoursEpsilon=0.000025 \
		--pbf \
		$^
	mv matsu_contour* $@


aw3d30-2.1/matsu-10_50_100-contour.pbf: aw3d30-2.1/matsu-zero.tif
	phyghtmap \
		--step=10 \
		--output-prefix=matsu_contour \
		--line-cat=500,100 \
		--simplifyContoursEpsilon=0.000025 \
		--pbf \
		$^
	mv matsu_contour* $@


matsu-lite-contour: aw3d30-3.1/matsu-20_50_100-contour.pbf
aw3d30-3.1/matsu-20_50_100-contour.pbf: aw3d30-3.1/matsu-zero.tif
	phyghtmap \
		--step=20 \
		--output-prefix=matsu_lite_contour \
		--line-cat=500,100 \
		--simplifyContoursEpsilon=0.000125 \
		$(PHYGHT_OPTIONS) \
		--pbf \
		$^
	mv matsu_lite_contour* $@


aw3d30-2.1/matsu-20_50_100-contour.pbf: aw3d30-2.1/matsu-zero.tif
	phyghtmap \
		--step=20 \
		--output-prefix=matsu_lite_contour \
		--line-cat=500,100 \
		--simplifyContoursEpsilon=0.000125 \
		$(PHYGHT_OPTIONS) \
		--pbf \
		$^
	mv matsu_lite_contour* $@


aw3d30-3.1/wuqiu-nodata0.tif: aw3d30-3.1/.unzip
	rm -f $@
	gdalwarp \
		$(OUTPUTS) \
		-crop_to_cutline \
		-cutline aw3d30-3.1/wuqiu.shp \
		-dstnodata 0 \
		aw3d30-3.1/ALPSMLC30_N024E119_DSM.tif \
		$@


aw3d30-2.1/wuqiu-nodata0.tif: aw3d30-2.1/.unzip
	rm -f $@
	gdalwarp \
		$(OUTPUTS) \
		-crop_to_cutline \
		-cutline aw3d30-2.1/wuqiu.shp \
		-dstnodata 0 \
		aw3d30-2.1/N024E119_AVE_DSM.tif \
		$@


wuqiu-contour: aw3d30-3.1/wuqiu-10_50_100-contour.pbf
aw3d30-3.1/wuqiu-10_50_100-contour.pbf: aw3d30-3.1/wuqiu-zero.tif
	phyghtmap \
		--step=10 \
		--output-prefix=wuqiu_contour \
		--line-cat=500,100 \
		--simplifyContoursEpsilon=0.000025 \
		$(PHYGHT_OPTIONS) \
		--pbf \
		$^
	mv wuqiu_contour* $@


aw3d30-2.1/wuqiu-10_50_100-contour.pbf: aw3d30-2.1/wuqiu-zero.tif
	phyghtmap \
		--step=10 \
		--output-prefix=wuqiu_contour \
		--line-cat=500,100 \
		--simplifyContoursEpsilon=0.000025 \
		$(PHYGHT_OPTIONS) \
		--pbf \
		$^
	mv wuqiu_contour* $@


wuqiu-lite-contour: aw3d30-3.1/wuqiu-20_50_100-contour.pbf
aw3d30-3.1/wuqiu-20_50_100-contour.pbf: aw3d30-3.1/wuqiu-zero.tif
	phyghtmap \
		--step=20 \
		--output-prefix=wuqiu_lite_contour \
		--line-cat=500,100 \
		--simplifyContoursEpsilon=0.000125 \
		$(PHYGHT_OPTIONS) \
		--pbf \
		$^
	mv wuqiu_lite_contour* $@


aw3d30-2.1/wuqiu-20_50_100-contour.pbf: aw3d30-2.1/wuqiu-zero.tif
	phyghtmap \
		--step=20 \
		--output-prefix=wuqiu_lite_contour \
		--line-cat=500,100 \
		--simplifyContoursEpsilon=0.000125 \
		$(PHYGHT_OPTIONS) \
		--pbf \
		$^
	mv wuqiu_lite_contour* $@


aw3d30-2.1/kinmen-nodata0.tif: aw3d30-2.1/.unzip
	rm -f $@
	gdalwarp \
		$(OUTPUTS) \
		-crop_to_cutline \
		-cutline aw3d30-2.1/kinmen.shp \
		-dstnodata 0 \
		aw3d30-2.1/N024E118_AVE_DSM.tif \
		$@


kinmen-contour: aw3d30-2.1/kinmen-10_50_100-contour.pbf
aw3d30-2.1/kinmen-10_50_100-contour.pbf: aw3d30-2.1/kinmen-zero.tif
	phyghtmap \
		--step=10 \
		--output-prefix=kinmen_contour \
		--line-cat=500,100 \
		--simplifyContoursEpsilon=0.000025 \
		$(PHYGHT_OPTIONS) \
		--pbf \
		$^
	mv kinmen_contour* $@


kinmen-lite-contour: aw3d30-2.1/kinmen-20_50_100-contour.pbf
aw3d30-2.1/kinmen-20_50_100-contour.pbf: aw3d30-2.1/kinmen-zero.tif
	phyghtmap \
		--step=20 \
		--output-prefix=kinmen_lite_contour \
		--line-cat=500,100 \
		--simplifyContoursEpsilon=0.000125 \
		$(PHYGHT_OPTIONS) \
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
		-wt $(WORKING_TYPE) \
	  $^ \
	  $@

moi-2016/dem_80m-zero.tif: moi-2016/dem_20m-zero.tif
	rm -f $@
	gdalwarp \
		 $(OUTPUTS) \
		-dstnodata $(NODATA_VALUE) \
		-ts 2745 0 \
		-r bilinear \
		-wt $(WORKING_TYPE) \
	  $^ \
	  $@

moi-2016/dem_160m-zero.tif: moi-2016/dem_20m-zero.tif
	rm -f $@
	gdalwarp \
		 $(OUTPUTS) \
		-dstnodata $(NODATA_VALUE) \
		-ts 1372 0 \
		-r bilinear \
		-wt $(WORKING_TYPE) \
	  $^ \
	  $@

moi-2016/dem_320m-zero.tif: moi-2016/dem_20m-zero.tif
	rm -f $@
	gdalwarp \
		 $(OUTPUTS) \
		-dstnodata $(NODATA_VALUE) \
		-ts 686 0 \
		-r bilinear \
		-wt $(WORKING_TYPE) \
	  $^ \
	  $@

moi-2016/dem_640m-zero.tif: moi-2016/dem_20m-zero.tif
	rm -f $@
	gdalwarp \
		 $(OUTPUTS) \
		-dstnodata $(NODATA_VALUE) \
		-ts 343 0 \
		-r bilinear \
		-wt $(WORKING_TYPE) \
	  $^ \
	  $@


moi-2016/dem_1280m-zero.tif: moi-2016/dem_20m-zero.tif
	rm -f $@
	gdalwarp \
		 $(OUTPUTS) \
		-dstnodata $(NODATA_VALUE) \
		-ts 172 0 \
		-r bilinear \
		-wt $(WORKING_TYPE) \
	  $^ \
	  $@


moi-2018/DEM_40m-zero.tif: $(MOI2018_TAIWAN)-zero.tif
	rm -f $@
	gdalwarp \
		 $(OUTPUTS) \
		-dstnodata $(NODATA_VALUE) \
		-ts 5414 0 \
		-r bilinear \
		-wt $(WORKING_TYPE) \
	  $^ \
	  $@

moi-2018/DEM_80m-zero.tif: $(MOI2018_TAIWAN)-zero.tif
	rm -f $@
	gdalwarp \
		 $(OUTPUTS) \
		-dstnodata $(NODATA_VALUE) \
		-ts 2707 0 \
		-r bilinear \
		-wt $(WORKING_TYPE) \
	  $^ \
	  $@

moi-2018/DEM_160m-zero.tif: $(MOI2018_TAIWAN)-zero.tif
	rm -f $@
	gdalwarp \
		 $(OUTPUTS) \
		-dstnodata $(NODATA_VALUE) \
		-ts 1353 0 \
		-r bilinear \
		-wt $(WORKING_TYPE) \
	  $^ \
	  $@

moi-2018/DEM_320m-zero.tif: $(MOI2018_TAIWAN)-zero.tif
	rm -f $@
	gdalwarp \
		 $(OUTPUTS) \
		-dstnodata $(NODATA_VALUE) \
		-ts 677 0 \
		-r bilinear \
		-wt $(WORKING_TYPE) \
	  $^ \
	  $@

moi-2018/DEM_640m-zero.tif: $(MOI2018_TAIWAN)-zero.tif
	rm -f $@
	gdalwarp \
		 $(OUTPUTS) \
		-dstnodata $(NODATA_VALUE) \
		-ts 338 0 \
		-r bilinear \
		-wt $(WORKING_TYPE) \
	  $^ \
	  $@


moi-2018/DEM_1280m-zero.tif: $(MOI2018_TAIWAN)-zero.tif
	rm -f $@
	gdalwarp \
		 $(OUTPUTS) \
		-dstnodata $(NODATA_VALUE) \
		-ts 169 0 \
		-r bilinear \
		-wt $(WORKING_TYPE) \
	  $^ \
	  $@


$(MOI2019_TAIWAN)_10m-zero.tif: $(MOI2019_TAIWAN)-zero.tif
	rm -f $@
	gdalwarp \
		 $(OUTPUTS) \
		-dstnodata $(NODATA_VALUE) \
		-ts 21652 0 \
		-r bilinear \
		-wt $(WORKING_TYPE) \
	  $^ \
	  $@

$(MOI2019_TAIWAN)_40m-zero.tif: $(MOI2019_TAIWAN)-zero.tif
	rm -f $@
	gdalwarp \
		 $(OUTPUTS) \
		-dstnodata $(NODATA_VALUE) \
		-ts 5413 0 \
		-r bilinear \
		-wt $(WORKING_TYPE) \
	  $^ \
	  $@

$(MOI2019_TAIWAN)_80m-zero.tif: $(MOI2019_TAIWAN)-zero.tif
	rm -f $@
	gdalwarp \
		 $(OUTPUTS) \
		-dstnodata $(NODATA_VALUE) \
		-ts 2707 0 \
		-r bilinear \
		-wt $(WORKING_TYPE) \
	  $^ \
	  $@

$(MOI2019_TAIWAN)_160m-zero.tif: $(MOI2019_TAIWAN)-zero.tif
	rm -f $@
	gdalwarp \
		 $(OUTPUTS) \
		-dstnodata $(NODATA_VALUE) \
		-ts 1353 0 \
		-r bilinear \
		-wt $(WORKING_TYPE) \
	  $^ \
	  $@

$(MOI2019_TAIWAN)_320m-zero.tif: $(MOI2019_TAIWAN)-zero.tif
	rm -f $@
	gdalwarp \
		 $(OUTPUTS) \
		-dstnodata $(NODATA_VALUE) \
		-ts 677 0 \
		-r bilinear \
		-wt $(WORKING_TYPE) \
	  $^ \
	  $@

$(MOI2019_TAIWAN)_640m-zero.tif: $(MOI2019_TAIWAN)-zero.tif
	rm -f $@
	gdalwarp \
		 $(OUTPUTS) \
		-dstnodata $(NODATA_VALUE) \
		-ts 338 0 \
		-r bilinear \
		-wt $(WORKING_TYPE) \
	  $^ \
	  $@


$(MOI2019_TAIWAN)_1280m-zero.tif: $(MOI2019_TAIWAN)-zero.tif
	rm -f $@
	gdalwarp \
		 $(OUTPUTS) \
		-dstnodata $(NODATA_VALUE) \
		-ts 169 0 \
		-r bilinear \
		-wt $(WORKING_TYPE) \
	  $^ \
	  $@


moi-2016/taiwan_40m-contour.pbf: moi-2016/dem_40m-zero.tif
	phyghtmap \
		--step=100 \
		--output-prefix=dem_40m_contour \
		--line-cat=1000,500 \
		--simplifyContoursEpsilon=0.00005 \
		$(PHYGHT_OPTIONS) \
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
		--output-prefix=dem_80m_contour \
		--line-cat=1000,500 \
		--simplifyContoursEpsilon=0.00005 \
		$(PHYGHT_OPTIONS) \
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
		--output-prefix=dem_160m_contour \
		--line-cat=1000,500 \
		--simplifyContoursEpsilon=0.00005 \
		$(PHYGHT_OPTIONS) \
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
		--output-prefix=dem_320m_contour \
		--line-cat=1000,500 \
		--simplifyContoursEpsilon=0.00005 \
		$(PHYGHT_OPTIONS) \
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
		--output-prefix=dem_640m_contour \
		--line-cat=1000,500 \
		--simplifyContoursEpsilon=0.00005 \
		$(PHYGHT_OPTIONS) \
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
		--output-prefix=dem_1280m_contour \
		--line-cat=1000,500 \
		--simplifyContoursEpsilon=0.00005 \
		$(PHYGHT_OPTIONS) \
		$^
	mv dem_1280m_contour* $(@:.pbf=.osm)
	$(SED_CMD) -e 's/contour_ext/contour_1280m/g' -i $(@:.pbf=.osm)
	osmconvert \
		--out-pbf \
		$(@:.pbf=.osm) \
		-o=$@


moi-2018/taiwan_40m-contour.pbf: moi-2018/DEM_40m-zero.tif
	phyghtmap \
		--step=100 \
		--output-prefix=dem_40m_contour \
		--line-cat=1000,500 \
		--simplifyContoursEpsilon=0.00005 \
		$(PHYGHT_OPTIONS) \
		$^
	mv dem_40m_contour* $(@:.pbf=.osm)
	$(SED_CMD) -e 's/contour_ext/contour_40m/g' -i $(@:.pbf=.osm)
	osmconvert \
		--out-pbf \
		$(@:.pbf=.osm) \
		-o=$@


moi-2018/taiwan_80m-contour.pbf: moi-2018/DEM_80m-zero.tif
	phyghtmap \
		--step=100 \
		--output-prefix=dem_80m_contour \
		--line-cat=1000,500 \
		--simplifyContoursEpsilon=0.00005 \
		$(PHYGHT_OPTIONS) \
		$^
	mv dem_80m_contour* $(@:.pbf=.osm)
	$(SED_CMD) -e 's/contour_ext/contour_80m/g' -i $(@:.pbf=.osm)
	osmconvert \
		--out-pbf \
		$(@:.pbf=.osm) \
		-o=$@


moi-2018/taiwan_160m-contour.pbf: moi-2018/DEM_160m-zero.tif
	phyghtmap \
		--step=100 \
		--output-prefix=dem_160m_contour \
		--line-cat=1000,500 \
		--simplifyContoursEpsilon=0.00005 \
		$(PHYGHT_OPTIONS) \
		$^
	mv dem_160m_contour* $(@:.pbf=.osm)
	$(SED_CMD) -e 's/contour_ext/contour_160m/g' -i $(@:.pbf=.osm)
	osmconvert \
		--out-pbf \
		$(@:.pbf=.osm) \
		-o=$@


moi-2018/taiwan_320m-contour.pbf: moi-2018/DEM_320m-zero.tif
	phyghtmap \
		--step=100 \
		--output-prefix=dem_320m_contour \
		--line-cat=1000,500 \
		--simplifyContoursEpsilon=0.00005 \
		$(PHYGHT_OPTIONS) \
		$^
	mv dem_320m_contour* $(@:.pbf=.osm)
	$(SED_CMD) -e 's/contour_ext/contour_320m/g' -i $(@:.pbf=.osm)
	osmconvert \
		--out-pbf \
		$(@:.pbf=.osm) \
		-o=$@


moi-2018/taiwan_640m-contour.pbf: moi-2018/DEM_640m-zero.tif
	phyghtmap \
		--step=100 \
		--output-prefix=dem_640m_contour \
		--line-cat=1000,500 \
		--simplifyContoursEpsilon=0.00005 \
		$(PHYGHT_OPTIONS) \
		$^
	mv dem_640m_contour* $(@:.pbf=.osm)
	$(SED_CMD) -e 's/contour_ext/contour_640m/g' -i $(@:.pbf=.osm)
	osmconvert \
		--out-pbf \
		$(@:.pbf=.osm) \
		-o=$@

moi-2018/taiwan_1280m-contour.pbf: moi-2018/DEM_1280m-zero.tif
	phyghtmap \
		--step=100 \
		--output-prefix=dem_1280m_contour \
		--line-cat=1000,500 \
		--simplifyContoursEpsilon=0.00005 \
		$(PHYGHT_OPTIONS) \
		$^
	mv dem_1280m_contour* $(@:.pbf=.osm)
	$(SED_CMD) -e 's/contour_ext/contour_1280m/g' -i $(@:.pbf=.osm)
	osmconvert \
		--out-pbf \
		$(@:.pbf=.osm) \
		-o=$@


moi-2019/taiwan_40m-contour.pbf: $(MOI2019_TAIWAN)_40m-zero.tif
	phyghtmap \
		--step=100 \
		--output-prefix=dem_40m_contour \
		--line-cat=1000,500 \
		--simplifyContoursEpsilon=0.00005 \
		$(PHYGHT_OPTIONS) \
		$^
	mv dem_40m_contour* $(@:.pbf=.osm)
	$(SED_CMD) -e 's/contour_ext/contour_40m/g' -i $(@:.pbf=.osm)
	osmconvert \
		--out-pbf \
		$(@:.pbf=.osm) \
		-o=$@


moi-2019/taiwan_80m-contour.pbf: $(MOI2019_TAIWAN)_80m-zero.tif
	phyghtmap \
		--step=100 \
		--output-prefix=dem_80m_contour \
		--line-cat=1000,500 \
		--simplifyContoursEpsilon=0.00005 \
		$(PHYGHT_OPTIONS) \
		$^
	mv dem_80m_contour* $(@:.pbf=.osm)
	$(SED_CMD) -e 's/contour_ext/contour_80m/g' -i $(@:.pbf=.osm)
	osmconvert \
		--out-pbf \
		$(@:.pbf=.osm) \
		-o=$@


moi-2019/taiwan_160m-contour.pbf: $(MOI2019_TAIWAN)_160m-zero.tif
	phyghtmap \
		--step=100 \
		--output-prefix=dem_160m_contour \
		--line-cat=1000,500 \
		--simplifyContoursEpsilon=0.00005 \
		$(PHYGHT_OPTIONS) \
		$^
	mv dem_160m_contour* $(@:.pbf=.osm)
	$(SED_CMD) -e 's/contour_ext/contour_160m/g' -i $(@:.pbf=.osm)
	osmconvert \
		--out-pbf \
		$(@:.pbf=.osm) \
		-o=$@


moi-2019/taiwan_320m-contour.pbf: $(MOI2019_TAIWAN)_320m-zero.tif
	phyghtmap \
		--step=100 \
		--output-prefix=dem_320m_contour \
		--line-cat=1000,500 \
		--simplifyContoursEpsilon=0.00005 \
		$(PHYGHT_OPTIONS) \
		$^
	mv dem_320m_contour* $(@:.pbf=.osm)
	$(SED_CMD) -e 's/contour_ext/contour_320m/g' -i $(@:.pbf=.osm)
	osmconvert \
		--out-pbf \
		$(@:.pbf=.osm) \
		-o=$@


moi-2019/taiwan_640m-contour.pbf: $(MOI2019_TAIWAN)_640m-zero.tif
	phyghtmap \
		--step=100 \
		--output-prefix=dem_640m_contour \
		--line-cat=1000,500 \
		--simplifyContoursEpsilon=0.00005 \
		$(PHYGHT_OPTIONS) \
		$^
	mv dem_640m_contour* $(@:.pbf=.osm)
	$(SED_CMD) -e 's/contour_ext/contour_640m/g' -i $(@:.pbf=.osm)
	osmconvert \
		--out-pbf \
		$(@:.pbf=.osm) \
		-o=$@

moi-2019/taiwan_1280m-contour.pbf: $(MOI2019_TAIWAN)_1280m-zero.tif
	phyghtmap \
		--step=100 \
		--output-prefix=dem_1280m_contour \
		--line-cat=1000,500 \
		--simplifyContoursEpsilon=0.00005 \
		$(PHYGHT_OPTIONS) \
		$^
	mv dem_1280m_contour* $(@:.pbf=.osm)
	$(SED_CMD) -e 's/contour_ext/contour_1280m/g' -i $(@:.pbf=.osm)
	osmconvert \
		--out-pbf \
		$(@:.pbf=.osm) \
		-o=$@


aw3d30-2.1/islands-10_50_100_500-contour.pbf: aw3d30-2.1/islands-10_100_500-contour.pbf
	rm -f $@
	python3 tools/elevation_sub.py $< $@


aw3d30-3.1/islands_nokinmen-10_50_100_500-contour.pbf: aw3d30-3.1/islands_nokinmen-10_100_500-contour.pbf
	rm -f $@
	python3 tools/elevation_sub.py $< $@


aw3d30-2.1/islands_nokinmen-10_50_100_500-contour.pbf: aw3d30-2.1/islands_nokinmen-10_100_500-contour.pbf
	rm -f $@
	python3 tools/elevation_sub.py $< $@


aw3d30-2.1/islands-10_100_500-contour.pbf: \
  aw3d30-2.1/kinmen-10_50_100-contour.pbf \
  aw3d30-2.1/matsu-10_50_100-contour.pbf \
  aw3d30-2.1/n3islets-10_50_100-contour.pbf \
  aw3d30-2.1/wuqiu-10_50_100-contour.pbf
	# combines all dependences
	./tools/combine.sh \
		$@ \
		1 \
		1 \
		$^


aw3d30-2.1/islands-20_100_500-contour.pbf: \
  aw3d30-2.1/kinmen-20_50_100-contour.pbf \
  aw3d30-2.1/matsu-20_50_100-contour.pbf \
  aw3d30-2.1/n3islets-20_50_100-contour.pbf \
  aw3d30-2.1/wuqiu-20_50_100-contour.pbf
	# combines all dependences
	./tools/combine.sh \
		$@ \
		1 \
		1 \
		$^


aw3d30-3.1/islands_nokinmen-10_100_500-contour.pbf: \
  aw3d30-3.1/matsu-10_50_100-contour.pbf \
  aw3d30-3.1/n3islets-10_50_100-contour.pbf \
  aw3d30-3.1/wuqiu-10_50_100-contour.pbf
	# combines all dependences
	./tools/combine.sh \
		$@ \
		1 \
		1 \
		$^


aw3d30-2.1/islands_nokinmen-10_100_500-contour.pbf: \
  aw3d30-2.1/matsu-10_50_100-contour.pbf \
  aw3d30-2.1/n3islets-10_50_100-contour.pbf \
  aw3d30-2.1/wuqiu-10_50_100-contour.pbf
	# combines all dependences
	./tools/combine.sh \
		$@ \
		1 \
		1 \
		$^


aw3d30-3.1/islands_nokinmen-20_100_500-contour.pbf: \
  aw3d30-3.1/matsu-20_50_100-contour.pbf \
  aw3d30-3.1/n3islets-20_50_100-contour.pbf \
  aw3d30-3.1/wuqiu-20_50_100-contour.pbf
	# combines all dependences
	./tools/combine.sh \
		$@ \
		1 \
		1 \
		$^


aw3d30-2.1/islands_nokinmen-20_100_500-contour.pbf: \
  aw3d30-2.1/matsu-20_50_100-contour.pbf \
  aw3d30-2.1/n3islets-20_50_100-contour.pbf \
  aw3d30-2.1/wuqiu-20_50_100-contour.pbf
	# combines all dependences
	./tools/combine.sh \
		$@ \
		1 \
		1 \
		$^


moi-2016/marker-contour.pbf: \
  moi-2016/taiwan_40m-contour.pbf \
  moi-2016/taiwan_80m-contour.pbf \
  moi-2016/taiwan_160m-contour.pbf \
  moi-2016/taiwan_320m-contour.pbf \
  moi-2016/taiwan_640m-contour.pbf \
  moi-2016/taiwan_1280m-contour.pbf
	# combines all dependences
	./tools/combine.sh \
		$@ \
		1 \
		1 \
		$^


moi-2018/marker-contour.pbf: \
  moi-2018/taiwan_40m-contour.pbf \
  moi-2018/taiwan_80m-contour.pbf \
  moi-2018/taiwan_160m-contour.pbf \
  moi-2018/taiwan_320m-contour.pbf \
  moi-2018/taiwan_640m-contour.pbf \
  moi-2018/taiwan_1280m-contour.pbf
	# combines all dependences
	./tools/combine.sh \
		$@ \
		1 \
		1 \
		$^


moi-2019/marker-contour.pbf: \
  moi-2019/taiwan_40m-contour.pbf \
  moi-2019/taiwan_80m-contour.pbf \
  moi-2019/taiwan_160m-contour.pbf \
  moi-2019/taiwan_320m-contour.pbf \
  moi-2019/taiwan_640m-contour.pbf \
  moi-2019/taiwan_1280m-contour.pbf
	# combines all dependences
	./tools/combine.sh \
		$@ \
		1 \
		1 \
		$^


.PHONY: taiwan-contour
taiwan-contour: taiwan-contour-2021


.PHONY: taiwan-contour-2016
taiwan-contour-2016: ele_taiwan_10_100_500-2016.pbf
ele_taiwan_10_100_500-2016.pbf: \
  moi-2016/taiwan-10_100_500-contour.pbf \
  moi-2016/penghu-10_100_500-contour.pbf \
  aw3d30-2.1/islands-10_100_500-contour.pbf
	# combines all dependences
	./tools/combine.sh \
		$@ \
		7000000000 \
		4000000000 \
		$^


.PHONY: taiwan-contour-2018
taiwan-contour-2018: ele_taiwan_10_100_500-2018.pbf
ele_taiwan_10_100_500-2018.pbf: \
  moi-2018/taiwan-10_100_500-contour.pbf \
  moi-2016/penghu-10_100_500-contour.pbf \
  aw3d30-2.1/islands-10_100_500-contour.pbf
	# combines all dependences
	./tools/combine.sh \
		$@ \
		7000000000 \
		4000000000 \
		$^


.PHONY: taiwan-contour-2019
taiwan-contour-2019: ele_taiwan_10_100_500-2019.pbf
ele_taiwan_10_100_500-2019.pbf: \
  moi-2019/taiwan-10_100_500-contour.pbf \
  moi-2019/penghu-10_100_500-contour.pbf \
  moi-2019/kinmen-10_100_500-contour.pbf \
  aw3d30-2.1/islands_nokinmen-10_100_500-contour.pbf
	# combines all dependences
	./tools/combine.sh \
		$@ \
		7000000000 \
		4000000000 \
		$^


.PHONY: taiwan-contour-mix
taiwan-contour-mix: taiwan-contour-mix-2021


.PHONY: taiwan-contour-mix-2016
taiwan-contour-mix-2016: ele_taiwan_10_50_100_500_mix-2016.pbf
ele_taiwan_10_50_100_500_mix-2016.pbf: \
  precompiled/taiwan-sealand.pbf \
  moi-2016/taiwan-10_50_100_500-contour.pbf \
  moi-2016/penghu-10_50_100_500-contour.pbf \
  aw3d30-2.1/islands-10_50_100_500-contour.pbf \
  moi-2016/marker-contour.pbf
	# combines all dependences
	./tools/combine.sh \
		$@ \
		7000000000 \
		4000000000 \
		$^


.PHONY: taiwan-contour-mix-2018
taiwan-contour-mix-2018: ele_taiwan_10_100_500_mix-2018.pbf
ele_taiwan_10_100_500_mix-2018.pbf: \
  precompiled/taiwan-sealand.pbf \
  moi-2018/taiwan-10_50_100_500-contour.pbf \
  moi-2016/penghu-10_50_100_500-contour.pbf \
  aw3d30-2.1/islands-10_50_100_500-contour.pbf \
  moi-2018/marker-contour.pbf
	# combines all dependences
	./tools/combine.sh \
		$@ \
		7000000000 \
		4000000000 \
		$^


.PHONY: taiwan-contour-mix-2019
taiwan-contour-mix-2019: ele_taiwan_10_100_500_mix-2019.pbf
ele_taiwan_10_100_500_mix-2019.pbf: \
  precompiled/taiwan-sealand.pbf \
  moi-2019/taiwan-10_50_100_500-contour.pbf \
  moi-2019/penghu-10_50_100_500-contour.pbf \
  moi-2019/kinmen-10_50_100_500-contour.pbf \
  aw3d30-2.1/islands_nokinmen-10_50_100_500-contour.pbf \
  moi-2019/marker-contour.pbf
	# combines all dependences
	./tools/combine.sh \
		$@ \
		7000000000 \
		4000000000 \
		$^


.PHONY: taiwan-lite-contour-mix
taiwan-lite-contour-mix: taiwan-lite-contour-mix-2021


.PHONY: taiwan-lite-contour-mix-2016
taiwan-lite-contour-mix-2016: ele_taiwan_20_100_500_mix-2016.pbf
ele_taiwan_20_100_500_mix-2016.pbf: \
  precompiled/taiwan-sealand.pbf \
  moi-2016/taiwan-20_100_500-contour.pbf \
  moi-2016/penghu-20_100_500-contour.pbf \
  aw3d30-2.1/islands-20_100_500-contour.pbf \
  moi-2016/marker-contour.pbf
	# combines all dependences
	./tools/combine.sh \
		$@ \
		7000000000 \
		4000000000 \
		$^


.PHONY: taiwan-lite-contour-mix-2018
taiwan-lite-contour-mix-2018: ele_taiwan_20_100_500_mix-2018.pbf
ele_taiwan_20_100_500_mix-2018.pbf: \
  precompiled/taiwan-sealand.pbf \
  moi-2018/taiwan-20_100_500-contour.pbf \
  moi-2016/penghu-20_100_500-contour.pbf \
  aw3d30-2.1/islands-20_100_500-contour.pbf \
  moi-2018/marker-contour.pbf
	# combines all dependences
	./tools/combine.sh \
		$@ \
		7000000000 \
		4000000000 \
		$^


.PHONY: taiwan-lite-contour-mix-2019
taiwan-lite-contour-mix-2019: ele_taiwan_20_100_500_mix-2019.pbf
ele_taiwan_20_100_500_mix-2019.pbf: \
  precompiled/taiwan-sealand.pbf \
  moi-2019/taiwan-20_100_500-contour.pbf \
  moi-2019/penghu-20_100_500-contour.pbf \
  moi-2019/kinmen-20_100_500-contour.pbf \
  aw3d30-2.1/islands_nokinmen-20_100_500-contour.pbf \
  moi-2019/marker-contour.pbf
	# combines all dependences
	./tools/combine.sh \
		$@ \
		7000000000 \
		4000000000 \
		$^
