# MapLibre Setup Instructions

## Current Issue
MapLibre pod is not being installed properly, causing "No such module 'Mapbox'" errors.

## Root Cause
The local podspec references source files from git that aren't being downloaded. MapLibre needs to be built from source or use a pre-built framework.

## Solution Options

### Option 1: Download Source Files (Recommended after restarting Terminal)

1. **Restart Terminal completely** (Full Disk Access requires restart)
2. Run the setup script:
   ```bash
   cd frontend/ios
   ./setup_maplibre.sh
   ```
3. Then run:
   ```bash
   pod install
   ```

### Option 2: Use IndoorAtlas Specs Repo

If you have network access, try:
```bash
cd frontend/ios
pod repo update indooratlas-maplibre-specs
pod install
```

### Option 3: Manual Framework Installation

If the above don't work, MapLibre might need to be installed as a pre-built framework. Check the maplibre-gl-native-distribution repository for XCFramework downloads.

## Current Configuration

- Podfile: Configured to use local podspec or specs repo
- Local podspec: Points to local source files (needs setup_maplibre.sh to run)
- Module name: Set to "Mapbox" for compatibility

## Next Steps

1. **Restart Terminal** (critical for Full Disk Access)
2. Run `./setup_maplibre.sh` to download MapLibre source
3. Run `pod install`
4. Try building again
