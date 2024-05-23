import Foundation

import GlobalConfModule



final class NoActorService : Sendable {
	init() {}
	func printHello() {
		print("Hello from NoActor service!")
	}
}


extension NoActorService : AutoInjectable {
	typealias AutoInjectionKey = ConfKeys.BestKey
}

extension ConfKeys {
	#declareServiceKey(visibility: DeclarationVisibility.internal, "noActorService", NoActorService.self, "BestKey", defaultValue: .init())
	var noActorFactoryService: NoActorFactoryConfKey.Type {NoActorFactoryConfKey.self}
}

struct NoActorFactoryConfKey : ConfKey {
	typealias Value = @Sendable () -> NoActorService
	static let defaultValue: Value! = { .init() }
}
