# =============================================================================
# Fujisan Region - Mount Fuji Area, Japan
# =============================================================================
#
# Geographic Coverage:
#   Latitude:  34.30°N - 35.95°N
#   Longitude: 138.35°E - 139.55°E
#
# Data Source: ALOS AW3D30 v4.1
# Tiles: N034E138, N034E139, N035E138, N035E139
#
# Outputs:
#   - ele_fujisan_10_100_500.pbf       : Standard contour (10m interval)
#   - ele_fujisan_10_100_500_mix.pbf   : Contour with markers
#   - aw3d30-4.1/fujisan_hgtmix.zip    : HGT 30m for Garmin devices
#   - aw3d30-4.1/fujisan_hgt90.zip     : HGT 90m for Garmin devices
# =============================================================================

# Bare tile IDs (NxxxEyyy); filename lists are derived in regions/common.mk
FUJISAN_TILE_IDS := \
    N034E138 N034E139 \
    N035E138 N035E139

# Bounding box for sea/land generation
FUJISAN_BBOX_LEFT   := 138.35
FUJISAN_BBOX_RIGHT  := 139.55
FUJISAN_BBOX_BOTTOM := 34.30
FUJISAN_BBOX_TOP    := 35.95

# Generate all rules (coastal: real coastline in bbox)
$(eval $(call define-region,fujisan,FUJISAN,Fujisan,coastal))
