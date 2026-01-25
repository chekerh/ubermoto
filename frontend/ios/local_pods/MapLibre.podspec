Pod::Spec.new do |s|
  s.name             = 'MapLibre'
  s.version          = '5.12.2'
  s.summary          = 'Open source vector map solution for iOS with full styling capabilities'
  s.description      = 'MapLibre GL Native is a complete open source alternative to Mapbox GL Native. It is a vector map solution for iOS with full styling capabilities.'
  s.homepage         = 'https://maplibre.org'
  s.license          = { :type => 'BSD' }
  s.author           = { 'MapLibre' => 'info@maplibre.org' }
  s.source           = { :path => '.' }
  s.platform         = :ios, '13.0'
  s.requires_arc     = true
  s.source_files     = 'maplibre-native/platform/ios/platform/ios/src/**/*.{h,m,mm}', 'maplibre-native/platform/ios/platform/darwin/src/**/*.{h,m,mm}'
  s.exclude_files    = 'maplibre-native/platform/ios/platform/darwin/src/headless_backend_cgl.mm', '**/headless_backend_cgl.mm'
  s.public_header_files = 'maplibre-native/platform/ios/platform/ios/src/**/*.h', 'maplibre-native/platform/ios/platform/darwin/src/**/*.h'
  s.frameworks       = 'UIKit', 'CoreLocation', 'QuartzCore', 'OpenGLES', 'CoreGraphics', 'SystemConfiguration'
  s.libraries        = 'c++', 'z'
  # Vendored frameworks not available - building from source
  # s.vendored_frameworks = 'maplibre-native/platform/ios/vendor/*.xcframework'
  # MapLibre uses "Mapbox" as the module name for compatibility
  s.module_name      = 'Mapbox'
  # Create MapLibre.h as alias to Mapbox.h for CocoaPods modulemap generation
  s.prepare_command = <<-CMD
    mkdir -p Headers
    cp maplibre-native/platform/ios/platform/ios/src/Mapbox.h Headers/MapLibre.h
    cp maplibre-native/platform/ios/platform/ios/src/Mapbox.h Headers/Mapbox.h
    cp MapLibre.modulemap Headers/module.modulemap
  CMD
  # Use the modulemap in Headers directory
  s.module_map       = 'Headers/module.modulemap'
  # Ensure the module is properly exposed
  s.pod_target_xcconfig = {
    'DEFINES_MODULE' => 'YES',
    'SWIFT_INCLUDE_PATHS' => '$(inherited)',
    'CLANG_ENABLE_MODULES' => 'YES',
    'MODULEMAP_FILE' => '$(PODS_TARGET_SRCROOT)/Headers/module.modulemap',
                'HEADER_SEARCH_PATHS' => '$(inherited) "$(PODS_TARGET_SRCROOT)/Headers" "$(PODS_TARGET_SRCROOT)/maplibre-native/platform/ios/platform/ios/src" "$(PODS_TARGET_SRCROOT)/maplibre-native/platform/ios/platform/darwin/src" "$(PODS_TARGET_SRCROOT)/maplibre-native/platform/ios/platform/darwin/include" "$(PODS_TARGET_SRCROOT)/maplibre-native/platform/darwin/include" "$(PODS_TARGET_SRCROOT)/maplibre-native/platform/ios/platform/ios/vendor/SMCalloutView" "$(PODS_TARGET_SRCROOT)/maplibre-native/platform/default/include" "$(PODS_TARGET_SRCROOT)/maplibre-native/platform/default/src" "$(PODS_TARGET_SRCROOT)/maplibre-native/include" "$(PODS_TARGET_SRCROOT)/maplibre-native/src" "$(PODS_TARGET_SRCROOT)/maplibre-native/vendor" "$(PODS_TARGET_SRCROOT)/maplibre-native/vendor/mapbox-base/include" "$(PODS_TARGET_SRCROOT)/maplibre-native/vendor/mapbox-base/include/mapbox/std" "$(PODS_TARGET_SRCROOT)/maplibre-native/vendor/mapbox-base/include/mapbox/geometry" "$(PODS_TARGET_SRCROOT)/maplibre-native/vendor/mapbox-base/include/mapbox/util" "$(PODS_TARGET_SRCROOT)/maplibre-native/vendor/mapbox-base/deps/geometry.hpp/include"',
                'USER_HEADER_SEARCH_PATHS' => '$(inherited) "$(PODS_TARGET_SRCROOT)/maplibre-native/platform/ios/platform/ios/src" "$(PODS_TARGET_SRCROOT)/maplibre-native/platform/ios/platform/darwin/src" "$(PODS_TARGET_SRCROOT)/maplibre-native/platform/ios/platform/darwin/include" "$(PODS_TARGET_SRCROOT)/maplibre-native/platform/darwin/include" "$(PODS_TARGET_SRCROOT)/maplibre-native/platform/ios/platform/ios/vendor/SMCalloutView" "$(PODS_TARGET_SRCROOT)/maplibre-native/platform/default/include" "$(PODS_TARGET_SRCROOT)/maplibre-native/platform/default/src" "$(PODS_TARGET_SRCROOT)/maplibre-native/include" "$(PODS_TARGET_SRCROOT)/maplibre-native/src" "$(PODS_TARGET_SRCROOT)/maplibre-native/vendor" "$(PODS_TARGET_SRCROOT)/maplibre-native/vendor/mapbox-base/include" "$(PODS_TARGET_SRCROOT)/maplibre-native/vendor/mapbox-base/include/mapbox/std" "$(PODS_TARGET_SRCROOT)/maplibre-native/vendor/mapbox-base/include/mapbox/geometry" "$(PODS_TARGET_SRCROOT)/maplibre-native/vendor/mapbox-base/include/mapbox/util"',
    'CLANG_CXX_LANGUAGE_STANDARD' => 'c++17',
    'CLANG_CXX_LIBRARY' => 'libc++'
  }
end
