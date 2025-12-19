#!/bin/bash

# Automatic generation for sea and land OSM files
# Creates sea.osm and nosea (land) OSM files from bounding box coordinates
#
# Based on map-creator.sh by devemux86

# Configuration

[ $OSMOSIS_HOME ] || OSMOSIS_HOME="$PWD/tools/osmosis"
[ $DATA_PATH ] || DATA_PATH="$PWD/land-polygons"
[ $OUTPUT_PATH ] || OUTPUT_PATH="$PWD/land-polygons"

[ $DAYS ] || DAYS="30"

# =========== DO NOT CHANGE AFTER THIS LINE. ===========================
# Below here is regular code, part of the file. This is not designed to
# be modified by users.
# ======================================================================

print_usage() {
  echo "Usage: $0 -l LEFT -r RIGHT -b BOTTOM -t TOP [-n NAME] [-o OUTPUT_PATH]"
  echo ""
  echo "Required arguments:"
  echo "  -l LEFT     Left longitude (min longitude)"
  echo "  -r RIGHT    Right longitude (max longitude)"
  echo "  -b BOTTOM   Bottom latitude (min latitude)"
  echo "  -t TOP      Top latitude (max latitude)"
  echo ""
  echo "Optional arguments:"
  echo "  -n NAME     Output file name prefix (default: sealand)"
  echo "  -o OUTPUT   Output directory path (default: $OUTPUT_PATH)"
  echo ""
  echo "Example: $0 -l -74.3 -r -73.7 -b 40.5 -t 40.9 -n newyork"
  exit 1
}

# Parse command line options

LEFT=""
RIGHT=""
BOTTOM=""
TOP=""
NAME="sealand"

while getopts "l:r:b:t:n:o:h" opt; do
  case $opt in
    l) LEFT="$OPTARG" ;;
    r) RIGHT="$OPTARG" ;;
    b) BOTTOM="$OPTARG" ;;
    t) TOP="$OPTARG" ;;
    n) NAME="$OPTARG" ;;
    o) OUTPUT_PATH="$OPTARG" ;;
    h) print_usage ;;
    *) print_usage ;;
  esac
done

# Validate required arguments

if [ -z "$LEFT" ] || [ -z "$RIGHT" ] || [ -z "$BOTTOM" ] || [ -z "$TOP" ]; then
  echo "Error: All bounding box coordinates (LEFT, RIGHT, BOTTOM, TOP) are required."
  echo ""
  print_usage
fi

# Validate coordinate values

validate_coordinate() {
  local value="$1"
  local name="$2"
  if ! [[ "$value" =~ ^-?[0-9]+\.?[0-9]*$ ]]; then
    echo "Error: $name must be a valid number."
    exit 1
  fi
}

validate_coordinate "$LEFT" "LEFT"
validate_coordinate "$RIGHT" "RIGHT"
validate_coordinate "$BOTTOM" "BOTTOM"
validate_coordinate "$TOP" "TOP"

cd "$(dirname "$0")"

WORK_PATH="$DATA_PATH/sealand_tmp_$$"

echo "Creating sea and land OSM files..."
echo "Bounding box: LEFT=$LEFT, RIGHT=$RIGHT, BOTTOM=$BOTTOM, TOP=$TOP"

# Pre-process

rm -rf "$WORK_PATH"
mkdir -p "$WORK_PATH"
mkdir -p "$OUTPUT_PATH"

# ========== Land (nosea) ==========

echo "Processing land polygons..."

# Download land

# if [ -f "$DATA_PATH/land-polygons-split-4326/land_polygons.shp" ] && [ $(find "$DATA_PATH/land-polygons-split-4326/land_polygons.shp" -mtime -$DAYS) ]; then
#   echo "Land polygons exist and are newer than $DAYS days."
# else
#   echo "Downloading land polygons..."
#   rm -rf "$DATA_PATH/land-polygons-split-4326"
#   rm -f "$DATA_PATH/land-polygons-split-4326.zip"
#   wget -nv -N -P "$DATA_PATH" https://osmdata.openstreetmap.de/download/land-polygons-split-4326.zip || exit 1
#   unzip -oq "$DATA_PATH/land-polygons-split-4326.zip" -d "$DATA_PATH"
#   rm -f "$DATA_PATH/land-polygons-split-4326.zip"
# fi

# Land (nosea) - clip land polygons to bounding box and convert to OSM

ogr2ogr -overwrite -progress -skipfailures -clipsrc $LEFT $BOTTOM $RIGHT $TOP "$WORK_PATH/land.shp" "$DATA_PATH/land-polygons-split-4326/land_polygons.shp"
python3 shape2osm.py -l "$WORK_PATH/land" "$WORK_PATH/land.shp"

# Merge all land OSM files into one nosea file
if ls $WORK_PATH/land*.osm 1> /dev/null 2>&1; then
  # If there's only one land file, copy it directly
  LAND_COUNT=$(ls -1 $WORK_PATH/land*.osm 2>/dev/null | wc -l)
  if [ "$LAND_COUNT" -eq 1 ]; then
    cp $WORK_PATH/land*.osm "$OUTPUT_PATH/$NAME-nosea.osm"
  else
    # Multiple land files - combine them
    # Create a header
    echo '<?xml version="1.0" encoding="UTF-8"?>' > "$OUTPUT_PATH/$NAME-nosea.osm"
    echo '<osm version="0.6">' >> "$OUTPUT_PATH/$NAME-nosea.osm"
    
    # Extract content from each land file (excluding headers and closing tags)
    for f in $WORK_PATH/land*.osm; do
      # Skip the XML header and osm opening/closing tags
      grep -v '<?xml' "$f" | grep -v '<osm' | grep -v '</osm>' >> "$OUTPUT_PATH/$NAME-nosea.osm"
    done
    
    echo '</osm>' >> "$OUTPUT_PATH/$NAME-nosea.osm"
  fi
  echo "Created: $OUTPUT_PATH/$NAME-nosea.osm"
else
  echo "Warning: No land polygons found in the specified bounding box."
  # Create an empty OSM file
  echo '<?xml version="1.0" encoding="UTF-8"?>' > "$OUTPUT_PATH/$NAME-nosea.osm"
  echo '<osm version="0.6">' >> "$OUTPUT_PATH/$NAME-nosea.osm"
  echo '</osm>' >> "$OUTPUT_PATH/$NAME-nosea.osm"
  echo "Created empty: $OUTPUT_PATH/$NAME-nosea.osm"
fi

# ========== Sea ==========

echo "Processing sea..."

# Sea - create sea OSM from template

cp sea.osm "$WORK_PATH/sea.osm"
sed -i "s/\$BOTTOM/$BOTTOM/g" "$WORK_PATH/sea.osm"
sed -i "s/\$LEFT/$LEFT/g" "$WORK_PATH/sea.osm"
sed -i "s/\$TOP/$TOP/g" "$WORK_PATH/sea.osm"
sed -i "s/\$RIGHT/$RIGHT/g" "$WORK_PATH/sea.osm"

cp "$WORK_PATH/sea.osm" "$OUTPUT_PATH/$NAME-sea.osm"
echo "Created: $OUTPUT_PATH/$NAME-sea.osm"

# ========== Merge Sea and Land ==========

echo "Merging sea and land with osmosis..."

CMD="$OSMOSIS_HOME/bin/osmosis --rx file=$WORK_PATH/sea.osm --s"
for f in $WORK_PATH/land*.osm; do
  CMD="$CMD --rx file=$f --s --m"
done
CMD="$CMD --wx file=$OUTPUT_PATH/$NAME-sealand.osm"
echo $CMD
eval "$CMD" || exit 1

echo "Created: $OUTPUT_PATH/$NAME-sealand.osm"

# ========== Renumber and Convert to PBF ==========

echo "Renumbering sealand and converting to PBF..."

osmium renumber -s 1,1,1 "$OUTPUT_PATH/$NAME-sealand.osm" -o "$OUTPUT_PATH/$NAME-sealand.pbf" --overwrite || exit 1

echo "Created: $OUTPUT_PATH/$NAME-sealand.pbf"

# ========== Post-process ==========

echo "Cleaning up..."
rm -rf "$WORK_PATH"
rm -f "$OUTPUT_PATH/$NAME-sea.osm"
rm -f "$OUTPUT_PATH/$NAME-nosea.osm"
rm -f "$OUTPUT_PATH/$NAME-sealand.osm"

echo ""
echo "Done! Output file:"
echo "  Sealand: $OUTPUT_PATH/$NAME-sealand.pbf"
