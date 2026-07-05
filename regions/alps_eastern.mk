# =============================================================================
# Alps Eastern Region - Eastern Alps & Dolomites (Italy, Austria, Slovenia)
# =============================================================================
#
# Geographic Coverage (output crop):
#   Latitude:  45.8°N  - 47.55°N
#   Longitude: 10.5°E  - 14.0°E    (6.1 sq°)
#
# Hot zones: Adamello/Presanella, Brenta, Arco/Garda climbing, Cevedale,
#            Ötztal/Stubai, Dolomites, Zillertal, Hohe Tauern (Grossglockner/
#            Grossvenediger), Dachstein, Julian Alps (Triglav)
#
# Data Source: ALOS AW3D30 v4.1
# Tiles: N045-N047 x E010-E013 (12 tiles cover the crop; overlap at E010/E013)
#
# Outputs:
#   - ele_alps_eastern_10_100_500.pbf       : Standard contour (10m interval)
#   - ele_alps_eastern_10_100_500_mix.pbf   : Contour with markers
#   - aw3d30-4.1/alps_eastern_hgtmix.zip    : HGT 30m for Garmin devices
#   - aw3d30-4.1/alps_eastern_hgt90.zip     : HGT 90m for Garmin devices
# =============================================================================

# Bare tile IDs (NxxxEyyy); filename lists are derived in regions/common.mk
ALPS_EASTERN_TILE_IDS := \
    N045E010 N045E011 N045E012 N045E013 \
    N046E010 N046E011 N046E012 N046E013 \
    N047E010 N047E011 N047E012 N047E013

# Bounding box for sea/land generation and output crop
ALPS_EASTERN_BBOX_LEFT   := 10.5
ALPS_EASTERN_BBOX_RIGHT  := 14.0
ALPS_EASTERN_BBOX_BOTTOM := 45.8
ALPS_EASTERN_BBOX_TOP    := 47.55

# Generate all rules (inland: no coastline in bbox)
$(eval $(call define-region,alps_eastern,ALPS_EASTERN,Alps Eastern,inland))
