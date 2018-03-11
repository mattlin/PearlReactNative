require "json"

package = JSON.parse(File.read(File.join(__dir__, "package.json")))
version = package['version']

source = { :git => 'https://github.com/facebook/react-native.git' }
if version == '1000.0.0'
  # This is an unpublished version, use the latest commit hash of the react-native repo, which we’re presumably in.
  source[:commit] = `git rev-parse HEAD`.strip
else
  source[:tag] = "v#{version}"
end

folly_compiler_flags = '-DFOLLY_NO_CONFIG -DFOLLY_MOBILE=1 -DFOLLY_USE_LIBCPP=1'

Pod::Spec.new do |s|
  s.name                    = "PearlReactNative"
  s.version                 = version
  s.summary                 = package["description"]
  s.description             = <<-DESC
                                React Native apps are built using the React JS
                                framework, and render directly to native UIKit
                                elements using a fully asynchronous architecture.
                                There is no browser and no HTML. We have picked what
                                we think is the best set of features from these and
                                other technologies to build what we hope to become
                                the best product development framework available,
                                with an emphasis on iteration speed, developer
                                delight, continuity of technology, and absolutely
                                beautiful and fast products with no compromises in
                                quality or capability.
                             DESC
  s.homepage                = "http://facebook.github.io/react-native/"
  s.license                 = package["license"]
  s.author                  = "Facebook"
  s.source                  = source
  s.default_subspec         = "Core"
  s.requires_arc            = true
  s.platforms               = { :ios => "8.0", :tvos => "9.2" }
  s.pod_target_xcconfig     = { "CLANG_CXX_LANGUAGE_STANDARD" => "c++14" }
  s.preserve_paths          = "package.json", "LICENSE", "LICENSE-docs", "PATENTS"
  s.cocoapods_version       = ">= 1.2.0"

  s.subspec "Core" do |ss|
    ss.dependency             "yoga", "#{package["version"]}.React"
    ss.source_files         = "PearlReactNative/react-native/React/**/*.{c,h,m,mm,S,cpp}"
    ss.exclude_files        = "**/__tests__/*",
                              "PearlReactNative/react-native/IntegrationTests/*",
                              "PearlReactNative/react-native/React/DevSupport/*",
                              "PearlReactNative/react-native/React/Inspector/*",
                              "PearlReactNative/react-native/ReactCommon/yoga/*",
                              "PearlReactNative/react-native/React/Cxx*/*",
                              "PearlReactNative/react-native/React/Base/RCTBatchedBridge.mm",
                              "PearlReactNative/react-native/React/Executors/*"
    ss.ios.exclude_files    = "PearlReactNative/react-native/React/**/RCTTV*.*"
    ss.tvos.exclude_files   = "PearlReactNative/react-native/React/Modules/RCTClipboard*",
                              "PearlReactNative/react-native/React/Views/RCTDatePicker*",
                              "PearlReactNative/react-native/React/Views/RCTPicker*",
                              "PearlReactNative/react-native/React/Views/RCTRefreshControl*",
                              "PearlReactNative/react-native/React/Views/RCTSlider*",
                              "PearlReactNative/react-native/React/Views/RCTSwitch*",
                              "PearlReactNative/react-native/React/Views/RCTWebView*"
    ss.header_dir           = "PearlReactNative/react-native/React"
    ss.framework            = "JavaScriptCore"
    ss.libraries            = "stdc++"
    ss.pod_target_xcconfig  = { "HEADER_SEARCH_PATHS" => "\"$(PODS_TARGET_SRCROOT)/PearlReactNative/react-native/ReactCommon\"" }
  end

  s.subspec "BatchedBridge" do |ss|
    ss.dependency             "PearlReactNative/react-native/React/Core"
    ss.dependency             "PearlReactNative/react-native/React/cxxreact_legacy"
    ss.source_files         = "PearlReactNative/react-native/React/Base/RCTBatchedBridge.mm", "PearlReactNative/react-native/React/Executors/*"
  end

  s.subspec "CxxBridge" do |ss|
    ss.dependency             "Folly", "2016.09.26.00"
    ss.dependency             "PearlReactNative/react-native/React/Core"
    ss.dependency             "PearlReactNative/react-native/React/cxxreact"
    ss.compiler_flags       = folly_compiler_flags
    ss.private_header_files = "PearlReactNative/react-native/React/Cxx*/*.h"
    ss.source_files         = "PearlReactNative/react-native/React/Cxx*/*.{h,m,mm}"
  end

  s.subspec "DevSupport" do |ss|
    ss.dependency             "PearlReactNative/react-native/React/Core"
    ss.dependency             "PearlReactNative/react-native/React/RCTWebSocket"
    ss.source_files         = "PearlReactNative/react-native/React/DevSupport/*",
                              "PearlReactNative/react-native/React/Inspector/*"
  end

  s.subspec "tvOS" do |ss|
    ss.dependency             "PearlReactNative/react-native/React/Core"
    ss.source_files         = "PearlReactNative/react-native/React/**/RCTTV*.{h, m}"
  end

  s.subspec "jschelpers_legacy" do |ss|
    ss.source_files         = "PearlReactNative/react-native/ReactCommon/jschelpers/{JavaScriptCore,JSCWrapper}.{cpp,h}", "PearlReactNative/react-native/ReactCommon/jschelpers/systemJSCWrapper.cpp"
    ss.private_header_files = "PearlReactNative/react-native/ReactCommon/jschelpers/{JavaScriptCore,JSCWrapper}.h"
    ss.pod_target_xcconfig  = { "HEADER_SEARCH_PATHS" => "\"$(PODS_TARGET_SRCROOT)/PearlReactNative/react-native/ReactCommon\"" }
    ss.framework            = "JavaScriptCore"
  end

  s.subspec "jsinspector_legacy" do |ss|
    ss.source_files         = "PearlReactNative/react-native/ReactCommon/jsinspector/{InspectorInterfaces}.{cpp,h}"
    ss.private_header_files = "PearlReactNative/react-native/ReactCommon/jsinspector/{InspectorInterfaces}.h"
    ss.pod_target_xcconfig  = { "HEADER_SEARCH_PATHS" => "\"$(PODS_TARGET_SRCROOT)/PearlReactNative/react-native/ReactCommon\"" }
  end

  s.subspec "cxxreact_legacy" do |ss|
    ss.dependency             "PearlReactNative/react-native/React/jschelpers_legacy"
    ss.dependency             "PearlReactNative/react-native/React/jsinspector_legacy"
    ss.source_files         = "PearlReactNative/react-native/ReactCommon/cxxreact/{JSBundleType,oss-compat-util}.{cpp,h}"
    ss.private_header_files = "PearlReactNative/react-native/ReactCommon/cxxreact/{JSBundleType,oss-compat-util}.h"
    ss.pod_target_xcconfig  = { "HEADER_SEARCH_PATHS" => "\"$(PODS_TARGET_SRCROOT)/PearlReactNative/react-native/ReactCommon\"" }
  end

  s.subspec "jschelpers" do |ss|
    ss.dependency             "Folly", "2016.09.26.00"
    ss.dependency             "PearlReactNative/react-native/React/PrivateDatabase"
    ss.compiler_flags       = folly_compiler_flags
    ss.source_files         = "PearlReactNative/react-native/ReactCommon/jschelpers/*.{cpp,h}"
    ss.private_header_files = "PearlReactNative/react-native/ReactCommon/jschelpers/*.h"
    ss.pod_target_xcconfig  = { "HEADER_SEARCH_PATHS" => "\"$(PODS_TARGET_SRCROOT)/PearlReactNative/react-native/ReactCommon\"" }
    ss.framework            = "JavaScriptCore"
  end

  s.subspec "jsinspector" do |ss|
    ss.source_files         = "PearlReactNative/react-native/ReactCommon/jsinspector/*.{cpp,h}"
    ss.private_header_files = "PearlReactNative/react-native/ReactCommon/jsinspector/*.h"
    ss.pod_target_xcconfig  = { "HEADER_SEARCH_PATHS" => "\"$(PODS_TARGET_SRCROOT)/PearlReactNative/react-native/ReactCommon\"" }
  end

  s.subspec "PrivateDatabase" do |ss|
    ss.source_files         = "PearlReactNative/react-native/ReactCommon/privatedata/*.{cpp,h}"
    ss.private_header_files = "PearlReactNative/react-native/ReactCommon/privatedata/*.h"
    ss.pod_target_xcconfig  = { "HEADER_SEARCH_PATHS" => "\"$(PODS_TARGET_SRCROOT)/PearlReactNative/react-native/ReactCommon\"" }
  end

  s.subspec "cxxreact" do |ss|
    ss.dependency             "PearlReactNative/react-native/React/jschelpers"
    ss.dependency             "PearlReactNative/react-native/React/jsinspector"
    ss.dependency             "boost"
    ss.dependency             "Folly", "2016.09.26.00"
    ss.compiler_flags       = folly_compiler_flags
    ss.source_files         = "PearlReactNative/react-native/ReactCommon/cxxreact/*.{cpp,h}"
    ss.exclude_files        = "PearlReactNative/react-native/ReactCommon/cxxreact/SampleCxxModule.*"
    ss.private_header_files = "PearlReactNative/react-native/ReactCommon/cxxreact/*.h"
    ss.pod_target_xcconfig  = { "HEADER_SEARCH_PATHS" => "\"$(PODS_TARGET_SRCROOT)/PearlReactNative/react-native/ReactCommon\" \"$(PODS_ROOT)/boost\" \"$(PODS_ROOT)/DoubleConversion\" \"$(PODS_ROOT)/Folly\"" }
  end

  s.subspec "ART" do |ss|
    ss.dependency             "PearlReactNative/react-native/React/Core"
    ss.source_files         = "PearlReactNative/react-native/Libraries/ART/**/*.{h,m}"
  end

  s.subspec "RCTActionSheet" do |ss|
    ss.dependency             "PearlReactNative/react-native/React/Core"
    ss.source_files         = "PearlReactNative/react-native/Libraries/ActionSheetIOS/*.{h,m}"
  end

  s.subspec "RCTAnimation" do |ss|
    ss.dependency             "PearlReactNative/react-native/React/Core"
    ss.source_files         = "PearlReactNative/react-native/Libraries/NativeAnimation/{Drivers/*,Nodes/*,*}.{h,m}"
    ss.header_dir           = "RCTAnimation"
  end

  s.subspec "RCTBlob" do |ss|
    ss.dependency             "PearlReactNative/react-native/React/Core"
    ss.source_files         = "PearlReactNative/react-native/Libraries/Blob/*.{h,m}"
    ss.preserve_paths       = "PearlReactNative/react-native/Libraries/Blob/*.js"
  end

  s.subspec "RCTCameraRoll" do |ss|
    ss.dependency             "PearlReactNative/react-native/React/Core"
    ss.dependency             'PearlReactNative/react-native/React/RCTImage'
    ss.source_files         = "PearlReactNative/react-native/Libraries/CameraRoll/*.{h,m}"
  end

  s.subspec "RCTGeolocation" do |ss|
    ss.dependency             "PearlReactNative/react-native/React/Core"
    ss.source_files         = "PearlReactNative/react-native/Libraries/Geolocation/*.{h,m}"
  end

  s.subspec "RCTImage" do |ss|
    ss.dependency             "PearlReactNative/react-native/React/Core"
    ss.dependency             "PearlReactNative/react-native/React/RCTNetwork"
    ss.source_files         = "PearlReactNative/react-native/Libraries/Image/*.{h,m}"
  end

  s.subspec "RCTNetwork" do |ss|
    ss.dependency             "PearlReactNative/react-native/React/Core"
    ss.source_files         = "PearlReactNative/react-native/Libraries/Network/*.{h,m,mm}"
  end

  s.subspec "RCTPushNotification" do |ss|
    ss.dependency             "PearlReactNative/react-native/React/Core"
    ss.source_files         = "PearlReactNative/react-native/Libraries/PushNotificationIOS/*.{h,m}"
  end

  s.subspec "RCTSettings" do |ss|
    ss.dependency             "PearlReactNative/react-native/React/Core"
    ss.source_files         = "PearlReactNative/react-native/Libraries/Settings/*.{h,m}"
  end

  s.subspec "RCTText" do |ss|
    ss.dependency             "PearlReactNative/react-native/React/Core"
    ss.source_files         = "PearlReactNative/react-native/Libraries/Text/*.{h,m}"
  end

  s.subspec "RCTVibration" do |ss|
    ss.dependency             "PearlReactNative/react-native/React/Core"
    ss.source_files         = "PearlReactNative/react-native/Libraries/Vibration/*.{h,m}"
  end

  s.subspec "RCTWebSocket" do |ss|
    ss.dependency             "PearlReactNative/react-native/React/Core"
    ss.dependency             "PearlReactNative/react-native/React/RCTBlob"
    ss.dependency             "PearlReactNative/react-native/React/fishhook"
    ss.source_files         = "PearlReactNative/react-native/Libraries/WebSocket/*.{h,m}"
  end

  s.subspec "fishhook" do |ss|
    ss.header_dir           = "fishhook"
    ss.source_files         = "PearlReactNative/react-native/Libraries/fishhook/*.{h,c}"
  end

  s.subspec "RCTLinkingIOS" do |ss|
    ss.dependency             "PearlReactNative/react-native/React/Core"
    ss.source_files         = "PearlReactNative/react-native/Libraries/LinkingIOS/*.{h,m}"
  end

  s.subspec "RCTTest" do |ss|
    ss.dependency             "PearlReactNative/react-native/React/Core"
    ss.source_files         = "PearlReactNative/react-native/Libraries/RCTTest/**/*.{h,m}"
    ss.frameworks           = "XCTest"
  end

  s.subspec "_ignore_me_subspec_for_linting_" do |ss|
    ss.dependency             "PearlReactNative/react-native/React/Core"
    ss.dependency             "PearlReactNative/react-native/React/CxxBridge"
  end
end
