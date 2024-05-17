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
		self.erasedAccessor = { context[InjectedKey.self] ?? defaultValue! }
	}
	
}

public extension Injected {
	
	static func value<InjectedKey : InjectionKey>(for keyType: InjectedKey.Type = InjectedKey.self) -> InjectedType
	where InjectedKey.Value == InjectedType {
		return context[InjectedKey.self] ?? InjectedKey.defaultValue
	}
	
	static func setValue<InjectedKey : InjectionKey>(_ newValue: InjectedType, for keyType: InjectedKey.Type = InjectedKey.self)
	where InjectedKey.Value == InjectedType {
		context[InjectedKey.self] = newValue
	}
	
	@inlinable
	static func value<InjectedKey : InjectionKey>(for keyPath: KeyPath<InjectionKeys, InjectedKey.Type>) -> InjectedType
	where InjectedKey.Value == InjectedType {
		return Self.value(for: InjectedKey.self)
	}
	
	@inlinable
	static func setValue<InjectedKey : InjectionKey>(_ newValue: InjectedType, for keyPath: KeyPath<InjectionKeys, InjectedKey.Type>)
	where InjectedKey.Value == InjectedType {
		Self.setValue(newValue, for: InjectedKey.self)
	}
	
}

public extension Injected where InjectedType : AutoInjectable {
	
	@inlinable
	static var value: InjectedType {
		get {   value(          for: InjectedType.AutoInjectionKey.self)}
		set {setValue(newValue, for: InjectedType.AutoInjectionKey.self)}
	}
	
	init() {
		let defaultValue = InjectedType.AutoInjectionKey.defaultValue
		self.erasedAccessor = { context[InjectedType.AutoInjectionKey.self] ?? defaultValue! }
	}
	
}
