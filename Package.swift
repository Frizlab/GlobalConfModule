// swift-tools-version:6.0
import PackageDescription
import CompilerPluginSupport


let swiftSettings: [SwiftSetting] = []

let package = Package(
	name: "GlobalConfModule",
	platforms: [
		.macOS(.v10_15),
		.tvOS(.v13),
		.iOS(.v13),
		.watchOS(.v6)
	],
	products: [
		.library(name: "GlobalConfModule", targets: ["GlobalConfModule"])
	],
	dependencies: [
		.package(url: "https://github.com/apple/swift-service-context.git", from: "1.0.0"),
		/* TODO: CI should test the package w/ all of the major versions we support of swift-syntax specified explicitly. */
		.package(url: "https://github.com/swiftlang/swift-syntax.git",      "509.0.0"..<"601.0.0"),
//		.package(url: "https://github.com/swiftlang/swift-syntax.git",      from: "600.0.0"),
//		.package(url: "https://github.com/swiftlang/swift-syntax.git",      from: "510.0.0"),
//		.package(url: "https://github.com/swiftlang/swift-syntax.git",      from: "509.0.0"),
	],
	targets: [
		.target(name: "GlobalConfModule", dependencies: [
			.target(name: "GlobalConfMacros"),
			.product(name: "ServiceContextModule", package: "swift-service-context"),
		], path: "Sources/GlobalConf", swiftSettings: swiftSettings),
		.testTarget(name: "GlobalConfModuleTests", dependencies: [
			"GlobalConfModule",
		], path: "Tests/GlobalConfTests", swiftSettings: swiftSettings),
		
		.macro(name: "GlobalConfMacros", dependencies: [
			.product(name: "SwiftSyntaxMacros",   package: "swift-syntax"),
			.product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
		], swiftSettings: swiftSettings),
		.testTarget(name: "GlobalConfMacrosTests", dependencies: [
			"GlobalConfMacros",
			.product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax"),
		], swiftSettings: swiftSettings)
	]
)
