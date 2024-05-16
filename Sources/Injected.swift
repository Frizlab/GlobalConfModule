import Foundation

import SafeGlobal
import ServiceContextModule



@SafeGlobal
private var context = ServiceContext.topLevel

@propertyWrapper
public struct Injected<InjectedType : Sendable> : Sendable {
	
	public static func value<InjectedKey : InjectionKey>(_ keyPath: KeyPath<InjectionKeys, InjectedKey.Type>, on isolation: isolated InjectedKey.Isolation) -> InjectedType where InjectedKey.Value == InjectedType {
		let defaultValue = InjectedKey.defaultValue(isolation)
		return context[InjectedKey.self] ?? defaultValue!
	}
	
	public static func value<InjectedKey : InjectionKey>(_ keyType: InjectedKey.Type = InjectedKey.self, on isolation: isolated InjectedKey.Isolation) -> InjectedType where InjectedKey.Value == InjectedType {
		let defaultValue = InjectedKey.defaultValue(isolation)
		return context[InjectedKey.self] ?? defaultValue!
	}
	
	public static func setValue<InjectedKey : InjectionKey>(_ value: InjectedType, for keyPath: KeyPath<InjectionKeys, InjectedKey.Type>) where InjectedKey.Value == InjectedType {
		context[InjectedKey.self] = value
	}
	
	public var wrappedValue: InjectedType {
		return erasedAccessor()
	}
	
	public init<InjectedKey : InjectionKey>(_ keyPath: KeyPath<InjectionKeys, InjectedKey.Type>, on isolation: isolated InjectedKey.Isolation) where InjectedKey.Value == InjectedType {
		let defaultValue = InjectedKey.defaultValue(isolation)
		self.erasedAccessor = { context[InjectedKey.self] ?? defaultValue! }
	}
	
	private let erasedAccessor: @Sendable () -> InjectedType
	
}


public extension Injected where InjectedType : AutoInjectable {
	
//	static var value: InjectedType {
//		get {context[InjectedType.AutoInjectionKey.self] ?? InjectedType.AutoInjectionKey.defaultValue(DummyInjectionActor.shared)!}
//		set {context[InjectedType.AutoInjectionKey.self] = newValue}
//	}
	
	static func setValue(_ newValue: InjectedType) {
		context[InjectedType.AutoInjectionKey.self] = newValue
	}
	
	init(on isolation: isolated InjectedType.AutoInjectionKey.Isolation) {
		let defaultValue = InjectedType.AutoInjectionKey.defaultValue(isolation)
		self.erasedAccessor = { context[InjectedType.AutoInjectionKey.self] ?? defaultValue! }
	}
	
	init(on isolation: isolated DummyInjectionActor = .shared) where InjectedType.AutoInjectionKey.Isolation == DummyInjectionActor {
		let defaultValue = InjectedType.AutoInjectionKey.defaultValue(isolation)
		self.erasedAccessor = { context[InjectedType.AutoInjectionKey.self] ?? defaultValue! }
	}
	
}
