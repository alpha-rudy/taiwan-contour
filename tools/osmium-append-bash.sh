#!/usr/bin/env bash

set -euo pipefail

# Usage: osmium-append-bash.sh target add
# Appends OSM/PBF file "$add" to existing "$target", renumbering IDs to avoid collisions.

target=${1:-}
add=${2:-}

if [ -z "$target" ] || [ -z "$add" ]; then
    echo "Usage: $0 <target.pbf> <add.pbf>" >&2
    exit 1
fi

[ -f "$target" ] || { echo "Target not found: $target" >&2; exit 1; }
[ -f "$add" ] || { echo "Add file not found: $add" >&2; exit 1; }

# Get largest IDs from target and prepare new start IDs by incrementing them
eval $(osmium fileinfo -e "$target" | \
    sed -e 's/Largest node ID: /LNID=/' -e 's/Largest way ID: /LWID=/' | \
    grep -E 'LNID=|LWID=' || true)

: ${LNID:=0}
: ${LWID:=0}

# increment
LNID=$((LNID + 1))
LWID=$((LWID + 1))

REN_FILE=$(mktemp /tmp/ren_XXXXXX.pbf)
MGR_FILE=$(mktemp /tmp/mgr_XXXXXX.pbf)

echo "renumber $add: ${LNID},${LWID},0"
osmium renumber \
    -s ${LNID},${LWID},0 \
    "$add" \
    -Oo "$REN_FILE"

echo "merge: $target $add"
osmium merge \
    "$target" \
    "$REN_FILE" \
    -Oo "$MGR_FILE"

rm -f "$REN_FILE"
mv "$MGR_FILE" "$target"
