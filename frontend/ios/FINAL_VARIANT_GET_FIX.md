# Final Variant get() Method Fix

## Summary
Fixed the root cause of remaining static assertion errors by replacing `std::get<U>()` calls in `mapbox::util::variant::get()` methods with safe `std::visit`-based implementations.

## Problem
The `mapbox::util::variant::get<U>()` methods were still using `std::get<U>(*this)` directly. When these methods were called from templated code paths, the compiler would instantiate `std::get<U>()` for all possible types `U`, even if `U` wasn't in the variant's type list, causing static assertion failures.

## Root Cause
In `vendor/mapbox-base/include/mapbox/variant.hpp`, lines 51-59:
```cpp
template <typename U>
U& get() {
    return std::get<U>(*this);  // ❌ Direct std::get causes template instantiation
}
```

This was being called from:
- `custom_geometry_tile.cpp`: `geoJSON.get<FeatureCollection>()`
- `geojson_source_impl.cpp`: `geoJSON.get<Features>()`
- `vector_source.cpp`: `urlOrTileset.get<std::string>()`, `urlOrTileset.get<Tileset>()`
- `raster_source.cpp`: Similar patterns

## Fix Applied

### File: `vendor/mapbox-base/include/mapbox/variant.hpp`

**Changed `get<U>()` methods to use `match()` internally:**

```cpp
// Before (unsafe):
template <typename U>
U& get() {
    return std::get<U>(*this);
}

// After (safe):
template <typename U>
U& get() {
    U* result = nullptr;
    this->match(
        [&](U& val) { result = &val; },
        [](auto&) { /* not U */ }
    );
    if (!result) {
        throw std::bad_variant_access();
    }
    return *result;
}
```

**Key Benefits:**
1. **No template instantiation for invalid types** - `match()` only instantiates lambdas for types actually present in the variant
2. **Same API** - Existing code calling `.get<U>()` continues to work
3. **Proper error handling** - Throws `std::bad_variant_access` if type not found (matching std::variant behavior)

## Impact

All `.get<T>()` calls throughout MapLibre Native now go through the safe implementation:
- `custom_geometry_tile.cpp`: `geoJSON.get<FeatureCollection>()` ✅ Safe
- `geojson_source_impl.cpp`: `geoJSON.get<Features>()` ✅ Safe  
- `vector_source.cpp`: `urlOrTileset.get<std::string>()` ✅ Safe
- `raster_source.cpp`: Similar calls ✅ Safe

## Verification

After this fix:
1. Clean Pods: `cd frontend/ios && rm -rf Pods Podfile.lock && pod install`
2. Clean Flutter: `cd frontend && flutter clean`
3. Build: `flutter run`

Expected result:
- ✅ No `__tuple/find_index.h` static assertion errors
- ✅ No template instantiation errors for types not in variant
- ✅ iOS build completes successfully
- ✅ App launches on simulator

## Notes

- The `match()` method internally uses `std::visit` with `overloaded` helper, which is safe
- This fix preserves the exact same API surface, so no code changes are needed elsewhere
- Error behavior matches `std::variant::get()` - throws `std::bad_variant_access` for invalid types
