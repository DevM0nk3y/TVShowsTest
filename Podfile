# Uncomment the next line to define a global platform for your project
platform :ios, '13.0'

target 'TVShowsTest' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!
  
    pod 'SDWebImage'


end
post_install do |installer_representation|
  installer_representation.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '11.0'
    end
  end
end