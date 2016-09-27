Pod::Spec.new do |s|

  s.name         = "JYHHHorizontalPagingView"
  s.version      = "1.0.2"
  s.summary      = "对HHHorizontalPagingView的优化，解决headerView 的点击痛点, 修复10.0系统下的Bug"

  s.homepage     = "https://github.com/weijingyunIOS/HHHorizontalPagingView"

  s.license      = "MIT"

  s.author             = { "魏景云" => "wei_jingyun@outlook.com" }
  s.platform     = :ios
  s.ios.deployment_target = "7.0"
  s.source       = { :git => "https://github.com/weijingyunIOS/HHHorizontalPagingView.git",:branch => "master", :tag => "1.0.2" }
  s.requires_arc = true
  s.source_files  = "HHHorizontalPagingView/*.{h,m}"

  s.framework  = "UIKit","Foundation"

end
