# =============================================================================
# Alps Pyrenees Region - Pyrenees Mountains (France, Spain, Andorra)
# =============================================================================
#
# Geographic Coverage:
#   Latitude:  42°N - 43.5°N
#   Longitude: 2°W - 3.5°E
#
# Data Source: ALOS AW3D30 v4.1
# Tiles: N042-N043 x W002, W001, E000-E003
#
# Outputs:
#   - ele_alps_pyrenees_10_100_500.pbf       : Standard contour (10m interval)
#   - ele_alps_pyrenees_10_100_500_mix.pbf   : Contour with markers
#   - aw3d30-4.1/alps_pyrenees_hgtmix.zip    : HGT 30m for Garmin devices
#   - aw3d30-4.1/alps_pyrenees_hgt90.zip     : HGT 90m for Garmin devices
# =============================================================================

# Region identifier
ALPS_PYRENEES_REGION := alps_pyrenees
ALPS_PYRENEES_DISPLAY_NAME := Alps Pyrenees

# HGT tile definitions (for SRTM output)
ALPS_PYRENEES_TILES := \
    N042W002_AVE_DSM.tif \
    N042W001_AVE_DSM.tif \
    N042E000_AVE_DSM.tif \
    N042E001_AVE_DSM.tif \
    N042E002_AVE_DSM.tif \
    N042E003_AVE_DSM.tif \
    N043W002_AVE_DSM.tif \
    N043W001_AVE_DSM.tif \
    N043E000_AVE_DSM.tif \
    N043E001_AVE_DSM.tif \
    N043E002_AVE_DSM.tif \
    N043E003_AVE_DSM.tif

# ALOS source tiles
ALPS_PYRENEES_ALPSMLC_TILES := \
    ALPSMLC30_N042W002_DSM.tif \
    ALPSMLC30_N042W001_DSM.tif \
    ALPSMLC30_N042E000_DSM.tif \
    ALPSMLC30_N042E001_DSM.tif \
    ALPSMLC30_N042E002_DSM.tif \
    ALPSMLC30_N042E003_DSM.tif \
    ALPSMLC30_N043W002_DSM.tif \
    ALPSMLC30_N043W001_DSM.tif \
    ALPSMLC30_N043E000_DSM.tif \
    ALPSMLC30_N043E001_DSM.tif \
    ALPSMLC30_N043E002_DSM.tif \
    ALPSMLC30_N043E003_DSM.tif

# Bounding box for sea/land generation (western longitudes are negative)
ALPS_PYRENEES_BBOX_LEFT   := -2.0
ALPS_PYRENEES_BBOX_RIGHT  := 3.5
ALPS_PYRENEES_BBOX_BOTTOM := 42.0
ALPS_PYRENEES_BBOX_TOP    := 43.5

# Generate all rules using separate macros
$(eval $(call define-foreign-region-all,$(ALPS_PYRENEES_REGION)))
$(eval $(call define-foreign-region-hgt,$(ALPS_PYRENEES_REGION),$(ALPS_PYRENEES_DISPLAY_NAME),$(ALPS_PYRENEES_TILES)))
$(eval $(call define-foreign-region-nodata,$(ALPS_PYRENEES_REGION),$(ALPS_PYRENEES_ALPSMLC_TILES)))
$(eval $(call define-foreign-region-sealand,$(ALPS_PYRENEES_REGION),$(ALPS_PYRENEES_BBOX_LEFT),$(ALPS_PYRENEES_BBOX_RIGHT),$(ALPS_PYRENEES_BBOX_BOTTOM),$(ALPS_PYRENEES_BBOX_TOP)))
$(eval $(call define-coastal-region-outputs,$(ALPS_PYRENEES_REGION),$(ALPS_PYRENEES_BBOX_LEFT),$(ALPS_PYRENEES_BBOX_RIGHT),$(ALPS_PYRENEES_BBOX_BOTTOM),$(ALPS_PYRENEES_BBOX_TOP)))
