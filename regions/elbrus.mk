# =============================================================================
# Elbrus Region - Mount Elbrus, Caucasus, Russia
# =============================================================================
#
# Geographic Coverage:
#   Latitude:  43.09°N - 43.76°N
#   Longitude: 41.89°E - 43.81°E
#
# Data Source: ALOS AW3D30 v4.1
# Tiles: N043E042
#
# Outputs:
#   - ele_elbrus_10_100_500.pbf       : Standard contour (10m interval)
#   - ele_elbrus_10_100_500_mix.pbf   : Contour with markers
#   - aw3d30-4.1/elbrus_hgtmix.zip    : HGT 30m for Garmin devices
#   - aw3d30-4.1/elbrus_hgt90.zip     : HGT 90m for Garmin devices
# =============================================================================

# Bare tile IDs (NxxxEyyy); filename lists are derived in regions/common.mk
ELBRUS_TILE_IDS := \
    N043E041 N043E042 N043E043

# Bounding box for sea/land generation
ELBRUS_BBOX_LEFT   := 41.89
ELBRUS_BBOX_RIGHT  := 43.81
ELBRUS_BBOX_BOTTOM := 43.09
ELBRUS_BBOX_TOP    := 43.76

# Generate all rules (inland: no coastline in bbox)
$(eval $(call define-region,elbrus,ELBRUS,Elbrus,inland))
