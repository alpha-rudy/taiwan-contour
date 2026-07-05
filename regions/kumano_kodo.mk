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

# Bare tile IDs (NxxxEyyy); filename lists are derived in regions/common.mk
KUMANO_KODO_TILE_IDS := \
    N033E135 N033E136 \
    N034E135 N034E136

# Bounding box for sea/land generation
KUMANO_KODO_BBOX_LEFT   := 135.0
KUMANO_KODO_BBOX_RIGHT  := 137.0
KUMANO_KODO_BBOX_BOTTOM := 33.0
KUMANO_KODO_BBOX_TOP    := 35.0

# Generate all rules (coastal: real coastline in bbox)
$(eval $(call define-region,kumano_kodo,KUMANO_KODO,Kumano Kodo,coastal))
