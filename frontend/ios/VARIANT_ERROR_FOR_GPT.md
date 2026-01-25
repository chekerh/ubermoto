# Variant Type Error Explanation for GPT

## Current Error

**Error**: `Static assertion failed due to requirement 'value != __not_found': type not found in type list`
**Location**: `/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator26.2.sdk/usr/include/c++/v1/__tuple/find_index.h:43:16`

## Problem Analysis

This error occurs when `std::get<T>()` is called on a `std::variant` with a type `T` that is **not** in the variant's type list. The error happens at compile time during template instantiation.

## Context

We're using a compatibility shim for `mapbox::util::variant` that wraps `std::variant`. The error is likely occurring in:

1. **The `comparer` visitor** in `mapbox/util/detail/variant_visitor.hpp` - used for variant equality comparison
2. **The `value::operator==`** in `mapbox/feature.hpp` - compares two `value` objects (which inherit from `value_base`, a variant)

## Root Cause

The `comparer` visitor's `operator()` template is being instantiated for **all types** that `std::visit` might call it with. However, when we call `std::get<T>()` inside the operator, the compiler tries to verify that `T` is in the variant's type list **at compile time**, even if that particular instantiation would never be called at runtime.

The issue is that `std::visit` will only call the visitor with types that are actually in the variant, but the template instantiation happens for all possible types, and `std::get<T>()` requires `T` to be in the variant's type list.

## Current Implementation

```cpp
template <typename T>
bool operator()(const T& rhs) const {
    using base_type = typename Variant::variant_type;
    return comp(std::get<T>(static_cast<const base_type&>(lhs)), rhs);
}
```

This fails because `std::get<T>()` is instantiated even when `T` might not be in the variant's type list.

## What GPT Should Do

1. **Use SFINAE (Substitution Failure Is Not An Error)** to prevent template instantiation when `T` is not in the variant:
   - Use `std::holds_alternative<T>` check, but this still requires `T` to be in the type list
   - Better: Use a helper that only allows `std::get<T>()` when `T` is actually in the variant's type list

2. **Alternative approach**: Since `std::visit` only calls the visitor with the actual type held, we can use a different pattern:
   - Use `std::visit` with a lambda that directly accesses the value
   - Or use a type-safe getter that checks the variant index first

3. **Best solution**: Modify the `comparer` to use `std::visit` on `lhs` as well, matching the type from `rhs`:
   ```cpp
   template <typename T>
   bool operator()(const T& rhs) const {
       return std::visit([&](const auto& lhs_val) {
           if constexpr (std::is_same_v<std::decay_t<decltype(lhs_val)>, T>) {
               return comp(lhs_val, rhs);
           }
           return false;
       }, static_cast<const typename Variant::variant_type&>(lhs));
   }
   ```

4. **Or simpler**: Since we've already checked `lhs.which() == rhs.which()`, we know they hold the same type. We can use the variant's index to get the value safely.

## Files to Modify

- `frontend/ios/local_pods/maplibre-native/vendor/mapbox-base/include/mapbox/util/detail/variant_visitor.hpp` - Fix the `comparer::operator()`

## Testing

After fixing, run:
```bash
cd frontend/ios && pod install
cd .. && flutter run
```

The error should be resolved if the template instantiation is properly constrained.
