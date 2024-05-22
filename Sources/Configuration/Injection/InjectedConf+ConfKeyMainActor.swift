import Foundation

import ServiceContextModule



@MainActor
public extension InjectedConf {
	
	init<InjectedKey : ConfKeyMainActor>(_ keyPath: KeyPath<ConfKeys, InjectedKey.Type>, customContext: ConfContext? = nil)
	where InjectedKey.Value == InjectedType {
		let defaultValue = InjectedKey.defaultValue
		if let customContext {self.erasedAccessor = { customContext.actualContext[InjectedKey.self] ?? defaultValue! }}
		else                 {self.erasedAccessor = {         Conf.currentContext[InjectedKey.self] ?? defaultValue! }}
	}
	
	init<InjectedKey : ConfKeyMainActor>(_ keyPath: KeyPath<ConfKeys, InjectedKey.Type>, customContext: ConfContext? = nil)
	where InjectedKey.Value == @Sendable () -> InjectedType {
		let defaultValue = InjectedKey.defaultValue
		if let customContext {self.erasedAccessor = { customContext.actualContext[InjectedKey.self]?() ?? defaultValue!() }}
		else                 {self.erasedAccessor = {         Conf.currentContext[InjectedKey.self]?() ?? defaultValue!() }}
	}
	
}
