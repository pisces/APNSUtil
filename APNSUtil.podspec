#
# Be sure to run `pod lib lint APNSUtil.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'APNSUtil'
  s.version          = '1.1.2'
  s.summary          = 'APNSUtil is makes code simple using apple push notification service.'
  s.description      = 'APNSUtil is makes code simple using apple push notification service.'
  s.homepage         = 'https://github.com/pisces/APNSUtil'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'pisces' => 'hh963103@gmail.com' }
  s.source           = { :git => 'https://github.com/pisces/APNSUtil.git', :tag => s.version.to_s }
  s.ios.deployment_target = '9.0'
  s.source_files = 'APNSUtil/Classes/**/*'
  s.dependency 'ObjectMapper', '~> 3.1'
end
