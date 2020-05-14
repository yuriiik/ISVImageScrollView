#
# Be sure to run `pod lib lint ISVImageScrollView.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'ISVImageScrollView'
  s.version          = '0.2.0'
  s.summary          = 'A subclass of the UIScrollView tweaked for image preview with zooming, scrolling and rotation support.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
When you need to incorporate an image preview into your application, usually you start with the UIScrollView and then spend hours tweaking it to get functionality similar to the default Photos app.
This control provides you out-of-the-box functionality to zoom, scroll and rotate an UIImageView attached to it.
                       DESC

  s.homepage         = 'https://github.com/yuriiik/ISVImageScrollView'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Yurii Kupratsevych' => 'kupratsevich@gmail.com' }
  s.source           = { :git => 'https://github.com/yuriiik/ISVImageScrollView.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.source_files = 'Sources/ISVImageScrollView/**/*'
  
  # s.resource_bundles = {
  #   'ISVImageScrollView' => ['ISVImageScrollView/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
