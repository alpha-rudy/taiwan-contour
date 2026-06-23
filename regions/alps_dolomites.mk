# =============================================================================
# Alps Dolomites Region - Dolomites (Italy, Austria)
# =============================================================================
#
# Geographic Coverage:
#   Latitude:  45.5°N - 47.1°N
#   Longitude: 9.5°E - 13.5°E
#
# Data Source: ALOS AW3D30 v4.1
# Tiles: N045-N047 x E009-E013
#
# Outputs:
#   - ele_alps_dolomites_10_100_500.pbf       : Standard contour (10m interval)
#   - ele_alps_dolomites_10_100_500_mix.pbf   : Contour with markers
#   - aw3d30-4.1/alps_dolomites_hgtmix.zip    : HGT 30m for Garmin devices
#   - aw3d30-4.1/alps_dolomites_hgt90.zip     : HGT 90m for Garmin devices
# =============================================================================

# Region identifier
ALPS_DOLOMITES_REGION := alps_dolomites
ALPS_DOLOMITES_DISPLAY_NAME := Alps Dolomites

# HGT tile definitions (for SRTM output)
ALPS_DOLOMITES_TILES := \
    N045E009_AVE_DSM.tif \
    N045E010_AVE_DSM.tif \
    N045E011_AVE_DSM.tif \
    N045E012_AVE_DSM.tif \
    N045E013_AVE_DSM.tif \
    N046E009_AVE_DSM.tif \
    N046E010_AVE_DSM.tif \
    N046E011_AVE_DSM.tif \
    N046E012_AVE_DSM.tif \
    N046E013_AVE_DSM.tif \
    N047E009_AVE_DSM.tif \
    N047E010_AVE_DSM.tif \
    N047E011_AVE_DSM.tif \
    N047E012_AVE_DSM.tif \
    N047E013_AVE_DSM.tif

# ALOS source tiles
ALPS_DOLOMITES_ALPSMLC_TILES := \
    ALPSMLC30_N045E009_DSM.tif \
    ALPSMLC30_N045E010_DSM.tif \
    ALPSMLC30_N045E011_DSM.tif \
    ALPSMLC30_N045E012_DSM.tif \
    ALPSMLC30_N045E013_DSM.tif \
    ALPSMLC30_N046E009_DSM.tif \
    ALPSMLC30_N046E010_DSM.tif \
    ALPSMLC30_N046E011_DSM.tif \
    ALPSMLC30_N046E012_DSM.tif \
    ALPSMLC30_N046E013_DSM.tif \
    ALPSMLC30_N047E009_DSM.tif \
    ALPSMLC30_N047E010_DSM.tif \
    ALPSMLC30_N047E011_DSM.tif \
    ALPSMLC30_N047E012_DSM.tif \
    ALPSMLC30_N047E013_DSM.tif

# Bounding box for sea/land generation
ALPS_DOLOMITES_BBOX_LEFT   := 9.5
ALPS_DOLOMITES_BBOX_RIGHT  := 13.5
ALPS_DOLOMITES_BBOX_BOTTOM := 45.5
ALPS_DOLOMITES_BBOX_TOP    := 47.1

# Generate all rules using separate macros
$(eval $(call define-foreign-region-all,$(ALPS_DOLOMITES_REGION)))
$(eval $(call define-foreign-region-hgt,$(ALPS_DOLOMITES_REGION),$(ALPS_DOLOMITES_DISPLAY_NAME),$(ALPS_DOLOMITES_TILES)))
$(eval $(call define-foreign-region-nodata,$(ALPS_DOLOMITES_REGION),$(ALPS_DOLOMITES_ALPSMLC_TILES)))
$(eval $(call define-inland-region-sealand,$(ALPS_DOLOMITES_REGION),$(ALPS_DOLOMITES_BBOX_LEFT),$(ALPS_DOLOMITES_BBOX_RIGHT),$(ALPS_DOLOMITES_BBOX_BOTTOM),$(ALPS_DOLOMITES_BBOX_TOP)))
$(eval $(call define-inland-region-outputs,$(ALPS_DOLOMITES_REGION),$(ALPS_DOLOMITES_BBOX_LEFT),$(ALPS_DOLOMITES_BBOX_RIGHT),$(ALPS_DOLOMITES_BBOX_BOTTOM),$(ALPS_DOLOMITES_BBOX_TOP)))
