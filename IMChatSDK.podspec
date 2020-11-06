#
# Be sure to run `pod lib lint IMChatSDK.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'IMChatSDK'
  s.version          = '1.1.6'
  s.summary          = 'Connect to custom service'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/ruilisi/IMChatSDK'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Thisismy0312' => 'qq867327466@163.com' }
  s.source           = { :git => 'https://github.com/ruilisi/IMChatSDK.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '10.0'
  s.dependency 'Starscream'
  s.dependency 'lottie-ios'
  s.dependency 'SwiftyJSON'
  s.dependency 'Kingfisher'
  s.swift_version= '5.0'

  s.source_files = ['Source/Core/*.{swift}',
                    'Source/*.{swift}',
                    'Source/API/*.{swift}',
                    'Source/Extensions/*.{swift}',
                    'Source/Uploader/*.{swift}',
                    'Source/Http/*.{swift}',
                    'Source/Views/*.{swift}']
  
  s.resource_bundles = {
   'IMChatSDK' => ['Resources/*.{xcassets,json}']
  }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
