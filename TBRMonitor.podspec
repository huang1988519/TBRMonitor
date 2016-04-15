
Pod::Spec.new do |s|
  s.name         = "TBRMonitor"
  s.version      = "0.0.1"
  s.summary      = "The monitor of iOS app performance."
  s.description  = <<-DESC
                   ios应用性能监控，暂时只支持>监听电量，网络异常，cpu，ram
                   DESC

  s.homepage     = "http://huang1988519.github.io/TBRMonitor"
  s.license      = "MIT"
  s.author             = { "huangwh" => "huang1988519@126.com" }

  s.platform     = :ios, "7.0"
  s.ios.deployment_target = "7.0"

  s.source       = { :git => "https://github.com/huang1988519/TBRMonitor.git", :tag => s.version }
  #s.source_files  = 'TBRMonitor/TBRMonitor.{h,m}', 'TBRMonitorFramework/', 'TBRMonitorFramework/TBRCatogory/', 'TBRMonitorFramework/TBRElectricity', 'TBRMonitorFramework/TBRMemory', 'TBRMonitorFramework/TBRURL/'
  s.source_files  = 'TBRMonitor/**/*', 'TBRMonitorFramework/**/*'
  s.exclude_files = "Classes/Exclude"
  s.public_header_files = "TBRMonitor/TBRMonitor.h"
end
