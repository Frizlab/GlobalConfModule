import Foundation

import ServiceContextModule



public extension Injected {
	
	@MainActor
	init<InjectedKey : ConfKeyMainActor>(_ keyPath: KeyPath<ConfKeys, InjectedKey.Type>)
	where InjectedKey.Value == InjectedType {
		let defaultValue = InjectedKey.defaultValue
		self.erasedAccessor = { Conf.currentContext[InjectedKey.self] ?? defaultValue! }
	}
	
}
