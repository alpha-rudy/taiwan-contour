# =============================================================================
# Kashmir Region - Kashmir Valley Area, India/Pakistan
# =============================================================================
#
# Geographic Coverage:
#   Latitude:  34.0°N - 34.75°N
#   Longitude: 74.5°E - 75.5°E
#
# Data Source: ALOS AW3D30 v4.1
# Tiles: N034E074, N034E075
#
# Outputs:
#   - ele_kashmir_10_100_500.pbf       : Standard contour (10m interval)
#   - ele_kashmir_10_100_500_mix.pbf   : Contour with markers
#   - aw3d30-4.1/kashmir_hgtmix.zip    : HGT 30m for Garmin devices
#   - aw3d30-4.1/kashmir_hgt90.zip     : HGT 90m for Garmin devices
# =============================================================================

# Bare tile IDs (NxxxEyyy); filename lists are derived in regions/common.mk
KASHMIR_TILE_IDS := \
    N034E074 N034E075

# Bounding box for sea/land generation
KASHMIR_BBOX_LEFT   := 74.5
KASHMIR_BBOX_RIGHT  := 75.5
KASHMIR_BBOX_BOTTOM := 34.0
KASHMIR_BBOX_TOP    := 34.75

# Generate all rules (inland: no coastline in bbox)
$(eval $(call define-region,kashmir,KASHMIR,Kashmir,inland))
