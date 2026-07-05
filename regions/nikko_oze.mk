# =============================================================================
# Nikko-Oze Region - Nikko National Park & Oze Area, Japan
# =============================================================================
#
# Geographic Coverage:
#   Latitude:  36.50°N - 37.47°N
#   Longitude: 138.68°E - 139.86°E
#
# Data Source: ALOS AW3D30 v4.1
# Tiles: N036E138, N036E139, N036E140, N037E138, N037E139, N037E140
#
# Outputs:
#   - ele_nikko_oze_10_100_500.pbf       : Standard contour (10m interval)
#   - ele_nikko_oze_10_100_500_mix.pbf   : Contour with markers
#   - aw3d30-4.1/nikko_oze_hgtmix.zip    : HGT 30m for Garmin devices
#   - aw3d30-4.1/nikko_oze_hgt90.zip     : HGT 90m for Garmin devices
# =============================================================================

# Bare tile IDs (NxxxEyyy); filename lists are derived in regions/common.mk
NIKKO_OZE_TILE_IDS := \
    N036E138 N036E139 N036E140 \
    N037E138 N037E139 N037E140

# Bounding box for sea/land generation
NIKKO_OZE_BBOX_LEFT   := 138.68
NIKKO_OZE_BBOX_RIGHT  := 139.86
NIKKO_OZE_BBOX_BOTTOM := 36.50
NIKKO_OZE_BBOX_TOP    := 37.47

# Generate all rules (inland: no coastline in bbox)
$(eval $(call define-region,nikko_oze,NIKKO_OZE,Nikko-Oze,inland))
