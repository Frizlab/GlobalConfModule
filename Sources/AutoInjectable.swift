import Foundation



public protocol AutoInjectable {
	
	associatedtype InjectedType
	static var injectionPath: WritableKeyPath<ServiceContext, InjectedType?> {get}
	
}


public extension Injected where Key : AutoInjectable, Key.InjectedType == Key {
	
	static var value: Key! {
		get {Self.value(Key.injectionPath)}
		set {Self.setValue(newValue, for: Key.injectionPath)}
	}
	
	init() {
		self.init(Key.injectionPath)
	}
	
}
