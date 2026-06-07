# Common macros for foreign region contour generation
#
# This file contains shared macros and pattern rules for all foreign regions.
# Include this file in each region-specific .mk file.
#
# Usage in region file:
#   include regions/common.mk


##############################################################################
# Macro: make-hgt-rule
# Generate HGT files for a region from ALOS AW3D30 data
#
# Parameters:
#   $(1) - region_name: The identifier for the region (e.g., fujisan, nikko_oze)
#   $(2) - display_name: Human-readable name for VERSION file (e.g., "Fujisan", "Nikko-Oze")
#   $(3) - tiles: List of HGT tiles in format NxxxEyyy_AVE_DSM.tif
#
# Creates:
#   aw3d30-4.1/$(region_name)_hgtmix.zip - 30m resolution HGT files
#   aw3d30-4.1/$(region_name)_hgt90.zip  - 90m resolution HGT files
#
# Example:
#   FUJISAN_TILES = N034E138_AVE_DSM.tif N034E139_AVE_DSM.tif
#   aw3d30-4.1/.fujisan-hgt: aw3d30-4.1/fujisan-zero.tif
#       $(call make-hgt-rule,fujisan,Fujisan,$(FUJISAN_TILES))
##############################################################################
define make-hgt-rule
    rm -rf aw3d30-4.1/$(1)/input aw3d30-4.1/$(1)/output
    mkdir -p aw3d30-4.1/$(1)/input aw3d30-4.1/$(1)/output
    cd aw3d30-4.1/$(1)/input && $(foreach tile,$(3),ln -sf ../../$(1)-zero.tif $(tile) && ) true
    cd aw3d30-4.1/$(1) && \
        ../../tools/aw3d2srtm30.sh && \
        echo '# $(2) HGT 30m' > output/VERSION
    cd aw3d30-4.1/$(1)/output && \
        7z a -tzip ../../$(1)_hgtmix.zip *.hgt VERSION && \
        rm *
    cd aw3d30-4.1/$(1) && \
        ../../tools/aw3d2srtm90.sh && \
        echo '# $(2) HGT 90m' > output/VERSION
    cd aw3d30-4.1/$(1)/output && \
        7z a -tzip ../../$(1)_hgt90.zip *.hgt VERSION && \
        rm *
    rm -rf aw3d30-4.1/$(1)/input aw3d30-4.1/$(1)/output
    touch $@
endef


##############################################################################
# Macro: define-foreign-region-hgt
# Define HGT targets for a foreign region
#
# Parameters:
#   $(1) - region_name: The identifier for the region (e.g., fujisan)
#   $(2) - display_name: Human-readable name (e.g., "Fujisan")
#   $(3) - tiles: List of HGT tiles in format NxxxEyyy_AVE_DSM.tif
##############################################################################
define define-foreign-region-hgt
.PHONY: $(1)-hgts
$(1)-hgts: aw3d30-4.1/.$(1)-hgt

aw3d30-4.1/.$(1)-hgt: aw3d30-4.1/$(1)-zero.tif
	$$(call make-hgt-rule,$(1),$(2),$(3))
endef


##############################################################################
# Macro: define-foreign-region-nodata
# Define nodata0.tif merge rule for a foreign region
#
# Parameters:
#   $(1) - region_name: The identifier for the region
#   $(2) - alpsmlc_tiles: List of ALOS source tiles
##############################################################################
define define-foreign-region-nodata
aw3d30-4.1/$(1)-nodata0.tif: $(foreach tile,$(2),aw3d30-4.1/$(tile))
	rm -f $$@
	gdalwarp \
		$$(OUTPUTS) \
		-dstnodata 0 \
		$$^ \
		$$@
endef


##############################################################################
# Macro: define-foreign-region-sealand
# Define sea/land boundary generation for a foreign region
#
# Parameters:
#   $(1) - region_name: The identifier for the region
#   $(2) - left_lon: Left boundary longitude
#   $(3) - right_lon: Right boundary longitude
#   $(4) - bottom_lat: Bottom boundary latitude
#   $(5) - top_lat: Top boundary latitude
##############################################################################
define define-foreign-region-sealand
land-polygons/$(1)-sealand.pbf: land-polygons/.unzip
	./tools/sealand-creator.sh -l $(2) -r $(3) -b $(4) -t $(5) -n $(1)
endef


##############################################################################
# Macro: define-coastal-region-outputs
# Define final PBF output targets for a COASTAL foreign region
# (has actual sea within bounding box, e.g. Japan coast, Mediterranean)
# - Standard pbf: no sealand (mkgmap adds its own sea/bound)
# - Mix pbf:      with sealand (mapsforge needs it for ocean rendering)
#
# Parameters:
#   $(1) - region_name: The identifier for the region
#   $(2) - left_lon, $(3) - right_lon, $(4) - bottom_lat, $(5) - top_lat
##############################################################################
define define-coastal-region-outputs
.PHONY: $(1)-contour $(1)-contour-mix

$(1)-contour: ele_$(1)_10_100_500.pbf
$(1)-contour-mix: ele_$(1)_10_100_500_mix.pbf

ele_$(1)_10_100_500.pbf: \
  aw3d30-4.1/$(1)-pygm_10_100_500.pbf
	rm -f tmp-$$@
	./tools/combine.sh \
		tmp-$$@ \
		1 \
		1 \
		$$^
	osmconvert tmp-$$@ -b=$(2),$(4),$(3),$(5) --complete-ways --complete-multipolygons --complete-boundaries --drop-broken-refs -o=$$@
	rm tmp-$$@

ele_$(1)_10_100_500_mix.pbf: \
  land-polygons/$(1)-sealand.pbf \
  aw3d30-4.1/$(1)-pygm_10_50_100_500.pbf \
  aw3d30-4.1/$(1)-marker-pygms.pbf
	rm -f tmp-$$@
	./tools/combine.sh \
		tmp-$$@ \
		1 \
		1 \
		$$^
	osmconvert tmp-$$@ -b=$(2),$(4),$(3),$(5) --complete-ways --complete-multipolygons --complete-boundaries --drop-broken-refs -o=$$@
	rm tmp-$$@
endef


##############################################################################
# Macro: define-inland-region-outputs
# Define final PBF output targets for an INLAND foreign region
# (no sea within bounding box, e.g. Elbrus, Annapurna, Alps core)
# - Standard pbf: no sealand (mkgmap adds its own sea/bound)
# - Mix pbf:      no sealand (rectangular nosea tiles break mapsforge rendering)
#
# Parameters:
#   $(1) - region_name: The identifier for the region
#   $(2) - left_lon, $(3) - right_lon, $(4) - bottom_lat, $(5) - top_lat
##############################################################################
define define-inland-region-outputs
.PHONY: $(1)-contour $(1)-contour-mix

$(1)-contour: ele_$(1)_10_100_500.pbf
$(1)-contour-mix: ele_$(1)_10_100_500_mix.pbf

ele_$(1)_10_100_500.pbf: \
  aw3d30-4.1/$(1)-pygm_10_100_500.pbf
	rm -f tmp-$$@
	./tools/combine.sh \
		tmp-$$@ \
		1 \
		1 \
		$$^
	osmconvert tmp-$$@ -b=$(2),$(4),$(3),$(5) --complete-ways --complete-multipolygons --complete-boundaries --drop-broken-refs -o=$$@
	rm tmp-$$@

ele_$(1)_10_100_500_mix.pbf: \
  aw3d30-4.1/$(1)-pygm_10_50_100_500.pbf \
  aw3d30-4.1/$(1)-marker-pygms.pbf
	rm -f tmp-$$@
	./tools/combine.sh \
		tmp-$$@ \
		1 \
		1 \
		$$^
	osmconvert tmp-$$@ -b=$(2),$(4),$(3),$(5) --complete-ways --complete-multipolygons --complete-boundaries --drop-broken-refs -o=$$@
	rm tmp-$$@
endef


##############################################################################
# Macro: define-foreign-region-all
# Define the main -all target for a foreign region
#
# Parameters:
#   $(1) - region_name: The identifier for the region
##############################################################################
define define-foreign-region-all
.PHONY: $(1)-all
$(1)-all: $(1)-hgts $(1)-contour $(1)-contour-mix
endef
