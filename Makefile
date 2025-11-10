# remove half-dones
.DELETE_ON_ERROR:

# keep intermediates 
.SECONDARY:

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

DESTDIR ?= drops

.PHONY: drops
drops: all
	mkdir -p $(DESTDIR)/
	osmconvert ele_taiwan_10_100_500-2024.pbf -o=$(DESTDIR)/ele_taiwan_10_100_500-2024.o5m
	cd $(DESTDIR) && $(MD5_CMD) ele_taiwan_10_100_500-2024.o5m > ele_taiwan_10_100_500-2024.o5m.md5
	osmconvert ele_taiwan_10_100_500_mix-2024.pbf -o=$(DESTDIR)/ele_taiwan_10_50_100_500_marker-2024.o5m
	cd $(DESTDIR) && $(MD5_CMD) ele_taiwan_10_50_100_500_marker-2024.o5m > ele_taiwan_10_50_100_500_marker-2024.o5m.md5
	osmconvert ele_taiwan_20_100_500_mix-2024.pbf -o=$(DESTDIR)/ele_taiwan_20_100_500_marker-2024.o5m
	cd $(DESTDIR) && $(MD5_CMD) ele_taiwan_20_100_500_marker-2024.o5m > ele_taiwan_20_100_500_marker-2024.o5m.md5

.PHONY: hgts
hgts: moi-2024/taiwan16_20m-zero.tif aw3d30-4.1/matsu-zero.tif aw3d30-4.1/n3islets-zero.tif aw3d30-4.1/wuqiu-zero.tif
	rm -rf input output
	mkdir -p input output
	ln -sf ../moi-2024/taiwan16_20m-zero.tif input/N025E121_AVE_DSM.tif
	ln -sf ../moi-2024/taiwan16_20m-zero.tif input/N024E121_AVE_DSM.tif
	ln -sf ../moi-2024/taiwan16_20m-zero.tif input/N024E120_AVE_DSM.tif
	ln -sf ../moi-2024/taiwan16_20m-zero.tif input/N023E121_AVE_DSM.tif
	ln -sf ../moi-2024/taiwan16_20m-zero.tif input/N023E120_AVE_DSM.tif
	ln -sf ../moi-2024/taiwan16_20m-zero.tif input/N022E121_AVE_DSM.tif
	ln -sf ../moi-2024/taiwan16_20m-zero.tif input/N022E120_AVE_DSM.tif
	ln -sf ../moi-2024/taiwan16_20m-zero.tif input/N021E121_AVE_DSM.tif
	ln -sf ../moi-2024/taiwan16_20m-zero.tif input/N021E120_AVE_DSM.tif
	ln -sf ../aw3d30-4.1/matsu-zero.tif input/N026E120_AVE_DSM.tif
	ln -sf ../aw3d30-4.1/matsu-zero.tif input/N026E119_AVE_DSM.tif
	ln -sf ../aw3d30-4.1/matsu-zero.tif input/N025E119_AVE_DSM.tif
	ln -sf ../aw3d30-4.1/n3islets-zero.tif input/N025E122_AVE_DSM.tif
	ln -sf ../aw3d30-4.1/wuqiu-zero.tif input/N024E119_AVE_DSM.tif
	./tools/aw3d2srtm30.sh
	cat precompiled/VERSION-hgtmix.txt > output/VERSION
	cd output && unzip ../precompiled/hgtmix-void.zip && 7z a -tzip hgtmix.zip *.hgt VERSION && rm -f *.hgt VERSION *.xml
	./tools/aw3d2srtm90.sh
	cat precompiled/VERSION-hgt90.txt > output/VERSION
	cd output && unzip ../precompiled/hgt90-void.zip && 7z a -tzip hgt90.zip *.hgt VERSION && rm -f *.hgt VERSION *.xml

taiwan-contour: taiwan-contour-2024
taiwan-contour-mix: taiwan-contour-mix-2024
taiwan-lite-contour-mix: taiwan-lite-contour-mix-2024

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


##
## Outputs
##

.PHONY: taiwan-contour-2024
taiwan-contour-2024: ele_taiwan_10_100_500-2024.pbf
ele_taiwan_10_100_500-2024.pbf: \
  moi-2024/taiwan16_15m-pygm_10_100_500.pbf \
  moi-2019/penghu-pygm_10_100_500.pbf \
  moi-2019/kinmen-pygm_10_100_500.pbf \
  aw3d30-4.1/matsu-pygm_10_100_500.pbf \
  aw3d30-4.1/n3islets-pygm_10_100_500.pbf \
  aw3d30-4.1/wuqiu-pygm_10_100_500.pbf
	# combines all dependences
	./tools/combine.sh \
		$@ \
		7000000000 \
		4000000000 \
		$^


.PHONY: taiwan-contour-2023
taiwan-contour-2023: ele_taiwan_10_100_500-2023.pbf
ele_taiwan_10_100_500-2023.pbf: \
  moi-2022/taiwan16_15m-pygm_10_100_500.pbf \
  moi-2019/penghu-pygm_10_100_500.pbf \
  moi-2019/kinmen-pygm_10_100_500.pbf \
  aw3d30-3.1/matsu-pygm_10_100_500.pbf \
  aw3d30-3.1/n3islets-pygm_10_100_500.pbf \
  aw3d30-3.1/wuqiu-pygm_10_100_500.pbf
	# combines all dependences
	./tools/combine.sh \
		$@ \
		7000000000 \
		4000000000 \
		$^


.PHONY: taiwan-contour-mix-2024
taiwan-contour-mix-2024: ele_taiwan_10_100_500_mix-2024.pbf
ele_taiwan_10_100_500_mix-2024.pbf: \
  precompiled/taiwan-sealand.pbf \
  moi-2024/taiwan16_15m-pygm_10_50_100_500.pbf \
  moi-2019/penghu-pygm_10_50_100_500.pbf \
  moi-2019/kinmen-pygm_10_50_100_500.pbf \
  aw3d30-4.1/matsu-pygm_10_50_100_500.pbf \
  aw3d30-4.1/n3islets-pygm_10_50_100_500.pbf \
  aw3d30-4.1/wuqiu-pygm_10_50_100_500.pbf \
  moi-2024/taiwan16-marker-pygms.pbf
	# combines all dependences
	./tools/combine.sh \
		$@ \
		7000000000 \
		4000000000 \
		$^


.PHONY: taiwan-contour-mix-2023
taiwan-contour-mix-2023: ele_taiwan_10_100_500_mix-2023.pbf
ele_taiwan_10_100_500_mix-2023.pbf: \
  precompiled/taiwan-sealand.pbf \
  moi-2022/taiwan16_15m-pygm_10_50_100_500.pbf \
  moi-2019/penghu-pygm_10_50_100_500.pbf \
  moi-2019/kinmen-pygm_10_50_100_500.pbf \
  aw3d30-3.1/matsu-pygm_10_50_100_500.pbf \
  aw3d30-3.1/n3islets-pygm_10_50_100_500.pbf \
  aw3d30-3.1/wuqiu-pygm_10_50_100_500.pbf \
  moi-2022/taiwan16-marker-pygms.pbf
	# combines all dependences
	./tools/combine.sh \
		$@ \
		7000000000 \
		4000000000 \
		$^


.PHONY: taiwan-lite-contour-mix-2024
taiwan-lite-contour-mix-2024: ele_taiwan_20_100_500_mix-2024.pbf
ele_taiwan_20_100_500_mix-2024.pbf: \
  precompiled/taiwan-sealand.pbf \
  moi-2024/taiwan16_60m-pygm_20_100_500.pbf \
  moi-2019/penghu-pygm_20_100_500.pbf \
  moi-2019/kinmen-pygm_20_100_500.pbf \
  aw3d30-4.1/matsu-pygm_20_100_500.pbf \
  aw3d30-4.1/n3islets-pygm_20_100_500.pbf \
  aw3d30-4.1/wuqiu-pygm_20_100_500.pbf \
  moi-2024/taiwan16-marker-pygms.pbf
	# combines all dependences
	./tools/combine.sh \
		$@ \
		7000000000 \
		4000000000 \
		$^


.PHONY: taiwan-lite-contour-mix-2023
taiwan-lite-contour-mix-2023: ele_taiwan_20_100_500_mix-2023.pbf
ele_taiwan_20_100_500_mix-2023.pbf: \
  precompiled/taiwan-sealand.pbf \
  moi-2022/taiwan16_60m-pygm_20_100_500.pbf \
  moi-2019/penghu-pygm_20_100_500.pbf \
  moi-2019/kinmen-pygm_20_100_500.pbf \
  aw3d30-3.1/matsu-pygm_20_100_500.pbf \
  aw3d30-3.1/n3islets-pygm_20_100_500.pbf \
  aw3d30-3.1/wuqiu-pygm_20_100_500.pbf \
  moi-2022/taiwan16-marker-pygms.pbf
	# combines all dependences
	./tools/combine.sh \
		$@ \
		7000000000 \
		4000000000 \
		$^


moi-2025/taiwan_20m.tif: moi-2025/.unzip
moi-2025/penghu_20m.tif: moi-2025/.unzip
moi-2025/kinmen_20m.tif: moi-2025/.unzip
moi-2025/.unzip: moi-2025/2025dtm20m.7z.001
	cd moi-2025/ && \
		7za x 2025dtm20m.7z.001
	touch $@

moi-2024/taiwan_20m.tif: moi-2024/.unzip
moi-2024/.unzip: moi-2024/2024dtm20m.7z.001
	cd moi-2024/ && \
		7za x 2024dtm20m.7z.001
	touch $@


moi-2022/taiwan_20m.tif: moi-2022/.unzip
moi-2022/.unzip: moi-2022/2022dtm20m.7z.001
	cd moi-2022/ && \
		7za x 2022dtm20m.7z.001
	touch $@


.PHONY: taiwan-contour-2022
taiwan-contour-2022: ele_taiwan_10_100_500-2022.pbf
ele_taiwan_10_100_500-2022.pbf: \
  moi-2020/taiwan16_20m-gdal_10_100_500.pbf \
  moi-2019/penghu-gdal_10_100_500.pbf \
  moi-2019/kinmen-gdal_10_100_500.pbf \
  aw3d30-3.1/matsu-gdal_10_100_500.pbf \
  aw3d30-3.1/n3islets-gdal_10_100_500.pbf \
  aw3d30-3.1/wuqiu-gdal_10_100_500.pbf
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
  moi-2020/taiwan16_20m-gdal_10_50_100_500.pbf \
  moi-2019/penghu-gdal_10_50_100_500.pbf \
  moi-2019/kinmen-gdal_10_50_100_500.pbf \
  aw3d30-3.1/matsu-gdal_10_50_100_500.pbf \
  aw3d30-3.1/n3islets-gdal_10_50_100_500.pbf \
  aw3d30-3.1/wuqiu-gdal_10_50_100_500.pbf \
  moi-2020/taiwan16-marker-gdal.pbf
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
  moi-2020/taiwan16_40m-gdal_20_100_500.pbf \
  moi-2019/penghu-gdal_20_100_500.pbf \
  moi-2019/kinmen-gdal_20_100_500.pbf \
  aw3d30-3.1/matsu-gdal_20_100_500.pbf \
  aw3d30-2.1/n3islets-gdal_20_100_500.pbf \
  aw3d30-2.1/wuqiu-gdal_20_100_500.pbf \
  moi-2020/taiwan16-marker-gdal.pbf
	# combines all dependences
	./tools/combine.sh \
		$@ \
		7000000000 \
		4000000000 \
		$^


.PHONY: taiwan-contour-2021
taiwan-contour-2021: ele_taiwan_10_100_500-2021.pbf
ele_taiwan_10_100_500-2021.pbf: \
  moi-2020/taiwan-pygm_10_100_500.pbf \
  moi-2019/penghu-pygm_10_100_500.pbf \
  moi-2019/kinmen-pygm_10_100_500.pbf \
  aw3d30-3.1/islands_nokinmen-pygm_10_100_500.pbf
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
  moi-2020/taiwan-pygm_10_50_100_500.pbf \
  moi-2019/penghu-pygm_10_50_100_500.pbf \
  moi-2019/kinmen-pygm_10_50_100_500.pbf \
  aw3d30-3.1/islands_nokinmen-pygm_10_50_100_500.pbf \
  moi-2020/marker-pygm.pbf
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
  moi-2020/taiwan-pygm_20_100_500.pbf \
  moi-2019/penghu-pygm_20_100_500.pbf \
  moi-2019/kinmen-pygm_20_100_500.pbf \
  aw3d30-3.1/islands_nokinmen-pygm_20_100_500.pbf \
  moi-2020/marker-pygm.pbf
	# combines all dependences
	./tools/combine.sh \
		$@ \
		7000000000 \
		4000000000 \
		$^


.PHONY: taiwan-contour-2020
taiwan-contour-2020: ele_taiwan_10_100_500-2020.pbf
ele_taiwan_10_100_500-2020.pbf: \
  moi-2020/taiwan-pygm_10_100_500.pbf \
  moi-2019/penghu-pygm_10_100_500.pbf \
  moi-2019/kinmen-pygm_10_100_500.pbf \
  aw3d30-2.1/islands_nokinmen-pygm_10_100_500.pbf
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
  moi-2020/taiwan-pygm_10_50_100_500.pbf \
  moi-2019/penghu-pygm_10_50_100_500.pbf \
  moi-2019/kinmen-pygm_10_50_100_500.pbf \
  aw3d30-2.1/islands_nokinmen-pygm_10_50_100_500.pbf \
  moi-2020/marker-pygm.pbf
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
  moi-2020/taiwan-pygm_20_100_500.pbf \
  moi-2019/penghu-pygm_20_100_500.pbf \
  moi-2019/kinmen-pygm_20_100_500.pbf \
  aw3d30-2.1/islands_nokinmen-pygm_20_100_500.pbf \
  moi-2020/marker-pygm.pbf
	# combines all dependences
	./tools/combine.sh \
		$@ \
		7000000000 \
		4000000000 \
		$^


.PHONY: taiwan-contour-2019
taiwan-contour-2019: ele_taiwan_10_100_500-2019.pbf
ele_taiwan_10_100_500-2019.pbf: \
  moi-2019/taiwan-pygm_10_100_500.pbf \
  moi-2019/penghu-pygm_10_100_500.pbf \
  moi-2019/kinmen-pygm_10_100_500.pbf \
  aw3d30-2.1/islands_nokinmen-pygm_10_100_500.pbf
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
  moi-2019/taiwan-pygm_10_50_100_500.pbf \
  moi-2019/penghu-pygm_10_50_100_500.pbf \
  moi-2019/kinmen-pygm_10_50_100_500.pbf \
  aw3d30-2.1/islands_nokinmen-pygm_10_50_100_500.pbf \
  moi-2019/marker-pygm.pbf
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
  moi-2019/taiwan-pygm_20_100_500.pbf \
  moi-2019/penghu-pygm_20_100_500.pbf \
  moi-2019/kinmen-pygm_20_100_500.pbf \
  aw3d30-2.1/islands_nokinmen-pygm_20_100_500.pbf \
  moi-2019/marker-pygm.pbf
	# combines all dependences
	./tools/combine.sh \
		$@ \
		7000000000 \
		4000000000 \
		$^


.PHONY: taiwan-contour-2018
taiwan-contour-2018: ele_taiwan_10_100_500-2018.pbf
ele_taiwan_10_100_500-2018.pbf: \
  moi-2018/taiwan-pygm_10_100_500.pbf \
  moi-2016/penghu-pygm_10_100_500.pbf \
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
  moi-2018/taiwan-pygm_10_50_100_500.pbf \
  moi-2016/penghu-pygm_10_50_100_500.pbf \
  aw3d30-2.1/islands-pygm_10_50_100_500.pbf \
  moi-2018/marker-pygm.pbf
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
  moi-2018/taiwan-pygm_20_100_500.pbf \
  moi-2016/penghu-pygm_20_100_500.pbf \
  aw3d30-2.1/islands-pygm_20_100_500.pbf \
  moi-2018/marker-pygm.pbf
	# combines all dependences
	./tools/combine.sh \
		$@ \
		7000000000 \
		4000000000 \
		$^


.PHONY: taiwan-contour-2016
taiwan-contour-2016: ele_taiwan_10_100_500-2016.pbf
ele_taiwan_10_100_500-2016.pbf: \
  moi-2016/taiwan-pygm_10_100_500.pbf \
  moi-2016/penghu-pygm_10_100_500.pbf \
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
  moi-2016/taiwan-pygm_10_50_100_500.pbf \
  moi-2016/penghu-pygm_10_50_100_500.pbf \
  aw3d30-2.1/islands-pygm_10_50_100_500.pbf \
  moi-2016/marker-pygm.pbf
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
  moi-2016/taiwan-pygm_20_100_500.pbf \
  moi-2016/penghu-pygm_20_100_500.pbf \
  aw3d30-2.1/islands-pygm_20_100_500.pbf \
  moi-2016/marker-pygm.pbf
	# combines all dependences
	./tools/combine.sh \
		$@ \
		7000000000 \
		4000000000 \
		$^


## 
## Inputs 
##

moi-2020/taiwan_20m.tif: moi-2020/.unzip
moi-2020/.unzip: moi-2020/2020dtm20m.7z.001
	cd moi-2020/ && \
		7za x 2020dtm20m.7z.001 && \
		mv 2020dtm20m.tif taiwan_20m.tif
	touch $@


moi-2019/taiwan_20m.tif: moi-2019/.unzip
moi-2019/penghu.tif: moi-2019/.unzip
moi-2019/kinmen.tif: moi-2019/.unzip
moi-2019/.unzip: moi-2019/DEMg_20m.7z.001
	cd moi-2019/ && \
		7za x DEMg_20m.7z.001 && \
		mv DEMg_geoid2014_20m_20190515.tif taiwan_20m.tif && \
		mv DEMg_20m_PH_20190521.tif penghu.tif && \
		mv DEMg_20m_KM_20190521.tif kinmen.tif
	touch $@


moi-2018/taiwan_20m.tif: moi-2018/.unzip
moi-2018/.unzip:
	cd moi-2018/ && \
		7za x DEM_20m.7z.001 && \
		mv DEM_20m.tif taiwan_20m.tif
	touch $@


moi-2016/taiwan_20m.tif: moi-2016/.unzip
moi-2016/penghu.tif: moi-2016/.unzip
moi-2016/.unzip: moi-2016/dem_20m.7z.001
	cd moi-2016/ && \
		7za x dem_20m.7z.001 && \
		mv dem_20m.tif taiwan_20m.tif && \
		mv phDEM_20m_119.tif penghu.tif
	touch $@


aw3d30-%/.unzip:
	cd aw3d30-$* && \
	7za x aw3d30-$*.7z
	touch $@


##
## zero tif ==gdal_contour==> contour shp
## 

%-ogr.pbf: %-ogr.osm
	osmium renumber -s 0,0,0 $^ -Oo $@


%-ogr.osm: %.shp
	time ogr2osm \
		--no-memory-copy \
		--force \
		$^ \
		-o $@


%-ogr_10_100_500.pbf: %-c10-ogr.pbf
	python3 tools/gdal2phyghtmap.py \
		-t 'contour_ext' \
		-m 100 \
		-M 500 \
		$^ \
		$@


%-ogr_20_100_500.pbf: %-c20-ogr.pbf
	python3 tools/gdal2phyghtmap.py \
		-t 'contour_ext' \
		-m 100 \
		-M 500 \
		$^ \
		$@


%-ogr_100_500_1000.pbf: %-c100-ogr.pbf
	python3 tools/gdal2phyghtmap.py \
		-t 'contour_ext' \
		-m 500 \
		-M 1000 \
		$^ \
		$@


%-ogr_40t_100_500_1000.pbf: %-c100-ogr.pbf
	python3 tools/gdal2phyghtmap.py \
		-t 'contour_40m' \
		-m 500 \
		-M 1000 \
		$^ \
		$@


%-ogr_80t_100_500_1000.pbf: %-c100-ogr.pbf
	python3 tools/gdal2phyghtmap.py \
		-t 'contour_80m' \
		-m 500 \
		-M 1000 \
		$^ \
		$@


%-ogr_160t_100_500_1000.pbf: %-c100-ogr.pbf
	python3 tools/gdal2phyghtmap.py \
		-t 'contour_160m' \
		-m 500 \
		-M 1000 \
		$^ \
		$@


%-ogr_320t_100_500_1000.pbf: %-c100-ogr.pbf
	python3 tools/gdal2phyghtmap.py \
		-t 'contour_320m' \
		-m 500 \
		-M 1000 \
		$^ \
		$@


%-ogr_640t_100_500_1000.pbf: %-c100-ogr.pbf
	python3 tools/gdal2phyghtmap.py \
		-t 'contour_640m' \
		-m 500 \
		-M 1000 \
		$^ \
		$@


%-ogr_1280t_100_500_1000.pbf: %-c100-ogr.pbf
	python3 tools/gdal2phyghtmap.py \
		-t 'contour_1280m' \
		-m 500 \
		-M 1000 \
		$^ \
		$@


%-gdal_10_100_500.pbf: %-c10.shp
	python3 tools/contour-osm.py \
		-t 'contour_ext' \
		-m 100 \
		-M 500 \
		--datasource $^ \
		$@


%-gdal_20_100_500.pbf: %-c20.shp
	python3 tools/contour-osm.py \
		-t 'contour_ext' \
		-m 100 \
		-M 500 \
		--datasource $^ \
		$@


%-gdal_100_500_1000.pbf: %-c100.shp
	python3 tools/contour-osm.py \
		-t 'contour_ext' \
		-m 500 \
		-M 1000 \
		--datasource $^ \
		$@


%-c10.shp: %-zero.tif
	gdal_contour \
		-i 10 \
		-a height \
		$^ \
		$@


%-c20.shp: %-zero.tif
	gdal_contour \
		-i 20 \
		-a height \
		$^ \
		$@


%-c100.shp: %-zero.tif
	gdal_contour \
		-i 100 \
		-a height \
		$^ \
		$@


%-gdal_40t_100_500_1000.pbf: %-c100.shp
	python3 tools/contour-osm.py \
		-t 'contour_40m' \
		-m 500 \
		-M 1000 \
		--datasource $^ \
		$@


%-gdal_80t_100_500_1000.pbf: %-c100.shp
	python3 tools/contour-osm.py \
		-t 'contour_80m' \
		-m 500 \
		-M 1000 \
		--datasource $^ \
		$@


%-gdal_160t_100_500_1000.pbf: %-c100.shp
	python3 tools/contour-osm.py \
		-t 'contour_160m' \
		-m 500 \
		-M 1000 \
		--datasource $^ \
		$@


%-gdal_320t_100_500_1000.pbf: %-c100.shp
	python3 tools/contour-osm.py \
		-t 'contour_320m' \
		-m 500 \
		-M 1000 \
		--datasource $^ \
		$@


%-gdal_640t_100_500_1000.pbf: %-c100.shp
	python3 tools/contour-osm.py \
		-t 'contour_640m' \
		-m 500 \
		-M 1000 \
		--datasource $^ \
		$@


%-gdal_1280t_100_500_1000.pbf: %-c100.shp
	python3 tools/contour-osm.py \
		-t 'contour_1280m' \
		-m 500 \
		-M 1000 \
		--datasource $^ \
		$@


##
## zero tif ==phyghtmap==> contour pbf
## 

%/taiwan16_15m-pygm_10_100_500.pbf: %/taiwan16_15m-zero.tif
	phyghtmap \
		--step=10 \
		--output-prefix=$(basename $(notdir $@)) \
		--line-cat=500,100 \
		--simplifyContoursEpsilon=0.00001 \
		$(PHYGHT_OPTIONS) \
		--pbf \
		$^
	mv $(basename $(notdir $@))* $@


%/taiwan16_20m-pygm_10_100_500.pbf: %/taiwan16_20m-zero.tif
	phyghtmap \
		--step=10 \
		--output-prefix=$(basename $(notdir $@)) \
		--line-cat=500,100 \
		--simplifyContoursEpsilon=0.00001 \
		$(PHYGHT_OPTIONS) \
		--pbf \
		$^
	mv $(basename $(notdir $@))* $@


%/taiwan16_40m-pygm_20_100_500.pbf: %/taiwan16_40m-zero.tif
	phyghtmap \
		--step=20 \
		--output-prefix=$(basename $(notdir $@)) \
		--line-cat=500,100 \
		--simplifyContoursEpsilon=0.00005 \
		$(PHYGHT_OPTIONS) \
		--pbf \
		$^
	mv $(basename $(notdir $@))* $@


moi-2016/taiwan-pygm_10_100_500.pbf: moi-2016/taiwan_20m-zero.tif
	phyghtmap \
		--step=10 \
		--output-prefix=$(basename $(notdir $@)) \
		--line-cat=500,100 \
		--simplifyContoursEpsilon=0.00001 \
		$(PHYGHT_OPTIONS) \
		--pbf \
		$^
	mv $(basename $(notdir $@))* $@


moi-2016/taiwan-pygm_20_100_500.pbf: moi-2016/taiwan_20m-zero.tif
	phyghtmap \
		--step=20 \
		--output-prefix=$(basename $(notdir $@)) \
		--line-cat=500,100 \
		--simplifyContoursEpsilon=0.00005 \
		$(PHYGHT_OPTIONS) \
		--pbf \
		$^
	mv $(basename $(notdir $@))* $@


%/penghu-pygm_10_100_500.pbf: %/penghu-zero.tif
	phyghtmap \
		--step=10 \
		--output-prefix=$(basename $(notdir $@)) \
		--line-cat=500,100 \
		--simplifyContoursEpsilon=0.00001 \
		$(PHYGHT_OPTIONS) \
		--pbf \
		$^
	mv $(basename $(notdir $@))* $@


%/penghu-pygm_20_100_500.pbf: %/penghu-zero.tif
	phyghtmap \
		--step=20 \
		--output-prefix=$(basename $(notdir $@)) \
		--line-cat=500,100 \
		--simplifyContoursEpsilon=0.00005 \
		$(PHYGHT_OPTIONS) \
		--pbf \
		$^
	mv $(basename $(notdir $@))* $@


moi-2019/kinmen-pygm_10_100_500.pbf: moi-2019/kinmen-zero.tif
	phyghtmap \
		--step=10 \
		--output-prefix=$(basename $(notdir $@)) \
		--line-cat=500,100 \
		--simplifyContoursEpsilon=0.00001 \
		$(PHYGHT_OPTIONS) \
		--pbf \
		$^
	mv $(basename $(notdir $@))* $@


moi-2019/kinmen-pygm_20_100_500.pbf: moi-2019/kinmen-zero.tif
	phyghtmap \
		--step=20 \
		--output-prefix=$(basename $(notdir $@)) \
		--line-cat=500,100 \
		--simplifyContoursEpsilon=0.00005 \
		$(PHYGHT_OPTIONS) \
		--pbf \
		$^
	mv $(basename $(notdir $@))* $@


%-pygm_10_100_500.pbf: %-zero.tif
	phyghtmap \
		--step=10 \
		--output-prefix=$(basename $(notdir $@)) \
		--line-cat=500,100 \
		--simplifyContoursEpsilon=0.000025 \
		$(PHYGHT_OPTIONS) \
		--pbf \
		$^
	mv $(basename $(notdir $@))* $@


%-pygm_20_100_500.pbf: %-zero.tif
	phyghtmap \
		--step=20 \
		--output-prefix=$(basename $(notdir $@)) \
		--line-cat=500,100 \
		--simplifyContoursEpsilon=0.000125 \
		$(PHYGHT_OPTIONS) \
		--pbf \
		$^
	mv $(basename $(notdir $@))* $@


%_40m-pygm_40t_100_500_1000.pbf: %_40m-zero.tif
	phyghtmap \
		--step=100 \
		--output-prefix=$(basename $(notdir $@)) \
		--line-cat=1000,500 \
		--simplifyContoursEpsilon=0.00005 \
		$(PHYGHT_OPTIONS) \
		$^
	mv $(basename $(notdir $@))* $(@:.pbf=.osm)
	$(SED_CMD) -e 's/contour_ext/contour_40m/g' -i $(@:.pbf=.osm)
	osmconvert \
		--out-pbf \
		$(@:.pbf=.osm) \
		-o=$@


%_80m-pygm_80t_100_500_1000.pbf: %_80m-zero.tif
	phyghtmap \
		--step=100 \
		--output-prefix=$(basename $(notdir $@)) \
		--line-cat=1000,500 \
		--simplifyContoursEpsilon=0.00005 \
		$(PHYGHT_OPTIONS) \
		$^
	mv $(basename $(notdir $@))* $(@:.pbf=.osm)
	$(SED_CMD) -e 's/contour_ext/contour_80m/g' -i $(@:.pbf=.osm)
	osmconvert \
		--out-pbf \
		$(@:.pbf=.osm) \
		-o=$@


%_160m-pygm_160t_100_500_1000.pbf: %_160m-zero.tif
	phyghtmap \
		--step=100 \
		--output-prefix=$(basename $(notdir $@)) \
		--line-cat=1000,500 \
		--simplifyContoursEpsilon=0.00005 \
		$(PHYGHT_OPTIONS) \
		$^
	mv $(basename $(notdir $@))* $(@:.pbf=.osm)
	$(SED_CMD) -e 's/contour_ext/contour_160m/g' -i $(@:.pbf=.osm)
	osmconvert \
		--out-pbf \
		$(@:.pbf=.osm) \
		-o=$@


%_320m-pygm_320t_100_500_1000.pbf: %_320m-zero.tif
	phyghtmap \
		--step=100 \
		--output-prefix=$(basename $(notdir $@)) \
		--line-cat=1000,500 \
		--simplifyContoursEpsilon=0.00005 \
		$(PHYGHT_OPTIONS) \
		$^
	mv $(basename $(notdir $@))* $(@:.pbf=.osm)
	$(SED_CMD) -e 's/contour_ext/contour_320m/g' -i $(@:.pbf=.osm)
	osmconvert \
		--out-pbf \
		$(@:.pbf=.osm) \
		-o=$@


%_640m-pygm_640t_100_500_1000.pbf: %_640m-zero.tif
	phyghtmap \
		--step=100 \
		--output-prefix=$(basename $(notdir $@)) \
		--line-cat=1000,500 \
		--simplifyContoursEpsilon=0.00005 \
		$(PHYGHT_OPTIONS) \
		$^
	mv $(basename $(notdir $@))* $(@:.pbf=.osm)
	$(SED_CMD) -e 's/contour_ext/contour_640m/g' -i $(@:.pbf=.osm)
	osmconvert \
		--out-pbf \
		$(@:.pbf=.osm) \
		-o=$@

%_1280m-pygm_1280t_100_500_1000.pbf: %_1280m-zero.tif
	phyghtmap \
		--step=100 \
		--output-prefix=$(basename $(notdir $@)) \
		--line-cat=1000,500 \
		--simplifyContoursEpsilon=0.00005 \
		$(PHYGHT_OPTIONS) \
		$^
	mv $(basename $(notdir $@))* $(@:.pbf=.osm)
	$(SED_CMD) -e 's/contour_ext/contour_1280m/g' -i $(@:.pbf=.osm)
	osmconvert \
		--out-pbf \
		$(@:.pbf=.osm) \
		-o=$@

%/three-wgs84.tif: moi-2020/taiwan_20m-wgs84.tif
	rm -f $@
	gdalwarp \
		$(OUTPUTS) \
		-dstnodata $(NODATA_VALUE) \
		-crop_to_cutline \
		-cutline $(dir $@)/three_islands.shp \
		$^ \
		$@


%/fours-wgs84.tif: moi-2020/taiwan_20m-wgs84.tif
	rm -f $@
	gdalwarp \
		$(OUTPUTS) \
		-dstnodata $(NODATA_VALUE) \
		-crop_to_cutline \
		-cutline $(dir $@)/four_islands.shp \
		$^ \
		$@


%/from2016-wgs84.tif: moi-2016/taiwan_20m-wgs84.tif
	rm -f $@
	gdalwarp \
		$(OUTPUTS) \
		-dstnodata $(NODATA_VALUE) \
		-crop_to_cutline \
		-cutline $(dir $@)/void_area.shp \
		$^ \
		$@


%_10_50_100_500.pbf: %_10_100_500.pbf
	rm -f $@
	python3 tools/elevation_sub.py $< $@


%-marker-ogrs.pbf: \
	%_40m-ogr_40t_100_500_1000.pbf \
	%_80m-ogr_80t_100_500_1000.pbf \
	%_160m-ogr_160t_100_500_1000.pbf \
	%_320m-ogr_320t_100_500_1000.pbf \
	%_640m-ogr_640t_100_500_1000.pbf \
	%_1280m-ogr_1280t_100_500_1000.pbf 
	# combines all dependences
	./tools/combine.sh \
		$@ \
		1 \
		1 \
		$^


%-marker-gdals.pbf: \
	%_40m-gdal_40t_100_500_1000.pbf \
	%_80m-gdal_80t_100_500_1000.pbf \
	%_160m-gdal_160t_100_500_1000.pbf \
	%_320m-gdal_320t_100_500_1000.pbf \
	%_640m-gdal_640t_100_500_1000.pbf \
	%_1280m-gdal_1280t_100_500_1000.pbf 
	# combines all dependences
	./tools/combine.sh \
		$@ \
		1 \
		1 \
		$^


%-marker-pygms.pbf: \
	%_40m-pygm_40t_100_500_1000.pbf \
	%_80m-pygm_80t_100_500_1000.pbf \
	%_160m-pygm_160t_100_500_1000.pbf \
	%_320m-pygm_320t_100_500_1000.pbf \
	%_640m-pygm_640t_100_500_1000.pbf \
	%_1280m-pygm_1280t_100_500_1000.pbf 
	# combines all dependences
	./tools/combine.sh \
		$@ \
		1 \
		1 \
		$^


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


%_40m-zero.tif: %_20m-zero.tif
	rm -f $@
	gdalwarp \
		 $(OUTPUTS) \
		-dstnodata $(NODATA_VALUE) \
		-ts 5413 0 \
		-r bilinear \
		-wt $(WORKING_TYPE) \
		$^ \
		$@


%_60m-zero.tif: %_20m-zero.tif
	rm -f $@
	gdalwarp \
		 $(OUTPUTS) \
		-dstnodata $(NODATA_VALUE) \
		-ts 3609 0 \
		-r bilinear \
		-wt $(WORKING_TYPE) \
		$^ \
		$@


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


%-zero.tif: %-nodata0.tif
	rm -f $@
	gdal_translate \
		$(OUTPUTS) \
		-a_nodata none \
		$^ \
		$@


# moi-2022/taiwan16_20m-nodata0.tif: moi-2022/taiwan16_20m-nodata.tif
# 	rm -f $@
# 	gdal_calc.py \
# 		--NoDataValue=0 \
# 		--calc="0" \
# 		-A $^ \
# 		--outfile=$@

%-nodata0.tif: %-nodata.tif
	rm -f $@
	gdal_calc.py \
		--NoDataValue=0 \
		--calc="(A > 0) * A" \
		-A $^ \
		--outfile=$@


moi-2024/taiwan16_20m-nodata.tif: moi-2024/taiwan_20m-wgs84.tif moi-2024/from2016-wgs84.tif moi-2024/three-wgs84.tif
moi-2022/taiwan16_20m-nodata.tif: moi-2022/taiwan_20m-wgs84.tif moi-2022/from2016-wgs84.tif moi-2022/fours-wgs84.tif
%/taiwan16_20m-nodata.tif: %/taiwan_20m-wgs84.tif %/from2016-wgs84.tif
	rm -f $@
	gdal_merge.py \
		$(OUTPUTS) \
		-n $(NODATA_VALUE) -a_nodata $(NODATA_VALUE) \
		$^ \
		-o $@


%-nodata.tif: %-wgs84.tif
	rm -f $@
	gdal_merge.py \
		$(OUTPUTS) \
		-n $(NODATA_VALUE) -a_nodata $(NODATA_VALUE) \
		$^ \
		-o $@


%-wgs84.tif: %.tif
	rm -f $@
	gdalwarp \
		$(OUTPUTS) \
		$(GDALWARP_WGS84_OPTIONS) \
		$^ \
		$@


aw3d30-%/n3islets-nodata0.tif: aw3d30-%/.unzip
	rm -f $@
	gdalwarp \
		$(OUTPUTS) \
		-crop_to_cutline \
		-cutline aw3d30-$*/n3islets.shp \
		-dstnodata 0 \
		aw3d30-$*/ALPSMLC30_N025E122_DSM.tif \
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


aw3d30-%/matsu-nodata0.tif: aw3d30-%/.unzip
	rm -f $@
	gdalwarp \
		$(OUTPUTS) \
		-crop_to_cutline \
		-cutline aw3d30-$*/matsu.shp \
		-dstnodata 0 \
		aw3d30-$*/ALPSMLC30_N026E119_DSM.tif \
		aw3d30-$*/ALPSMLC30_N026E120_DSM.tif \
		aw3d30-$*/ALPSMLC30_N025E119_DSM.tif \
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


aw3d30-%/wuqiu-nodata0.tif: aw3d30-%/.unzip
	rm -f $@
	gdalwarp \
		$(OUTPUTS) \
		-crop_to_cutline \
		-cutline aw3d30-$*/wuqiu.shp \
		-dstnodata 0 \
		aw3d30-$*/ALPSMLC30_N024E119_DSM.tif \
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


aw3d30-2.1/kinmen-nodata0.tif: aw3d30-2.1/.unzip
	rm -f $@
	gdalwarp \
		$(OUTPUTS) \
		-crop_to_cutline \
		-cutline aw3d30-2.1/kinmen.shp \
		-dstnodata 0 \
		aw3d30-2.1/N024E118_AVE_DSM.tif \
		$@


moi-2016/taiwan_40m-zero.tif: moi-2016/taiwan_20m-zero.tif
	rm -f $@
	gdalwarp \
		 $(OUTPUTS) \
		-dstnodata $(NODATA_VALUE) \
		-ts 5490 0 \
		-r bilinear \
		-wt $(WORKING_TYPE) \
		$^ \
		$@

moi-2016/taiwan_80m-zero.tif: moi-2016/taiwan_20m-zero.tif
	rm -f $@
	gdalwarp \
		 $(OUTPUTS) \
		-dstnodata $(NODATA_VALUE) \
		-ts 2745 0 \
		-r bilinear \
		-wt $(WORKING_TYPE) \
		$^ \
		$@

moi-2016/taiwan_160m-zero.tif: moi-2016/taiwan_20m-zero.tif
	rm -f $@
	gdalwarp \
		 $(OUTPUTS) \
		-dstnodata $(NODATA_VALUE) \
		-ts 1372 0 \
		-r bilinear \
		-wt $(WORKING_TYPE) \
		$^ \
		$@

moi-2016/taiwan_320m-zero.tif: moi-2016/taiwan_20m-zero.tif
	rm -f $@
	gdalwarp \
		 $(OUTPUTS) \
		-dstnodata $(NODATA_VALUE) \
		-ts 686 0 \
		-r bilinear \
		-wt $(WORKING_TYPE) \
		$^ \
		$@

moi-2016/taiwan_640m-zero.tif: moi-2016/taiwan_20m-zero.tif
	rm -f $@
	gdalwarp \
		 $(OUTPUTS) \
		-dstnodata $(NODATA_VALUE) \
		-ts 343 0 \
		-r bilinear \
		-wt $(WORKING_TYPE) \
		$^ \
		$@


moi-2016/taiwan_1280m-zero.tif: moi-2016/taiwan_20m-zero.tif
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
  aw3d30-2.1/kinmen-pygm_10_100_500.pbf \
  aw3d30-2.1/matsu-pygm_10_100_500.pbf \
  aw3d30-2.1/n3islets-pygm_10_100_500.pbf \
  aw3d30-2.1/wuqiu-pygm_10_100_500.pbf
	# combines all dependences
	./tools/combine.sh \
		$@ \
		1 \
		1 \
		$^


aw3d30-2.1/islands-pygm_20_100_500.pbf: \
  aw3d30-2.1/kinmen-pygm_20_100_500.pbf \
  aw3d30-2.1/matsu-pygm_20_100_500.pbf \
  aw3d30-2.1/n3islets-pygm_20_100_500.pbf \
  aw3d30-2.1/wuqiu-pygm_20_100_500.pbf
	# combines all dependences
	./tools/combine.sh \
		$@ \
		1 \
		1 \
		$^


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


moi-2016/marker-pygm.pbf: \
  moi-2016/taiwan-pygm_40m.pbf \
  moi-2016/taiwan-pygm_80m.pbf \
  moi-2016/taiwan-pygm_160m.pbf \
  moi-2016/taiwan-pygm_320m.pbf \
  moi-2016/taiwan-pygm_640m.pbf \
  moi-2016/taiwan-pygm_1280m.pbf
	# combines all dependences
	./tools/combine.sh \
		$@ \
		1 \
		1 \
		$^


moi-2018/marker-pygm.pbf: \
  moi-2018/taiwan-pygm_40m.pbf \
  moi-2018/taiwan-pygm_80m.pbf \
  moi-2018/taiwan-pygm_160m.pbf \
  moi-2018/taiwan-pygm_320m.pbf \
  moi-2018/taiwan-pygm_640m.pbf \
  moi-2018/taiwan-pygm_1280m.pbf
	# combines all dependences
	./tools/combine.sh \
		$@ \
		1 \
		1 \
		$^


moi-2019/marker-pygm.pbf: \
  moi-2019/taiwan-pygm_40m.pbf \
  moi-2019/taiwan-pygm_80m.pbf \
  moi-2019/taiwan-pygm_160m.pbf \
  moi-2019/taiwan-pygm_320m.pbf \
  moi-2019/taiwan-pygm_640m.pbf \
  moi-2019/taiwan-pygm_1280m.pbf
	# combines all dependences
	./tools/combine.sh \
		$@ \
		1 \
		1 \
		$^

