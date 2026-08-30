# =============================================================================
# Kita Alps Region - Northern Japan Alps (Hida Mountains), Japan
# =============================================================================
#
# Geographic Coverage (output crop):
#   Latitude:  35.90°N  - 37.05°N
#   Longitude: 137.15°E - 138.25°E
#
# Hot zones: Hotakadake/Yarigatake, Norikuradake, Tateyama/Tsurugidake,
#            Kurobe gorge, Shirouma/Ushiro-Tateyama, Hakuba valley,
#            Toyama Bay coast and Oyashirazu (north end of the range)
#
# Data Source: ALOS AW3D30 v4.1
# Tiles: N035-N037 x E137-E138 (6 tiles cover the crop)
#
# Outputs:
#   - ele_kita_alps_10_100_500.pbf       : Standard contour (10m interval)
#   - ele_kita_alps_10_100_500_mix.pbf   : Contour with markers
#   - aw3d30-4.1/kita_alps_hgtmix.zip    : HGT 30m for Garmin devices
#   - aw3d30-4.1/kita_alps_hgt90.zip     : HGT 90m for Garmin devices
# =============================================================================

# Bare tile IDs (NxxxEyyy); filename lists are derived in regions/common.mk
KITA_ALPS_TILE_IDS := \
    N035E137 N035E138 \
    N036E137 N036E138 \
    N037E137 N037E138

# Bounding box for sea/land generation and output crop
KITA_ALPS_BBOX_LEFT   := 137.15
KITA_ALPS_BBOX_RIGHT  := 138.25
KITA_ALPS_BBOX_BOTTOM := 35.90
KITA_ALPS_BBOX_TOP    := 37.05

# Generate all rules (coastal: Toyama Bay / Japan Sea coastline is in the bbox)
$(eval $(call define-region,kita_alps,KITA_ALPS,Kita Alps,coastal))
