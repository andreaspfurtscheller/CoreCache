Pod::Spec.new do |s|

  s.name             = 'CoreCache'
  s.version          = '0.1.0'
  s.summary          = 'CoreCache provides a leightweight wrapper for Apple\'s complex CoreData
                        framework.'

  s.description      = 'CoreCache provides wrappers for CoreData as well as a performant image cache.'

  s.homepage         = 'https://github.com/borchero/CoreCache'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'borchero' => 'oliver.borchert@in.tum.de' }
  s.source           = { :git => 'https://github.com/borchero/CoreCache.git', :tag => s.version.to_s }

  s.ios.deployment_target = '9.0'

  s.source_files = 'CoreCache/**/*'

  s.frameworks = 'UIKit'

  s.dependency 'CorePromises'
  s.dependency 'Alamofire'
  s.dependency 'AlamofireImage'
  s.dependency 'CoreUtility'

end
