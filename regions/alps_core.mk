# =============================================================================
# Alps Core Region - Central Alps (Switzerland, France, Austria)
# =============================================================================
#
# Geographic Coverage:
#   Latitude:  45°N - 47°N
#   Longitude: 5.5°E - 8.5°E
#
# Data Source: ALOS AW3D30 v4.1
# Tiles: N045E005-E008, N046E005-E008
#
# Outputs:
#   - ele_alps_core_10_100_500.pbf       : Standard contour (10m interval)
#   - ele_alps_core_10_100_500_mix.pbf   : Contour with markers
#   - aw3d30-4.1/alps_core_hgtmix.zip    : HGT 30m for Garmin devices
#   - aw3d30-4.1/alps_core_hgt90.zip     : HGT 90m for Garmin devices
# =============================================================================

# Region identifier
ALPS_CORE_REGION := alps_core
ALPS_CORE_DISPLAY_NAME := Alps Core

# HGT tile definitions (for SRTM output)
ALPS_CORE_TILES := \
    N045E005_AVE_DSM.tif \
    N045E006_AVE_DSM.tif \
    N045E007_AVE_DSM.tif \
    N045E008_AVE_DSM.tif \
    N046E005_AVE_DSM.tif \
    N046E006_AVE_DSM.tif \
    N046E007_AVE_DSM.tif \
    N046E008_AVE_DSM.tif

# ALOS source tiles
ALPS_CORE_ALPSMLC_TILES := \
    ALPSMLC30_N045E005_DSM.tif \
    ALPSMLC30_N045E006_DSM.tif \
    ALPSMLC30_N045E007_DSM.tif \
    ALPSMLC30_N045E008_DSM.tif \
    ALPSMLC30_N046E005_DSM.tif \
    ALPSMLC30_N046E006_DSM.tif \
    ALPSMLC30_N046E007_DSM.tif \
    ALPSMLC30_N046E008_DSM.tif

# Bounding box for sea/land generation
ALPS_CORE_BBOX_LEFT   := 5.5
ALPS_CORE_BBOX_RIGHT  := 8.5
ALPS_CORE_BBOX_BOTTOM := 45.0
ALPS_CORE_BBOX_TOP    := 47.0

# Generate all rules using separate macros
$(eval $(call define-foreign-region-all,$(ALPS_CORE_REGION)))
$(eval $(call define-foreign-region-hgt,$(ALPS_CORE_REGION),$(ALPS_CORE_DISPLAY_NAME),$(ALPS_CORE_TILES)))
$(eval $(call define-foreign-region-nodata,$(ALPS_CORE_REGION),$(ALPS_CORE_ALPSMLC_TILES)))
$(eval $(call define-inland-region-sealand,$(ALPS_CORE_REGION),$(ALPS_CORE_BBOX_LEFT),$(ALPS_CORE_BBOX_RIGHT),$(ALPS_CORE_BBOX_BOTTOM),$(ALPS_CORE_BBOX_TOP)))
$(eval $(call define-inland-region-outputs,$(ALPS_CORE_REGION),$(ALPS_CORE_BBOX_LEFT),$(ALPS_CORE_BBOX_RIGHT),$(ALPS_CORE_BBOX_BOTTOM),$(ALPS_CORE_BBOX_TOP)))
