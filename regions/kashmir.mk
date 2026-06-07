# =============================================================================
# Kashmir Region - Kashmir Valley Area, India/Pakistan
# =============================================================================
#
# Geographic Coverage:
#   Latitude:  34.0°N - 34.75°N
#   Longitude: 74.5°E - 75.5°E
#
# Data Source: ALOS AW3D30 v4.1
# Tiles: N034E074, N034E075
#
# Outputs:
#   - ele_kashmir_10_100_500.pbf       : Standard contour (10m interval)
#   - ele_kashmir_10_100_500_mix.pbf   : Contour with markers
#   - aw3d30-4.1/kashmir_hgtmix.zip    : HGT 30m for Garmin devices
#   - aw3d30-4.1/kashmir_hgt90.zip     : HGT 90m for Garmin devices
# =============================================================================

# Region identifier
KASHMIR_REGION := kashmir
KASHMIR_DISPLAY_NAME := Kashmir

# HGT tile definitions (for SRTM output)
KASHMIR_TILES := \
    N034E074_AVE_DSM.tif \
    N034E075_AVE_DSM.tif

# ALOS source tiles
KASHMIR_ALPSMLC_TILES := \
    ALPSMLC30_N034E074_DSM.tif \
    ALPSMLC30_N034E075_DSM.tif

# Bounding box for sea/land generation
KASHMIR_BBOX_LEFT   := 74.5
KASHMIR_BBOX_RIGHT  := 75.5
KASHMIR_BBOX_BOTTOM := 34.0
KASHMIR_BBOX_TOP    := 34.75

# Generate all rules using separate macros
$(eval $(call define-foreign-region-all,$(KASHMIR_REGION)))
$(eval $(call define-foreign-region-hgt,$(KASHMIR_REGION),$(KASHMIR_DISPLAY_NAME),$(KASHMIR_TILES)))
$(eval $(call define-foreign-region-nodata,$(KASHMIR_REGION),$(KASHMIR_ALPSMLC_TILES)))
$(eval $(call define-inland-region-outputs,$(KASHMIR_REGION),$(KASHMIR_BBOX_LEFT),$(KASHMIR_BBOX_RIGHT),$(KASHMIR_BBOX_BOTTOM),$(KASHMIR_BBOX_TOP)))
