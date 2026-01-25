# Mapbox Namespace Alias Fix

## Summary
Fixed missing `mapbox::std` and `mapbox::base` namespace aliases that were causing compilation errors.

## Problem
The iOS build was failing with errors like:
- `No member named 'base' in namespace 'mapbox'`
- `No template named 'vector' in namespace 'mapbox::std'`
- `No member named 'move' in namespace 'mapbox::std'`

## Root Cause
MapLibre Native expects `mapbox::std` to be a namespace alias to `::std`, and `mapbox::base` to be available for compatibility types. These aliases were missing or not properly included.

## Files Created/Modified

### 1. `vendor/mapbox-base/include/mapbox/std.hpp` (NEW)
- **Purpose:** Defines `mapbox::std` as a namespace alias to `::std`
- **Content:** `namespace mapbox { namespace std = ::std; }`
- **Includes:** Common std headers (vector, memory, utility, etc.)

### 2. `vendor/mapbox-base/include/mapbox/std/weak.hpp` (MODIFIED)
- **Change:** Changed `mapbox::std::weak_ptr` from a custom class to a type alias
- **Reason:** Cannot have both a namespace alias (`mapbox::std = ::std`) and a class definition in the same namespace
- **New Implementation:** `template <typename T> using weak_ptr = ::std::weak_ptr<T>;`

### 3. `vendor/mapbox-base/include/mapbox/base.hpp` (NEW)
- **Purpose:** Convenience header to ensure `mapbox::base` namespace is available
- **Includes:** `mapbox/compatibility/base.hpp` and `mapbox/compatibility/value.hpp`
- **Note:** `mapbox::base` is already defined in compatibility headers, this ensures it's accessible

### 4. `include/mbgl/style/layer.hpp` (MODIFIED)
- **Added includes:**
  - `#include <mapbox/std.hpp>` - Ensures `mapbox::std` alias is available
  - `#include <mapbox/base.hpp>` - Ensures `mapbox::base` namespace is available

### 5. `include/mbgl/util/feature.hpp` (MODIFIED)
- **Added include:** `#include <mapbox/base.hpp>` - Ensures `mapbox::base` types are available

### 6. `include/mbgl/actor/scheduler.hpp` (MODIFIED)
- **Added includes:**
  - `#include <mapbox/std.hpp>` - Ensures `mapbox::std` alias is available
  - `#include <mapbox/base.hpp>` - Ensures `mapbox::base` namespace is available

## Namespace Structure

```cpp
namespace mapbox {
    namespace std = ::std;  // Alias to standard library
    namespace base {        // Compatibility types
        // Types defined in compatibility/base.hpp and compatibility/value.hpp
    }
}
```

## Why This Works

1. **Namespace Alias:** `namespace mapbox { namespace std = ::std; }` makes `mapbox::std::vector`, `mapbox::std::move`, etc. work correctly
2. **Type Alias:** `using weak_ptr = ::std::weak_ptr<T>` allows `mapbox::std::weak_ptr` to work while maintaining the namespace alias
3. **Forward Includes:** Including `mapbox/std.hpp` and `mapbox/base.hpp` ensures aliases are available before use

## Verification

After these fixes:
1. Clean Pods: `cd frontend/ios && rm -rf Pods Podfile.lock && pod install`
2. Clean Flutter: `cd frontend && flutter clean`
3. Build: `flutter run`

Expected result: No more "mapbox::std" or "mapbox::base" namespace errors.
