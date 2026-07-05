# =============================================================================
# Annapurna Region - Annapurna Mountain Range, Nepal
# =============================================================================
#
# Geographic Coverage:
#   Latitude:  28.0°N - 29.0°N
#   Longitude: 83.0°E - 85.0°E
#
# Data Source: ALOS AW3D30 v4.1
# Tiles: N028E083, N028E084
#
# Outputs:
#   - ele_annapurna_10_100_500.pbf       : Standard contour (10m interval)
#   - ele_annapurna_10_100_500_mix.pbf   : Contour with markers
#   - aw3d30-4.1/annapurna_hgtmix.zip    : HGT 30m for Garmin devices
#   - aw3d30-4.1/annapurna_hgt90.zip     : HGT 90m for Garmin devices
# =============================================================================

# Bare tile IDs (NxxxEyyy); filename lists are derived in regions/common.mk
ANNAPURNA_TILE_IDS := \
    N028E083 N028E084

# Bounding box for sea/land generation
ANNAPURNA_BBOX_LEFT   := 83.0
ANNAPURNA_BBOX_RIGHT  := 85.0
ANNAPURNA_BBOX_BOTTOM := 28.0
ANNAPURNA_BBOX_TOP    := 29.0

# Generate all rules (inland: no coastline in bbox)
$(eval $(call define-region,annapurna,ANNAPURNA,Annapurna,inland))
