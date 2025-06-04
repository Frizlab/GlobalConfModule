import Foundation

import ServiceContextModule



public extension InjectedConf {
	
	init<InjectedKey : ConfKey>(_ keyPath: KeyPath<ConfKeys, InjectedKey.Type>, customContext: ConfContext? = nil)
	where InjectedKey.Value == InjectedType {
		let defaultValue = { @Sendable in InjectedKey.defaultValue }
		if let customContext {self.erasedAccessor = { customContext.actualContext[InjectedKey.self] ?? defaultValue()! }}
		else                 {self.erasedAccessor = {         Conf.currentContext[InjectedKey.self] ?? defaultValue()! }}
	}
	
	init<InjectedKey : ConfKey>(_ keyPath: KeyPath<ConfKeys, InjectedKey.Type>, customContext: ConfContext? = nil)
	where InjectedKey.Value == @Sendable () -> InjectedType {
		let defaultValue = { @Sendable in InjectedKey.defaultValue }
		if let customContext {self.erasedAccessor = { customContext.actualContext[InjectedKey.self]?() ?? defaultValue()!() }}
		else                 {self.erasedAccessor = {         Conf.currentContext[InjectedKey.self]?() ?? defaultValue()!() }}
	}
	
}
