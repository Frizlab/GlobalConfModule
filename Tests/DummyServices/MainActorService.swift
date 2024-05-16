import Foundation

import DependencyInjection



@MainActor
public final class MainActorService : Sendable {
	init() {}
	func printHello() {
		print("Hello from MainActor service!")
	}
}


extension MainActorService : AutoInjectable 
{public struct AutoInjectionKey : InjectionKey {
	public typealias Value = MainActorService
	public static let defaultValue = { @Sendable (_: isolated MainActor) -> Value? in
		MainActor.assumeIsolated{ .init() }
	}
}}
