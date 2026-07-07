# =============================================================================
# Yakushima Region - Yakushima Island & Osumi Islands, Japan
# =============================================================================
#
# Geographic Coverage:
#   Latitude:  30.16°N - 30.93°N
#   Longitude: 129.83°E - 131.16°E
#
# Data Source: ALOS AW3D30 v4.1
# Tiles: N030E129, N030E130, N030E131
#
# Outputs:
#   - ele_yakushima_10_100_500.pbf       : Standard contour (10m interval)
#   - ele_yakushima_10_100_500_mix.pbf   : Contour with markers
#   - aw3d30-4.1/yakushima_hgtmix.zip    : HGT 30m for Garmin devices
#   - aw3d30-4.1/yakushima_hgt90.zip     : HGT 90m for Garmin devices
# =============================================================================

# Bare tile IDs (NxxxEyyy); filename lists are derived in regions/common.mk
YAKUSHIMA_TILE_IDS := \
    N030E129 N030E130 N030E131

# Bounding box for sea/land generation
YAKUSHIMA_BBOX_LEFT   := 129.83
YAKUSHIMA_BBOX_RIGHT  := 131.16
YAKUSHIMA_BBOX_BOTTOM := 30.16
YAKUSHIMA_BBOX_TOP    := 30.93

# Generate all rules (coastal: real coastline in bbox)
$(eval $(call define-region,yakushima,YAKUSHIMA,Yakushima,coastal))
