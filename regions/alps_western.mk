# =============================================================================
# Alps Western Region - Western & Maritime Alps (France, Italy, Switzerland)
# =============================================================================
#
# Geographic Coverage (output crop):
#   Latitude:  44.0°N - 46.2°N
#   Longitude: 6.0°E  - 8.0°E   (4.4 sq°)
#
# Hot zones: Maritime/Mercantour, Queyras/Monviso, Écrins, Vanoise,
#            Gran Paradiso, Mont Blanc, Pennine (Matterhorn/Monte Rosa/Mischabel)
#
# Data Source: ALOS AW3D30 v4.1
# Tiles: N044-N046 x E006-E007 (6 tiles cover the crop)
#
# Outputs:
#   - ele_alps_western_10_100_500.pbf       : Standard contour (10m interval)
#   - ele_alps_western_10_100_500_mix.pbf   : Contour with markers
#   - aw3d30-4.1/alps_western_hgtmix.zip    : HGT 30m for Garmin devices
#   - aw3d30-4.1/alps_western_hgt90.zip     : HGT 90m for Garmin devices
# =============================================================================

# Bare tile IDs (NxxxEyyy); filename lists are derived in regions/common.mk
ALPS_WESTERN_TILE_IDS := \
    N044E006 N044E007 \
    N045E006 N045E007 \
    N046E006 N046E007

# Bounding box for sea/land generation and output crop
ALPS_WESTERN_BBOX_LEFT   := 6.0
ALPS_WESTERN_BBOX_RIGHT  := 8.0
ALPS_WESTERN_BBOX_BOTTOM := 44.0
ALPS_WESTERN_BBOX_TOP    := 46.2

# Generate all rules (inland: no coastline in bbox)
$(eval $(call define-region,alps_western,ALPS_WESTERN,Alps Western,inland))
