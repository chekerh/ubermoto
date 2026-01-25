Pod::Spec.new do |s|
  s.name             = 'MapLibre'
  s.version          = '5.12.2'
  s.summary          = 'Open source vector map solution for iOS with full styling capabilities'
  s.description      = 'MapLibre GL Native is a complete open source alternative to Mapbox GL Native. It is a vector map solution for iOS with full styling capabilities.'
  s.homepage         = 'https://maplibre.org'
  s.license          = { :type => 'BSD' }
  s.author           = { 'MapLibre' => 'info@maplibre.org' }
  
  # Use git source with specific tag - no local C++ patches needed
  # This podspec wraps the git source to provide the correct pod name (MapLibre)
  # Version 5.12.2 is required by maplibre_gl Flutter plugin and MapLibreAnnotationExtension
  s.source           = { 
    :git => 'https://github.com/maplibre/maplibre-native.git', 
    :tag => 'ios-v5.12.2'
  }
  
  s.platform         = :ios, '13.0'
  s.ios.deployment_target = '13.0'
  s.requires_arc     = true
  
  # Source files from the git repository (paths relative to repo root)
  s.source_files     = 'platform/ios/platform/ios/src/**/*.{h,m,mm}', 'platform/ios/platform/darwin/src/**/*.{h,m,mm}'
  s.exclude_files    = 'platform/ios/platform/darwin/src/headless_backend_cgl.mm', '**/headless_backend_cgl.mm'
  s.public_header_files = 'platform/ios/platform/ios/src/**/*.h', 'platform/ios/platform/darwin/src/**/*.h'
  
  # Vendored frameworks (XCFrameworks) containing the compiled C++ core
  # These should exist in the git repository at platform/ios/vendor/
  s.vendored_frameworks = 'platform/ios/vendor/*.xcframework'
  
  s.frameworks       = 'UIKit', 'CoreLocation', 'QuartzCore', 'OpenGLES', 'CoreGraphics', 'SystemConfiguration'
  s.libraries        = 'c++', 'z'
  
  # MapLibre uses "Mapbox" as the module name for compatibility with maplibre_gl Flutter plugin
  s.module_name      = 'Mapbox'
  
  # Create MapLibre.h header alias and modulemap for module compatibility
  s.prepare_command = <<-CMD
    mkdir -p Headers
    if [ -f platform/ios/platform/ios/src/Mapbox.h ]; then
      cp platform/ios/platform/ios/src/Mapbox.h Headers/MapLibre.h
      cp platform/ios/platform/ios/src/Mapbox.h Headers/Mapbox.h
    fi
    # Create modulemap directly (since we can't reliably copy from podspec directory)
    cat > Headers/module.modulemap <<'MODULEMAP'
framework module Mapbox {
    umbrella header "Mapbox.h"
    export *
    module * { export * }
}
MODULEMAP
  CMD
  
  # Use explicit modulemap to ensure Mapbox module is properly exposed
  s.module_map = 'Headers/module.modulemap'
  
  # C++17 standard and extensive header search paths required for building from source
  s.pod_target_xcconfig = {
    'DEFINES_MODULE' => 'YES',
    'SWIFT_INCLUDE_PATHS' => '$(inherited)',
    'CLANG_ENABLE_MODULES' => 'YES',
    'HEADER_SEARCH_PATHS' => '$(inherited) "$(PODS_TARGET_SRCROOT)/Headers" "$(PODS_TARGET_SRCROOT)/platform/ios/platform/ios/src" "$(PODS_TARGET_SRCROOT)/platform/ios/platform/darwin/src" "$(PODS_TARGET_SRCROOT)/platform/ios/platform/darwin/include" "$(PODS_TARGET_SRCROOT)/platform/darwin/include" "$(PODS_TARGET_SRCROOT)/platform/ios/platform/ios/vendor/SMCalloutView" "$(PODS_TARGET_SRCROOT)/platform/default/include" "$(PODS_TARGET_SRCROOT)/platform/default/src" "$(PODS_TARGET_SRCROOT)/include" "$(PODS_TARGET_SRCROOT)/src" "$(PODS_TARGET_SRCROOT)/vendor" "$(PODS_TARGET_SRCROOT)/vendor/mapbox-base/include" "$(PODS_TARGET_SRCROOT)/vendor/mapbox-base/include/mapbox/std" "$(PODS_TARGET_SRCROOT)/vendor/mapbox-base/include/mapbox/geometry" "$(PODS_TARGET_SRCROOT)/vendor/mapbox-base/include/mapbox/util" "$(PODS_TARGET_SRCROOT)/vendor/mapbox-base/deps/geometry.hpp/include"',
    'USER_HEADER_SEARCH_PATHS' => '$(inherited) "$(PODS_TARGET_SRCROOT)/platform/ios/platform/ios/src" "$(PODS_TARGET_SRCROOT)/platform/ios/platform/darwin/src" "$(PODS_TARGET_SRCROOT)/platform/ios/platform/darwin/include" "$(PODS_TARGET_SRCROOT)/platform/darwin/include" "$(PODS_TARGET_SRCROOT)/platform/ios/platform/ios/vendor/SMCalloutView" "$(PODS_TARGET_SRCROOT)/platform/default/include" "$(PODS_TARGET_SRCROOT)/platform/default/src" "$(PODS_TARGET_SRCROOT)/include" "$(PODS_TARGET_SRCROOT)/src" "$(PODS_TARGET_SRCROOT)/vendor" "$(PODS_TARGET_SRCROOT)/vendor/mapbox-base/include" "$(PODS_TARGET_SRCROOT)/vendor/mapbox-base/include/mapbox/std" "$(PODS_TARGET_SRCROOT)/vendor/mapbox-base/include/mapbox/geometry" "$(PODS_TARGET_SRCROOT)/vendor/mapbox-base/include/mapbox/util"',
    'CLANG_CXX_LANGUAGE_STANDARD' => 'c++17',
    'CLANG_CXX_LIBRARY' => 'libc++'
  }
end
