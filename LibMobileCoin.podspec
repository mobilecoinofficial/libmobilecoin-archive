# release.env is the single source of truth for the version and the checksum of
# the released xcframework. Package.swift and the Makefile read the same file.
release_settings = File.readlines(File.join(__dir__, "release.env"))
  .reject { |line| line.strip.empty? || line.strip.start_with?("#") }
  .map { |line| line.strip.split("=", 2) }
  .to_h

Pod::Spec.new do |s|

  # ―――  Spec Metadata  ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  s.name         = "LibMobileCoin"
  s.version      = release_settings.fetch("VERSION")
  s.summary      = "A library for communicating with MobileCoin network"

  s.author       = "MobileCoin"
  s.homepage     = "https://www.mobilecoin.com/"
  s.license      = { :type => "GPLv3" }

  s.source       = {
    :git => "https://github.com/mobilecoinofficial/libmobilecoin.git",
    :tag => "v#{s.version}"
  }

  # ――― Prebuilt binary ―――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  # The xcframework is downloaded and checksum-verified at install time. The
  # same archive and checksum back the SwiftPM binaryTarget in Package.swift,
  # so neither consumer needs git-lfs.
  xcframework_url = "https://github.com/mobilecoinofficial/libmobilecoin/releases/download/v#{s.version}/LibMobileCoinLibrary.xcframework.zip"
  xcframework_checksum = release_settings.fetch("XCFRAMEWORK_SHA256")

  s.prepare_command = <<-CMD
    set -eu
    mkdir -p Artifacts
    # The stamp carries the checksum, so a tree left over from a different
    # version - or a half-extracted one from an interrupted unzip - re-downloads
    # instead of being silently accepted. Written only after unzip succeeds.
    stamp="Artifacts/.xcframework-#{xcframework_checksum}"
    if [ ! -f "$stamp" ]; then
      rm -rf Artifacts/LibMobileCoinLibrary.xcframework
      rm -f Artifacts/.xcframework-*
      curl --fail --location --silent --show-error \
        --retry 3 --retry-connrefused \
        --output Artifacts/xcframework.zip "#{xcframework_url}"
      echo "#{xcframework_checksum}  Artifacts/xcframework.zip" | shasum -a 256 -c -
      unzip -q -o Artifacts/xcframework.zip -d Artifacts
      rm Artifacts/xcframework.zip
      touch "$stamp"
    fi
    # Every slice carries the same C headers. The pod compiles them into its own
    # module map, so lift one copy to the path source_files already names.
    mkdir -p Artifacts/include
    cp Artifacts/LibMobileCoinLibrary.xcframework/ios-arm64/Headers/*.h Artifacts/include/
  CMD

  # ――― Platform Specifics ――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  # Matches the .iOS(.v13) floor in Package.swift. Xcode 15 and later reject a
  # deployment target below 12.0 outright.
  s.platform     = :ios, "13.0"

  # ――― Privacy manifest ―――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  # resource_bundles is NOT inherited, so each subspec declares it from this
  # constant. Setting it on the root spec too makes `pod lib lint` build the
  # bundle twice under one name and fail with "Multiple commands produce".
  privacy_bundle = {
    "LibMobileCoin_Privacy" => ["Sources/Common/PrivacyInfo.xcprivacy"]
  }

  # ――― Subspecs ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  # CocoaPods carries the HTTP transport only. gRPC-Swift tops out at 1.8.0 on
  # trunk, whose Logging dependency tops out at 1.4.0. That version targets
  # iOS 8.0, so clang links libarclite, which current Xcode does not ship.
  # Package.swift carries the gRPC product.
  s.default_subspecs = "CoreHTTP"

   s.subspec "TestVectors" do |subspec|
     subspec.resource_bundles = privacy_bundle

     subspec.source_files = [
       "Sources/TestVector/Util/Bundle+TestVector.swift",
       "Sources/TestVector/Util/TestVectorError.swift"
     ]

     subspec.preserve_paths = [
       'Artifacts/LibMobileCoinLibrary.xcframework/**/*.a',
     ]
     subspec.resources = [
       "Sources/TestVector/vectors/*.*",
     ]
   end

   s.subspec "CoreHTTP" do |subspec|
     subspec.resource_bundles = privacy_bundle

     subspec.preserve_paths = [
       'Artifacts/LibMobileCoinLibrary.xcframework/**/*.a',
     ]

     subspec.source_files = [
       "Artifacts/include/*.h",
       "Sources/HTTP/*.{http}.swift",
       "Sources/HTTP/Interface/*.swift",
       "Sources/Common/*.{pb}.swift",
     ]

     # Floor matches the protoc-gen-swift pin in the Makefile. 1.38 needs a
     # Swift 6.1 compiler for the `nonisolated extension` in its sources.
     subspec.dependency "SwiftProtobuf", ">= 1.36.1", "< 1.38"
   end

  # ――― Project Settings ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  s.swift_version = "5.2"

  s.pod_target_xcconfig = {
    "GCC_OPTIMIZATION_LEVEL" => "z",
    # "LLVM_LTO" => "YES",
    # Rust bitcode is not verified to be compatible with Apple Xcode's LLVM bitcode,
    # so this is disabled to be on the safe side.
    "ENABLE_BITCODE" => "YES",
    # Mac Catalyst is not supported since tjis library includes a vendored binary
    # that only includes support for iOS archictures.
    "SUPPORTS_MACCATALYST" => "NO",
    # The vendored binary doesn't include support for 32-bit architectures or arm64
    # for iphonesimulator. This must be manually configured to avoid Xcode's default
    # setting of building 32-bit and Xcode 12's default setting of including the
    # arm64 simulator. Note: 32-bit is officially dropped in iOS 11

    "HEADER_SEARCH_PATHS": "$(PODS_TARGET_SRCROOT)/Artifacts/include",
    "SWIFT_INCLUDE_PATHS": "$(HEADER_SEARCH_PATHS)",

    "LIBMOBILECOIN_XCFRAMEWORK": "$(PODS_TARGET_SRCROOT)/Artifacts/LibMobileCoinLibrary.xcframework",
    "LIBMOBILECOIN_LIB_IF_NEEDED[sdk=iphoneos*]": "$(LIBMOBILECOIN_XCFRAMEWORK)/ios-arm64/libmobilecoin.a",
    "LIBMOBILECOIN_LIB_IF_NEEDED[sdk=iphonesimulator*]": "$(LIBMOBILECOIN_XCFRAMEWORK)/ios-arm64_x86_64-simulator/libmobilecoin_iossimulator.a",
    "LIBMOBILECOIN_LIB_IF_NEEDED[sdk=macosx*]": "$(LIBMOBILECOIN_XCFRAMEWORK)/macos-arm64_x86_64/libmobilecoin_macos.a",
    "OTHER_LDFLAGS": "-lz -u _mc_string_free $(LIBMOBILECOIN_LIB_IF_NEEDED)",

    "VALID_ARCHS[sdk=iphoneos*]" => "arm64",
    "VALID_ARCHS[sdk=iphonesimulator*]" => "x86_64 arm64",
    "ARCHS[sdk=iphonesimulator*]": "x86_64 arm64",
    "ARCHS[sdk=iphoneos*]": "arm64",
    "EXCLUDED_ARCHS[sdk=iphoneos*]" => "armv7",
    "EXCLUDED_ARCHS[sdk=iphonesimulator*]" => "i386",
  }

  # `user_target_xcconfig` should only be set when the setting needs to propogate to
  # all targets that depend on this library.
  s.user_target_xcconfig = {
    "SUPPORTS_MACCATALYST" => "NO",
    "EXCLUDED_ARCHS[sdk=iphoneos*]" => "armv7",
    "EXCLUDED_ARCHS[sdk=iphonesimulator*]" => "i386",
    "VALID_ARCHS[sdk=iphoneos*]" => "arm64",
    "VALID_ARCHS[sdk=iphonesimulator*]" => "x86_64 arm64",
  }

end
