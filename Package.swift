// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "ZeroProofFlavorTheaterSupport",
    platforms: [.iOS(.v17)],
    products: [.library(name: "ZeroProofFlavorTheaterSupport", targets: ["ZeroProofFlavorTheaterSupport"])],
    targets: [.target(name: "ZeroProofFlavorTheaterSupport", path: "ZeroProofFlavorTheaterSupport")]
)
