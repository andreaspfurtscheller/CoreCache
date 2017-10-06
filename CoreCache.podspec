Pod::Spec.new do |s|

  s.name             = 'CoreCache'
  s.version = '0.6.6'
  s.summary          = 'CoreCache provides a leightweight wrapper for Apple\'s complex CoreData
                        framework.'

  s.description      = 'CoreCache provides wrappers for CoreData as well as a performant image cache for use in iOS applications.'

  s.homepage         = 'https://github.com/borchero/CoreCache'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'borchero' => 'oliver.borchert@in.tum.de' }
  s.source           = { :git => 'https://github.com/borchero/CoreCache.git', :tag => s.version.to_s }

  s.ios.deployment_target = '9.0'

  s.source_files = 'CoreCache/**/*.swift',
                   'CoreCache/CoreCache/ImageCache/CCCache.xcdatamodeld',
                   'CoreCache/CoreCache/ImageCache/CCCache.xcdatamodeld/Cache.xcdatamodel',
                   'CoreCache/CoreCache/ImageCache/CCCache.xcdatamodeld/Cache.xcdatamodel/contents'

  s.frameworks = 'UIKit', 'CoreData'

  s.dependency 'CorePromises'
  s.dependency 'Alamofire'
  s.dependency 'AlamofireImage'
  s.dependency 'CoreUtility'
  s.dependency 'WebParsing'
  s.dependency 'SwiftKeychainWrapper'

  s.resources = ['CoreCache/ImageCache/CCCache.xcdatamodeld',
                 'CoreCache/ImageCache/CCCache.xcdatamodeld/Cache.xcdatamodel',
                 'CoreCache/ImageCache/CCCache.xcdatamodeld/Cache.xcdatamodel/contents']

  s.preserve_paths = 'CoreCache/ImageCache/CCCache.xcdatamodeld'

end
