Pod::Spec.new do |s|
  s.name         = "PAssert"
  s.version      = "0.1.0"
  s.summary      = "Power Assert inspired debug tool in Swift"
  s.homepage     = "https://github.com/keygx/PAssert"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author             = { "keygx" => "y.kagiyama@gmail.com" }
  s.social_media_url   = "http://twitter.com/keygx"
  s.platform     = :ios
  s.ios.deployment_target = '8.0'
  s.source       = { :git => "https://github.com/keygx/PAssert.git", :tag => "#{s.version}" }
  s.source_files  = "Source/*"
  s.requires_arc = true
end
