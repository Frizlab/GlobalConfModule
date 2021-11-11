// swift-tools-version:5.5
import PackageDescription


let package = Package(
	name: "DependencyInjection",
	products: [.library(name: "DependencyInjection", targets: ["DependencyInjection"])],
	targets: [.target(name: "DependencyInjection")]
)
