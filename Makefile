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

taiwan-contour: taiwan-contour-2022
taiwan-contour-mix: taiwan-contour-mix-2022
taiwan-lite-contour-mix: taiwan-lite-contour-mix-2022

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


MOI2020_TAIWAN = moi-2020/taiwan
MOI2020_MARKER = moi-2020/marker

MOI2019_TAIWAN = moi-2019/taiwan
MOI2019_PENGHU = moi-2019/penghu
MOI2019_KINMEN = moi-2019/kinmen
MOI2019_MARKER = moi-2019/marker

MOI2018_TAIWAN = moi-2018/taiwan
MOI2018_MARKER = moi-2018/marker

MOI2016_TAIWAN = moi-2016/taiwan
MOI2016_PENGHU = moi-2016/penghu
MOI2016_MARKER = moi-2016/marker

AW31_N3ISLETS = aw3d30-3.1/n3islets
AW31_MATSU = aw3d30-3.1/matsu
AW31_WUQIU = aw3d30-3.1/wuqiu
AW31_NO_KINMEN = aw3d30-3.1/islands_nokinmen

AW21_N3ISLETS = aw3d30-2.1/n3islets
AW21_MATSU = aw3d30-2.1/matsu
AW21_WUQIU = aw3d30-2.1/wuqiu
AW21_KINMEN = aw3d30-2.1/kinmen
AW21_NO_KINMEN = aw3d30-2.1/islands_nokinmen


##
## Outputs
##

.PHONY: taiwan-contour-2022
taiwan-contour-2022: ele_taiwan_10_100_500-2022.pbf
ele_taiwan_10_100_500-2022.pbf: \
  $(MOI2020_TAIWAN)_20m-gdal_10_100_500.pbf \
  $(MOI2019_PENGHU)-gdal_10_100_500.pbf \
  $(MOI2019_KINMEN)-gdal_10_100_500.pbf \
  $(AW31_MATSU)-gdal_10_100_500.pbf \
  $(AW31_N3ISLETS)-gdal_10_100_500.pbf \
  $(AW31_WUQIU)-gdal_10_100_500.pbf
	# combines all dependences
	./tools/combine.sh \
		$@ \
		7000000000 \
		4000000000 \
		$^


.PHONY: taiwan-contour-mix-2022
taiwan-contour-mix-2022: ele_taiwan_10_100_500_mix-2022.pbf
ele_taiwan_10_100_500_mix-2022.pbf: \
  precompiled/taiwan-sealand.pbf \
  $(MOI2020_TAIWAN)_20m-gdal_10_50_100_500.pbf \
  $(MOI2019_PENGHU)-gdal_10_50_100_500.pbf \
  $(MOI2019_KINMEN)-gdal_10_50_100_500.pbf \
  $(AW31_MATSU)-gdal_10_50_100_500.pbf \
  $(AW31_N3ISLETS)-gdal_10_50_100_500.pbf \
  $(AW31_WUQIU)-gdal_10_50_100_500.pbf \
  $(MOI2020_MARKER)-gdal.pbf
	# combines all dependences
	./tools/combine.sh \
		$@ \
		7000000000 \
		4000000000 \
		$^


.PHONY: taiwan-lite-contour-mix-2022
taiwan-lite-contour-mix-2022: ele_taiwan_20_100_500_mix-2022.pbf
ele_taiwan_20_100_500_mix-2022.pbf: \
  precompiled/taiwan-sealand.pbf \
  $(MOI2020_TAIWAN)_40m-gdal_20_100_500.pbf \
  $(MOI2019_PENGHU)-gdal_20_100_500.pbf \
  $(MOI2019_KINMEN)-gdal_20_100_500.pbf \
  $(AW31_MATSU)-gdal_20_100_500.pbf \
  $(AW21_N3ISLETS)-gdal_20_100_500.pbf \
  $(AW21_WUQIU)-gdal_20_100_500.pbf \
  $(MOI2020_MARKER)-gdal.pbf
	# combines all dependences
	./tools/combine.sh \
		$@ \
		7000000000 \
		4000000000 \
		$^


.PHONY: taiwan-contour-2021
taiwan-contour-2021: ele_taiwan_10_100_500-2021.pbf
ele_taiwan_10_100_500-2021.pbf: \
  $(MOI2020_TAIWAN)-pygm_10_100_500.pbf \
  $(MOI2019_PENGHU)-pygm_10_100_500.pbf \
  $(MOI2019_KINMEN)-pygm_10_100_500.pbf \
  $(AW31_NO_KINMEN)-pygm_10_100_500.pbf
	# combines all dependences
	./tools/combine.sh \
		$@ \
		7000000000 \
		4000000000 \
		$^


.PHONY: taiwan-contour-mix-2021
taiwan-contour-mix-2021: ele_taiwan_10_100_500_mix-2021.pbf
ele_taiwan_10_100_500_mix-2021.pbf: \
  precompiled/taiwan-sealand.pbf \
  $(MOI2020_TAIWAN)-pygm_10_50_100_500.pbf \
  $(MOI2019_PENGHU)-pygm_10_50_100_500.pbf \
  $(MOI2019_KINMEN)-pygm_10_50_100_500.pbf \
  $(AW31_NO_KINMEN)-pygm_10_50_100_500.pbf \
  $(MOI2020_MARKER)-pygm.pbf
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
  $(MOI2020_TAIWAN)-pygm_20_100_500.pbf \
  $(MOI2019_PENGHU)-pygm_20_100_500.pbf \
  $(MOI2019_KINMEN)-pygm_20_100_500.pbf \
  $(AW31_NO_KINMEN)-pygm_20_100_500.pbf \
  $(MOI2020_MARKER)-pygm.pbf
	# combines all dependences
	./tools/combine.sh \
		$@ \
		7000000000 \
		4000000000 \
		$^


.PHONY: taiwan-contour-2020
taiwan-contour-2020: ele_taiwan_10_100_500-2020.pbf
ele_taiwan_10_100_500-2020.pbf: \
  $(MOI2020_TAIWAN)-pygm_10_100_500.pbf \
  $(MOI2019_PENGHU)-pygm_10_100_500.pbf \
  $(MOI2019_KINMEN)-pygm_10_100_500.pbf \
  $(AW21_NO_KINMEN)-pygm_10_100_500.pbf
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
  $(MOI2020_TAIWAN)-pygm_10_50_100_500.pbf \
  $(MOI2019_PENGHU)-pygm_10_50_100_500.pbf \
  $(MOI2019_KINMEN)-pygm_10_50_100_500.pbf \
  $(AW21_NO_KINMEN)-pygm_10_50_100_500.pbf \
  $(MOI2020_MARKER)-pygm.pbf
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
  $(MOI2020_TAIWAN)-pygm_20_100_500.pbf \
  $(MOI2019_PENGHU)-pygm_20_100_500.pbf \
  $(MOI2019_KINMEN)-pygm_20_100_500.pbf \
  $(AW21_NO_KINMEN)-pygm_20_100_500.pbf \
  $(MOI2020_MARKER)-pygm.pbf
	# combines all dependences
	./tools/combine.sh \
		$@ \
		7000000000 \
		4000000000 \
		$^


.PHONY: taiwan-contour-2019
taiwan-contour-2019: ele_taiwan_10_100_500-2019.pbf
ele_taiwan_10_100_500-2019.pbf: \
  $(MOI2019_TAIWAN)-pygm_10_100_500.pbf \
  $(MOI2019_PENGHU)-pygm_10_100_500.pbf \
  $(MOI2019_KINMEN)-pygm_10_100_500.pbf \
  $(AW21_NO_KINMEN)-pygm_10_100_500.pbf
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
  $(MOI2019_TAIWAN)-pygm_10_50_100_500.pbf \
  $(MOI2019_PENGHU)-pygm_10_50_100_500.pbf \
  $(MOI2019_KINMEN)-pygm_10_50_100_500.pbf \
  $(AW21_NO_KINMEN)-pygm_10_50_100_500.pbf \
  $(MOI2019_MARKER)-pygm.pbf
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
  $(MOI2019_TAIWAN)-pygm_20_100_500.pbf \
  $(MOI2019_PENGHU)-pygm_20_100_500.pbf \
  $(MOI2019_KINMEN)-pygm_20_100_500.pbf \
  $(AW21_NO_KINMEN)-pygm_20_100_500.pbf \
  $(MOI2019_MARKER)-pygm.pbf
	# combines all dependences
	./tools/combine.sh \
		$@ \
		7000000000 \
		4000000000 \
		$^


.PHONY: taiwan-contour-2018
taiwan-contour-2018: ele_taiwan_10_100_500-2018.pbf
ele_taiwan_10_100_500-2018.pbf: \
  $(MOI2018_TAIWAN)-pygm_10_100_500.pbf \
  $(MOI2016_PENGHU)-pygm_10_100_500.pbf \
  aw3d30-2.1/islands-pygm_10_100_500.pbf
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
  $(MOI2018_TAIWAN)-pygm_10_50_100_500.pbf \
  $(MOI2016_PENGHU)-pygm_10_50_100_500.pbf \
  aw3d30-2.1/islands-pygm_10_50_100_500.pbf \
  $(MOI2018_MARKER)-pygm.pbf
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
  $(MOI2018_TAIWAN)-pygm_20_100_500.pbf \
  $(MOI2016_PENGHU)-pygm_20_100_500.pbf \
  aw3d30-2.1/islands-pygm_20_100_500.pbf \
  $(MOI2018_MARKER)-pygm.pbf
	# combines all dependences
	./tools/combine.sh \
		$@ \
		7000000000 \
		4000000000 \
		$^


.PHONY: taiwan-contour-2016
taiwan-contour-2016: ele_taiwan_10_100_500-2016.pbf
ele_taiwan_10_100_500-2016.pbf: \
  $(MOI2016_TAIWAN)-pygm_10_100_500.pbf \
  $(MOI2016_PENGHU)-pygm_10_100_500.pbf \
  aw3d30-2.1/islands-pygm_10_100_500.pbf
	# combines all dependences
	./tools/combine.sh \
		$@ \
		7000000000 \
		4000000000 \
		$^


.PHONY: taiwan-contour-mix-2016
taiwan-contour-mix-2016: ele_taiwan_10_50_100_500_mix-2016.pbf
ele_taiwan_10_50_100_500_mix-2016.pbf: \
  precompiled/taiwan-sealand.pbf \
  $(MOI2016_TAIWAN)-pygm_10_50_100_500.pbf \
  $(MOI2016_PENGHU)-pygm_10_50_100_500.pbf \
  aw3d30-2.1/islands-pygm_10_50_100_500.pbf \
  $(MOI2016_MARKER)-pygm.pbf
	# combines all dependences
	./tools/combine.sh \
		$@ \
		7000000000 \
		4000000000 \
		$^


.PHONY: taiwan-lite-contour-mix-2016
taiwan-lite-contour-mix-2016: ele_taiwan_20_100_500_mix-2016.pbf
ele_taiwan_20_100_500_mix-2016.pbf: \
  precompiled/taiwan-sealand.pbf \
  $(MOI2016_TAIWAN)-pygm_20_100_500.pbf \
  $(MOI2016_PENGHU)-pygm_20_100_500.pbf \
  aw3d30-2.1/islands-pygm_20_100_500.pbf \
  $(MOI2016_MARKER)-pygm.pbf
	# combines all dependences
	./tools/combine.sh \
		$@ \
		7000000000 \
		4000000000 \
		$^


## 
## Inputs 
##

$(MOI2020_TAIWAN)_20m.tif: moi-2020/.unzip
moi-2020/.unzip: moi-2020/2020dtm20m.7z.001
	cd moi-2020/ && \
		7za x 2020dtm20m.7z.001 && \
		mv 2020dtm20m.tif taiwan_20m.tif
	touch $@


$(MOI2019_TAIWAN)_20m.tif: moi-2019/.unzip
$(MOI2019_PENGHU).tif: moi-2019/.unzip
$(MOI2019_KINMEN).tif: moi-2019/.unzip
moi-2019/.unzip: moi-2019/DEMg_20m.7z.001
	cd moi-2019/ && \
		7za x DEMg_20m.7z.001 && \
		mv DEMg_geoid2014_20m_20190515.tif taiwan_20m.tif && \
		mv DEMg_20m_PH_20190521.tif penghu.tif && \
		mv DEMg_20m_KM_20190521.tif kinmen.tif
	touch $@


$(MOI2018_TAIWAN)_20m.tif: moi-2018/.unzip
moi-2018/.unzip:
	cd moi-2018/ && \
		7za x DEM_20m.7z.001 && \
		mv DEM_20m.tif taiwan_20m.tif
	touch $@


$(MOI2016_TAIWAN)_20m.tif: moi-2016/.unzip
$(MOI2016_PENGHU).tif: moi-2016/.unzip
moi-2016/.unzip: moi-2016/dem_20m.7z.001
	cd moi-2016/ && \
		7za x dem_20m.7z.001 && \
		mv dem_20m.tif taiwan_20m.tif && \
		mv phDEM_20m_119.tif penghu.tif
	touch $@


aw3d-orig: aw3d30-3.1/.unzip
aw3d30-3.1/.unzip:
	cd aw3d30-3.1/ && \
	7za x aw3d30-3.1.7z
	touch $@


aw3d30-2.1/.unzip:
	cd aw3d30-2.1/ && \
	7za x aw3d30-2.1.7z.001
	touch $@


##
## zero tif ==gdal_contour==> contour shp
## 

$(MOI2020_TAIWAN)_15m-c10.shp: $(MOI2020_TAIWAN)_15m-zero.tif
$(MOI2019_KINMEN)-c10.shp: $(MOI2019_KINMEN)-zero.tif
%-c10.shp: %-zero.tif
	gdal_contour \
		-i 10 \
		-a height \
		$^ \
		$@


$(MOI2020_TAIWAN)_15m-gdal_10_100_500.pbf: $(MOI2020_TAIWAN)_15m-c10.shp
$(MOI2019_KINMEN)-gdal_10_100_500.pbf: $(MOI2019_KINMEN)-c10.shp
%-gdal_10_100_500.pbf: %-c10.shp
	python3 tools/contour-osm.py \
		-t 'contour_ext' \
		-m 100 \
		-M 500 \
		--datasource $^ \
		$@


%-c20.shp: %-zero.tif
	gdal_contour \
		-i 20 \
		-a height \
		$^ \
		$@


%-gdal_20_100_500.pbf: %-c20.shp
	python3 tools/contour-osm.py \
		-t 'contour_ext' \
		-m 100 \
		-M 500 \
		--datasource $^ \
		$@


%_40m-c100.shp: %_40m-zero.tif
	gdal_contour \
		-i 100 \
		-a height \
		$^ \
		$@


%-gdal_40m.pbf: %_40m-c100.shp
	python3 tools/contour-osm.py \
		-t 'contour_40m' \
		-m 500 \
		-M 1000 \
		--datasource $^ \
		$@


%_80m-c100.shp: %_80m-zero.tif
	gdal_contour \
		-i 100 \
		-a height \
		$^ \
		$@


%-gdal_80m.pbf: %_80m-c100.shp
	python3 tools/contour-osm.py \
		-t 'contour_80m' \
		-m 500 \
		-M 1000 \
		--datasource $^ \
		$@


%_160m-c100.shp: %_160m-zero.tif
	gdal_contour \
		-i 100 \
		-a height \
		$^ \
		$@


%-gdal_160m.pbf: %_160m-c100.shp
	python3 tools/contour-osm.py \
		-t 'contour_160m' \
		-m 500 \
		-M 1000 \
		--datasource $^ \
		$@


%_320m-c100.shp: %_320m-zero.tif
	gdal_contour \
		-i 100 \
		-a height \
		$^ \
		$@


%-gdal_320m.pbf: %_320m-c100.shp
	python3 tools/contour-osm.py \
		-t 'contour_320m' \
		-m 500 \
		-M 1000 \
		--datasource $^ \
		$@


%_640m-c100.shp: %_640m-zero.tif
	gdal_contour \
		-i 100 \
		-a height \
		$^ \
		$@


%-gdal_640m.pbf: %_640m-c100.shp
	python3 tools/contour-osm.py \
		-t 'contour_640m' \
		-m 500 \
		-M 1000 \
		--datasource $^ \
		$@


%_1280m-c100.shp: %_1280m-zero.tif
	gdal_contour \
		-i 100 \
		-a height \
		$^ \
		$@


%-gdal_1280m.pbf: %_1280m-c100.shp
	python3 tools/contour-osm.py \
		-t 'contour_1280m' \
		-m 500 \
		-M 1000 \
		--datasource $^ \
		$@


##
## zero tif ==phyghtmap==> contour pbf
## 

$(MOI2020_TAIWAN)-pygm_10_100_500.pbf: $(MOI2020_TAIWAN)_15m-zero.tif
	phyghtmap \
		--step=10 \
		--output-prefix=dem_contour \
		--line-cat=500,100 \
		--simplifyContoursEpsilon=0.00001 \
		$(PHYGHT_OPTIONS) \
		--pbf \
		$^
	mv dem_contour* $@


$(MOI2019_TAIWAN)-pygm_10_100_500.pbf: $(MOI2019_TAIWAN)_20m-zero.tif
$(MOI2018_TAIWAN)-pygm_10_100_500.pbf: $(MOI2018_TAIWAN)_20m-zero.tif
%-pygm_10_100_500.pbf: %_20m-zero.tif
	phyghtmap \
		--step=10 \
		--output-prefix=dem_contour \
		--line-cat=500,100 \
		--simplifyContoursEpsilon=0.00001 \
		$(PHYGHT_OPTIONS) \
		--pbf \
		$^
	mv dem_contour* $@


$(MOI2016_TAIWAN)-pygm_10_100_500.pbf: $(MOI2016_TAIWAN)_20m-zero.tif
	phyghtmap \
		--step=10 \
		--output-prefix=dem_contour \
		--line-cat=500,100 \
		--simplifyContoursEpsilon=0.000002 \
		$(PHYGHT_OPTIONS) \
		--pbf \
		$^
	mv dem_contour* $@


$(MOI2020_TAIWAN)-pygm_20_100_500.pbf: $(MOI2020_TAIWAN)_20m-zero.tif
$(MOI2019_TAIWAN)-pygm_20_100_500.pbf: $(MOI2019_TAIWAN)_20m-zero.tif
$(MOI2018_TAIWAN)-pygm_20_100_500.pbf: $(MOI2018_TAIWAN)_20m-zero.tif
%/taiwan-pygm_20_100_500.pbf: %/taiwan_20m-zero.tif
	phyghtmap \
		--step=20 \
		--output-prefix=dem_lite_contour \
		--line-cat=500,100 \
		--simplifyContoursEpsilon=0.00005 \
		$(PHYGHT_OPTIONS) \
		--pbf \
		$^
	mv dem_lite_contour* $@


$(MOI2016_TAIWAN)-pygm_20_100_500.pbf: $(MOI2016_TAIWAN)_20m-zero.tif
	phyghtmap \
		--step=20 \
		--output-prefix=dem_lite_contour \
		--line-cat=500,100 \
		--simplifyContoursEpsilon=0.000005 \
		$(PHYGHT_OPTIONS) \
		--pbf \
		$^
	mv dem_lite_contour* $@


$(MOI2019_PENGHU)-pygm_10_100_500.pbf: $(MOI2019_PENGHU)-zero.tif
$(MOI2016_PENGHU)-pygm_10_100_500.pbf: $(MOI2016_PENGHU)-zero.tif
%/penghu-pygm_10_100_500.pbf: %/penghu-zero.tif
	phyghtmap \
		--step=10 \
		--output-prefix=penghu_contour \
		--line-cat=500,100 \
		--simplifyContoursEpsilon=0.00001 \
		$(PHYGHT_OPTIONS) \
		--pbf \
		$^
	mv penghu_contour* $@


$(MOI2019_PENGHU)-pygm_20_100_500.pbf: $(MOI2019_PENGHU)-zero.tif
$(MOI2016_PENGHU)-pygm_20_100_500.pbf: $(MOI2016_PENGHU)-zero.tif
%/penghu-pygm_20_100_500.pbf: %/penghu-zero.tif
	phyghtmap \
		--step=20 \
		--output-prefix=penghu_lite_contour \
		--line-cat=500,100 \
		--simplifyContoursEpsilon=0.00005 \
		$(PHYGHT_OPTIONS) \
		--pbf \
		$^
	mv penghu_lite_contour* $@


$(MOI2019_KINMEN)-pygm_10_100_500.pbf: $(MOI2019_KINMEN)-zero.tif
	phyghtmap \
		--step=10 \
		--output-prefix=kinmen_contour \
		--line-cat=500,100 \
		--simplifyContoursEpsilon=0.00001 \
		$(PHYGHT_OPTIONS) \
		--pbf \
		$^
	mv kinmen_contour* $@


$(MOI2019_KINMEN)-pygm_20_100_500.pbf: $(MOI2019_KINMEN)-zero.tif
	phyghtmap \
		--step=20 \
		--output-prefix=kinmen_lite_contour \
		--line-cat=500,100 \
		--simplifyContoursEpsilon=0.00005 \
		$(PHYGHT_OPTIONS) \
		--pbf \
		$^
	mv kinmen_lite_contour* $@


$(AW21_KINMEN)-pygm_10_100_500.pbf: $(AW21_KINMEN)-zero.tif
	phyghtmap \
		--step=10 \
		--output-prefix=kinmen_contour \
		--line-cat=500,100 \
		--simplifyContoursEpsilon=0.000025 \
		$(PHYGHT_OPTIONS) \
		--pbf \
		$^
	mv kinmen_contour* $@


$(AW21_KINMEN)-pygm_20_100_500.pbf: $(AW21_KINMEN)-zero.tif
	phyghtmap \
		--step=20 \
		--output-prefix=kinmen_lite_contour \
		--line-cat=500,100 \
		--simplifyContoursEpsilon=0.000125 \
		$(PHYGHT_OPTIONS) \
		--pbf \
		$^
	mv kinmen_lite_contour* $@


$(AW31_MATSU)-pygm_10_100_500.pbf: $(AW31_MATSU)-zero.tif
$(AW21_MATSU)-pygm_10_100_500.pbf: $(AW21_MATSU)-zero.tif
%/matsu-pygm_10_100_500.pbf: %/matsu-zero.tif
	phyghtmap \
		--step=10 \
		--output-prefix=matsu_contour \
		--line-cat=500,100 \
		--simplifyContoursEpsilon=0.000025 \
		--pbf \
		$^
	mv matsu_contour* $@


$(AW31_MATSU)-pygm_20_100_500.pbf: $(AW31_MATSU)-zero.tif
$(AW21_MATSU)-pygm_20_100_500.pbf: $(AW21_MATSU)-zero.tif
%/matsu-pygm_20_100_500.pbf: %/matsu-zero.tif
	phyghtmap \
		--step=20 \
		--output-prefix=matsu_lite_contour \
		--line-cat=500,100 \
		--simplifyContoursEpsilon=0.000125 \
		$(PHYGHT_OPTIONS) \
		--pbf \
		$^
	mv matsu_lite_contour* $@


$(AW31_N3ISLETS)-pygm_10_100_500.pbf: $(AW31_N3ISLETS)-zero.tif
$(AW21_N3ISLETS)-pygm_10_100_500.pbf: $(AW21_N3ISLETS)-zero.tif
%/n3islets-pygm_10_100_500.pbf: %/n3islets-zero.tif
	phyghtmap \
		--step=10 \
		--output-prefix=n3islets_contour \
		--line-cat=500,100 \
		--simplifyContoursEpsilon=0.000025 \
		$(PHYGHT_OPTIONS) \
		--pbf \
		$^
	mv n3islets_contour* $@


$(AW31_N3ISLETS)-pygm_20_100_500.pbf: $(AW31_N3ISLETS)-zero.tif
$(AW21_N3ISLETS)-pygm_20_100_500.pbf: $(AW21_N3ISLETS)-zero.tif
%/n3islets-pygm_20_100_500.pbf: %/n3islets-zero.tif
	phyghtmap \
		--step=20 \
		--output-prefix=n3islets_lite_contour \
		--line-cat=500,100 \
		--simplifyContoursEpsilon=0.000125 \
		$(PHYGHT_OPTIONS) \
		--pbf \
		$^
	mv n3islets_lite_contour* $@


$(AW31_WUQIU)-pygm_10_100_500.pbf: $(AW31_WUQIU)-zero.tif
$(AW21_WUQIU)-pygm_10_100_500.pbf: $(AW21_WUQIU)-zero.tif
%/wuqiu-pygm_10_100_500.pbf: %/wuqiu-zero.tif
	phyghtmap \
		--step=10 \
		--output-prefix=wuqiu_contour \
		--line-cat=500,100 \
		--simplifyContoursEpsilon=0.000025 \
		$(PHYGHT_OPTIONS) \
		--pbf \
		$^
	mv wuqiu_contour* $@


$(AW31_WUQIU)-pygm_20_100_500.pbf: $(AW31_WUQIU)-zero.tif
$(AW21_WUQIU)-pygm_20_100_500.pbf: $(AW21_WUQIU)-zero.tif
%/wuqiu-pygm_20_100_500.pbf: %/wuqiu-zero.tif
	phyghtmap \
		--step=20 \
		--output-prefix=wuqiu_lite_contour \
		--line-cat=500,100 \
		--simplifyContoursEpsilon=0.000125 \
		$(PHYGHT_OPTIONS) \
		--pbf \
		$^
	mv wuqiu_lite_contour* $@


$(MOI2020_TAIWAN)-pygm_40m.pbf: $(MOI2020_TAIWAN)_40m-zero.tif
$(MOI2019_TAIWAN)-pygm_40m.pbf: $(MOI2019_TAIWAN)_40m-zero.tif
$(MOI2018_TAIWAN)-pygm_40m.pbf: $(MOI2018_TAIWAN)_40m-zero.tif
$(MOI2016_TAIWAN)-pygm_40m.pbf: $(MOI2016_TAIWAN)_40m-zero.tif
%-pygm_40m.pbf: %_40m-zero.tif
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


$(MOI2020_TAIWAN)-pygm_80m.pbf: $(MOI2020_TAIWAN)_80m-zero.tif
$(MOI2019_TAIWAN)-pygm_80m.pbf: $(MOI2019_TAIWAN)_80m-zero.tif
$(MOI2018_TAIWAN)-pygm_80m.pbf: $(MOI2018_TAIWAN)_80m-zero.tif
$(MOI2016_TAIWAN)-pygm_80m.pbf: $(MOI2016_TAIWAN)_80m-zero.tif
%-pygm_80m.pbf: %_80m-zero.tif
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


$(MOI2020_TAIWAN)-pygm_160m.pbf: $(MOI2020_TAIWAN)_160m-zero.tif
$(MOI2019_TAIWAN)-pygm_160m.pbf: $(MOI2019_TAIWAN)_160m-zero.tif
$(MOI2018_TAIWAN)-pygm_160m.pbf: $(MOI2018_TAIWAN)_160m-zero.tif
$(MOI2016_TAIWAN)-pygm_160m.pbf: $(MOI2016_TAIWAN)_160m-zero.tif
%-pygm_160m.pbf: %_160m-zero.tif
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


$(MOI2020_TAIWAN)-pygm_320m.pbf: $(MOI2020_TAIWAN)_320m-zero.tif
$(MOI2019_TAIWAN)-pygm_320m.pbf: $(MOI2019_TAIWAN)_320m-zero.tif
$(MOI2018_TAIWAN)-pygm_320m.pbf: $(MOI2018_TAIWAN)_320m-zero.tif
$(MOI2016_TAIWAN)-pygm_320m.pbf: $(MOI2016_TAIWAN)_320m-zero.tif
%-pygm_320m.pbf: %_320m-zero.tif
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


$(MOI2020_TAIWAN)-pygm_640m.pbf: $(MOI2020_TAIWAN)_640m-zero.tif
$(MOI2019_TAIWAN)-pygm_640m.pbf: $(MOI2019_TAIWAN)_640m-zero.tif
$(MOI2018_TAIWAN)-pygm_640m.pbf: $(MOI2018_TAIWAN)_640m-zero.tif
$(MOI2016_TAIWAN)-pygm_640m.pbf: $(MOI2016_TAIWAN)_640m-zero.tif
%-pygm_640m.pbf: %_640m-zero.tif
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

$(MOI2020_TAIWAN)-pygm_1280m.pbf: $(MOI2020_TAIWAN)_1280m-zero.tif
$(MOI2019_TAIWAN)-pygm_1280m.pbf: $(MOI2019_TAIWAN)_1280m-zero.tif
$(MOI2018_TAIWAN)-pygm_1280m.pbf: $(MOI2018_TAIWAN)_1280m-zero.tif
$(MOI2016_TAIWAN)-pygm_1280m.pbf: $(MOI2016_TAIWAN)_1280m-zero.tif
%-pygm_1280m.pbf: %_1280m-zero.tif
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


moi-2018/from2016.tif: $(MOI2016_TAIWAN)_20m-zero.tif
	rm -f $@
	gdalwarp \
		$(OUTPUTS) \
		-dstnodata $(NODATA_VALUE) \
		-crop_to_cutline \
		-cutline moi-2018/void_area.shp \
		$^ \
		$@


moi-2019/from2016.tif: $(MOI2016_TAIWAN)_20m-zero.tif
	rm -f $@
	gdalwarp \
		$(OUTPUTS) \
		-dstnodata $(NODATA_VALUE) \
		-crop_to_cutline \
		-cutline moi-2019/void_area.shp \
		$^ \
		$@


aw3d30-2.1/islands-pygm_10_50_100_500.pbf: aw3d30-2.1/islands-pygm_10_100_500.pbf
$(MOI2020_TAIWAN)-pygm_10_50_100_500.pbf: $(MOI2020_TAIWAN)-pygm_10_100_500.pbf
$(MOI2019_TAIWAN)-pygm_10_50_100_500.pbf: $(MOI2019_TAIWAN)-pygm_10_100_500.pbf
$(MOI2019_PENGHU)-pygm_10_50_100_500.pbf: $(MOI2019_PENGHU)-pygm_10_100_500.pbf
$(MOI2019_KINMEN)-pygm_10_50_100_500.pbf: $(MOI2019_KINMEN)-pygm_10_100_500.pbf
$(MOI2018_TAIWAN)-pygm_10_50_100_500.pbf: $(MOI2018_TAIWAN)-pygm_10_100_500.pbf
$(MOI2016_PENGHU)-pygm_10_50_100_500.pbf: $(MOI2016_PENGHU)-pygm_10_100_500.pbf
$(MOI2016_TAIWAN)-pygm_10_50_100_500.pbf: $(MOI2016_TAIWAN)-pygm_10_100_500.pbf
$(AW31_NO_KINMEN)-pygm_10_50_100_500.pbf: $(AW31_NO_KINMEN)-pygm_10_100_500.pbf
$(AW21_NO_KINMEN)-pygm_10_50_100_500.pbf: $(AW21_NO_KINMEN)-pygm_10_100_500.pbf
%_10_50_100_500.pbf: %_10_100_500.pbf
	rm -f $@
	python3 tools/elevation_sub.py $< $@


%/marker-gdal.pbf: \
  %/taiwan-gdal_40m.pbf \
  %/taiwan-gdal_80m.pbf \
  %/taiwan-gdal_160m.pbf \
  %/taiwan-gdal_320m.pbf \
  %/taiwan-gdal_640m.pbf \
  %/taiwan-gdal_1280m.pbf
	# combines all dependences
	./tools/combine.sh \
		$@ \
		1 \
		1 \
		$^


$(MOI2020_MARKER)-pygm.pbf: \
  $(MOI2020_TAIWAN)-pygm_40m.pbf \
  $(MOI2020_TAIWAN)-pygm_80m.pbf \
  $(MOI2020_TAIWAN)-pygm_160m.pbf \
  $(MOI2020_TAIWAN)-pygm_320m.pbf \
  $(MOI2020_TAIWAN)-pygm_640m.pbf \
  $(MOI2020_TAIWAN)-pygm_1280m.pbf
	# combines all dependences
	./tools/combine.sh \
		$@ \
		1 \
		1 \
		$^


$(MOI2019_TAIWAN)_10m-zero.tif: $(MOI2019_TAIWAN)_20m-zero.tif
%_10m-zero.tif: %_20m-zero.tif
	rm -f $@
	gdalwarp \
		 $(OUTPUTS) \
		-dstnodata $(NODATA_VALUE) \
		-ts 21652 0 \
		-r bilinear \
		-wt $(WORKING_TYPE) \
	  $^ \
	  $@


$(MOI2020_TAIWAN)_15m-zero.tif: $(MOI2020_TAIWAN)_20m-zero.tif
%_15m-zero.tif: %_20m-zero.tif
	rm -f $@
	gdalwarp \
		 $(OUTPUTS) \
		-dstnodata $(NODATA_VALUE) \
		-ts 14435 0 \
		-r bilinear \
		-wt $(WORKING_TYPE) \
	  $^ \
	  $@


$(MOI2018_TAIWAN)_40m-zero.tif: $(MOI2018_TAIWAN)_20m-zero.tif
$(MOI2019_TAIWAN)_40m-zero.tif: $(MOI2019_TAIWAN)_20m-zero.tif
$(MOI2020_TAIWAN)_40m-zero.tif: $(MOI2020_TAIWAN)_20m-zero.tif
%_40m-zero.tif: %_20m-zero.tif
	rm -f $@
	gdalwarp \
		 $(OUTPUTS) \
		-dstnodata $(NODATA_VALUE) \
		-ts 5414 0 \
		-r bilinear \
		-wt $(WORKING_TYPE) \
	  $^ \
	  $@


$(MOI2018_TAIWAN)_80m-zero.tif: $(MOI2018_TAIWAN)_20m-zero.tif
$(MOI2019_TAIWAN)_80m-zero.tif: $(MOI2019_TAIWAN)_20m-zero.tif
$(MOI2020_TAIWAN)_80m-zero.tif: $(MOI2020_TAIWAN)_20m-zero.tif
%_80m-zero.tif: %_20m-zero.tif
	rm -f $@
	gdalwarp \
		 $(OUTPUTS) \
		-dstnodata $(NODATA_VALUE) \
		-ts 2707 0 \
		-r bilinear \
		-wt $(WORKING_TYPE) \
	  $^ \
	  $@


$(MOI2018_TAIWAN)_160m-zero.tif: $(MOI2018_TAIWAN)_20m-zero.tif
$(MOI2019_TAIWAN)_160m-zero.tif: $(MOI2019_TAIWAN)_20m-zero.tif
$(MOI2020_TAIWAN)_160m-zero.tif: $(MOI2020_TAIWAN)_20m-zero.tif
%_160m-zero.tif: %_20m-zero.tif
	rm -f $@
	gdalwarp \
		 $(OUTPUTS) \
		-dstnodata $(NODATA_VALUE) \
		-ts 1353 0 \
		-r bilinear \
		-wt $(WORKING_TYPE) \
	  $^ \
	  $@


$(MOI2018_TAIWAN)_320m-zero.tif: $(MOI2018_TAIWAN)_20m-zero.tif
$(MOI2019_TAIWAN)_320m-zero.tif: $(MOI2019_TAIWAN)_20m-zero.tif
$(MOI2020_TAIWAN)_320m-zero.tif: $(MOI2020_TAIWAN)_20m-zero.tif
%_320m-zero.tif: %_20m-zero.tif
	rm -f $@
	gdalwarp \
		 $(OUTPUTS) \
		-dstnodata $(NODATA_VALUE) \
		-ts 677 0 \
		-r bilinear \
		-wt $(WORKING_TYPE) \
	  $^ \
	  $@


$(MOI2018_TAIWAN)_640m-zero.tif: $(MOI2018_TAIWAN)_20m-zero.tif
$(MOI2019_TAIWAN)_640m-zero.tif: $(MOI2019_TAIWAN)_20m-zero.tif
$(MOI2020_TAIWAN)_640m-zero.tif: $(MOI2020_TAIWAN)_20m-zero.tif
%_640m-zero.tif: %_20m-zero.tif
	rm -f $@
	gdalwarp \
		 $(OUTPUTS) \
		-dstnodata $(NODATA_VALUE) \
		-ts 338 0 \
		-r bilinear \
		-wt $(WORKING_TYPE) \
	  $^ \
	  $@


$(MOI2018_TAIWAN)_1280m-zero.tif: $(MOI2018_TAIWAN)_20m-zero.tif
$(MOI2019_TAIWAN)_1280m-zero.tif: $(MOI2019_TAIWAN)_20m-zero.tif
$(MOI2020_TAIWAN)_1280m-zero.tif: $(MOI2020_TAIWAN)_20m-zero.tif
%_1280m-zero.tif: %_20m-zero.tif
	rm -f $@
	gdalwarp \
		 $(OUTPUTS) \
		-dstnodata $(NODATA_VALUE) \
		-ts 169 0 \
		-r bilinear \
		-wt $(WORKING_TYPE) \
	  $^ \
	  $@


$(AW21_KINMEN)-zero.tif: $(AW21_KINMEN)-nodata0.tif
$(AW21_WUQIU)-zero.tif: $(AW21_WUQIU)-nodata0.tif
$(AW31_WUQIU)-zero.tif: $(AW31_WUQIU)-nodata0.tif
$(AW21_MATSU)-zero.tif: $(AW21_MATSU)-nodata0.tif
$(AW31_MATSU)-zero.tif: $(AW31_MATSU)-nodata0.tif
$(AW21_N3ISLETS)-zero.tif: $(AW21_N3ISLETS)-nodata0.tif
$(AW31_N3ISLETS)-zero.tif: $(AW31_N3ISLETS)-nodata0.tif
$(MOI2016_TAIWAN)_20m-zero.tif: $(MOI2016_TAIWAN)_20m-nodata0.tif
$(MOI2016_PENGHU)-zero.tif: $(MOI2016_PENGHU)-nodata0.tif
$(MOI2018_TAIWAN)_20m-zero.tif: $(MOI2018_TAIWAN)_20m-nodata0.tif
$(MOI2019_KINMEN)-zero.tif: $(MOI2019_KINMEN)-nodata0.tif
$(MOI2019_PENGHU)-zero.tif: $(MOI2019_PENGHU)-nodata0.tif
$(MOI2019_TAIWAN)_20m-zero.tif: $(MOI2019_TAIWAN)_20m-nodata0.tif
$(MOI2020_TAIWAN)_20m-zero.tif: $(MOI2020_TAIWAN)_20m-nodata0.tif
%-zero.tif: %-nodata0.tif
	rm -f $@
	gdal_translate \
		$(OUTPUTS) \
		-a_nodata none \
		$^ \
		$@


$(MOI2016_TAIWAN)_20m-nodata0.tif: $(MOI2016_TAIWAN)_20m-nodata.tif
$(MOI2016_PENGHU)-nodata0.tif: $(MOI2016_PENGHU)-nodata.tif
$(MOI2018_TAIWAN)_20m-nodata0.tif: $(MOI2018_TAIWAN)_20m-nodata.tif
$(MOI2019_KINMEN)-nodata0.tif: $(MOI2019_KINMEN)-nodata.tif
$(MOI2019_PENGHU)-nodata0.tif: $(MOI2019_PENGHU)-nodata.tif
$(MOI2019_TAIWAN)_20m-nodata0.tif: $(MOI2019_TAIWAN)_20m-nodata.tif
$(MOI2020_TAIWAN)_20m-nodata0.tif: $(MOI2020_TAIWAN)_20m-nodata.tif
%-nodata0.tif: %-nodata.tif
	rm -f $@
	gdal_calc.py \
		--NoDataValue=0 \
		--calc="(A > 0) * A" \
		-A $^ \
		--outfile=$@


$(MOI2016_TAIWAN)_20m-nodata.tif: $(MOI2016_TAIWAN)_20m-wgs84.tif
$(MOI2016_PENGHU)-nodata.tif: $(MOI2016_PENGHU)-wgs84.tif
$(MOI2018_TAIWAN)_20m-nodata.tif: $(MOI2018_TAIWAN)_20m-wgs84.tif moi-2018/from2016.tif 
$(MOI2019_KINMEN)-nodata.tif: $(MOI2019_KINMEN)-wgs84.tif
$(MOI2019_PENGHU)-nodata.tif: $(MOI2019_PENGHU)-wgs84.tif
$(MOI2019_TAIWAN)_20m-nodata.tif: $(MOI2019_TAIWAN)_20m-wgs84.tif moi-2019/from2016.tif 
$(MOI2020_TAIWAN)_20m-nodata.tif: $(MOI2020_TAIWAN)_20m-wgs84.tif moi-2020/from2016.tif 
%-nodata.tif: %-wgs84.tif
	rm -f $@
	gdal_merge.py \
		$(OUTPUTS) \
		-n $(NODATA_VALUE) -a_nodata $(NODATA_VALUE) \
		$^ \
		-o $@


$(MOI2016_TAIWAN)_20m-wgs84.tif: $(MOI2016_TAIWAN)_20m.tif
$(MOI2016_PENGHU)-wgs84.tif: $(MOI2016_PENGHU).tif
$(MOI2018_TAIWAN)_20m-wgs84.tif: $(MOI2018_TAIWAN)_20m.tif
$(MOI2019_KINMEN)-wgs84.tif: $(MOI2019_KINMEN).tif
$(MOI2019_PENGHU)-wgs84.tif: $(MOI2019_PENGHU).tif
$(MOI2019_TAIWAN)_20m-wgs84.tif: $(MOI2019_TAIWAN)_20m.tif
$(MOI2020_TAIWAN)_20m-wgs84.tif: $(MOI2020_TAIWAN)_20m.tif
%-wgs84.tif: %.tif
	rm -f $@
	gdalwarp \
		$(OUTPUTS) \
		$(GDALWARP_WGS84_OPTIONS) \
	  $^ \
	  $@


moi-2020/from2016.tif: $(MOI2016_TAIWAN)_20m-zero.tif
	rm -f $@
	gdalwarp \
		$(OUTPUTS) \
		-dstnodata $(NODATA_VALUE) \
		-crop_to_cutline \
		-cutline moi-2020/void_area.shp \
		$^ \
		$@


$(AW31_N3ISLETS)-nodata0.tif: aw3d30-3.1/.unzip
	rm -f $@
	gdalwarp \
		$(OUTPUTS) \
		-crop_to_cutline \
		-cutline $(AW31_N3ISLETS).shp \
		-dstnodata 0 \
		aw3d30-3.1/ALPSMLC30_N025E122_DSM.tif \
		$@


$(AW21_N3ISLETS)-nodata0.tif: aw3d30-2.1/.unzip
	rm -f $@
	gdalwarp \
		$(OUTPUTS) \
		-crop_to_cutline \
		-cutline $(AW21_N3ISLETS).shp \
		-dstnodata 0 \
		aw3d30-2.1/N025E122_AVE_DSM.tif \
		$@


$(AW31_MATSU)-nodata0.tif: aw3d30-3.1/.unzip
	rm -f $@
	gdalwarp \
		$(OUTPUTS) \
		-crop_to_cutline \
		-cutline $(AW31_MATSU).shp \
		-dstnodata 0 \
		aw3d30-3.1/ALPSMLC30_N026E119_DSM.tif \
		aw3d30-3.1/ALPSMLC30_N026E120_DSM.tif \
		aw3d30-3.1/ALPSMLC30_N025E119_DSM.tif \
		$@


$(AW21_MATSU)-nodata0.tif: aw3d30-2.1/.unzip
	rm -f $@
	gdalwarp \
		$(OUTPUTS) \
		-crop_to_cutline \
		-cutline $(AW21_MATSU).shp \
		-dstnodata 0 \
		aw3d30-2.1/N026E119_AVE_DSM.tif \
		aw3d30-2.1/N026E120_AVE_DSM.tif \
		aw3d30-2.1/N025E119_AVE_DSM.tif \
		$@


$(AW31_WUQIU)-nodata0.tif: aw3d30-3.1/.unzip
	rm -f $@
	gdalwarp \
		$(OUTPUTS) \
		-crop_to_cutline \
		-cutline $(AW31_WUQIU).shp \
		-dstnodata 0 \
		aw3d30-3.1/ALPSMLC30_N024E119_DSM.tif \
		$@


$(AW21_WUQIU)-nodata0.tif: aw3d30-2.1/.unzip
	rm -f $@
	gdalwarp \
		$(OUTPUTS) \
		-crop_to_cutline \
		-cutline $(AW21_WUQIU).shp \
		-dstnodata 0 \
		aw3d30-2.1/N024E119_AVE_DSM.tif \
		$@


$(AW21_KINMEN)-nodata0.tif: aw3d30-2.1/.unzip
	rm -f $@
	gdalwarp \
		$(OUTPUTS) \
		-crop_to_cutline \
		-cutline $(AW21_KINMEN).shp \
		-dstnodata 0 \
		aw3d30-2.1/N024E118_AVE_DSM.tif \
		$@


$(MOI2016_TAIWAN)_40m-zero.tif: $(MOI2016_TAIWAN)_20m-zero.tif
	rm -f $@
	gdalwarp \
		 $(OUTPUTS) \
		-dstnodata $(NODATA_VALUE) \
		-ts 5490 0 \
		-r bilinear \
		-wt $(WORKING_TYPE) \
	  $^ \
	  $@

$(MOI2016_TAIWAN)_80m-zero.tif: $(MOI2016_TAIWAN)_20m-zero.tif
	rm -f $@
	gdalwarp \
		 $(OUTPUTS) \
		-dstnodata $(NODATA_VALUE) \
		-ts 2745 0 \
		-r bilinear \
		-wt $(WORKING_TYPE) \
	  $^ \
	  $@

$(MOI2016_TAIWAN)_160m-zero.tif: $(MOI2016_TAIWAN)_20m-zero.tif
	rm -f $@
	gdalwarp \
		 $(OUTPUTS) \
		-dstnodata $(NODATA_VALUE) \
		-ts 1372 0 \
		-r bilinear \
		-wt $(WORKING_TYPE) \
	  $^ \
	  $@

$(MOI2016_TAIWAN)_320m-zero.tif: $(MOI2016_TAIWAN)_20m-zero.tif
	rm -f $@
	gdalwarp \
		 $(OUTPUTS) \
		-dstnodata $(NODATA_VALUE) \
		-ts 686 0 \
		-r bilinear \
		-wt $(WORKING_TYPE) \
	  $^ \
	  $@

$(MOI2016_TAIWAN)_640m-zero.tif: $(MOI2016_TAIWAN)_20m-zero.tif
	rm -f $@
	gdalwarp \
		 $(OUTPUTS) \
		-dstnodata $(NODATA_VALUE) \
		-ts 343 0 \
		-r bilinear \
		-wt $(WORKING_TYPE) \
	  $^ \
	  $@


$(MOI2016_TAIWAN)_1280m-zero.tif: $(MOI2016_TAIWAN)_20m-zero.tif
	rm -f $@
	gdalwarp \
		 $(OUTPUTS) \
		-dstnodata $(NODATA_VALUE) \
		-ts 172 0 \
		-r bilinear \
		-wt $(WORKING_TYPE) \
	  $^ \
	  $@


aw3d30-2.1/islands-pygm_10_100_500.pbf: \
  $(AW21_KINMEN)-pygm_10_100_500.pbf \
  $(AW21_MATSU)-pygm_10_100_500.pbf \
  $(AW21_N3ISLETS)-pygm_10_100_500.pbf \
  $(AW21_WUQIU)-pygm_10_100_500.pbf
	# combines all dependences
	./tools/combine.sh \
		$@ \
		1 \
		1 \
		$^


aw3d30-2.1/islands-pygm_20_100_500.pbf: \
  $(AW21_KINMEN)-pygm_20_100_500.pbf \
  $(AW21_MATSU)-pygm_20_100_500.pbf \
  $(AW21_N3ISLETS)-pygm_20_100_500.pbf \
  $(AW21_WUQIU)-pygm_20_100_500.pbf
	# combines all dependences
	./tools/combine.sh \
		$@ \
		1 \
		1 \
		$^


$(AW31_NO_KINMEN)-pygm_10_100_500.pbf: \
  $(AW31_MATSU)-pygm_10_100_500.pbf \
  $(AW31_N3ISLETS)-pygm_10_100_500.pbf \
  $(AW31_WUQIU)-pygm_10_100_500.pbf
$(AW21_NO_KINMEN)-pygm_10_100_500.pbf: \
  $(AW21_MATSU)-pygm_10_100_500.pbf \
  $(AW21_N3ISLETS)-pygm_10_100_500.pbf \
  $(AW21_WUQIU)-pygm_10_100_500.pbf
%/islands_nokinmen-pygm_10_100_500.pbf: \
  %/matsu-pygm_10_100_500.pbf \
  %/n3islets-pygm_10_100_500.pbf \
  %/wuqiu-pygm_10_100_500.pbf
	# combines all dependences
	./tools/combine.sh \
		$@ \
		1 \
		1 \
		$^


$(AW31_NO_KINMEN)-pygm_20_100_500.pbf: \
  $(AW31_MATSU)-pygm_20_100_500.pbf \
  $(AW31_N3ISLETS)-pygm_20_100_500.pbf \
  $(AW31_WUQIU)-pygm_20_100_500.pbf
$(AW21_NO_KINMEN)-pygm_20_100_500.pbf: \
  $(AW21_MATSU)-pygm_20_100_500.pbf \
  $(AW21_N3ISLETS)-pygm_20_100_500.pbf \
  $(AW21_WUQIU)-pygm_20_100_500.pbf
%/islands_nokinmen-pygm_20_100_500.pbf: \
  %/matsu-pygm_20_100_500.pbf \
  %/n3islets-pygm_20_100_500.pbf \
  %/wuqiu-pygm_20_100_500.pbf
	# combines all dependences
	./tools/combine.sh \
		$@ \
		1 \
		1 \
		$^


$(MOI2016_MARKER)-pygm.pbf: \
  $(MOI2016_TAIWAN)-pygm_40m.pbf \
  $(MOI2016_TAIWAN)-pygm_80m.pbf \
  $(MOI2016_TAIWAN)-pygm_160m.pbf \
  $(MOI2016_TAIWAN)-pygm_320m.pbf \
  $(MOI2016_TAIWAN)-pygm_640m.pbf \
  $(MOI2016_TAIWAN)-pygm_1280m.pbf
	# combines all dependences
	./tools/combine.sh \
		$@ \
		1 \
		1 \
		$^


$(MOI2018_MARKER)-pygm.pbf: \
  $(MOI2018_TAIWAN)-pygm_40m.pbf \
  $(MOI2018_TAIWAN)-pygm_80m.pbf \
  $(MOI2018_TAIWAN)-pygm_160m.pbf \
  $(MOI2018_TAIWAN)-pygm_320m.pbf \
  $(MOI2018_TAIWAN)-pygm_640m.pbf \
  $(MOI2018_TAIWAN)-pygm_1280m.pbf
	# combines all dependences
	./tools/combine.sh \
		$@ \
		1 \
		1 \
		$^


$(MOI2019_MARKER)-pygm.pbf: \
  $(MOI2019_TAIWAN)-pygm_40m.pbf \
  $(MOI2019_TAIWAN)-pygm_80m.pbf \
  $(MOI2019_TAIWAN)-pygm_160m.pbf \
  $(MOI2019_TAIWAN)-pygm_320m.pbf \
  $(MOI2019_TAIWAN)-pygm_640m.pbf \
  $(MOI2019_TAIWAN)-pygm_1280m.pbf
	# combines all dependences
	./tools/combine.sh \
		$@ \
		1 \
		1 \
		$^

