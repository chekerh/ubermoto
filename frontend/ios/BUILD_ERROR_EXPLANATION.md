# Build Error Explanation for GPT

## Current Error State

The iOS build is failing with **two missing header file errors**:

### Error 1: Missing `mbgl/interface/native_apple_interface.h`
- **Location**: `MGLNetworkConfiguration_Private.h:1:9`
- **File exists at**: `local_pods/maplibre-native/platform/darwin/include/mbgl/interface/native_apple_interface.h`
- **Problem**: The header search paths don't include `platform/darwin/include`
- **Solution**: Add `platform/darwin/include` to `HEADER_SEARCH_PATHS` in Podfile's `post_install` hook

### Error 2: Missing `SMCalloutView.h`
- **Location**: `MGLCompactCalloutView.h:0:8`
- **Problem**: `SMCalloutView` is a third-party dependency (from https://github.com/nfarina/calloutview) that's not included in the Podfile
- **Solution**: Add `pod 'SMCalloutView'` to the Podfile, or find if it's bundled in MapLibre and add the correct path

## Context

We're building a Flutter app that uses MapLibre GL Native (open-source alternative to Mapbox) via the `maplibre_gl` Flutter package. MapLibre is being built from local source files in `frontend/ios/local_pods/maplibre-native/`.

## What GPT Should Do

**STATUS: FIXES HAVE BEEN APPLIED**

1. ✅ **Added the missing header search path** for `platform/darwin/include`:
   - Added `darwin_platform_include_path` to Podfile
   - Added it to both `HEADER_SEARCH_PATHS` and `USER_HEADER_SEARCH_PATHS` for the MapLibre target
   - Also added to MapLibre.podspec

2. ✅ **Resolved SMCalloutView dependency**:
   - Found that SMCalloutView is bundled in MapLibre at `platform/ios/platform/ios/vendor/SMCalloutView/`
   - Added `smcallout_vendor_path` to Podfile header search paths
   - Also added to MapLibre.podspec

3. **Next Steps**:
   - Run `cd frontend/ios && pod install` to apply the Podfile changes
   - Then run `flutter run` to test the build
   - If errors persist, check that the paths are correctly resolved relative to `installer.sandbox.root`

## Files to Modify

- `frontend/ios/Podfile` - Add header search paths and potentially add SMCalloutView pod

## Current Podfile Structure

The Podfile already has extensive header search path configuration in the `post_install` hook for the MapLibre target. The missing path is `platform/darwin/include` which contains the `mbgl/interface/` headers.
