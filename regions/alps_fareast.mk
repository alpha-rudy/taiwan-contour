# =============================================================================
# Alps Far-Eastern Region - Far-Eastern Alps (Slovenia, Austria)
# =============================================================================
#
# Geographic Coverage (output crop):
#   Latitude:  46.3°N  - 47.85°N
#   Longitude: 13.9°E  - 15.9°E    (3.1 sq°)
#
# Hot zones: Karawanks, Kamnik–Savinja Alps, Totes Gebirge, Gesäuse,
#            Hochschwab, Schneeberg/Rax
#   (Julian Alps / Triglav at 13.8°E are covered by alps_eastern.)
#
# Data Source: ALOS AW3D30 v4.1
# Tiles: N046-N047 x E013-E015 (6 tiles cover the crop; overlap at E013)
#
# Outputs:
#   - ele_alps_fareast_10_100_500.pbf       : Standard contour (10m interval)
#   - ele_alps_fareast_10_100_500_mix.pbf   : Contour with markers
#   - aw3d30-4.1/alps_fareast_hgtmix.zip    : HGT 30m for Garmin devices
#   - aw3d30-4.1/alps_fareast_hgt90.zip     : HGT 90m for Garmin devices
# =============================================================================

# Bare tile IDs (NxxxEyyy); filename lists are derived in regions/common.mk
ALPS_FAREAST_TILE_IDS := \
    N046E013 N046E014 N046E015 \
    N047E013 N047E014 N047E015

# Bounding box for sea/land generation and output crop
ALPS_FAREAST_BBOX_LEFT   := 13.9
ALPS_FAREAST_BBOX_RIGHT  := 15.9
ALPS_FAREAST_BBOX_BOTTOM := 46.3
ALPS_FAREAST_BBOX_TOP    := 47.85

# Generate all rules (inland: no coastline in bbox)
$(eval $(call define-region,alps_fareast,ALPS_FAREAST,Alps Far-Eastern,inland))
