# Foreign Regions - Contour Generation Guide

This guide explains how to add new foreign regions (areas outside Taiwan) to the contour generation system.

## Table of Contents

- [Overview](#overview)
- [Concepts](#concepts)
- [Directory Structure](#directory-structure)
- [Step-by-Step Guide](#step-by-step-guide)
- [Configuration Reference](#configuration-reference)
- [Troubleshooting](#troubleshooting)

---

## Overview

The taiwan-contour project generates elevation contour lines in OSM PBF format for use in mapping applications. While originally designed for Taiwan, it supports adding custom "foreign regions" using ALOS AW3D30 satellite elevation data.

### What You'll Get

For each region, the build process generates:

| Output File | Description |
|------------|-------------|
| `ele_{region}_10_100_500.pbf` | Contour lines at 10m intervals (100m/500m highlighted) |
| `ele_{region}_10_100_500_mix.pbf` | Contour with zoom-level markers for better rendering |
| `aw3d30-4.1/{region}_hgtmix.zip` | 30m HGT files for Garmin devices |
| `aw3d30-4.1/{region}_hgt90.zip` | 90m HGT files for Garmin devices |

---

## Concepts

### Key Terms

| Term | Description |
|------|-------------|
| **Region** | A geographic area defined by a bounding box and name identifier |
| **Tile** | A 1°×1° grid cell of elevation data (e.g., N034E138 = 34°N, 138°E) |
| **ALOS AW3D30** | JAXA's 30-meter resolution global digital surface model |
| **ALPSMLC30** | ALOS naming convention for DSM tiles |
| **HGT** | Height file format used by Garmin devices |
| **PBF** | Protocol Buffer Binary Format for OSM data |
| **Sealand** | Sea/land boundary polygons for coastline rendering |

### Data Flow

```
ALOS Tiles (ALPSMLC30_*.tif)
       │
       ▼
   Merge & Warp
       │
       ▼
{region}-nodata0.tif
       │
       ▼
{region}-zero.tif
       │
       ├──────────────────┐
       ▼                  ▼
   pyhgtmap           HGT Export
       │                  │
       ▼                  ▼
 Contour PBF        HGT ZIP files
       │
       ▼
  + Sealand PBF
       │
       ▼
Final ele_*.pbf
```

### Tile Naming Convention

ALOS AW3D30 tiles follow this pattern:

```
ALPSMLC30_N034E138_DSM.tif
          │   │
          │   └── Longitude (E=East, W=West)
          └────── Latitude (N=North, S=South)
```

The tile represents the southwest corner. For example, `N034E138` covers:
- Latitude: 34°N to 35°N
- Longitude: 138°E to 139°E

---

## Directory Structure

```
taiwan-contour/
├── Makefile              # Main makefile (includes region files)
├── regions/
│   ├── README.md         # This file
│   ├── common.mk         # Shared macros for all regions
│   ├── fujisan.mk        # Mount Fuji region
│   ├── nikko_oze.mk      # Nikko-Oze region
│   ├── kumano_kodo.mk    # Kumano Kodo region
│   ├── annapurna.mk      # Annapurna region
│   ├── kashmir.mk        # Kashmir region
│   └── elbrus.mk         # Elbrus region
├── aw3d30-4.1/           # ALOS source tiles and outputs
├── downloads/
│   └── land-polygons/    # Sea/land boundary data; land-polygons-split-4326.zip
│                         # is wget'd here automatically by `make` (coastal
│                         # regions only - see define-foreign-region-sealand)
└── tools/                # Processing scripts
```

---

## Step-by-Step Guide

### Step 1: Determine Your Region's Coverage

1. **Find the geographic bounds** of your area using a mapping tool like [OpenStreetMap](https://www.openstreetmap.org/) or Google Maps.

2. **Note the bounding box** (in decimal degrees):
   - Left longitude (west boundary)
   - Right longitude (east boundary)
   - Bottom latitude (south boundary)
   - Top latitude (north boundary)

3. **Identify required ALOS tiles** that cover your region.

   Example: For an area covering 34.5°N - 35.5°N, 138.5°E - 139.5°E:
   - You need tiles: N034E138, N034E139, N035E138, N035E139

### Step 2: Download ALOS Data

1. Register at [JAXA Earth Observation Research Center](https://www.eorc.jaxa.jp/ALOS/en/dataset/aw3d30/aw3d30_e.htm)

2. Download the DSM tiles for your region in GeoTIFF format

3. Place the tiles in `aw3d30-4.1/` with naming format:
   ```
   ALPSMLC30_N034E138_DSM.tif
   ```

### Step 3: Create Your Region File

Create a new file `regions/{your_region}.mk` using this template:

```makefile
# =============================================================================
# {Your Region Name} - {Location Description}
# =============================================================================
#
# Geographic Coverage:
#   Latitude:  {bottom}°N - {top}°N
#   Longitude: {left}°E - {right}°E
#
# Data Source: ALOS AW3D30 v4.1
# Tiles: {list of tile IDs}
# =============================================================================

# Bare tile IDs (NxxxEyyy); the *_AVE_DSM.tif and ALPSMLC30_*_DSM.tif
# filename lists are derived automatically in regions/common.mk
{REGION_VAR}_TILE_IDS := \
    N{lat1}E{lon1} N{lat2}E{lon2}

# Bounding box for sea/land generation
{REGION_VAR}_BBOX_LEFT   := {left}
{REGION_VAR}_BBOX_RIGHT  := {right}
{REGION_VAR}_BBOX_BOTTOM := {bottom}
{REGION_VAR}_BBOX_TOP    := {top}

# Generate all rules with a single entry macro. define-region reads
# {REGION_VAR}_TILE_IDS and {REGION_VAR}_BBOX_* by naming convention.
# Arguments: (region_id, PREFIX, Display Name, coastal|inland)
#
# The 4th argument selects the sealand/outputs behaviour - choose ONE
# depending on whether your bounding box touches the sea:
#
#   coastal - bbox includes real coastline (e.g. Fujisan, Japan coast):
#             clips the real OSM land-polygon shapefile to your bbox (needs
#             downloads/land-polygons/, wget'd automatically by `make` - see
#             Directory Structure above) and builds a mix pbf with those
#             clipped sealand polygons for ocean rendering.
#   inland  - bbox is entirely land (e.g. Alps Core, Elbrus, Annapurna):
#             covers the whole bbox with a fine grid (-g 0.1) of "nosea"
#             tiles instead of real coastline - no land-polygon download
#             needed - and builds a mix pbf with those tiles for correct
#             land rendering.
$(eval $(call define-region,{region_id},{REGION_VAR},{Human Readable Name},coastal))
```

The Display Name may contain spaces (e.g. `Alps Far-Eastern`); do not quote it.
`define-region` invokes the five lower-level macros for you - you can still call
them individually (see [Available Macros](#available-macros)) if you need finer
control.

### Step 4: Register Your Region

Add the include statement to the main `Makefile`:

```makefile
include regions/common.mk
include regions/fujisan.mk
# ... existing regions ...
include regions/{your_region}.mk   # Add this line
```

### Step 5: Build Your Region

```bash
# Build everything for your region
make {region_id}-all

# Or build specific outputs:
make {region_id}-hgts        # HGT files only
make {region_id}-contour     # Standard contour PBF
make {region_id}-contour-mix # Contour with markers
```

---

## Configuration Reference

### Required Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `*_TILE_IDS` | Bare tile IDs covering the region; the `*_AVE_DSM.tif` (HGT) and `ALPSMLC30_*_DSM.tif` (ALOS input) filename lists are derived automatically in `common.mk` | `N034E138 N034E139` |
| `*_BBOX_LEFT` | West boundary longitude | `138.15` |
| `*_BBOX_RIGHT` | East boundary longitude | `139.55` |
| `*_BBOX_BOTTOM` | South boundary latitude | `34.30` |
| `*_BBOX_TOP` | North boundary latitude | `35.95` |

The region identifier, display name, and coastal/inland type are no longer
variables - they are passed directly as arguments to `define-region`:
`$(eval $(call define-region,{region_id},{PREFIX},{Display Name},{coastal|inland}))`.
The `*` prefix above is the uppercase `{PREFIX}` (e.g. `FUJISAN`, `ALPS_FAREAST`).

### Generated Targets

The macros in `common.mk` generate these Make targets:

| Target | Description |
|--------|-------------|
| `{region}-all` | Build all outputs |
| `{region}-hgts` | Build HGT files |
| `{region}-contour` | Build `ele_{region}_10_100_500.pbf` |
| `{region}-contour-mix` | Build `ele_{region}_10_100_500_mix.pbf` |

### Available Macros

The following macros are defined in `common.mk`:

| Macro | Purpose |
|-------|---------|
| `define-region` | **Primary entry point.** Derives the tile filename lists from `*_TILE_IDS` and invokes all five macros below. Signature: `(region_id, PREFIX, Display Name, coastal\|inland)`. `coastal` selects `define-foreign-region-sealand` + `define-coastal-region-outputs`; `inland` selects `define-inland-region-sealand` + `define-inland-region-outputs` |
| `define-foreign-region-all` | Defines the `{region}-all` target |
| `define-foreign-region-hgt` | Defines HGT generation rules |
| `define-foreign-region-nodata` | Defines the nodata0.tif merge rule |
| `define-foreign-region-sealand` | COASTAL: clips the real OSM land-polygon shapefile to the bbox |
| `define-inland-region-sealand` | INLAND: covers the bbox with a fine grid (`-g 0.1`) of nosea tiles, no land-polygon download needed |
| `define-coastal-region-outputs` | COASTAL: defines final PBF output targets (contour + sealand-clipped mix) |
| `define-inland-region-outputs` | INLAND: defines final PBF output targets (contour + fine-grid-sealand mix) |
| `make-hgt-rule` | Internal macro for HGT generation (used by `define-foreign-region-hgt`) |

---

## Example: Adding Mount Rainier

Here's a complete example for adding Mount Rainier, Washington, USA:

### Step 1: Determine Coverage

- Region: Mount Rainier National Park
- Bounds: 46.7°N - 47.0°N, 121.4°W - 122.0°W
- Tiles needed: N046W122, N046W121

### Step 2: Create Region File

Create `regions/rainier.mk`:

```makefile
# =============================================================================
# Mount Rainier Region - Washington State, USA
# =============================================================================
#
# Geographic Coverage:
#   Latitude:  46.7°N - 47.0°N
#   Longitude: 121.4°W - 122.0°W
#
# Data Source: ALOS AW3D30 v4.1
# Tiles: N046W122, N046W121
# =============================================================================

RAINIER_TILE_IDS := \
    N046W122 N046W121

# Note: Western longitudes are negative
RAINIER_BBOX_LEFT   := -122.0
RAINIER_BBOX_RIGHT  := -121.4
RAINIER_BBOX_BOTTOM := 46.7
RAINIER_BBOX_TOP    := 47.0

# Mount Rainier is entirely inland (no coastline in the bbox), so pass "inland"
# as the type: a fine grid of nosea tiles covers the whole bbox and no
# land-polygon download is required.
$(eval $(call define-region,rainier,RAINIER,Mount Rainier,inland))
```

### Step 3: Update Makefile

```makefile
include regions/rainier.mk
```

### Step 4: Build

```bash
make rainier-all
```

---

## Troubleshooting

### Common Issues

#### Missing ALOS Tiles

```
Error: aw3d30-4.1/ALPSMLC30_N034E138_DSM.tif not found
```

**Solution**: Download the missing tile from JAXA and place it in `aw3d30-4.1/`.

#### Land Polygon Data Missing

```
Error: downloads/land-polygons/.unzip not found
```

**Solution**: This only applies to COASTAL regions (`define-foreign-region-sealand`).
`make` downloads and unzips the archive automatically the first time it's needed:

```bash
make downloads/land-polygons/.unzip
```

which `wget`s `land-polygons-split-4326.zip` from
`https://osmdata.openstreetmap.de/download/land-polygons-split-4326.zip` into
`downloads/land-polygons/` and unzips it there. If the download fails (e.g. no
network access), fetch the zip manually and place it in `downloads/land-polygons/`
before re-running `make`. INLAND regions (`define-inland-region-sealand`) don't
need this at all.

#### Bounding Box Issues

If the output appears truncated or missing coastline:
- Verify the bounding box extends slightly beyond your actual area of interest
- Ensure coordinates are in the correct order (left < right, bottom < top)
- Check that western longitudes are negative

#### Memory Errors

For large regions, pyhgtmap may run out of memory:
- Try processing smaller areas separately
- Increase system swap space
- Use the `--max-nodes-per-tile` option

### Verifying Output

View the generated PBF file with:

```bash
osmium fileinfo -e ele_{region}_10_100_500.pbf
```

Check contour coverage with QGIS or another GIS tool.

---

## Support

For questions or issues, please open an issue on the GitHub repository.
