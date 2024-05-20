import Foundation

import Configuration



@MainActor
public final class MainActorService : Sendable {
	init() {}
	func printHello() {
		print("Hello from MainActor service!")
	}
}


extension MainActorService : AutoInjectableMainActor
{@MainActor public struct AutoInjectionKey : ConfKeyMainActor {
	public typealias Value = MainActorService
	public static let defaultValue: Value! = .init()
}}

extension ConfKeys {
	var mainActorService:  MainActorService.AutoInjectionKey.Type {MainActorService.AutoInjectionKey.self}
	var mainActorService2: OtherConfKey                     .Type {OtherConfKey                     .self}
}

public struct OtherConfKey : ConfKeyMainActor {
	public typealias Value = MainActorService
	public static let defaultValue: Value! = .init()
}
