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
│   └── kashmir.mk        # Kashmir region
├── aw3d30-4.1/           # ALOS source tiles and outputs
├── land-polygons/        # Sea/land boundary data
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

# Region identifier (lowercase, underscores allowed)
{REGION_VAR}_REGION := {region_id}
{REGION_VAR}_DISPLAY_NAME := {Human Readable Name}

# HGT tile definitions (for SRTM output)
{REGION_VAR}_TILES := \
    N{lat1}E{lon1}_AVE_DSM.tif \
    N{lat2}E{lon2}_AVE_DSM.tif

# ALOS source tiles
{REGION_VAR}_ALPSMLC_TILES := \
    ALPSMLC30_N{lat1}E{lon1}_DSM.tif \
    ALPSMLC30_N{lat2}E{lon2}_DSM.tif

# Bounding box for sea/land generation
{REGION_VAR}_BBOX_LEFT   := {left}
{REGION_VAR}_BBOX_RIGHT  := {right}
{REGION_VAR}_BBOX_BOTTOM := {bottom}
{REGION_VAR}_BBOX_TOP    := {top}

# Generate all rules using separate macros
$(eval $(call define-foreign-region-all,$({REGION_VAR}_REGION)))
$(eval $(call define-foreign-region-hgt,$({REGION_VAR}_REGION),$({REGION_VAR}_DISPLAY_NAME),$({REGION_VAR}_TILES)))
$(eval $(call define-foreign-region-nodata,$({REGION_VAR}_REGION),$({REGION_VAR}_ALPSMLC_TILES)))
$(eval $(call define-foreign-region-sealand,$({REGION_VAR}_REGION),$({REGION_VAR}_BBOX_LEFT),$({REGION_VAR}_BBOX_RIGHT),$({REGION_VAR}_BBOX_BOTTOM),$({REGION_VAR}_BBOX_TOP)))
$(eval $(call define-foreign-region-outputs,$({REGION_VAR}_REGION)))
```

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
| `*_REGION` | Unique region identifier | `fujisan` |
| `*_DISPLAY_NAME` | Human-readable name for VERSION file | `Fujisan` |
| `*_TILES` | HGT output tile names | `N034E138_AVE_DSM.tif` |
| `*_ALPSMLC_TILES` | ALOS input tile names | `ALPSMLC30_N034E138_DSM.tif` |
| `*_BBOX_LEFT` | West boundary longitude | `138.15` |
| `*_BBOX_RIGHT` | East boundary longitude | `139.55` |
| `*_BBOX_BOTTOM` | South boundary latitude | `34.30` |
| `*_BBOX_TOP` | North boundary latitude | `35.95` |

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
| `define-foreign-region-all` | Defines the `{region}-all` target |
| `define-foreign-region-hgt` | Defines HGT generation rules |
| `define-foreign-region-nodata` | Defines the nodata0.tif merge rule |
| `define-foreign-region-sealand` | Defines sea/land boundary generation |
| `define-foreign-region-outputs` | Defines final PBF output targets |
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

RAINIER_REGION := rainier
RAINIER_DISPLAY_NAME := Mount Rainier

RAINIER_TILES := \
    N046W122_AVE_DSM.tif \
    N046W121_AVE_DSM.tif

RAINIER_ALPSMLC_TILES := \
    ALPSMLC30_N046W122_DSM.tif \
    ALPSMLC30_N046W121_DSM.tif

# Note: Western longitudes are negative
RAINIER_BBOX_LEFT   := -122.0
RAINIER_BBOX_RIGHT  := -121.4
RAINIER_BBOX_BOTTOM := 46.7
RAINIER_BBOX_TOP    := 47.0

# Generate all rules using separate macros
$(eval $(call define-foreign-region-all,$(RAINIER_REGION)))
$(eval $(call define-foreign-region-hgt,$(RAINIER_REGION),$(RAINIER_DISPLAY_NAME),$(RAINIER_TILES)))
$(eval $(call define-foreign-region-nodata,$(RAINIER_REGION),$(RAINIER_ALPSMLC_TILES)))
$(eval $(call define-foreign-region-sealand,$(RAINIER_REGION),$(RAINIER_BBOX_LEFT),$(RAINIER_BBOX_RIGHT),$(RAINIER_BBOX_BOTTOM),$(RAINIER_BBOX_TOP)))
$(eval $(call define-foreign-region-outputs,$(RAINIER_REGION)))
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
Error: land-polygons/.unzip not found
```

**Solution**: Extract the land polygon archive:
```bash
cd land-polygons
7z x land-polygons-split-4326.7z.001
```

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
