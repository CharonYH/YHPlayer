#
# Be sure to run `pod lib lint YHPlayer.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'YHPlayer'
  s.version          = '0.1.1'
  s.summary          = 'An easy-to-use video player based on swift language'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: The player provides a simple API and Delegate, and supports placeholder image for the first frame of the video.
                       DESC

  s.homepage         = 'https://github.com/CharonYH/YHPlayer'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'YEHAN' => '2436567084@qq.com' }
  s.source           = { :git => 'https://github.com/CharonYH/YHPlayer.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'
  s.swift_version = "5.0"
  s.ios.deployment_target = '11.0'

  s.source_files = 'YHPlayer/Classes/**/*'
  
  # s.resource_bundles = {
  #   'YHPlayer' => ['YHPlayer/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  s.dependency 'SnapKit'
end
