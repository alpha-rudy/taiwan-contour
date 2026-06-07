# =============================================================================
# Kumano Kodo Region - Kumano Ancient Pilgrimage Routes, Japan
# =============================================================================
#
# Geographic Coverage:
#   Latitude:  33.0°N - 35.0°N
#   Longitude: 135.0°E - 137.0°E
#
# Data Source: ALOS AW3D30 v4.1
# Tiles: N033E135, N033E136, N034E135, N034E136
#
# Outputs:
#   - ele_kumano_kodo_10_100_500.pbf       : Standard contour (10m interval)
#   - ele_kumano_kodo_10_100_500_mix.pbf   : Contour with markers
#   - aw3d30-4.1/kumano_kodo_hgtmix.zip    : HGT 30m for Garmin devices
#   - aw3d30-4.1/kumano_kodo_hgt90.zip     : HGT 90m for Garmin devices
# =============================================================================

# Region identifier
KUMANO_KODO_REGION := kumano_kodo
KUMANO_KODO_DISPLAY_NAME := Kumano Kodo

# HGT tile definitions (for SRTM output)
KUMANO_KODO_TILES := \
    N033E135_AVE_DSM.tif \
    N033E136_AVE_DSM.tif \
    N034E135_AVE_DSM.tif \
    N034E136_AVE_DSM.tif

# ALOS source tiles
KUMANO_KODO_ALPSMLC_TILES := \
    ALPSMLC30_N033E135_DSM.tif \
    ALPSMLC30_N033E136_DSM.tif \
    ALPSMLC30_N034E135_DSM.tif \
    ALPSMLC30_N034E136_DSM.tif

# Bounding box for sea/land generation
KUMANO_KODO_BBOX_LEFT   := 135.0
KUMANO_KODO_BBOX_RIGHT  := 137.0
KUMANO_KODO_BBOX_BOTTOM := 33.0
KUMANO_KODO_BBOX_TOP    := 35.0

# Generate all rules using separate macros
$(eval $(call define-foreign-region-all,$(KUMANO_KODO_REGION)))
$(eval $(call define-foreign-region-hgt,$(KUMANO_KODO_REGION),$(KUMANO_KODO_DISPLAY_NAME),$(KUMANO_KODO_TILES)))
$(eval $(call define-foreign-region-nodata,$(KUMANO_KODO_REGION),$(KUMANO_KODO_ALPSMLC_TILES)))
$(eval $(call define-foreign-region-sealand,$(KUMANO_KODO_REGION),$(KUMANO_KODO_BBOX_LEFT),$(KUMANO_KODO_BBOX_RIGHT),$(KUMANO_KODO_BBOX_BOTTOM),$(KUMANO_KODO_BBOX_TOP)))
$(eval $(call define-coastal-region-outputs,$(KUMANO_KODO_REGION),$(KUMANO_KODO_BBOX_LEFT),$(KUMANO_KODO_BBOX_RIGHT),$(KUMANO_KODO_BBOX_BOTTOM),$(KUMANO_KODO_BBOX_TOP)))
