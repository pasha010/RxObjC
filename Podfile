use_frameworks!
inhibit_all_warnings!

def shared_pods
  pod 'libextobjc', '~> 0.4.1'
end

def shared_pods_ios
    platform :ios, '8.0'
    shared_pods
end

def shared_pods_macosx
    platform :osx, '10.9'
    shared_pods
end

def shared_pods_watchos
    platform :watchos, '2.0'
    shared_pods
end

def shared_pods_tvos
    platform :tvos, '9.0'
    shared_pods
end

target 'RxObjC-iOS' do
  shared_pods_ios
end

target 'RxObjC-OSX' do
    shared_pods_macosx
end

target 'RxObjC-tvOS' do
    shared_pods_tvos
end

target 'RxObjC-watchOS' do
    shared_pods_watchos
end

target 'RxCocoa-iOS' do
    shared_pods_ios
end

target 'RxCocoa-OSX' do
    shared_pods_macosx
end

target 'RxCocoa-tvOS' do
    shared_pods_tvos
end

target 'RxCocoa-watchOS' do
    shared_pods_watchos
end

target 'RxBlocking-iOS' do
    shared_pods_ios
end

target 'RxBlocking-OSX' do
    shared_pods_macosx
end

target 'RxBlocking-tvOS' do
    shared_pods_tvos
end

target 'RxBlocking-watchOS' do
    shared_pods_watchos
end

target 'RxTests-iOS' do
    shared_pods_ios
end

target 'RxTests-OSX' do
    shared_pods_macosx
end

target 'RxTests-tvOS' do
    shared_pods_tvos
end

target 'RxTests-watchOS' do
    shared_pods_watchos
end

target 'AllTests-iOS' do
    shared_pods_ios
end

target 'AllTests-OSX' do
    shared_pods_macosx
end

target 'AllTests-tvOS' do
    shared_pods_tvos
end