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
	dependencies: [.package(url: "https://github.com/apple/swift-service-context.git", from: "1.0.0")],
	targets: [.target(name: "DependencyInjection", dependencies: [
		.product(name: "ServiceContextModule", package: "swift-service-context"),
	], path: "Sources")]
)
