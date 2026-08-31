// swift-tools-version:5.7
import PackageDescription
import Foundation
let package = Package(
    name: "libmobilecoin",
    platforms: [
        .iOS(.v13),
        .macOS(.v11)
    ],
    products: [
        .library(
            name: "LibMobileCoinCore",
            targets: ["LibMobileCoinTestVector", "LibMobileCoinHTTP", "LibMobileCoinGRPC", "LibMobileCoinCommon", "LibMobileCoinLibrary"]),
        .library(
            name: "LibMobileCoinCoreCommon",
            targets: ["LibMobileCoinTestVector", "LibMobileCoinCommon", "LibMobileCoinLibrary"]),
        .library(
            name: "LibMobileCoinCoreGRPC",
            targets: ["LibMobileCoinTestVector", "LibMobileCoinGRPC", "LibMobileCoinCommon", "LibMobileCoinLibrary"]),
        .library(
            name: "LibMobileCoinCoreHTTP",
            targets: ["LibMobileCoinTestVector", "LibMobileCoinHTTP", "LibMobileCoinCommon", "LibMobileCoinLibrary"])
    ],
    dependencies: [
        // Here we define our package's external dependencies
        // and from where they can be fetched:
        .package(
            url: "https://github.com/apple/swift-protobuf.git",
            from: "1.28.2"
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
            path: "Sources/Common"
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
        // The binary ships as a checksummed release asset.
        // tools/package-xcframework.sh builds the zip reproducibly, so this
        // checksum is stable for a given xcframework tree.
        .binaryTarget(
            name: "LibMobileCoinLibrary",
            url: "https://github.com/mobilecoinofficial/libmobilecoin/releases/download/v6.0.4/LibMobileCoinLibrary.xcframework.zip",
            checksum: "11add94b73891b3203d627590fe3a1c3c53c561cf9f8817cbb7c378f78736527"
        )
    ]
)

