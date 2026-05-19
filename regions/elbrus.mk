# =============================================================================
# Elbrus Region - Mount Elbrus, Caucasus, Russia
# =============================================================================
#
# Geographic Coverage:
#   Latitude:  43.09°N - 43.76°N
#   Longitude: 41.89°E - 43.81°E
#
# Data Source: ALOS AW3D30 v4.1
# Tiles: N043E042
#
# Outputs:
#   - ele_elbrus_10_100_500.pbf       : Standard contour (10m interval)
#   - ele_elbrus_10_100_500_mix.pbf   : Contour with markers
#   - aw3d30-4.1/elbrus_hgtmix.zip    : HGT 30m for Garmin devices
#   - aw3d30-4.1/elbrus_hgt90.zip     : HGT 90m for Garmin devices
# =============================================================================

# Region identifier
ELBRUS_REGION := elbrus
ELBRUS_DISPLAY_NAME := Elbrus

# HGT tile definitions (for SRTM output)
ELBRUS_TILES := \
    N043E041_AVE_DSM.tif \
    N043E042_AVE_DSM.tif \
    N043E043_AVE_DSM.tif

# ALOS source tiles
ELBRUS_ALPSMLC_TILES := \
    ALPSMLC30_N043E041_DSM.tif \
    ALPSMLC30_N043E042_DSM.tif \
    ALPSMLC30_N043E043_DSM.tif

# Bounding box for sea/land generation
ELBRUS_BBOX_LEFT   := 41.89
ELBRUS_BBOX_RIGHT  := 43.81
ELBRUS_BBOX_BOTTOM := 43.09
ELBRUS_BBOX_TOP    := 43.76

# Generate all rules using separate macros
$(eval $(call define-foreign-region-all,$(ELBRUS_REGION)))
$(eval $(call define-foreign-region-hgt,$(ELBRUS_REGION),$(ELBRUS_DISPLAY_NAME),$(ELBRUS_TILES)))
$(eval $(call define-foreign-region-nodata,$(ELBRUS_REGION),$(ELBRUS_ALPSMLC_TILES)))
$(eval $(call define-foreign-region-sealand,$(ELBRUS_REGION),$(ELBRUS_BBOX_LEFT),$(ELBRUS_BBOX_RIGHT),$(ELBRUS_BBOX_BOTTOM),$(ELBRUS_BBOX_TOP)))
$(eval $(call define-foreign-region-outputs,$(ELBRUS_REGION),$(ELBRUS_BBOX_LEFT),$(ELBRUS_BBOX_RIGHT),$(ELBRUS_BBOX_BOTTOM),$(ELBRUS_BBOX_TOP)))
