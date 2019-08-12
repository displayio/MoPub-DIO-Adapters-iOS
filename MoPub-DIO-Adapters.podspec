#
# Be sure to run `pod lib lint MoPub-DIO-Adapters.podspec' to ensure this is a
# valid spec before submitting.
#

Pod::Spec.new do |s|
    s.name             = 'MoPub-DIO-Adapters'
    s.version          = '1.0.1'
    s.summary          = 'DIO Adapters for mediating through MoPub.'
    s.homepage         = 'https://www.display.io/'
    s.license          = { :type => 'New BSD', :file => 'LICENSE' }
    s.author           = { 'Ariel Malka' => 'arielm@display.io' }
    s.source           = { :git => "https://github.com/artin3/MoPub-DIO-Adapters.git", :tag => "#{s.version}"}
    s.ios.deployment_target = '11.0'
    s.static_framework = true
    # s.dependency 'DIOSDK', '2.3.0'
    # s.dependency 'mopub-ios-sdk/Core', '~> 5.6'
    # s.source_files = 'DIOMopubInterstitialAdapter.m'
    # s.ios.source_files = 'DIOMopubInterstitialAdapter.m'
    # #s.ios.source_files = 'Classes/DIOMopubInterstitialAdapter.h', 'Classes/DIOMopubInterstitialAdapter.m'
    s.subspec 'MoPub' do |ms|
       ms.dependency 'mopub-ios-sdk/Core', '~> 5.6'
    end

    s.subspec 'Network' do |ns|
        ns.source_files = 'Classes/*.{h,m}'
        ns.dependency 'DIOSDK', '2.3.0'
        ns.dependency 'mopub-ios-sdk/Core', '~> 5.6'
    end
end
