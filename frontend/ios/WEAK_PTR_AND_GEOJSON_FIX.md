# Weak Pointer and GeoJSON Header Fix

## Summary
Fixed two critical issues:
1. **weak_ptr misuse** in `scheduler.hpp` - corrected improper usage of `std::weak_ptr`
2. **Missing geojson.hpp** - created compatibility shim for `mapbox::geojson` namespace

## Issue 1: Weak Pointer Misuse

### Problem
In `mbgl/actor/scheduler.hpp`, the `scheduleAndReplyValue` method was incorrectly using `weak_ptr`:
- Line 97: `auto lock = replyScheduler.lock();` - gets shared_ptr but doesn't use it
- Line 98: `if (!replyScheduler) return;` - checks weak_ptr instead of locked shared_ptr
- Line 100: `replyScheduler->schedule(...)` - tries to use weak_ptr as pointer (invalid)

### Fix
Changed to proper `lock()` pattern:
```cpp
if (auto locked = replyScheduler.lock()) {
    auto scheduledReply = [reply, result = task()] { reply(result); };
    locked->schedule(std::move(scheduledReply));
}
```

### File Modified
- `include/mbgl/actor/scheduler.hpp` (lines 96-101)

## Issue 2: Missing geojson.hpp Header

### Problem
MapLibre Native expects `#include <mapbox/geojson.hpp>` but this file was missing from the vendor directory, causing:
- `'mapbox/geojson.hpp' file not found` compilation errors

### Root Cause
The `geojson.hpp` dependency from `mapbox-base` was not present in the local pods structure. MapLibre uses:
- `mapbox::geojson::geojson` - variant type for GeoJSON
- `mapbox::geojson::feature_collection` - feature collection type

### Fix
Created compatibility shim `vendor/mapbox-base/include/mapbox/geojson.hpp` that:
- Defines `mapbox::geojson` namespace
- Provides `geojson` as a variant of feature/feature_collection
- Provides `feature_collection` type alias
- Uses existing `mapbox::feature` and `mapbox::geometry` types

### File Created
- `vendor/mapbox-base/include/mapbox/geojson.hpp`

## Implementation Details

### geojson.hpp Structure
```cpp
namespace mapbox {
namespace geojson {
    using geojson = mapbox::util::variant<
        mapbox::feature::feature<double>,
        mapbox::feature::feature_collection<double>
    >;
    using feature_collection = mapbox::feature::feature_collection<double>;
}
}
```

This provides the types that `mbgl/util/geojson.hpp` expects:
- `mapbox::geojson::geojson` → `GeoJSON`
- `mapbox::geojson::feature_collection` → `FeatureCollection`

## Verification

After these fixes:
1. Clean Pods: `cd frontend/ios && rm -rf Pods Podfile.lock && pod install`
2. Clean Flutter: `cd frontend && flutter clean`
3. Build: `flutter run`

Expected result:
- No weak_ptr misuse errors
- No missing geojson.hpp errors
- iOS build completes successfully
