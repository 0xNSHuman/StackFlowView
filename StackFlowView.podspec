Pod::Spec.new do |s|

  s.name         = "StackFlowView"
  s.version      = "1.0.0"
  s.summary      = "Enforcing stack order for custom UI elements"

  s.homepage     = "https://github.com/vladaverin24/StackFlowView"
  s.screenshots  = "https://raw.githubusercontent.com/vladaverin24/StackFlowView/master/Screenshots/two_stacks.gif", "https://github.com/vladaverin24/StackFlowView/raw/master/Screenshots/cards_stack.gif", "https://raw.githubusercontent.com/vladaverin24/StackFlowView/master/Screenshots/stack_of_stacks.gif"

  s.license      = { :type => "MIT", :file => "LICENSE.md" }

  s.author             = { "Vlad Averin" => "hello@vladaverin.me" }
  s.social_media_url   = "http://facebook.com/vaverin"

  s.platform     = :ios
  s.ios.deployment_target = "8.0"

  s.source       = { :git => "https://github.com/vladaverin24/StackFlowView.git", :tag => "v1.0.1" }

  s.source_files  = "StackFlowView", "StackFlowView/**/*.swift"

  s.frameworks  = "UIKit"

  s.requires_arc = true
  s.pod_target_xcconfig = { 'OTHER_SWIFT_FLAGS[config=Debug]' => '-D DEBUG' }

end
