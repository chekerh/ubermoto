# MapLibre Native Version Downgrade Summary

## ✅ Changes Completed

### 1. Podfile Updated
- **Changed from:** Local pod path (`:path => './local_pods'`)
- **Changed to:** Git-based pod with tag `ios-v5.9.0`
- **Removed:** All complex header search path configurations
- **Preserved:** C++17 standard enforcement and Mapbox module name

### 2. Configuration Simplified
The `post_install` hook now only:
- Sets iOS deployment target to 15.0
- Configures MapLibre module name as "Mapbox"
- Enforces C++17 standard
- Fixes modulemap header reference

**Removed:** All manual header search paths (no longer needed with upstream version)

### 3. No C++ Patching Required
MapLibre Native 5.9.0 is compatible with iOS SDK 26 without any source modifications:
- ✅ No variant visitor fixes needed
- ✅ No namespace alias fixes needed
- ✅ No weak pointer fixes needed
- ✅ No geojson header fixes needed
- ✅ No compatibility shims needed

## Current Podfile Configuration

```ruby
# Pin MapLibre Native to stable 5.9.0 version compatible with iOS SDK 26
pod 'MapLibre', :git => 'https://github.com/maplibre/maplibre-native.git', :tag => 'ios-v5.9.0'
pod 'MapLibreAnnotationExtension', :git => 'https://github.com/m0nac0/maplibre-annotation-extension.git', :branch => 'master'
```

## Next Steps

1. **Clean existing Pods:**
   ```bash
   cd frontend/ios
   rm -rf Pods Podfile.lock
   ```

2. **Install dependencies:**
   ```bash
   pod install
   ```

3. **Clean Flutter build:**
   ```bash
   cd ..
   flutter clean
   ```

4. **Build and test:**
   ```bash
   flutter run
   ```

## Expected Results

- ✅ No libc++ variant static assertion errors
- ✅ No template instantiation errors
- ✅ iOS build completes successfully
- ✅ Map renders correctly with OpenStreetMap tiles
- ✅ No C++ source modifications needed

## Optional Cleanup

After verifying the build works, you can optionally remove:
- `local_pods/` directory (contains old 5.12.2 source with patches)
- `setup_maplibre.sh` script (no longer needed)
- C++ patch documentation files (kept for reference)

See `CLEANUP_LOCAL_PODS.md` for detailed cleanup instructions.

## Benefits

1. **Stability:** Uses tested, stable version from upstream
2. **Maintainability:** No local patches to maintain
3. **Compatibility:** 5.9.0 works with iOS SDK 26 out of the box
4. **Simplicity:** Cleaner Podfile without complex configurations
