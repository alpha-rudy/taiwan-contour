# =============================================================================
# Alps Core Region - Central Alps (Switzerland, Italy)
# =============================================================================
#
# Geographic Coverage (output crop):
#   Latitude:  45.8°N  - 47.3°N
#   Longitude: 7.15°E  - 10.75°E   (5.6 sq°)
#
# Hot zones: Bernese Oberland (Diablerets/Wildhorn west, Eiger/Jungfrau/
#            Finsteraarhorn/Aletsch), Tödi/Glarus, Säntis/Alpstein,
#            Bernina/Bregaglia, Engadin/Silvretta, Ortler/Stelvio,
#            Grigna, Orobie
#
# Data Source: ALOS AW3D30 v4.1
# Tiles: N045-N047 x E007-E010 (12 tiles cover the crop; overlap at E007/E010)
#
# Outputs:
#   - ele_alps_core_10_100_500.pbf       : Standard contour (10m interval)
#   - ele_alps_core_10_100_500_mix.pbf   : Contour with markers
#   - aw3d30-4.1/alps_core_hgtmix.zip    : HGT 30m for Garmin devices
#   - aw3d30-4.1/alps_core_hgt90.zip     : HGT 90m for Garmin devices
# =============================================================================

# Bare tile IDs (NxxxEyyy); filename lists are derived in regions/common.mk
ALPS_CORE_TILE_IDS := \
    N045E007 N045E008 N045E009 N045E010 \
    N046E007 N046E008 N046E009 N046E010 \
    N047E007 N047E008 N047E009 N047E010

# Bounding box for sea/land generation and output crop
ALPS_CORE_BBOX_LEFT   := 7.15
ALPS_CORE_BBOX_RIGHT  := 10.75
ALPS_CORE_BBOX_BOTTOM := 45.8
ALPS_CORE_BBOX_TOP    := 47.3

# Generate all rules (inland: no coastline in bbox)
$(eval $(call define-region,alps_core,ALPS_CORE,Alps Core,inland))
