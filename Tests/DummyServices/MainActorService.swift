import Foundation

import DependencyInjection



@MainActor
public final class MainActorService : Sendable {
	init() {}
	func printHello() {
		print("Hello from MainActor service!")
	}
}


extension MainActorService : AutoInjectableMainActor
{@MainActor public struct AutoInjectionKey : InjectionKeyMainActor {
	public typealias Value = MainActorService
	public static let defaultValue: Value! = .init()
}}

extension InjectionKeys {
	var mainActorService: MainActorService.AutoInjectionKey.Type {MainActorService.AutoInjectionKey.self}
	var mainActorService2: OtherInjectionKey.Type {OtherInjectionKey.self}
}

public struct OtherInjectionKey : InjectionKeyMainActor {
	public typealias Value = MainActorService
	public static let defaultValue: Value! = .init()
}
