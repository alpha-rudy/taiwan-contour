# =============================================================================
# Minami Alps Region - Southern Japan Alps (Akaishi Mountains), Japan
# =============================================================================
#
# Geographic Coverage (output crop):
#   Latitude:  35.15°N  - 35.90°N
#   Longitude: 137.70°E - 138.65°E
#
# Hot zones: Kitadake/Notoridake/Aino-dake (Shirane Sanzan), Senjogatake,
#            Shiomidake, Akaishidake, Hijiridake, Ojidake, Hoodzan
#
# Data Source: ALOS AW3D30 v4.1
# Tiles: N035 x E137-E138 (2 tiles cover the crop)
#
# Outputs:
#   - ele_minami_alps_10_100_500.pbf       : Standard contour (10m interval)
#   - ele_minami_alps_10_100_500_mix.pbf   : Contour with markers
#   - aw3d30-4.1/minami_alps_hgtmix.zip    : HGT 30m for Garmin devices
#   - aw3d30-4.1/minami_alps_hgt90.zip     : HGT 90m for Garmin devices
# =============================================================================

# Bare tile IDs (NxxxEyyy); filename lists are derived in regions/common.mk
MINAMI_ALPS_TILE_IDS := \
    N035E137 N035E138

# Bounding box for sea/land generation and output crop
MINAMI_ALPS_BBOX_LEFT   := 137.70
MINAMI_ALPS_BBOX_RIGHT  := 138.65
MINAMI_ALPS_BBOX_BOTTOM := 35.15
MINAMI_ALPS_BBOX_TOP    := 35.90

# Generate all rules (inland: no coastline in bbox)
$(eval $(call define-region,minami_alps,MINAMI_ALPS,Minami Alps,inland))
