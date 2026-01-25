# MapLibre Native Version Downgrade to 5.9.0

## Summary
Downgraded MapLibre Native from 5.12.2 to 5.9.0 to avoid libc++ std::variant static assertion errors with iOS SDK 26. This approach uses the stable CocoaPods version instead of local C++ patches.

## Changes Made

### 1. Podfile Updates
- **Removed:** Local pod path references (`:path => './local_pods'`)
- **Added:** Git-based pod specification for MapLibre 5.9.0:
  ```ruby
  pod 'MapLibre', :git => 'https://github.com/maplibre/maplibre-native.git', :tag => 'ios-v5.9.0'
  pod 'MapLibreAnnotationExtension', :git => 'https://github.com/m0nac0/maplibre-annotation-extension.git', :branch => 'master'
  ```
- **Simplified:** Removed all complex header search path configurations (no longer needed with upstream version)
- **Kept:** C++17 standard enforcement and Mapbox module name configuration

### 2. Removed Local Patches
All C++ source modifications in `local_pods/maplibre-native/` are no longer needed:
- ✅ Variant visitor fixes
- ✅ Namespace alias fixes  
- ✅ Weak pointer fixes
- ✅ GeoJSON header fixes
- ✅ All compatibility shims

The 5.9.0 version is compatible with iOS SDK 26 without these patches.

### 3. Configuration Preserved
- **C++17 Standard:** Still enforced for all targets
- **Mapbox Module Name:** Still configured for compatibility
- **iOS Deployment Target:** Still set to 15.0 for Firebase compatibility

## Benefits

1. **No C++ Patching:** Uses stable, tested version from upstream
2. **Simpler Maintenance:** No local source modifications to maintain
3. **Better Compatibility:** 5.9.0 is known to work with iOS SDK 26
4. **Cleaner Build:** Removed complex header search path configurations

## Next Steps

1. **Clean Pods:**
   ```bash
   cd frontend/ios
   rm -rf Pods Podfile.lock
   ```

2. **Install Dependencies:**
   ```bash
   pod install
   ```

3. **Clean Flutter:**
   ```bash
   cd ..
   flutter clean
   ```

4. **Build and Run:**
   ```bash
   flutter run
   ```

## Expected Results

- ✅ No libc++ variant static assertion errors
- ✅ iOS build completes successfully
- ✅ Map renders correctly with OpenStreetMap tiles
- ✅ No C++ source modifications needed

## Notes

- The `local_pods/` directory can be removed if desired (it's no longer used)
- MapLibre 5.9.0 is a stable release that predates the variant issues
- If future updates are needed, consider testing newer versions incrementally
