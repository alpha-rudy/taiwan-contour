# =============================================================================
# Annapurna Region - Annapurna Mountain Range, Nepal
# =============================================================================
#
# Geographic Coverage:
#   Latitude:  28.0°N - 29.0°N
#   Longitude: 83.0°E - 85.0°E
#
# Data Source: ALOS AW3D30 v4.1
# Tiles: N028E083, N028E084
#
# Outputs:
#   - ele_annapurna_10_100_500.pbf       : Standard contour (10m interval)
#   - ele_annapurna_10_100_500_mix.pbf   : Contour with markers
#   - aw3d30-4.1/annapurna_hgtmix.zip    : HGT 30m for Garmin devices
#   - aw3d30-4.1/annapurna_hgt90.zip     : HGT 90m for Garmin devices
# =============================================================================

# Region identifier
ANNAPURNA_REGION := annapurna
ANNAPURNA_DISPLAY_NAME := Annapurna

# HGT tile definitions (for SRTM output)
ANNAPURNA_TILES := \
    N028E083_AVE_DSM.tif \
    N028E084_AVE_DSM.tif

# ALOS source tiles
ANNAPURNA_ALPSMLC_TILES := \
    ALPSMLC30_N028E083_DSM.tif \
    ALPSMLC30_N028E084_DSM.tif

# Bounding box for sea/land generation
ANNAPURNA_BBOX_LEFT   := 83.0
ANNAPURNA_BBOX_RIGHT  := 85.0
ANNAPURNA_BBOX_BOTTOM := 28.0
ANNAPURNA_BBOX_TOP    := 29.0

# Generate all rules using separate macros
$(eval $(call define-foreign-region-all,$(ANNAPURNA_REGION)))
$(eval $(call define-foreign-region-hgt,$(ANNAPURNA_REGION),$(ANNAPURNA_DISPLAY_NAME),$(ANNAPURNA_TILES)))
$(eval $(call define-foreign-region-nodata,$(ANNAPURNA_REGION),$(ANNAPURNA_ALPSMLC_TILES)))
$(eval $(call define-inland-region-outputs,$(ANNAPURNA_REGION),$(ANNAPURNA_BBOX_LEFT),$(ANNAPURNA_BBOX_RIGHT),$(ANNAPURNA_BBOX_BOTTOM),$(ANNAPURNA_BBOX_TOP)))
