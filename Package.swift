// swift-tools-version:6.1
import PackageDescription
// release.env is the single source of truth for these two. `make stamp` writes
// them in here; a manifest cannot read a sidecar file at resolve time.
//
// SwiftPM compiles a dependency's manifest through a VFS overlay that presents
// it at "/Package.swift", so both #filePath and Context.packageDirectory give
// "/" and any read fails with "error: Invalid manifest".
let version = "6.1.0"
let xcframeworkChecksum = "11add94b73891b3203d627590fe3a1c3c53c561cf9f8817cbb7c378f78736527"

let package = Package(
    name: "libmobilecoin",
    platforms: [
        .iOS(.v13),
        .macOS(.v11)
    ],
    products: [
        .library(
            name: "LibMobileCoinCore",
            targets: ["LibMobileCoinHTTP", "LibMobileCoinGRPC", "LibMobileCoinCommon", "LibMobileCoinLibrary"]),
        .library(
            name: "LibMobileCoinCoreCommon",
            targets: ["LibMobileCoinCommon", "LibMobileCoinLibrary"]),
        .library(
            name: "LibMobileCoinCoreGRPC",
            targets: ["LibMobileCoinGRPC", "LibMobileCoinCommon", "LibMobileCoinLibrary"]),
        .library(
            name: "LibMobileCoinCoreHTTP",
            targets: ["LibMobileCoinHTTP", "LibMobileCoinCommon", "LibMobileCoinLibrary"]),
        // Test fixtures, kept out of the products above so a shipping app does
        // not carry the vectors bundle. The podspec already splits them this way.
        .library(
            name: "LibMobileCoinTestVectors",
            targets: ["LibMobileCoinTestVector"])
    ],
    dependencies: [
        // Floor matches the protoc-gen-swift pin in the Makefile; below 1.31
        // the runtime has no _NameMap(bytecode:) to call. Ceiling matches the
        // podspec: 1.38 needs a Swift 6.1 compiler for `nonisolated extension`.
        .package(
            url: "https://github.com/apple/swift-protobuf.git",
            "1.36.1"..<"1.38.0"
        ),
        .package(url: "https://github.com/grpc/grpc-swift.git", from: "1.24.1")
    ],
    targets: [
        .target(
            name: "LibMobileCoinTestVector",
            dependencies: [],
            path: "Sources/TestVector",
            resources: [
                .copy("vectors")
            ]
         ),
        .target(
            name: "LibMobileCoinCommon",
            dependencies: [.product(name: "SwiftProtobuf", package: "swift-protobuf")],
            path: "Sources/Common",
            // Every shipping product includes this target, so one copy reaches
            // every consumer. The manifest declares no tracking, and file
            // timestamps as the one accessed API category.
            resources: [
                .copy("PrivacyInfo.xcprivacy")
            ]
         ),
        .target(
            name: "LibMobileCoinHTTP",
            dependencies: [.target(name: "LibMobileCoinCommon")],
            path: "Sources/HTTP"
        ),
        .target(
            name: "LibMobileCoinGRPC",
            dependencies: [.target(name: "LibMobileCoinCommon"), .product(name: "GRPC", package: "grpc-swift")],
            path: "Sources/GRPC"
        ),
        // The binary ships as a checksummed release asset, not as a git
        // submodule. tools/package-xcframework.sh builds the zip reproducibly,
        // so this checksum is stable for a given xcframework tree.
        .binaryTarget(
            name: "LibMobileCoinLibrary",
            url: "https://github.com/mobilecoinofficial/libmobilecoin/releases/download/v\(version)/LibMobileCoinLibrary.xcframework.zip",
            checksum: xcframeworkChecksum
        )
    ]
)

