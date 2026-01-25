Pod::Spec.new do |s|
  s.name             = 'MapLibreAnnotationExtension'
  s.version          = '0.0.1-beta.2'
  s.summary          = 'Framework extensions for MapLibre Maps SDK for iOS'
  s.description      = 'Framework extensions that can be used with the Maplibre Maps SDK for iOS.'
  s.homepage         = 'https://github.com/m0nac0/maplibre-annotation-extension'
  s.license          = { :type => 'BSD' }
  s.author           = { 'MapLibre' => 'info@maplibre.org' }
  s.source           = { :path => '.' }
  s.platform         = :ios, '13.0'
  s.requires_arc     = true
  s.source_files     = 'maplibre-annotation-extension/MapboxAnnotationExtension/**/*.{h,m,swift}'
  s.public_header_files = 'maplibre-annotation-extension/MapboxAnnotationExtension/**/*.h'
  s.frameworks       = 'UIKit', 'CoreLocation'
  s.dependency       'MapLibre', '~> 5.12.0'
end
