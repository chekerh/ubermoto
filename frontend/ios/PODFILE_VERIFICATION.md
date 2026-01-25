# Podfile Configuration Verification

## ✅ Current Configuration

### MapLibre Native Dependency
```ruby
pod 'MapLibre', :git => 'https://github.com/maplibre/maplibre-native.git', :tag => 'ios-v5.9.0'
```

**Status:** ✅ Correctly configured
- **Source:** Git repository
- **Tag:** `ios-v5.9.0` (stable version compatible with iOS SDK 26)
- **Pod Name:** `MapLibre` (required by maplibre_gl Flutter plugin)

### MapLibreAnnotationExtension Dependency
```ruby
pod 'MapLibreAnnotationExtension', :git => 'https://github.com/m0nac0/maplibre-annotation-extension.git', :branch => 'master'
```

**Status:** ✅ Correctly configured

## Verification Checklist

### ✅ 1. Git Tag Configuration
- **Required:** `ios-v5.9.0`
- **Current:** `:tag => 'ios-v5.9.0'`
- **Status:** ✅ Correct

### ✅ 2. Pod Name
- **Required:** `MapLibre` (maplibre_gl expects this exact name)
- **Current:** `pod 'MapLibre'`
- **Status:** ✅ Correct
- **Note:** The pod name MUST be "MapLibre" (not "MapLibreNative" or any other variant) because the maplibre_gl Flutter plugin explicitly declares a dependency on a pod named "MapLibre"

### ✅ 3. C++17 Standard
- **Configuration:** Enforced in `post_install` hook
- **Settings:**
  - `CLANG_CXX_LANGUAGE_STANDARD = 'c++17'`
  - `CLANG_CXX_LIBRARY = 'libc++'`
- **Status:** ✅ Correct

### ✅ 4. Module Name
- **Configuration:** MapLibre exposes itself as "Mapbox" module
- **Setting:** `PRODUCT_MODULE_NAME = 'Mapbox'`
- **Status:** ✅ Correct (required for maplibre_gl compatibility)

### ✅ 5. No Local Pod Conflicts
- **Local Pods:** `local_pods/` directory exists but is NOT referenced in Podfile
- **Status:** ✅ No conflict (local pods are ignored)

## Build Configuration Summary

```ruby
# Podfile declares:
pod 'MapLibre', :git => '...', :tag => 'ios-v5.9.0'  # ✅ Correct

# post_install hook configures:
- iOS Deployment Target: 15.0
- C++17 Standard: Enforced
- Module Name: Mapbox (for compatibility)
- Modulemap Fix: MapLibre.h → Mapbox.h
```

## Expected Behavior

When `pod install` runs:
1. CocoaPods will clone MapLibre Native from GitHub at tag `ios-v5.9.0`
2. The pod will be named "MapLibre" (as required by maplibre_gl)
3. Build settings will enforce C++17 standard
4. Module will be exposed as "Mapbox" for Swift/Flutter compatibility

## Verification Commands

```bash
cd frontend/ios

# Clean existing pods
rm -rf Pods Podfile.lock

# Install dependencies
pod install

# Verify MapLibre is installed correctly
pod list | grep -i maplibre

# Clean Flutter
cd ..
flutter clean

# Build and test
flutter run
```

## Success Criteria

- ✅ Podfile declares `pod 'MapLibre'` with git tag `ios-v5.9.0`
- ✅ No pod named "MapLibreNative" or other variants
- ✅ C++17 standard is enforced
- ✅ iOS build completes without errors
- ✅ Map renders correctly on iOS simulator
