# iOS Pod Install Fix

## Issue
If you encounter the error:
```
[!] Unable to find a specification for `MapLibreAnnotationExtension (~> 0.0.1-beta.2)` depended upon by `maplibre_gl`
```

This occurs because `MapLibreAnnotationExtension` is not available in the CocoaPods trunk repository. The Podfile has been configured to fetch it directly from GitHub.

## Solution

The Podfile is already configured to fetch `MapLibreAnnotationExtension` from GitHub. Simply run:

```bash
cd frontend/ios
pod install
```

## Permission Error Fix

If you encounter:
```
[!] Failed to download 'MapLibreAnnotationExtension': Operation not permitted @ rb_sysopen - /Users/mac/Library/Caches/CocoaPods/Pods/VERSION
```

This is a CocoaPods cache permission issue. Fix it by:

1. **Fix cache permissions (recommended):**
   ```bash
   sudo chown -R $(whoami) ~/Library/Caches/CocoaPods
   cd frontend/ios
   pod install
   ```

2. **Or remove and recreate cache:**
   ```bash
   rm -rf ~/Library/Caches/CocoaPods
   cd frontend/ios
   pod install
   ```

3. **If permission errors persist, try:**
   ```bash
   # Clear CocoaPods cache completely
   pod cache clean --all
   rm -rf ~/Library/Caches/CocoaPods
   rm -rf ~/Library/Developer/Xcode/DerivedData
   cd frontend/ios
   rm -rf Pods Podfile.lock
   pod install
   ```

**Note:** The Podfile is configured to fetch `MapLibreAnnotationExtension` from GitHub. Once permissions are fixed, `pod install` should complete successfully.

## Verification

After successful installation, you should see `MapLibreAnnotationExtension` in your `Pods` directory and the build should complete without errors.
