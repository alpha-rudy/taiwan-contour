# =============================================================================
# Shikoku Region - Shikoku Island, Japan
# =============================================================================
#
# Geographic Coverage:
#   Latitude:  32.702°N - 34.428°N
#   Longitude: 132.000°E - 134.846°E
#
# Data Source: ALOS AW3D30 v4.1
# Tiles: N032E132, N032E133,
#        N033E132, N033E133, N033E134,
#        N034E132, N034E133, N034E134
#   (N032E134 is open Pacific with no ALOS land tile, so it is omitted.)
#
# Outputs:
#   - ele_shikoku_10_100_500.pbf       : Standard contour (10m interval)
#   - ele_shikoku_10_100_500_mix.pbf   : Contour with markers
#   - aw3d30-4.1/shikoku_hgtmix.zip    : HGT 30m for Garmin devices
#   - aw3d30-4.1/shikoku_hgt90.zip     : HGT 90m for Garmin devices
# =============================================================================

# Bare tile IDs (NxxxEyyy); filename lists are derived in regions/common.mk
SHIKOKU_TILE_IDS := \
    N032E132 N032E133 \
    N033E132 N033E133 N033E134 \
    N034E132 N034E133 N034E134

# Bounding box for sea/land generation
SHIKOKU_BBOX_LEFT   := 132.000
SHIKOKU_BBOX_RIGHT  := 134.846
SHIKOKU_BBOX_BOTTOM := 32.702
SHIKOKU_BBOX_TOP    := 34.428

# Generate all rules (coastal: real coastline in bbox)
$(eval $(call define-region,shikoku,SHIKOKU,Shikoku,coastal))
