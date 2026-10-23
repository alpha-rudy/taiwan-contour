# =============================================================================
# Jeju Region - Jeju Island, Udo, Marado & Chuja Islands, South Korea
# =============================================================================
#
# Geographic Coverage:
#   Latitude:  33.108°N - 34.018°N
#   Longitude: 126.138°E - 126.978°E
#   (land extent from OSM land polygons + ~500m margin; the northernmost
#   Chuja islets reach 34.013°N, hence the N034E126 tile)
#
# Data Source: ALOS AW3D30 v4.1
# Tiles: N033E126, N034E126
#
# Outputs:
#   - ele_jeju_10_100_500.pbf       : Standard contour (10m interval)
#   - ele_jeju_10_100_500_mix.pbf   : Contour with markers
#   - aw3d30-4.1/jeju_hgtmix.zip    : HGT 30m for Garmin devices
#   - aw3d30-4.1/jeju_hgt90.zip     : HGT 90m for Garmin devices
# =============================================================================

# Bare tile IDs (NxxxEyyy); filename lists are derived in regions/common.mk
JEJU_TILE_IDS := \
    N033E126 N034E126

# Bounding box for sea/land generation
JEJU_BBOX_LEFT   := 126.138
JEJU_BBOX_RIGHT  := 126.978
JEJU_BBOX_BOTTOM := 33.108
JEJU_BBOX_TOP    := 34.018

# Generate all rules (coastal: real coastline in bbox)
$(eval $(call define-region,jeju,JEJU,Jeju,coastal))
