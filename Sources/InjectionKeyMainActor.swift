import Foundation

import ServiceContextModule



@MainActor
public protocol InjectionKeyMainActor : ServiceContextKey {
	
	/**
	 The default value for the injected key.
	 
	 If this is set to `nil`, the value **must** be set by the dependency clients before trying to retrieve it. */
	static var defaultValue: Value! {get}
	
}


public extension Injected {
	
	@MainActor
	static func value<InjectedKey : InjectionKeyMainActor>(_ keyType: InjectedKey.Type = InjectedKey.self) -> InjectedType
	where InjectedKey.Value == InjectedType {
		return context[InjectedKey.self] ?? InjectedKey.defaultValue!
	}
	
	@MainActor
	static func value<InjectedKey : InjectionKeyMainActor>(_ keyPath: KeyPath<InjectionKeys, InjectedKey.Type>) -> InjectedType
	where InjectedKey.Value == InjectedType {
		return context[InjectedKey.self] ?? InjectedKey.defaultValue
	}
	
	@MainActor
	init<InjectedKey : InjectionKeyMainActor>(_ keyPath: KeyPath<InjectionKeys, InjectedKey.Type>)
	where InjectedKey.Value == InjectedType {
		let defaultValue = InjectedKey.defaultValue
		self.erasedAccessor = { context[InjectedKey.self] ?? defaultValue! }
	}
	
}

public extension Injected where InjectedType : AutoInjectableMainActor {
	
	@MainActor
	static var value: InjectedType {
		get {context[InjectedType.AutoInjectionKey.self] ?? InjectedType.AutoInjectionKey.defaultValue}
		set {context[InjectedType.AutoInjectionKey.self] = newValue}
	}
	
	@MainActor
	init() {
		let defaultValue = InjectedType.AutoInjectionKey.defaultValue
		self.erasedAccessor = { context[InjectedType.AutoInjectionKey.self] ?? defaultValue! }
	}
	
}