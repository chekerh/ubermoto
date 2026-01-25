# MapLibre Podspec Fix

## Problem
CocoaPods couldn't find a podspec for `MapLibre` when pulling from git because:
1. The repository's podspec is named `Mapbox-iOS-SDK.podspec` (not `MapLibre.podspec`)
2. The podspec defines the pod as `Mapbox-iOS-SDK` (not `MapLibre`)
3. The Flutter plugin `maplibre_gl` requires a pod named `MapLibre`
4. Dependencies require MapLibre 5.12.x (maplibre_gl ~> 5.12.2, MapLibreAnnotationExtension ~> 5.12.0)

## Solution
Created a minimal local podspec wrapper (`MapLibre.podspec`) that:
- Defines the pod as `MapLibre` (required by Flutter plugin)
- Uses git source with tag `ios-v5.12.2` (required by dependencies, no C++ source patching)
- Points to source files in the git repository
- Enforces C++17 standard

## Important Notes
- **This is NOT a C++ patch** - it's just a dependency declaration (podspec file)
- The actual C++ source code comes directly from the git repository, untouched
- No local C++ modifications are made
- The podspec wraps the git source to provide the correct pod name

## Podfile Configuration
```ruby
pod 'MapLibre', :path => './MapLibre.podspec'
```

## Verification
```bash
cd frontend/ios
pod spec lint MapLibre.podspec --quick  # Should pass validation
pod install  # Should successfully install MapLibre from git tag ios-v5.9.0
```
