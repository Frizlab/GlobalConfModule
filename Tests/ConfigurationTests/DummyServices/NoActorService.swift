import Foundation

import Configuration



public final class NoActorService : Sendable {
	init() {}
	func printHello() {
		print("Hello from NoActor service!")
	}
}


extension NoActorService : AutoInjectable {
	public typealias AutoInjectionKey = ConfKeys.BestKey
}

extension ConfKeys {
	#declareServiceKey("noActorService", NoActorService.self, "BestKey", defaultValue: .init())
	var noActorFactoryService: NoActorFactoryConfKey.Type {NoActorFactoryConfKey.self}
}

public struct NoActorFactoryConfKey : ConfKey {
	public typealias Value = @Sendable () -> NoActorService
	public static let defaultValue: Value! = { .init() }
}
