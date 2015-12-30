Pod::Spec.new do |s|
  s.name         = "DMAddressPickerView"
  s.version      = "0.0.1"
  s.summary      = ""
  s.description  = ""
  s.homepage     = "https://github.com/caojun/DMAddressPickerView"

  s.license      = { :type => "MIT", :file => "LICENSE" }

  s.author       = { "caojun" => "caojengineer@126.com" }

  s.platform    = :ios
  s.platform    = :ios, "7.0"

  s.source       = { :git => "https://github.com/caojun/DMAddressPickerView.git", :tag => s.version.to_s }

  s.source_files  = 'DMForwardAnimation/*.{h,m,xib,json}'
  s.exclude_files = "DMForwardAnimation/Exclude"

  s.requires_arc = true

end