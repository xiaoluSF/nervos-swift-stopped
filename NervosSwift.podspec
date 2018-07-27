
Pod::Spec.new do |s|
s.name         = "NervosSwift"
s.version      = "0.172"
s.summary      = "Nervos SDK implementation in Swift for  iOS and macOS"
s.description  = <<-DESC
Nervos SDK implementation in Swift for  iOS and macOS,intended for mobile developers of wallets, Dapps and Nervos
                 DESC
s.homepage     = "https://github.com/cryptape/NervosSwift"
s.license      = "Apache License 2.0"
s.author             = { "LuFP" => "lfp@cryptape.com" }
s.source       = { :git => "https://github.com/cryptape/NervosSwift.git", :tag => "v#{s.version}" } # = "v0.17"
s.social_media_url = 'https://twitter.com/nervosnetwork'

s.swift_version = '4.1'
s.module_name = 'NervosSwift'
s.ios.deployment_target = "9.0"
s.osx.deployment_target = "10.11"
s.source_files = "web3swift/**/*.{h,swift}", 
s.public_header_files = "web3swift/**/*.{h}"
s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }

s.frameworks = 'CoreImage'
s.dependency 'BigInt', '~> 3.1.0'
s.dependency 'Result', '~> 3.0.0'
s.dependency 'CryptoSwift', '~> 0.10.0'
s.dependency 'libsodium', '~> 1.0.12'
s.dependency 'secp256k1_ios', '~> 0.1.3'
s.dependency 'PromiseKit', '~> 6.3.0'
s.dependency 'SwiftProtobuf', '~> 1.0.3'

end
