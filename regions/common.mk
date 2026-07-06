# Common macros for foreign region contour generation
#
# This file contains shared macros and pattern rules for all foreign regions.
# Include this file in each region-specific .mk file.
#
# Usage in region file:
#   include regions/common.mk

LAND_POLYGONS_DIR ?= downloads/land-polygons

# Directory holding ALOS AW3D30 source tiles and derived outputs.
# Used by all region macros below (the root Makefile keeps its own literal
# aw3d30-4.1 references for the Taiwan rules).
ALOS_DIR ?= aw3d30-4.1


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
#   $(ALOS_DIR)/$(region_name)_hgtmix.zip - 30m resolution HGT files
#   $(ALOS_DIR)/$(region_name)_hgt90.zip  - 90m resolution HGT files
#
# Example:
#   FUJISAN_TILES = N034E138_AVE_DSM.tif N034E139_AVE_DSM.tif
#   $(ALOS_DIR)/.fujisan-hgt: $(ALOS_DIR)/fujisan-zero.tif
#       $(call make-hgt-rule,fujisan,Fujisan,$(FUJISAN_TILES))
##############################################################################
define make-hgt-rule
    rm -rf $(ALOS_DIR)/$(1)/input $(ALOS_DIR)/$(1)/output
    mkdir -p $(ALOS_DIR)/$(1)/input $(ALOS_DIR)/$(1)/output
    cd $(ALOS_DIR)/$(1)/input && $(foreach tile,$(3),ln -sf ../../$(1)-zero.tif $(tile) && ) true
    cd $(ALOS_DIR)/$(1) && \
        ../../tools/aw3d2srtm30.sh && \
        echo '# $(2) HGT 30m' > output/VERSION
    cd $(ALOS_DIR)/$(1)/output && \
        7z a -tzip ../../$(1)_hgtmix.zip *.hgt VERSION && \
        rm *
    cd $(ALOS_DIR)/$(1) && \
        ../../tools/aw3d2srtm90.sh && \
        echo '# $(2) HGT 90m' > output/VERSION
    cd $(ALOS_DIR)/$(1)/output && \
        7z a -tzip ../../$(1)_hgt90.zip *.hgt VERSION && \
        rm *
    rm -rf $(ALOS_DIR)/$(1)/input $(ALOS_DIR)/$(1)/output
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
$(1)-hgts: $(ALOS_DIR)/.$(1)-hgt

$(ALOS_DIR)/.$(1)-hgt: $(ALOS_DIR)/$(1)-zero.tif
	$$(call make-hgt-rule,$(1),$(2),$(3))
endef


##############################################################################
# Macro: define-foreign-region-nodata
# Define nodata0.tif merge rule for a foreign region
#
# Parameters:
#   $(1) - region_name: The identifier for the region
#   $(2) - alpsmlc_tiles: List of ALOS source tiles
#
# NOTE on voids: ALOS AW3D30 tiles declare NoData=-9999 (true voids such as
# unresolved cloud/water gaps); 0 is used for sea. `-dstnodata 0` below maps
# any -9999 void pixel to 0, and the downstream `%-zero.tif` rule strips the
# nodata flag entirely (-a_nodata none), so a void would surface as a fake
# 0 m elevation and could produce dense spurious contour rings inland (the
# pyhgtmap --void-range-max=-50 mask can then never trigger). This is
# currently safe: all v4.1 tiles used by every existing region (checked
# 2026-07: elbrus, annapurna, kashmir, alps_core/eastern/western/fareast,
# nikko_oze, fujisan, kumano_kodo inland set) contain ZERO -9999 pixels —
# v4.1 ships void-filled. If a future region's tiles DO contain -9999
# pixels (check: gdal_calc counting A==-9999), give inland regions a
# separate merge that keeps `-dstnodata -9999` and skips the `-a_nodata
# none` step so voids reach pyhgtmap below --void-range-max; keep the
# coastal path (sea must read 0) unchanged.
##############################################################################
define define-foreign-region-nodata
$(ALOS_DIR)/$(1)-nodata0.tif: $(foreach tile,$(2),$(ALOS_DIR)/$(tile))
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
$(LAND_POLYGONS_DIR)/$(1)-sealand.pbf: $(LAND_POLYGONS_DIR)/.unzip
	./tools/sealand-creator.sh -l $(2) -r $(3) -b $(4) -t $(5) -n $(1)
endef


##############################################################################
# Macro: define-inland-region-sealand
# Define sea/land boundary generation for an INLAND foreign region using
# a fine grid of rectangular nosea tiles (no land polygon shapefile needed).
# The entire bounding box is covered with small tiles so mapsforge renders
# the area as land without the rendering artifacts caused by large rectangles.
#
# Parameters:
#   $(1) - region_name: The identifier for the region
#   $(2) - left_lon: Left boundary longitude
#   $(3) - right_lon: Right boundary longitude
#   $(4) - bottom_lat: Bottom boundary latitude
#   $(5) - top_lat: Top boundary latitude
##############################################################################
define define-inland-region-sealand
$(LAND_POLYGONS_DIR)/$(1)-sealand.pbf:
	mkdir -p $(LAND_POLYGONS_DIR)
	./tools/sealand-creator.sh -l $(2) -r $(3) -b $(4) -t $(5) -n $(1) -g 0.1
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
  $(ALOS_DIR)/$(1)-pygm_10_100_500.pbf
	rm -f tmp-$$@
	./tools/combine.sh \
		tmp-$$@ \
		1 \
		1 \
		$$^
	osmconvert tmp-$$@ -b=$(2),$(4),$(3),$(5) --complete-ways --complete-multipolygons --complete-boundaries --drop-broken-refs -o=$$@
	rm tmp-$$@

ele_$(1)_10_100_500_mix.pbf: \
  $(LAND_POLYGONS_DIR)/$(1)-sealand.pbf \
  $(ALOS_DIR)/$(1)-pygm_10_50_100_500.pbf \
  $(ALOS_DIR)/$(1)-marker-pygms.pbf
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
# - Mix pbf:      fine-grid sealand (0.1° nosea tiles cover entire bbox so
#                 mapsforge renders land correctly without rendering artifacts
#                 caused by large rectangular nosea polygons)
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
  $(ALOS_DIR)/$(1)-pygm_10_100_500.pbf
	rm -f tmp-$$@
	./tools/combine.sh \
		tmp-$$@ \
		1 \
		1 \
		$$^
	osmconvert tmp-$$@ -b=$(2),$(4),$(3),$(5) --complete-ways --complete-multipolygons --complete-boundaries --drop-broken-refs -o=$$@
	rm tmp-$$@

ele_$(1)_10_100_500_mix.pbf: \
  $(LAND_POLYGONS_DIR)/$(1)-sealand.pbf \
  $(ALOS_DIR)/$(1)-pygm_10_50_100_500.pbf \
  $(ALOS_DIR)/$(1)-marker-pygms.pbf
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


##############################################################################
# Macro: define-region
# One-line entry point that defines ALL rules for a region from a single bare
# tile-ID list plus a bounding box, following naming conventions. This removes
# the per-region duplication of the *_TILES / *_ALPSMLC_TILES lists and the
# five repeated $(eval $(call ...)) lines.
#
# Parameters:
#   $(1) - region_name:  lowercase identifier (e.g. fujisan, alps_fareast)
#   $(2) - PREFIX:        uppercase variable prefix (e.g. FUJISAN, ALPS_FAREAST)
#   $(3) - display_name:  human-readable name for VERSION files; may contain
#                         spaces, e.g. Alps Far-Eastern
#   $(4) - type:          coastal (real coastline in bbox -> clip land polygons)
#                         or inland (fine-grid nosea tiles, no download)
#
# Read by naming convention from $(2):
#   $(PREFIX)_TILE_IDS                       bare tile IDs, e.g. N034E137 ...
#   $(PREFIX)_BBOX_{LEFT,RIGHT,BOTTOM,TOP}   bounding box in decimal degrees
#
# Filename lists are derived here:
#   HGT tiles   : NxxxEyyy_AVE_DSM.tif        (addsuffix)
#   ALOS tiles  : ALPSMLC30_NxxxEyyy_DSM.tif  (addprefix + addsuffix)
#
# The individual define-*-region-* macros remain usable directly.
#
# Example:
#   FUJISAN_TILE_IDS := N034E137 N034E138 N034E139 N035E137 N035E138 N035E139
#   FUJISAN_BBOX_LEFT := 137.69   # ... RIGHT/BOTTOM/TOP ...
#   $(eval $(call define-region,fujisan,FUJISAN,Fujisan,coastal))
##############################################################################
define define-region
$(call define-foreign-region-all,$(1))
$(call define-foreign-region-hgt,$(1),$(3),$(addsuffix _AVE_DSM.tif,$($(2)_TILE_IDS)))
$(call define-foreign-region-nodata,$(1),$(addprefix ALPSMLC30_,$(addsuffix _DSM.tif,$($(2)_TILE_IDS))))
$(call define-$(if $(filter coastal,$(4)),foreign,inland)-region-sealand,$(1),$($(2)_BBOX_LEFT),$($(2)_BBOX_RIGHT),$($(2)_BBOX_BOTTOM),$($(2)_BBOX_TOP))
$(call define-$(4)-region-outputs,$(1),$($(2)_BBOX_LEFT),$($(2)_BBOX_RIGHT),$($(2)_BBOX_BOTTOM),$($(2)_BBOX_TOP))
endef
