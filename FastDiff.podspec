Pod::Spec.new do |s|

    # 1
    s.platform = :ios
    s.ios.deployment_target = '9.0'
    s.name = "FastDiff"
    s.summary = "FastDiff is a general purpose diffing algorithm with Linear complexity O(n)"
    s.requires_arc = true
    
    # 2
    s.version = "1.0.1"
    
    # 3
    s.license = { :type => "MIT", :file => "LICENSE" }
    
    # 4 
    s.author = { "Vijaya Prakash Kandel" => "kandelvijaya@gmail.com" }
    
    # 5 
    s.homepage = "https://github.com/kandelvijaya/FastDiff"
    
    # 6 - Replace this URL with your own Git URL from "Quick Setup"
    s.source = { :git => "https://github.com/kandelvijaya/FastDiff.git", 
                 :tag => "#{s.version}" }
    
    # 7
    # s.framework = "UIKit"
    
    # 8
    s.source_files = "Sources/**/*.{swift}"
    
    # 9
    #s.resources = "RWPickFlavor/**/*.{png,jpeg,jpg,storyboard,xib,xcassets}"
    
    # 10
    s.swift_version = "4.2"
    
    end
