import Foundation

import ServiceContextModule



@MainActor
public extension Conf {
	
	/* *** Accessing the current value (in current Task) for a given key (or key path). *** */
	
	static func value<InjectedKey : ConfKeyMainActor>(for keyType: InjectedKey.Type = InjectedKey.self) -> InjectedKey.Value {
		return Conf.currentContext[InjectedKey.self] ?? InjectedKey.defaultValue
	}
	@inlinable
	static subscript<InjectedKey : ConfKeyMainActor>(key key: InjectedKey.Type = InjectedKey.self) -> InjectedKey.Value {
		return value(for: InjectedKey.self)
	}
	
	@inlinable
	static func value<InjectedKey : ConfKeyMainActor>(for keyPath: KeyPath<ConfKeys, InjectedKey.Type>) -> InjectedKey.Value {
		return Self.value(for: InjectedKey.self)
	}
	@inlinable
	static subscript<InjectedKey : ConfKeyMainActor>(keyPath: KeyPath<ConfKeys, InjectedKey.Type>) -> InjectedKey.Value {
		return value(for: keyPath)
	}
	
	/* *** Overridding the value for a given key (or key path) for the current Task for a synchronous operation. *** */
	
	static func withValue<InjectedKey : ConfKeyMainActor, T>(_ newValue: InjectedKey.Value, for keyType: InjectedKey.Type = InjectedKey.self, operation: () throws -> T) rethrows -> T {
		var newContext = Conf.currentContext
		newContext[InjectedKey.self] = newValue
		return try Conf.$currentTaskContext.withValue(newContext, operation: operation)
	}
	
	@inlinable
	static func withValue<InjectedKey : ConfKeyMainActor, T>(_ newValue: InjectedKey.Value, for keyPath: KeyPath<ConfKeys, InjectedKey.Type>, operation: () throws -> T) rethrows -> T {
		return try withValue(newValue, for: InjectedKey.self, operation: operation)
	}
	
	/* *** Overridding the value for a given key (or key path) for the current Task for an asynchronous operation. *** */
	
	@_unsafeInheritExecutor /* Same as withValue declared in the stdlib (and ServiceContext); because we do not want to hop off the executor at all. */
	static func withValue<InjectedKey : ConfKeyMainActor, T>(_ newValue: InjectedKey.Value, for keyType: InjectedKey.Type = InjectedKey.self, operation: () async throws -> T) async rethrows -> T {
		var newContext = Conf.currentContext
		newContext[InjectedKey.self] = newValue
		return try await Conf.$currentTaskContext.withValue(newContext, operation: operation)
	}
	
	@inlinable
	@_unsafeInheritExecutor /* Same as withValue declared in the stdlib (and ServiceContext); because we do not want to hop off the executor at all. */
	static func withValue<InjectedKey : ConfKeyMainActor, T>(_ newValue: InjectedKey.Value, for keyPath: KeyPath<ConfKeys, InjectedKey.Type>, operation: () async throws -> T) async rethrows -> T {
		return try await withValue(newValue, for: InjectedKey.self, operation: operation)
	}
	
}


@MainActor
public extension Conf {
	
	/* *** Accessing the root value (base propagated in sub-Tasks) for a given key (or key path). *** */
	
	static func rootValue<InjectedKey : ConfKeyMainActor>(for keyType: InjectedKey.Type = InjectedKey.self) -> InjectedKey.Value {
		return Conf.rootContext[InjectedKey.self] ?? InjectedKey.defaultValue
	}
	
	@inlinable
	static func rootValue<InjectedKey : ConfKeyMainActor>(for keyPath: KeyPath<ConfKeys, InjectedKey.Type>) -> InjectedKey.Value {
		return Self.rootValue(for: InjectedKey.self)
	}
	
	/* *** Setting the root value (base propagated in sub-Tasks) for a given key (or key path). *** */
	
	/* Important: The change of root value is not propagated in Tasks where a value is overridden.
	 * This means if you have the dependencies A and B whose root values are instances a1 and b1,
	 *  then you override the value for A _for the current task_ and
	 *  in the handler of A’s change scope, you change the _root_ value of B,
	 *  B’s value will still be b1 while you stay in the scope, even though you changed it. */
	
	static func setRootValue<InjectedKey : ConfKeyMainActor>(_ newValue: InjectedKey.Value, for keyType: InjectedKey.Type = InjectedKey.self) {
		Conf.rootContext[InjectedKey.self] = newValue
	}
	
	@inlinable
	static func setRootValue<InjectedKey : ConfKeyMainActor>(_ newValue: InjectedKey.Value, for keyPath: KeyPath<ConfKeys, InjectedKey.Type>) {
		Self.setRootValue(newValue, for: InjectedKey.self)
	}
	
	/* *** Same as both of the above, via a subscript. *** */
	
	@inlinable
	static subscript<InjectedKey : ConfKeyMainActor>(rootValueForKey key: InjectedKey.Type = InjectedKey.self) -> InjectedKey.Value {
		get {   rootValue(          for: InjectedKey.self)}
		set {setRootValue(newValue, for: InjectedKey.self)}
	}
	
	@inlinable
	static subscript<InjectedKey : ConfKeyMainActor>(rootValueFor keyPath: KeyPath<ConfKeys, InjectedKey.Type>) -> InjectedKey.Value {
		get {   rootValue(          for: InjectedKey.self)}
		set {setRootValue(newValue, for: InjectedKey.self)}
	}
	
}
