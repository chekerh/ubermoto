# Cleanup Guide: Removing Local Pod Patches

## Summary
After downgrading to MapLibre Native 5.9.0 via CocoaPods, the `local_pods/` directory and all C++ patches are no longer needed.

## What Can Be Removed

### 1. Local Pods Directory (Optional)
The `frontend/ios/local_pods/` directory contains:
- Modified MapLibre Native source (5.12.2)
- Local podspecs
- All C++ compatibility patches

**Safe to remove:** Yes, after confirming CocoaPods installation works

### 2. C++ Patch Files (No Longer Needed)
All modifications in `local_pods/maplibre-native/` are obsolete:
- `vendor/mapbox-base/include/mapbox/variant.hpp` - variant get() fixes
- `vendor/mapbox-base/include/mapbox/util/detail/variant_visitor.hpp` - comparer fixes
- `vendor/mapbox-base/include/mapbox/std.hpp` - namespace alias
- `vendor/mapbox-base/include/mapbox/base.hpp` - base namespace
- `vendor/mapbox-base/include/mapbox/geojson.hpp` - geojson compatibility
- `vendor/mapbox-base/include/mapbox/compatibility/*` - all compatibility shims
- `include/mbgl/actor/scheduler.hpp` - weak_ptr fixes
- `include/mbgl/style/expression/*` - expression variant fixes
- All other C++ source modifications

### 3. Local Podspecs (No Longer Used)
- `local_pods/MapLibre.podspec`
- `local_pods/MapLibreAnnotationExtension.podspec`
- `local_pods/MapLibre.modulemap`

## Cleanup Steps

### Option 1: Keep for Reference (Recommended Initially)
```bash
# Just rename to backup
cd frontend/ios
mv local_pods local_pods.backup
```

### Option 2: Complete Removal (After Verification)
```bash
cd frontend/ios
rm -rf local_pods
```

## Verification Before Cleanup

1. **Test CocoaPods Installation:**
   ```bash
   cd frontend/ios
   rm -rf Pods Podfile.lock
   pod install
   ```

2. **Test Build:**
   ```bash
   cd ..
   flutter clean
   flutter run
   ```

3. **Verify Map Renders:**
   - Check that map displays correctly
   - Verify no runtime errors
   - Confirm OpenStreetMap tiles load

## After Cleanup

Once verified, you can safely remove:
- `local_pods/` directory
- `setup_maplibre.sh` script (if not needed)
- All C++ patch documentation files (optional):
  - `VARIANT_FIX_*.md`
  - `NAMESPACE_*.md`
  - `WEAK_PTR_*.md`
  - `FINAL_VARIANT_*.md`

## Benefits of Cleanup

1. **Reduced Repository Size:** Removes ~100MB+ of source code
2. **Simpler Maintenance:** No local patches to maintain
3. **Clearer Dependencies:** All dependencies come from CocoaPods
4. **Easier Updates:** Can update MapLibre version by changing Podfile
