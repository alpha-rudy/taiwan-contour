# =============================================================================
# Chuo Alps Region - Central Japan Alps (Kiso Mountains), Japan
# =============================================================================
#
# Geographic Coverage (output crop):
#   Latitude:  35.35°N  - 36.05°N
#   Longitude: 137.30°E - 138.10°E
#
# Hot zones: Kiso Komagatake/Hokendake (Senjojiki), Utsugidake, Ontakesan,
#            Norikuradake south flank, Kiso valley, Ina valley
#
# Data Source: ALOS AW3D30 v4.1
# Tiles: N035-N036 x E137-E138 (4 tiles cover the crop)
#
# Outputs:
#   - ele_chuo_alps_10_100_500.pbf       : Standard contour (10m interval)
#   - ele_chuo_alps_10_100_500_mix.pbf   : Contour with markers
#   - aw3d30-4.1/chuo_alps_hgtmix.zip    : HGT 30m for Garmin devices
#   - aw3d30-4.1/chuo_alps_hgt90.zip     : HGT 90m for Garmin devices
# =============================================================================

# Bare tile IDs (NxxxEyyy); filename lists are derived in regions/common.mk
CHUO_ALPS_TILE_IDS := \
    N035E137 N035E138 \
    N036E137 N036E138

# Bounding box for sea/land generation and output crop
CHUO_ALPS_BBOX_LEFT   := 137.30
CHUO_ALPS_BBOX_RIGHT  := 138.10
CHUO_ALPS_BBOX_BOTTOM := 35.35
CHUO_ALPS_BBOX_TOP    := 36.05

# Generate all rules (inland: no coastline in bbox)
$(eval $(call define-region,chuo_alps,CHUO_ALPS,Chuo Alps,inland))
