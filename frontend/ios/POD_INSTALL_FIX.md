# iOS Pod Install Fix

## Issue
If you encounter the error:
```
[!] Unable to find a specification for `MapLibreAnnotationExtension (~> 0.0.1-beta.2)` depended upon by `maplibre_gl`
```

This occurs because the CocoaPods specs repository is out of date and doesn't have the MapLibreAnnotationExtension pod specification.

## Solution

Run the following commands to update CocoaPods specs and install pods:

```bash
cd frontend/ios
pod repo update
pod install
```

**Note:** The `pod repo update` command may take several minutes as it downloads the latest pod specifications.

## Alternative Solution

If `pod repo update` fails due to network issues, try:

```bash
cd frontend/ios
rm -rf Pods Podfile.lock
pod install --repo-update
```

The `--repo-update` flag will update the specs repository during installation.

## After Fix

Once the CocoaPods specs repository is updated, `pod install` should complete successfully and the MapLibreAnnotationExtension dependency will be resolved automatically by maplibre_gl.
