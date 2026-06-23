# =============================================================================
# Alps Eastern Region - Eastern Alps & Dolomites (Italy, Austria, Slovenia)
# =============================================================================
#
# Geographic Coverage (output crop):
#   Latitude:  45.8°N  - 47.55°N
#   Longitude: 10.5°E  - 14.0°E    (6.1 sq°)
#
# Hot zones: Adamello/Presanella, Brenta, Arco/Garda climbing, Cevedale,
#            Ötztal/Stubai, Dolomites, Zillertal, Hohe Tauern (Grossglockner/
#            Grossvenediger), Dachstein, Julian Alps (Triglav)
#
# Data Source: ALOS AW3D30 v4.1
# Tiles: N045-N047 x E010-E013 (12 tiles cover the crop; overlap at E010/E013)
#
# Outputs:
#   - ele_alps_eastern_10_100_500.pbf       : Standard contour (10m interval)
#   - ele_alps_eastern_10_100_500_mix.pbf   : Contour with markers
#   - aw3d30-4.1/alps_eastern_hgtmix.zip    : HGT 30m for Garmin devices
#   - aw3d30-4.1/alps_eastern_hgt90.zip     : HGT 90m for Garmin devices
# =============================================================================

# Region identifier
ALPS_EASTERN_REGION := alps_eastern
ALPS_EASTERN_DISPLAY_NAME := Alps Eastern

# HGT tile definitions (for SRTM output)
ALPS_EASTERN_TILES := \
    N045E010_AVE_DSM.tif \
    N045E011_AVE_DSM.tif \
    N045E012_AVE_DSM.tif \
    N045E013_AVE_DSM.tif \
    N046E010_AVE_DSM.tif \
    N046E011_AVE_DSM.tif \
    N046E012_AVE_DSM.tif \
    N046E013_AVE_DSM.tif \
    N047E010_AVE_DSM.tif \
    N047E011_AVE_DSM.tif \
    N047E012_AVE_DSM.tif \
    N047E013_AVE_DSM.tif

# ALOS source tiles
ALPS_EASTERN_ALPSMLC_TILES := \
    ALPSMLC30_N045E010_DSM.tif \
    ALPSMLC30_N045E011_DSM.tif \
    ALPSMLC30_N045E012_DSM.tif \
    ALPSMLC30_N045E013_DSM.tif \
    ALPSMLC30_N046E010_DSM.tif \
    ALPSMLC30_N046E011_DSM.tif \
    ALPSMLC30_N046E012_DSM.tif \
    ALPSMLC30_N046E013_DSM.tif \
    ALPSMLC30_N047E010_DSM.tif \
    ALPSMLC30_N047E011_DSM.tif \
    ALPSMLC30_N047E012_DSM.tif \
    ALPSMLC30_N047E013_DSM.tif

# Bounding box for sea/land generation and output crop
ALPS_EASTERN_BBOX_LEFT   := 10.5
ALPS_EASTERN_BBOX_RIGHT  := 14.0
ALPS_EASTERN_BBOX_BOTTOM := 45.8
ALPS_EASTERN_BBOX_TOP    := 47.55

# Generate all rules using separate macros
$(eval $(call define-foreign-region-all,$(ALPS_EASTERN_REGION)))
$(eval $(call define-foreign-region-hgt,$(ALPS_EASTERN_REGION),$(ALPS_EASTERN_DISPLAY_NAME),$(ALPS_EASTERN_TILES)))
$(eval $(call define-foreign-region-nodata,$(ALPS_EASTERN_REGION),$(ALPS_EASTERN_ALPSMLC_TILES)))
$(eval $(call define-inland-region-sealand,$(ALPS_EASTERN_REGION),$(ALPS_EASTERN_BBOX_LEFT),$(ALPS_EASTERN_BBOX_RIGHT),$(ALPS_EASTERN_BBOX_BOTTOM),$(ALPS_EASTERN_BBOX_TOP)))
$(eval $(call define-inland-region-outputs,$(ALPS_EASTERN_REGION),$(ALPS_EASTERN_BBOX_LEFT),$(ALPS_EASTERN_BBOX_RIGHT),$(ALPS_EASTERN_BBOX_BOTTOM),$(ALPS_EASTERN_BBOX_TOP)))
