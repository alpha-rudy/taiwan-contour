# =============================================================================
# Alps Western Region - Western & Maritime Alps (France, Italy, Switzerland)
# =============================================================================
#
# Geographic Coverage (output crop):
#   Latitude:  44.0°N - 46.2°N
#   Longitude: 6.0°E  - 8.0°E   (4.4 sq°)
#
# Hot zones: Maritime/Mercantour, Queyras/Monviso, Écrins, Vanoise,
#            Gran Paradiso, Mont Blanc, Pennine (Matterhorn/Monte Rosa/Mischabel)
#
# Data Source: ALOS AW3D30 v4.1
# Tiles: N044-N046 x E006-E007 (6 tiles cover the crop)
#
# Outputs:
#   - ele_alps_western_10_100_500.pbf       : Standard contour (10m interval)
#   - ele_alps_western_10_100_500_mix.pbf   : Contour with markers
#   - aw3d30-4.1/alps_western_hgtmix.zip    : HGT 30m for Garmin devices
#   - aw3d30-4.1/alps_western_hgt90.zip     : HGT 90m for Garmin devices
# =============================================================================

# Region identifier
ALPS_WESTERN_REGION := alps_western
ALPS_WESTERN_DISPLAY_NAME := Alps Western

# HGT tile definitions (for SRTM output)
ALPS_WESTERN_TILES := \
    N044E006_AVE_DSM.tif \
    N044E007_AVE_DSM.tif \
    N045E006_AVE_DSM.tif \
    N045E007_AVE_DSM.tif \
    N046E006_AVE_DSM.tif \
    N046E007_AVE_DSM.tif

# ALOS source tiles
ALPS_WESTERN_ALPSMLC_TILES := \
    ALPSMLC30_N044E006_DSM.tif \
    ALPSMLC30_N044E007_DSM.tif \
    ALPSMLC30_N045E006_DSM.tif \
    ALPSMLC30_N045E007_DSM.tif \
    ALPSMLC30_N046E006_DSM.tif \
    ALPSMLC30_N046E007_DSM.tif

# Bounding box for sea/land generation and output crop
ALPS_WESTERN_BBOX_LEFT   := 6.0
ALPS_WESTERN_BBOX_RIGHT  := 8.0
ALPS_WESTERN_BBOX_BOTTOM := 44.0
ALPS_WESTERN_BBOX_TOP    := 46.2

# Generate all rules using separate macros
$(eval $(call define-foreign-region-all,$(ALPS_WESTERN_REGION)))
$(eval $(call define-foreign-region-hgt,$(ALPS_WESTERN_REGION),$(ALPS_WESTERN_DISPLAY_NAME),$(ALPS_WESTERN_TILES)))
$(eval $(call define-foreign-region-nodata,$(ALPS_WESTERN_REGION),$(ALPS_WESTERN_ALPSMLC_TILES)))
$(eval $(call define-inland-region-sealand,$(ALPS_WESTERN_REGION),$(ALPS_WESTERN_BBOX_LEFT),$(ALPS_WESTERN_BBOX_RIGHT),$(ALPS_WESTERN_BBOX_BOTTOM),$(ALPS_WESTERN_BBOX_TOP)))
$(eval $(call define-inland-region-outputs,$(ALPS_WESTERN_REGION),$(ALPS_WESTERN_BBOX_LEFT),$(ALPS_WESTERN_BBOX_RIGHT),$(ALPS_WESTERN_BBOX_BOTTOM),$(ALPS_WESTERN_BBOX_TOP)))
