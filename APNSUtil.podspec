#
# Be sure to run `pod lib lint APNSUtil.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'APNSUtil'
  s.version          = '1.0.0'
  s.summary          = 'APNSUtil is makes code simple using apple push notification service.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = 'APNSUtil is makes code simple using apple push notification service.'

  s.homepage         = 'https://github.com/pisces/APNSUtil'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'pisces' => 'hh963103@gmail.com' }
  s.source           = { :git => 'https://github.com/pisces/APNSUtil.git', :tag => s.version.to_s }

  s.ios.deployment_target = '9.0'

  s.source_files = 'APNSUtil/Classes/**/*'
  s.dependency 'ObjectMapper', '~> 2.0'
end
