# =============================================================================
# Alps Core Region - Central Alps (Switzerland, Italy)
# =============================================================================
#
# Geographic Coverage (output crop):
#   Latitude:  45.8°N  - 47.3°N
#   Longitude: 7.15°E  - 10.75°E   (5.6 sq°)
#
# Hot zones: Bernese Oberland (Diablerets/Wildhorn west, Eiger/Jungfrau/
#            Finsteraarhorn/Aletsch), Tödi/Glarus, Säntis/Alpstein,
#            Bernina/Bregaglia, Engadin/Silvretta, Ortler/Stelvio,
#            Grigna, Orobie
#
# Data Source: ALOS AW3D30 v4.1
# Tiles: N045-N047 x E007-E010 (12 tiles cover the crop; overlap at E007/E010)
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
    N045E007_AVE_DSM.tif \
    N045E008_AVE_DSM.tif \
    N045E009_AVE_DSM.tif \
    N045E010_AVE_DSM.tif \
    N046E007_AVE_DSM.tif \
    N046E008_AVE_DSM.tif \
    N046E009_AVE_DSM.tif \
    N046E010_AVE_DSM.tif \
    N047E007_AVE_DSM.tif \
    N047E008_AVE_DSM.tif \
    N047E009_AVE_DSM.tif \
    N047E010_AVE_DSM.tif

# ALOS source tiles
ALPS_CORE_ALPSMLC_TILES := \
    ALPSMLC30_N045E007_DSM.tif \
    ALPSMLC30_N045E008_DSM.tif \
    ALPSMLC30_N045E009_DSM.tif \
    ALPSMLC30_N045E010_DSM.tif \
    ALPSMLC30_N046E007_DSM.tif \
    ALPSMLC30_N046E008_DSM.tif \
    ALPSMLC30_N046E009_DSM.tif \
    ALPSMLC30_N046E010_DSM.tif \
    ALPSMLC30_N047E007_DSM.tif \
    ALPSMLC30_N047E008_DSM.tif \
    ALPSMLC30_N047E009_DSM.tif \
    ALPSMLC30_N047E010_DSM.tif

# Bounding box for sea/land generation and output crop
ALPS_CORE_BBOX_LEFT   := 7.15
ALPS_CORE_BBOX_RIGHT  := 10.75
ALPS_CORE_BBOX_BOTTOM := 45.8
ALPS_CORE_BBOX_TOP    := 47.3

# Generate all rules using separate macros
$(eval $(call define-foreign-region-all,$(ALPS_CORE_REGION)))
$(eval $(call define-foreign-region-hgt,$(ALPS_CORE_REGION),$(ALPS_CORE_DISPLAY_NAME),$(ALPS_CORE_TILES)))
$(eval $(call define-foreign-region-nodata,$(ALPS_CORE_REGION),$(ALPS_CORE_ALPSMLC_TILES)))
$(eval $(call define-inland-region-sealand,$(ALPS_CORE_REGION),$(ALPS_CORE_BBOX_LEFT),$(ALPS_CORE_BBOX_RIGHT),$(ALPS_CORE_BBOX_BOTTOM),$(ALPS_CORE_BBOX_TOP)))
$(eval $(call define-inland-region-outputs,$(ALPS_CORE_REGION),$(ALPS_CORE_BBOX_LEFT),$(ALPS_CORE_BBOX_RIGHT),$(ALPS_CORE_BBOX_BOTTOM),$(ALPS_CORE_BBOX_TOP)))
