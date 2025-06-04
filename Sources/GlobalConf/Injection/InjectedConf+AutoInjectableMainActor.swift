import Foundation

import ServiceContextModule



@MainActor
public extension InjectedConf where InjectedType : AutoInjectableMainActor {
	
	init(customContext: ConfContext? = nil) {
		let defaultValue = { @MainActor @Sendable in InjectedType.AutoInjectionKey.defaultValue }
		if let customContext {self.erasedAccessor = { MainActor.assumeIsolated{ customContext.actualContext[InjectedType.AutoInjectionKey.self] ?? defaultValue()! } }}
		else                 {self.erasedAccessor = { MainActor.assumeIsolated{         Conf.currentContext[InjectedType.AutoInjectionKey.self] ?? defaultValue()! } }}
	}
	
}


@MainActor
public extension InjectedConf where InjectedType : AutoInjectableMainActor {
	
	@inlinable
	static var value: InjectedType {
		Conf.value(for: InjectedType.AutoInjectionKey.self)
	}
	
	@inlinable
	static func withValue<T>(_ newValue: InjectedType.AutoInjectionKey.Value, operation: () throws -> T) rethrows -> T {
		try Conf.withValue(newValue, for: InjectedType.AutoInjectionKey.self, operation: operation)
	}
	
	@inlinable
	static func withValue<T>(_ newValue: InjectedType.AutoInjectionKey.Value, operation: () async throws -> T, isolation: isolated (any Actor)? = #isolation) async rethrows -> T {
		try await Conf.withValue(newValue, for: InjectedType.AutoInjectionKey.self, operation: operation, isolation: isolation)
	}
}


@MainActor
public extension InjectedConf where InjectedType : AutoInjectableMainActor {
	
	@inlinable
	static var rootValue: InjectedType {
		get {Conf   .rootValue(          for: InjectedType.AutoInjectionKey.self)}
		set {Conf.setRootValue(newValue, for: InjectedType.AutoInjectionKey.self)}
	}
	
	
}
