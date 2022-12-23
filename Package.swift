// swift-tools-version:5.5
import PackageDescription


let package = Package(
	name: "DependencyInjection",
	platforms: [
		.macOS(.v10_15),
		.tvOS(.v13),
		.iOS(.v13),
		.watchOS(.v6)
	],
	products: [.library(name: "DependencyInjection", targets: ["DependencyInjection"])],
	targets: [.target(name: "DependencyInjection")]
)
