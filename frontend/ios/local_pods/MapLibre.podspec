Pod::Spec.new do |s|
  s.name             = 'MapLibre'
  s.version          = '5.12.2'
  s.summary          = 'Open source vector map solution for iOS with full styling capabilities'
  s.description      = 'MapLibre GL Native is a complete open source alternative to Mapbox GL Native. It is a vector map solution for iOS with full styling capabilities.'
  s.homepage         = 'https://maplibre.org'
  s.license          = { :type => 'BSD', :file => 'LICENSE.md' }
  s.author           = { 'MapLibre' => 'info@maplibre.org' }
  s.source           = { 
    :git => 'https://github.com/maplibre/maplibre-native.git', 
    :tag => 'ios-v5.12.0-pre.1'
  }
  s.platform         = :ios, '13.0'
  s.requires_arc     = true
  s.source_files     = 'platform/ios/src/**/*.{h,m,mm}'
  s.public_header_files = 'platform/ios/src/**/*.h'
  s.frameworks       = 'UIKit', 'CoreLocation', 'QuartzCore', 'OpenGLES', 'CoreGraphics', 'SystemConfiguration'
  s.libraries        = 'c++', 'z'
  s.vendored_frameworks = 'platform/ios/vendor/*.xcframework'
end
