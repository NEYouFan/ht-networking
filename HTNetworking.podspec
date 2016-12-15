Pod::Spec.new do |s|
  s.name         = "HTNetworking"
  s.version      = "0.2.0"
  s.summary      = "HTNetworking is a high level request util based on AFNetworking and RestKit."
  s.homepage     = "https://github.com/NEYouFan/HTNetworking"
  s.license      = "Apache License, Version 2.0"
  s.source        = { :git => "https://github.com/NEYouFan/HTNetworking.git", :tag => "v#{s.version}"}
  s.author        = { "wlp" => "hzwangliping@corp.netease.com" }
  s.requires_arc  = true

  # Platform setup
  s.ios.deployment_target = '7.0'

  # TODO: Currently it does not support osx as it depends HTCommonUtility and HTCommonUtility doesn't support osx.
  # s.osx.deployment_target = '10.8'

    # Add Core Data to the PCH if the Core Data subspec is imported. This enables conditional compilation to kick in.
  s.prefix_header_contents = <<-EOS
#if __has_include("RKCoreData.h")
    #import <CoreData/CoreData.h>
#endif
EOS

  # Preserve the layout of headers in the Code directory. HTHttp/HTHttp下的文件夹保持原有的文件夹组织结构
  #s.header_mappings_dir = 'HTHttp/HTHttp'

  s.subspec 'HT' do |ht|
    ht.name = 'HT'
    ht.dependency       'HTNetworking/HTRestKit'
    ht.header_mappings_dir = 'HTHttp/HTHttp'
    #ht.default_subspec = 'PublicHeaders'

    ht.subspec 'PublicHeaders' do |htp|
      htp.source_files = 'HTHttp/HTHttp/HThttp/HTNetworking.h', 
                         'HTHttp/HTHttp/HThttp/HTAutoBaseRequest.h', 
                         'HTHttp/HTHttp/HThttp/HTBaseRequest.h',
                         'HTHttp/HTHttp/HThttp/HTHTTPModel.h',
                         'HTHttp/HTHttp/HThttp/NSObject+HTModel.h'
      htp.header_mappings_dir = 'HTHttp/HTHttp/HTHttp'
      htp.dependency 'HTNetworking/HT/Core'
    end

    ht.subspec 'Core' do |hto|
      hto.source_files   = 'HTHttp/HTHttp/HThttp/Core/*.{h,m}'
      hto.dependency 'HTNetworking/HT/Cache'
      hto.dependency 'HTNetworking/HT/Freeze'
      hto.dependency 'HTNetworking/HT/RACSupport'
      hto.dependency 'HTNetworking/HT/Support'
      hto.dependency 'AFDownloadRequestOperation', '~> 2.0'
    end

    ht.subspec 'Cache' do |htc|
      htc.source_files   = 'HTHttp/HTHttp/HThttp/Cache/*.{h,m}'
      htc.dependency 'HTNetworking/HT/Support'
      htc.dependency 'FMDB'
      htc.dependency 'HTCommonUtility', '~> 0.0.1'
    end

    ht.subspec 'Freeze' do |htf|
      htf.source_files   = 'HTHttp/HTHttp/HThttp/Freeze/*.{h,m}'
      htf.dependency 'HTNetworking/HT/Cache'
    end

    ht.subspec 'RACSupport' do |htr|
      htr.source_files = 'HTHttp/HTHttp/HThttp/RACSupport/*.{h,m}'
      htr.dependency 'ReactiveCocoa', '2.1.8'
      htr.dependency 'HTCommonUtility', '~> 0.0.1'
      htr.dependency 'HTNetworking/HT/Support'
    end

    ht.subspec 'Support' do |hts|
      hts.source_files = 'HTHttp/HTHttp/HThttp/Support/*.{h,m}'
      hts.dependency 'HTCommonUtility', '~> 0.0.1'
    end

  end

  s.subspec 'HTRestKit' do |rs|
    rs.name = 'HTRestKit'
    #rs.default_subspec = 'Core'

    # Preserve the layout of headers in the 'HTHttp/RestKit/Code' directory and map to header_dir 'RestKit'
    rs.header_mappings_dir = 'HTHttp/RestKit/Code'
    rs.header_dir = 'RestKit'

    rs.subspec 'Core' do |cs|
      cs.dependency 'HTNetworking/HTRestKit/ObjectMapping'
      cs.dependency 'HTNetworking/HTRestKit/Network'
      cs.dependency 'HTNetworking/HTRestKit/CoreData'
    end

    rs.subspec 'ObjectMapping' do |os|
      os.source_files   = 'HTHTTP/RestKit/Code/ObjectMapping.h', 'HTHTTP/RestKit/Code/ObjectMapping/**/*'
      os.dependency       'HTNetworking/HTRestKit/Support'
      os.dependency       'RKValueTransformers', '~> 1.1.0'
      os.dependency       'ISO8601DateFormatterValueTransformer', '~> 0.6.1'
    end

    rs.subspec 'Network' do |ns|
      ns.source_files   = 'HTHTTP/RestKit/Code/Network.h', 'HTHTTP/RestKit/Code/Network/**/*'
      ns.ios.frameworks = 'CFNetwork', 'Security', 'MobileCoreServices', 'SystemConfiguration'
      ns.osx.frameworks = 'CoreServices', 'Security', 'SystemConfiguration'
      ns.dependency       'SOCKit'
      ns.dependency       "AFNetworking", "2.6.2"
      ns.dependency       'HTNetworking/HTRestKit/ObjectMapping'
      ns.dependency       'HTNetworking/HTRestKit/Support'

      ns.prefix_header_contents = <<-EOS
#import <Availability.h>
#define _AFNETWORKING_PIN_SSL_CERTIFICATES_
#if __IPHONE_OS_VERSION_MIN_REQUIRED
  #import <SystemConfiguration/SystemConfiguration.h>
  #import <MobileCoreServices/MobileCoreServices.h>
  #import <Security/Security.h>
#else
  #import <SystemConfiguration/SystemConfiguration.h>
  #import <CoreServices/CoreServices.h>
  #import <Security/Security.h>
#endif
EOS
    end

    rs.subspec 'CoreData' do |cdos|
      cdos.source_files = 'HTHTTP/RestKit/Code/CoreData.h', 'HTHTTP/RestKit/Code/CoreData/**/*'
      cdos.frameworks   = 'CoreData'
      cdos.dependency 'HTNetworking/HTRestKit/ObjectMapping'
    end

    rs.subspec 'Testing' do |ts|
      ts.source_files = 'HTHTTP/RestKit/Code/Testing.h', 'HTHTTP/RestKit/Code/Testing'
      ts.dependency 'HTNetworking/HTRestKit/Network'
      ts.prefix_header_contents = <<-EOS
#import <Availability.h>
#define _AFNETWORKING_PIN_SSL_CERTIFICATES_
#if __IPHONE_OS_VERSION_MIN_REQUIRED
  #import <SystemConfiguration/SystemConfiguration.h>
  #import <MobileCoreServices/MobileCoreServices.h>
  #import <Security/Security.h>
#else
  #import <SystemConfiguration/SystemConfiguration.h>
  #import <CoreServices/CoreServices.h>
  #import <Security/Security.h>
#endif
EOS
    end

    rs.subspec 'Search' do |ss|
      ss.source_files   = 'HTHTTP/RestKit/Code/Search.h', 'HTHTTP/RestKit/Code/Search'
      ss.dependency 'HTNetworking/HTRestKit/CoreData'
    end

    rs.subspec 'Support' do |ss|
      ss.source_files   = 'HTHTTP/RestKit/Code/RestKit.h', 'HTHTTP/RestKit/Code/Support.h', 'HTHTTP/RestKit/Code/Support'
      ss.dependency 'TransitionKit', '~> 2.1.0'
    end

    rs.subspec 'CocoaLumberjack' do |cl|
      cl.source_files = 'HTHTTP/RestKit/Code/CocoaLumberjack/RKLumberjackLogger.*'
      cl.dependency 'CocoaLumberjack'
      cl.dependency 'HTNetworking/HTRestKit/Support'
  end
  
  end


end