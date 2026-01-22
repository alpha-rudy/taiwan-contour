# =============================================================================
# Fujisan Region - Mount Fuji Area, Japan
# =============================================================================
#
# Geographic Coverage:
#   Latitude:  34.30°N - 35.95°N
#   Longitude: 138.15°E - 139.55°E
#
# Data Source: ALOS AW3D30 v4.1
# Tiles: N034E138, N034E139, N035E138, N035E139
#
# Outputs:
#   - ele_fujisan_10_100_500.pbf       : Standard contour (10m interval)
#   - ele_fujisan_10_100_500_mix.pbf   : Contour with markers
#   - aw3d30-4.1/fujisan_hgtmix.zip    : HGT 30m for Garmin devices
#   - aw3d30-4.1/fujisan_hgt90.zip     : HGT 90m for Garmin devices
# =============================================================================

# Region identifier
FUJISAN_REGION := fujisan
FUJISAN_DISPLAY_NAME := Fujisan

# HGT tile definitions (for SRTM output)
FUJISAN_TILES := \
    N034E137_AVE_DSM.tif \
    N034E138_AVE_DSM.tif \
    N034E139_AVE_DSM.tif \
    N035E137_AVE_DSM.tif \
    N035E138_AVE_DSM.tif \
    N035E139_AVE_DSM.tif

# ALOS source tiles
FUJISAN_ALPSMLC_TILES := \
    ALPSMLC30_N034E137_DSM.tif \
    ALPSMLC30_N034E138_DSM.tif \
    ALPSMLC30_N034E139_DSM.tif \
    ALPSMLC30_N035E137_DSM.tif \
    ALPSMLC30_N035E138_DSM.tif \
    ALPSMLC30_N035E139_DSM.tif

# Bounding box for sea/land generation
FUJISAN_BBOX_LEFT   := 137.69
FUJISAN_BBOX_RIGHT  := 139.55
FUJISAN_BBOX_BOTTOM := 34.30
FUJISAN_BBOX_TOP    := 35.95

# Generate all rules using separate macros
$(eval $(call define-foreign-region-all,$(FUJISAN_REGION)))
$(eval $(call define-foreign-region-hgt,$(FUJISAN_REGION),$(FUJISAN_DISPLAY_NAME),$(FUJISAN_TILES)))
$(eval $(call define-foreign-region-nodata,$(FUJISAN_REGION),$(FUJISAN_ALPSMLC_TILES)))
$(eval $(call define-foreign-region-sealand,$(FUJISAN_REGION),$(FUJISAN_BBOX_LEFT),$(FUJISAN_BBOX_RIGHT),$(FUJISAN_BBOX_BOTTOM),$(FUJISAN_BBOX_TOP)))
$(eval $(call define-foreign-region-outputs,$(FUJISAN_REGION),$(FUJISAN_BBOX_LEFT),$(FUJISAN_BBOX_RIGHT),$(FUJISAN_BBOX_BOTTOM),$(FUJISAN_BBOX_TOP)))
