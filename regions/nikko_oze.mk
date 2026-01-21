# =============================================================================
# Nikko-Oze Region - Nikko National Park & Oze Area, Japan
# =============================================================================
#
# Geographic Coverage:
#   Latitude:  36.50°N - 37.47°N
#   Longitude: 138.68°E - 139.86°E
#
# Data Source: ALOS AW3D30 v4.1
# Tiles: N036E138, N036E139, N036E140, N037E138, N037E139, N037E140
#
# Outputs:
#   - ele_nikko_oze_10_100_500.pbf       : Standard contour (10m interval)
#   - ele_nikko_oze_10_100_500_mix.pbf   : Contour with markers
#   - aw3d30-4.1/nikko_oze_hgtmix.zip    : HGT 30m for Garmin devices
#   - aw3d30-4.1/nikko_oze_hgt90.zip     : HGT 90m for Garmin devices
# =============================================================================

# Region identifier
NIKKO_OZE_REGION := nikko_oze
NIKKO_OZE_DISPLAY_NAME := Nikko-Oze

# HGT tile definitions (for SRTM output)
NIKKO_OZE_TILES := \
    N036E138_AVE_DSM.tif \
    N036E139_AVE_DSM.tif \
    N036E140_AVE_DSM.tif \
    N037E138_AVE_DSM.tif \
    N037E139_AVE_DSM.tif \
    N037E140_AVE_DSM.tif

# ALOS source tiles
NIKKO_OZE_ALPSMLC_TILES := \
    ALPSMLC30_N036E138_DSM.tif \
    ALPSMLC30_N036E139_DSM.tif \
    ALPSMLC30_N036E140_DSM.tif \
    ALPSMLC30_N037E138_DSM.tif \
    ALPSMLC30_N037E139_DSM.tif \
    ALPSMLC30_N037E140_DSM.tif

# Bounding box for sea/land generation
NIKKO_OZE_BBOX_LEFT   := 138.68
NIKKO_OZE_BBOX_RIGHT  := 139.86
NIKKO_OZE_BBOX_BOTTOM := 36.50
NIKKO_OZE_BBOX_TOP    := 37.47

# Generate all rules using separate macros
$(eval $(call define-foreign-region-all,$(NIKKO_OZE_REGION)))
$(eval $(call define-foreign-region-hgt,$(NIKKO_OZE_REGION),$(NIKKO_OZE_DISPLAY_NAME),$(NIKKO_OZE_TILES)))
$(eval $(call define-foreign-region-nodata,$(NIKKO_OZE_REGION),$(NIKKO_OZE_ALPSMLC_TILES)))
$(eval $(call define-foreign-region-sealand,$(NIKKO_OZE_REGION),$(NIKKO_OZE_BBOX_LEFT),$(NIKKO_OZE_BBOX_RIGHT),$(NIKKO_OZE_BBOX_BOTTOM),$(NIKKO_OZE_BBOX_TOP)))
$(eval $(call define-foreign-region-outputs,$(NIKKO_OZE_REGION)))
