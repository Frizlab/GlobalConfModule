import Foundation

import DependencyInjection



public final class NoActorService : Sendable {
	init() {}
	func printHello() {
		print("Hello from NoActor service!")
	}
}


extension NoActorService : AutoInjectable
{public struct AutoInjectionKey : InjectionKey {
	public typealias Value = NoActorService
	public static let defaultValue = { @Sendable (_: isolated DummyInjectionActor) -> Value? in
		return .init()
	}
}}
