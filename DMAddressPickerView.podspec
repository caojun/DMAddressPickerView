Pod::Spec.new do |s|
  s.name         = "DMAddressPickerView"
  s.version      = “0.0.4”
  s.summary      = "地址选择器"
  s.description  = ""
  s.homepage     = "https://github.com/caojun/DMAddressPickerView"

  s.license      = { :type => "MIT", :file => "LICENSE" }

  s.author       = { "caojun" => "caojengineer@126.com" }

  s.platform    = :ios
  s.platform    = :ios, "7.0"

  s.source       = { :git => "https://github.com/caojun/DMAddressPickerView.git", :tag => s.version.to_s }

  s.source_files  = 'DMAddressPickerView/*.{h,m}'
  s.exclude_files = "DMAddressPickerView/Exclude"
  s.resource      = 'DMAddressPickerView/*.{xib,json}'

  s.requires_arc = true

end
