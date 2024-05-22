import Foundation

import ServiceContextModule



public extension Injected where InjectedType : AutoInjectable {
	
	init(customContext: ConfContext? = nil) {
		let defaultValue = InjectedType.AutoInjectionKey.defaultValue
		if let customContext {self.erasedAccessor = { customContext.actualContext[InjectedType.AutoInjectionKey.self] ?? defaultValue! }}
		else                 {self.erasedAccessor = {         Conf.currentContext[InjectedType.AutoInjectionKey.self] ?? defaultValue! }}
	}
	
}


public extension Injected where InjectedType : AutoInjectable {
	
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


public extension Injected where InjectedType : AutoInjectable {
	
	@inlinable
	static var rootValue: InjectedType {
		get {Conf   .rootValue(          for: InjectedType.AutoInjectionKey.self)}
		set {Conf.setRootValue(newValue, for: InjectedType.AutoInjectionKey.self)}
	}
	
}
