// swift-tools-version:5.7
import PackageDescription
import Foundation

// release.env is the single source of truth for the version and the checksum of
// the released xcframework. The release workflow writes it, and the podspec and
// the Makefile read the same file.
func releaseSetting(_ key: String) -> String {
    let path = URL(fileURLWithPath: #filePath)
        .deletingLastPathComponent()
        .appendingPathComponent("release.env")
    guard let contents = try? String(contentsOf: path, encoding: .utf8) else {
        fatalError("libmobilecoin: cannot read release.env at \(path.path)")
    }
    for line in contents.split(separator: "\n") {
        let trimmed = line.trimmingCharacters(in: .whitespaces)
        guard !trimmed.hasPrefix("#"), let equals = trimmed.firstIndex(of: "=") else { continue }
        guard trimmed[trimmed.startIndex..<equals] == key else { continue }
        return String(trimmed[trimmed.index(after: equals)...])
            .trimmingCharacters(in: .whitespaces)
    }
    fatalError("libmobilecoin: release.env has no \(key)")
}

let version = releaseSetting("VERSION")
let xcframeworkChecksum = releaseSetting("XCFRAMEWORK_SHA256")

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

