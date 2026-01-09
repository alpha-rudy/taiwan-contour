# Docker Usage for Taiwan Contour Map Making

## Building the Docker Image

Build with your user ID to avoid permission issues:

```bash
docker build \
  --build-arg USER_ID=$(id -u) \
  --build-arg GROUP_ID=$(id -g) \
  -t taiwan-contour:latest .
```

Or build with default UID/GID (1000:1000):

```bash
docker build -t taiwan-contour:latest .
```

## Running the Container

### Interactive Mode (Recommended)

Run the container with your workspace mounted:

```bash
docker run -it --rm \
  -v $(pwd):/workspace \
  -u builder \
  taiwan-contour:latest
```

### Running Make Commands Directly

```bash
docker run --rm \
  -v $(pwd):/workspace \
  -u builder \
  taiwan-contour:latest \
  make taiwan-lite-contour-mix
```

### Running as Root (if needed)

```bash
docker run -it --rm \
  -v $(pwd):/workspace \
  -u root \
  taiwan-contour:latest
```

## Using the Builder User

The container includes a user called `builder` with sudo permissions:

- **Username**: `builder`
- **Password**: `builder`
- **Sudo**: Enabled (passwordless)

### Switch to Builder User (if running as root)

```bash
su - builder
cd /workspace
```

### Use Sudo as Builder

```bash
sudo apt-get update
sudo apt-get install <package>
```

## Docker Compose (Optional)

The `docker-compose.yml` file is already configured to use your host user's UID/GID.

Set your user ID in environment (or it will default to 1000):

```bash
export USER_ID=$(id -u)
export GROUP_ID=$(id -g)
```

Run with:

```bash
docker-compose run --rm taiwan-contour
```

Or in one command:

```bash
USER_ID=$(id -u) GROUP_ID=$(id -g) docker-compose run --rm taiwan-contour
```

## Installed Tools

The Docker image includes:

- **GDAL Tools**: gdal_contour, gdal_translate, gdal_merge.py, gdal_calc.py, gdalwarp
- **OSM Tools**: osmium-tool, osmconvert, pyhgtmap
- **Python 3** with packages:
  - pyosmium
  - ogr2osm
  - pyhgtmap
  - numpy
  - GDAL Python bindings
- **Archive Tools**: 7z (p7zip-full), unzip
- **Build Tools**: make, gcc, g++

## Example Workflow

```bash
# Build the image with your user ID
docker build \
  --build-arg USER_ID=$(id -u) \
  --build-arg GROUP_ID=$(id -g) \
  -t taiwan-contour:latest .

# Or Rebuild withou caches
docker build --no-cache \
  --build-arg USER_ID=$(id -u) \
  --build-arg GROUP_ID=$(id -g) \
  -t taiwan-contour:latest .

# Run interactively
docker run -it --rm -v $(pwd):/workspace -u builder taiwan-contour:latest

# Inside container, run make commands
make taiwan-lite-contour-mix
make drops

# Or use docker-compose
USER_ID=$(id -u) GROUP_ID=$(id -g) docker-compose run --rm taiwan-contour
```

## Troubleshooting

### Permission Issues

The Dockerfile now supports matching your host user's UID/GID. **Always build with your user ID:**

```bash
docker build \
  --build-arg USER_ID=$(id -u) \
  --build-arg GROUP_ID=$(id -g) \
  -t taiwan-contour:latest .
```

If you already built the image without the correct UID/GID, rebuild it with the command above.

Alternatively, you can run as your host user directly (without the builder user):

```bash
# Run as your host user ID
docker run -it --rm \
  -v $(pwd):/workspace \
  -u $(id -u):$(id -g) \
  taiwan-contour:latest
```

### Memory Issues

For large builds, you may need to increase Docker's memory limit:

```bash
# Add memory limit (e.g., 8GB)
docker run -it --rm \
  -v $(pwd):/workspace \
  -u builder \
  --memory=8g \
  taiwan-contour:latest
```

## Clean Up

Remove the image:

```bash
docker rmi taiwan-contour:latest
```

Remove all build artifacts:

```bash
make clean
```
