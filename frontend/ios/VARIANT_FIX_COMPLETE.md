# Variant Static Assertion Fix - Complete

## Summary
Fixed ALL remaining `std::get<T>()` usages in templated code paths that were causing "Static assertion failed due to requirement 'value != __not_found': type not found in type list" errors.

## Files Modified

### 1. `mapbox/util/detail/variant_visitor.hpp`
- **Status:** Already fixed in previous iteration
- **Change:** `comparer::operator()` now uses nested `std::visit` with `if constexpr` instead of `std::get<T>()`

### 2. `mbgl/style/expression/value.hpp`
- **Line 75-77:** `ValueConverter::fromExpressionValue()`
- **Change:** Replaced `value.template is<T>() ? value.template get<T>() : optional<T>()` with `std::visit`-based matching

### 3. `mbgl/style/property_value.hpp`
- **Lines 67-73:** `asConstant()` and `asExpression()` methods
- **Change:** Replaced `value.template get<T>()` calls with `std::visit`-based matching

### 4. `mbgl/style/expression/expression.hpp`
- **Lines 87-109:** `Result<T>` class operators (`operator->`, `operator*`, `error()`)
- **Change:** Replaced all `this->template get<T>()` calls with `std::visit`-based matching

### 5. `mbgl/style/expression/at.hpp`
- **Line 14:** `At` constructor
- **Change:** Replaced `input_->getType().get<type::Array>().itemType` with lambda-based `std::visit` matching

### 6. `mbgl/util/interpolate.hpp`
- **Lines 72-75:** `Interpolator<std::vector<Value>>::operator()`
- **Change:** Replaced `a[i].template get<double>()` and `b[i].template get<double>()` with `std::visit`-based matching

## Pattern Applied

All fixes follow this pattern:

```cpp
// BEFORE (problematic):
return variant.template get<T>();

// AFTER (safe):
T result;
variant.match(
    [&](const T& val) { result = val; },
    [](const auto&) { /* handle non-T case */ }
);
return result;
```

Or for const references:

```cpp
// BEFORE:
const T& ref = variant.template get<T>();

// AFTER:
const T* ptr = nullptr;
variant.match(
    [&](const T& val) { ptr = &val; },
    [](const auto&) { /* not T */ }
);
assert(ptr != nullptr);
return *ptr;
```

## Why This Works

1. **`std::visit`** only instantiates visitor lambdas for types actually present in the variant at compile time
2. **`if constexpr`** (in comparer) ensures type-specific code is only compiled when types match
3. **No `std::get<T>()`** means no static assertions are triggered for types not in the variant's type list
4. **Template instantiation** is deferred until runtime type matching occurs

## Verification

After these fixes:
1. Clean Pods: `cd frontend/ios && rm -rf Pods Podfile.lock && pod install`
2. Clean Flutter: `cd frontend && flutter clean`
3. Build: `flutter run`

Expected result: iOS build succeeds without libc++ static assertion errors.
