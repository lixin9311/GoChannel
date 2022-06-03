#
# Be sure to run `pod lib lint GoChannel.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
    s.name             = 'GoChannel'
    s.version          = '0.1.0'
    s.summary          = 'Golang like channel in swift.'
  
  # This description is used to generate tags and improve search results.
  #   * Think: What does it do? Why did you write it? What is the focus?
  #   * Try to keep it short, snappy and to the point.
  #   * Write the description between the DESC delimiters below.
  #   * Finally, don't worry about the indent, CocoaPods strips it!
  
    s.description      = <<-DESC
  TODO: Add long description of the pod here.
                         DESC
  
    s.homepage         = 'https://github.com/lixin9311/GoChannel'
    # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
    s.license          = { :type => 'MIT', :file => 'LICENSE' }
    s.author           = { 'lucas lee' => 'lixin9311@gmail.com' }
    s.source           = { :git => 'https://github.com/lixin9311/GoChannel.git', :tag => s.version.to_s }
    # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'
  
    s.platforms = { :ios => "8.0", :osx => "10.7", :watchos => "2.0", :tvos => "9.0" }
    s.osx.deployment_target = "10.10"
  
    s.source_files = 'Sources/GoChannel/**/*'
  
    # s.resource_bundles = {
    #   'GoChannel' => ['GoChannel/Assets/*.png']
    # }
  
    # s.public_header_files = 'Pod/Classes/**/*.h'
    # s.frameworks = 'Cocoa'
    # s.dependency 'AFNetworking', '~> 2.3'
  end
  