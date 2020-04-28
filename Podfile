platform :ios, '11.0'
source 'https://github.com/CocoaPods/Specs.git'
use_frameworks!

def common_pods
    pod 'RxSwift', :git => 'https://github.com/ReactiveX/RxSwift.git'
#    , :branch => 'develop'
    pod 'RxCocoa', :git => 'https://github.com/ReactiveX/RxSwift.git'
#    , :branch => 'develop'
end

target 'SplitTimer' do
    common_pods
    pod 'SwiftLint'
end

target 'SplitTimerTests' do
    inherit! :search_paths
    
    common_pods

    pod 'RxBlocking',   :git => 'https://github.com/ReactiveX/RxSwift.git'
#    , :branch => 'develop'
    pod 'RxTest',       :git => 'https://github.com/ReactiveX/RxSwift.git'
#    , :branch => 'develop'
end
