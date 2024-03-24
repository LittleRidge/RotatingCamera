#
# Be sure to run `pod lib lint RotatingCamera.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'RotatingCamera'
  s.version          = '1.0'
  s.summary          = 'A short description of RotatingCamera.'
  s.homepage         = 'https://github.com/LittleRidge/RotatingCamera.git'
  s.author           = { 'Евгений Сергеев' => 'bf2account@mail.ru' }
  s.source           = { :git => 'https://github.com/LittleRidge/RotatingCamera.git', :tag => s.version.to_s }

  s.ios.deployment_target = '13.0'

  s.source_files = 'Sources/RotatingCamera/**/*'
  
  s.frameworks = 'UIKit', 'AVFoundation'
  s.dependency 'SnapKit', '~> 5.0.1'
  s.dependency 'MBProgressHUD', '~> 1.2.0'
end
