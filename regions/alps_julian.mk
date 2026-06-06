# =============================================================================
# Alps Julian Region - Julian Alps (Slovenia, Italy)
# =============================================================================
#
# Geographic Coverage:
#   Latitude:  45.3°N - 46.9°N
#   Longitude: 13.3°E - 16.6°E
#
# Data Source: ALOS AW3D30 v4.1
# Tiles: N045-N046 x E013-E016
#
# Outputs:
#   - ele_alps_julian_10_100_500.pbf       : Standard contour (10m interval)
#   - ele_alps_julian_10_100_500_mix.pbf   : Contour with markers
#   - aw3d30-4.1/alps_julian_hgtmix.zip    : HGT 30m for Garmin devices
#   - aw3d30-4.1/alps_julian_hgt90.zip     : HGT 90m for Garmin devices
# =============================================================================

# Region identifier
ALPS_JULIAN_REGION := alps_julian
ALPS_JULIAN_DISPLAY_NAME := Alps Julian

# HGT tile definitions (for SRTM output)
ALPS_JULIAN_TILES := \
    N045E013_AVE_DSM.tif \
    N045E014_AVE_DSM.tif \
    N045E015_AVE_DSM.tif \
    N045E016_AVE_DSM.tif \
    N046E013_AVE_DSM.tif \
    N046E014_AVE_DSM.tif \
    N046E015_AVE_DSM.tif \
    N046E016_AVE_DSM.tif

# ALOS source tiles
ALPS_JULIAN_ALPSMLC_TILES := \
    ALPSMLC30_N045E013_DSM.tif \
    ALPSMLC30_N045E014_DSM.tif \
    ALPSMLC30_N045E015_DSM.tif \
    ALPSMLC30_N045E016_DSM.tif \
    ALPSMLC30_N046E013_DSM.tif \
    ALPSMLC30_N046E014_DSM.tif \
    ALPSMLC30_N046E015_DSM.tif \
    ALPSMLC30_N046E016_DSM.tif

# Bounding box for sea/land generation
ALPS_JULIAN_BBOX_LEFT   := 13.3
ALPS_JULIAN_BBOX_RIGHT  := 16.6
ALPS_JULIAN_BBOX_BOTTOM := 45.3
ALPS_JULIAN_BBOX_TOP    := 46.9

# Generate all rules using separate macros
$(eval $(call define-foreign-region-all,$(ALPS_JULIAN_REGION)))
$(eval $(call define-foreign-region-hgt,$(ALPS_JULIAN_REGION),$(ALPS_JULIAN_DISPLAY_NAME),$(ALPS_JULIAN_TILES)))
$(eval $(call define-foreign-region-nodata,$(ALPS_JULIAN_REGION),$(ALPS_JULIAN_ALPSMLC_TILES)))
$(eval $(call define-foreign-region-sealand,$(ALPS_JULIAN_REGION),$(ALPS_JULIAN_BBOX_LEFT),$(ALPS_JULIAN_BBOX_RIGHT),$(ALPS_JULIAN_BBOX_BOTTOM),$(ALPS_JULIAN_BBOX_TOP)))
$(eval $(call define-foreign-region-outputs,$(ALPS_JULIAN_REGION),$(ALPS_JULIAN_BBOX_LEFT),$(ALPS_JULIAN_BBOX_RIGHT),$(ALPS_JULIAN_BBOX_BOTTOM),$(ALPS_JULIAN_BBOX_TOP)))
