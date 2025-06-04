import Foundation

import ServiceContextModule



@MainActor
public extension InjectedConf {
	
	init<InjectedKey : ConfKeyMainActor>(_ keyPath: KeyPath<ConfKeys, InjectedKey.Type>, customContext: ConfContext? = nil)
	where InjectedKey.Value == InjectedType {
		let defaultValue = { @MainActor @Sendable in InjectedKey.defaultValue }
		if let customContext {self.erasedAccessor = { MainActor.assumeIsolated{ customContext.actualContext[InjectedKey.self] ?? defaultValue()! } }}
		else                 {self.erasedAccessor = { MainActor.assumeIsolated{         Conf.currentContext[InjectedKey.self] ?? defaultValue()! } }}
	}
	
	init<InjectedKey : ConfKeyMainActor>(_ keyPath: KeyPath<ConfKeys, InjectedKey.Type>, customContext: ConfContext? = nil)
	where InjectedKey.Value == @Sendable () -> InjectedType {
		let defaultValue = { @MainActor @Sendable in InjectedKey.defaultValue }
		if let customContext {self.erasedAccessor = { MainActor.assumeIsolated{ customContext.actualContext[InjectedKey.self]?() ?? defaultValue()!() } }}
		else                 {self.erasedAccessor = { MainActor.assumeIsolated{         Conf.currentContext[InjectedKey.self]?() ?? defaultValue()!() } }}
	}
	
}
