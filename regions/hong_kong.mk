# =============================================================================
# Hong Kong Region - Hong Kong SAR and adjacent Shenzhen, China
# =============================================================================
#
# Geographic Coverage (output crop):
#   Latitude:  22.130°N  - 22.569°N
#   Longitude: 113.813°E - 114.506°E
#
# Hot zones: Tai Mo Shan / MacLehose Trail, Lantau Peak and Sunset Peak,
#            Ma On Shan, Pat Sin Leng, Sai Kung peninsula, Victoria Peak,
#            outlying islands (Lamma, Cheung Chau, Po Toi)
#
# Data Source: ALOS AW3D30 v4.1
# Tiles: N022 x E113-E114 (2 tiles cover the crop)
#
# Outputs:
#   - ele_hong_kong_10_100_500.pbf       : Standard contour (10m interval)
#   - ele_hong_kong_10_100_500_mix.pbf   : Contour with markers
#   - aw3d30-4.1/hong_kong_hgtmix.zip    : HGT 30m for Garmin devices
#   - aw3d30-4.1/hong_kong_hgt90.zip     : HGT 90m for Garmin devices
# =============================================================================

# Bare tile IDs (NxxxEyyy); filename lists are derived in regions/common.mk
HONG_KONG_TILE_IDS := \
    N022E113 N022E114

# Bounding box for sea/land generation and output crop
HONG_KONG_BBOX_LEFT   := 113.813
HONG_KONG_BBOX_RIGHT  := 114.506
HONG_KONG_BBOX_BOTTOM := 22.130
HONG_KONG_BBOX_TOP    := 22.569

# Generate all rules (coastal: only ~40% of the bbox is land)
$(eval $(call define-region,hong_kong,HONG_KONG,Hong Kong,coastal))
