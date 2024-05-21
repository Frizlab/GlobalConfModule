// swift-tools-version:5.9
import PackageDescription
import CompilerPluginSupport


//let swiftSettings: [SwiftSetting] = []
let swiftSettings: [SwiftSetting] = [.enableExperimentalFeature("StrictConcurrency")]

let package = Package(
	name: "Configuration",
	platforms: [
		.macOS(.v10_15),
		.tvOS(.v13),
		.iOS(.v13),
		.watchOS(.v6)
	],
	products: [
		.library(name: "Configuration", targets: ["Configuration"])
	],
	dependencies: [
		.package(url: "https://github.com/apple/swift-service-context.git", from: "1.0.0"),
		/* TODO: CI should test the package w/ all of the major versions we support of swift-syntax specified explicitly. */
		.package(url: "https://github.com/apple/swift-syntax.git",          "509.0.0"..<"511.0.0"),
		.package(url: "https://github.com/Frizlab/SafeGlobal.git",          from: "0.2.0"),
		.package(url: "https://github.com/Frizlab/UnwrapOrThrow.git",       from: "1.0.1"),
	],
	targets: [
		.target(name: "Configuration", dependencies: [
			.target(name: "ConfigurationMacros"),
			.product(name: "SafeGlobal",           package: "SafeGlobal"),
			.product(name: "ServiceContextModule", package: "swift-service-context"),
		], swiftSettings: swiftSettings),
		.testTarget(name: "ConfigurationTests", dependencies: [
			"Configuration",
		], swiftSettings: swiftSettings),
		
		.macro(name: "ConfigurationMacros", dependencies: [
			.product(name: "SwiftSyntaxMacros",   package: "swift-syntax"),
			.product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
			.product(name: "UnwrapOrThrow",       package: "UnwrapOrThrow"),
		], swiftSettings: swiftSettings),
		.testTarget(name: "ConfigurationMacrosTests", dependencies: [
			"ConfigurationMacros",
			.product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax"),
		], swiftSettings: swiftSettings)
	]
)
