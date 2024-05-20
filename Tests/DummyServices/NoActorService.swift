import Foundation

import Configuration



public final class NoActorService : Sendable {
	init() {}
	func printHello() {
		print("Hello from NoActor service!")
	}
}


extension NoActorService : AutoInjectable
{public struct AutoInjectionKey : ConfKey {
	public typealias Value = NoActorService
	public static let defaultValue: Value! = .init()
}}

extension ConfKeys {
	var noActorService: NoActorService.AutoInjectionKey.Type {NoActorService.AutoInjectionKey.self}
}
