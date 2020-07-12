Pod::Spec.new do |spec|
    spec.name = 'DynamicButtonStack'
    spec.module_name = 'DynamicButtonStackKit' # Module name must be different from the class name.
    spec.version = '1.1.3'
    spec.license = { :type => 'MIT', :file => 'License.txt' }
    spec.homepage = 'https://github.com/douglashill/DynamicButtonStack'
    spec.authors = { 'Douglas Hill' => 'https://twitter.com/qdoug' }
    spec.summary = 'A view that dynamically lays out a collection of buttons to suit the button content and the available space.'

    spec.description = <<-DESC
A view for UIKit apps that dynamically lays out a collection of UIButtons in either a column or a row to suit the button content and the available space.
                       DESC

    spec.source = { :git => 'https://github.com/douglashill/DynamicButtonStack.git', :tag => spec.version.to_s }
    spec.swift_version = '5.0'
    spec.ios.deployment_target  = '13.0'
    spec.source_files = 'DynamicButtonStack.swift'

end
