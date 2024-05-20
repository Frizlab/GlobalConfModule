import Foundation

import ServiceContextModule



public protocol InjectionKey : ServiceContextKey {

	/**
	 The default value for the injected key.
	 
	 If this is set to `nil`, the value **must** be set by the dependency clients before trying to retrieve it. */
	static var defaultValue: Value! {get}
	
}


public extension Injected {
	
	init<InjectedKey : InjectionKey>(_ keyPath: KeyPath<InjectionKeys, InjectedKey.Type>)
	where InjectedKey.Value == InjectedType {
		let defaultValue = InjectedKey.defaultValue
		self.erasedAccessor = { InjectionContext.current[InjectedKey.self] ?? defaultValue! }
	}
	
}

public extension Injected where InjectedType : AutoInjectable {
	
	@inlinable
	static var value: InjectedType {
		InjectionContext.value(for: InjectedType.AutoInjectionKey.self)
	}
	
	@inlinable
	static func withValue<T>(_ newValue: InjectedType.AutoInjectionKey.Value, operation: () throws -> T) rethrows -> T {
		try InjectionContext.withValue(newValue, for: InjectedType.AutoInjectionKey.self, operation: operation)
	}
	
	@inlinable
	@_unsafeInheritExecutor /* Same as withValue declared in the stdlib (and ServiceContext); because we do not want to hop off the executor at all. */
	static func withValue<T>(_ newValue: InjectedType.AutoInjectionKey.Value, operation: () async throws -> T) async rethrows -> T {
		try await InjectionContext.withValue(newValue, for: InjectedType.AutoInjectionKey.self, operation: operation)
	}
	
	@inlinable
	static var rootValue: InjectedType {
		get {InjectionContext   .rootValue(          for: InjectedType.AutoInjectionKey.self)}
		set {InjectionContext.setRootValue(newValue, for: InjectedType.AutoInjectionKey.self)}
	}
	
	init() {
		let defaultValue = InjectedType.AutoInjectionKey.defaultValue
		self.erasedAccessor = { InjectionContext.current[InjectedType.AutoInjectionKey.self] ?? defaultValue! }
	}
	
}


public extension InjectionContext {
	
	/* *** Accessing the current value (in current Task) for a given key (or key path). *** */
	
	static func value<InjectedKey : InjectionKey>(for keyType: InjectedKey.Type = InjectedKey.self) -> InjectedKey.Value {
		return InjectionContext.current[InjectedKey.self] ?? InjectedKey.defaultValue
	}
	
	@inlinable
	static func value<InjectedKey : InjectionKey>(for keyPath: KeyPath<InjectionKeys, InjectedKey.Type>) -> InjectedKey.Value {
		return Self.value(for: InjectedKey.self)
	}
	
	/* *** Overridding the value for a given key (or key path) for the current Task. *** */
	
	static func withValue<InjectedKey : InjectionKey, T>(_ newValue: InjectedKey.Value, for keyType: InjectedKey.Type = InjectedKey.self, operation: () throws -> T) rethrows -> T {
		var newContext = InjectionContext.current
		newContext[InjectedKey.self] = newValue
		return try InjectionContext.$forCurrentTask.withValue(newContext, operation: operation)
	}
	
	@_unsafeInheritExecutor /* Same as withValue declared in the stdlib (and ServiceContext); because we do not want to hop off the executor at all. */
	static func withValue<InjectedKey : InjectionKey, T>(_ newValue: InjectedKey.Value, for keyType: InjectedKey.Type = InjectedKey.self, operation: () async throws -> T) async rethrows -> T {
		var newContext = InjectionContext.current
		newContext[InjectedKey.self] = newValue
		return try await ServiceContext.$current.withValue(newContext, operation: operation)
	}
	
	static func withValue<InjectedKey : InjectionKey, T>(_ newValue: InjectedKey.Value, for keyPath: KeyPath<InjectionKeys, InjectedKey.Type>, operation: () throws -> T) rethrows -> T {
		var newContext = InjectionContext.current
		newContext[InjectedKey.self] = newValue
		return try InjectionContext.$forCurrentTask.withValue(newContext, operation: operation)
	}
	
	@_unsafeInheritExecutor /* Same as withValue declared in the stdlib (and ServiceContext); because we do not want to hop off the executor at all. */
	static func withValue<InjectedKey : InjectionKey, T>(_ newValue: InjectedKey.Value, for keyPath: KeyPath<InjectionKeys, InjectedKey.Type>, operation: () async throws -> T) async rethrows -> T {
		var newContext = InjectionContext.current
		newContext[InjectedKey.self] = newValue
		return try await ServiceContext.$current.withValue(newContext, operation: operation)
	}
	
}

public extension InjectionContext {
	
	/* *** Accessing the root value (base propagated in sub-Tasks) for a given key (or key path). *** */
	
	static func rootValue<InjectedKey : InjectionKey>(for keyType: InjectedKey.Type = InjectedKey.self) -> InjectedKey.Value {
		return InjectionContext.root[InjectedKey.self] ?? InjectedKey.defaultValue
	}
	
	@inlinable
	static func rootValue<InjectedKey : InjectionKey>(for keyPath: KeyPath<InjectionKeys, InjectedKey.Type>) -> InjectedKey.Value {
		return Self.rootValue(for: InjectedKey.self)
	}
	
	/* *** Setting the root value (base propagated in sub-Tasks) for a given key (or key path). *** */
	
	/* Important: The change of root value is not propagated in Tasks where a value is overridden.
	 * This means if you have the dependencies A and B whose root values are instance a1 and b1,
	 *  then you override the value for A _for the current task_ and
	 *  in the handler of A’s change scope, you change the _root_ value of B,
	 *  B’s value will still be b1 while you stay in the scope, even though you changed it. */
	
	static func setRootValue<InjectedKey : InjectionKey>(_ newValue: InjectedKey.Value, for keyType: InjectedKey.Type = InjectedKey.self) {
		InjectionContext.root[InjectedKey.self] = newValue
	}
	
	@inlinable
	static func setRootValue<InjectedKey : InjectionKey>(_ newValue: InjectedKey.Value, for keyPath: KeyPath<InjectionKeys, InjectedKey.Type>) {
		Self.setRootValue(newValue, for: InjectedKey.self)
	}
	
}
