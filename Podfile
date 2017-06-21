# Uncomment this line to define a global platform for your project
#platform :ios, '10.3'

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['ENABLE_BITCODE'] = 'NO'
            config.build_settings['SWIFT_VERSION'] = '3.0'
        end
    end
end

target 'ChatApp' do
  # Comment this line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for ChatApp
  pod 'Firebase', '~> 3.9'
  pod 'Firebase/AdMob'
  pod 'FirebaseAuth', '~> 3.0'
  pod 'FirebaseDatabase', '~> 3.1'
  pod 'Firebase/RemoteConfig'
  pod 'FirebaseStorage', '~> 1.0'
  pod 'FirebaseCore', '~> 3.4'
  pod 'Firebase/Messaging'
  pod 'SwiftLoader'
  pod 'SDWebImage', ' >= 3.8'
  pod 'Alamofire', '~> 4.0.1’
  pod 'ReachabilitySwift', '~> 3.0' 
  pod 'NVActivityIndicatorView','~> 3.0'
  pod 'SVPullToRefresh'
 
end
