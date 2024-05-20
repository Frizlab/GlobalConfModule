import Foundation

import ServiceContextModule



@MainActor
public extension Injected where InjectedType : AutoInjectableMainActor {
	
	init() {
		let defaultValue = InjectedType.AutoInjectionKey.defaultValue
		self.erasedAccessor = { Conf.currentContext[InjectedType.AutoInjectionKey.self] ?? defaultValue! }
	}
	
}


@MainActor
public extension Injected where InjectedType : AutoInjectableMainActor {
	
	@inlinable
	static var value: InjectedType {
		Conf.value(for: InjectedType.AutoInjectionKey.self)
	}
	
	@inlinable
	static func withValue<T>(_ newValue: InjectedType.AutoInjectionKey.Value, operation: () throws -> T) rethrows -> T {
		try Conf.withValue(newValue, for: InjectedType.AutoInjectionKey.self, operation: operation)
	}
	
	@inlinable
	@_unsafeInheritExecutor /* Same as withValue declared in the stdlib (and ServiceContext); because we do not want to hop off the executor at all. */
	static func withValue<T>(_ newValue: InjectedType.AutoInjectionKey.Value, operation: () async throws -> T) async rethrows -> T {
		try await Conf.withValue(newValue, for: InjectedType.AutoInjectionKey.self, operation: operation)
	}
}


@MainActor
public extension Injected where InjectedType : AutoInjectableMainActor {
	
	@inlinable
	static var rootValue: InjectedType {
		get {Conf   .rootValue(          for: InjectedType.AutoInjectionKey.self)}
		set {Conf.setRootValue(newValue, for: InjectedType.AutoInjectionKey.self)}
	}
	
	
}
