# =============================================================================
# Alps Far-Eastern Region - Far-Eastern Alps (Slovenia, Austria)
# =============================================================================
#
# Geographic Coverage (output crop):
#   Latitude:  46.3°N  - 47.85°N
#   Longitude: 13.9°E  - 15.9°E    (3.1 sq°)
#
# Hot zones: Karawanks, Kamnik–Savinja Alps, Totes Gebirge, Gesäuse,
#            Hochschwab, Schneeberg/Rax
#   (Julian Alps / Triglav at 13.8°E are covered by alps_eastern.)
#
# Data Source: ALOS AW3D30 v4.1
# Tiles: N046-N047 x E013-E015 (6 tiles cover the crop; overlap at E013)
#
# Outputs:
#   - ele_alps_fareast_10_100_500.pbf       : Standard contour (10m interval)
#   - ele_alps_fareast_10_100_500_mix.pbf   : Contour with markers
#   - aw3d30-4.1/alps_fareast_hgtmix.zip    : HGT 30m for Garmin devices
#   - aw3d30-4.1/alps_fareast_hgt90.zip     : HGT 90m for Garmin devices
# =============================================================================

# Region identifier
ALPS_FAREAST_REGION := alps_fareast
ALPS_FAREAST_DISPLAY_NAME := Alps Far-Eastern

# HGT tile definitions (for SRTM output)
ALPS_FAREAST_TILES := \
    N046E013_AVE_DSM.tif \
    N046E014_AVE_DSM.tif \
    N046E015_AVE_DSM.tif \
    N047E013_AVE_DSM.tif \
    N047E014_AVE_DSM.tif \
    N047E015_AVE_DSM.tif

# ALOS source tiles
ALPS_FAREAST_ALPSMLC_TILES := \
    ALPSMLC30_N046E013_DSM.tif \
    ALPSMLC30_N046E014_DSM.tif \
    ALPSMLC30_N046E015_DSM.tif \
    ALPSMLC30_N047E013_DSM.tif \
    ALPSMLC30_N047E014_DSM.tif \
    ALPSMLC30_N047E015_DSM.tif

# Bounding box for sea/land generation and output crop
ALPS_FAREAST_BBOX_LEFT   := 13.9
ALPS_FAREAST_BBOX_RIGHT  := 15.9
ALPS_FAREAST_BBOX_BOTTOM := 46.3
ALPS_FAREAST_BBOX_TOP    := 47.85

# Generate all rules using separate macros
$(eval $(call define-foreign-region-all,$(ALPS_FAREAST_REGION)))
$(eval $(call define-foreign-region-hgt,$(ALPS_FAREAST_REGION),$(ALPS_FAREAST_DISPLAY_NAME),$(ALPS_FAREAST_TILES)))
$(eval $(call define-foreign-region-nodata,$(ALPS_FAREAST_REGION),$(ALPS_FAREAST_ALPSMLC_TILES)))
$(eval $(call define-inland-region-sealand,$(ALPS_FAREAST_REGION),$(ALPS_FAREAST_BBOX_LEFT),$(ALPS_FAREAST_BBOX_RIGHT),$(ALPS_FAREAST_BBOX_BOTTOM),$(ALPS_FAREAST_BBOX_TOP)))
$(eval $(call define-inland-region-outputs,$(ALPS_FAREAST_REGION),$(ALPS_FAREAST_BBOX_LEFT),$(ALPS_FAREAST_BBOX_RIGHT),$(ALPS_FAREAST_BBOX_BOTTOM),$(ALPS_FAREAST_BBOX_TOP)))
