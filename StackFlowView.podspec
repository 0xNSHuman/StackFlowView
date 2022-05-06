Pod::Spec.new do |s|

  s.name         = "StackFlowView"
  s.version      = "1.0.2"
  s.summary      = "Enforcing stack order for custom UI elements"

  s.homepage     = "https://github.com/0xNSHuman/StackFlowView"
  s.screenshots  = "https://raw.githubusercontent.com/0xNSHuman/StackFlowView/master/Screenshots/two_stacks.gif", "https://github.com/0xNSHuman/StackFlowView/raw/master/Screenshots/cards_stack.gif", "https://raw.githubusercontent.com/0xNSHuman/StackFlowView/master/Screenshots/stack_of_stacks.gif"

  s.license      = { :type => "MIT", :file => "LICENSE.md" }

  s.platform     = :ios
  s.ios.deployment_target = "8.0"

  s.source       = { :git => "https://github.com/0xNSHuman/StackFlowView.git", :tag => "v1.0.2" }

  s.source_files  = "StackFlowView", "StackFlowView/**/*.swift"

  s.frameworks  = "UIKit"

  s.requires_arc = true
  s.pod_target_xcconfig = { 'OTHER_SWIFT_FLAGS[config=Debug]' => '-D DEBUG' }

end
