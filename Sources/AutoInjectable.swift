import Foundation



public protocol AutoInjectable {
	
	static var injectionPath: WritableKeyPath<ServiceContext, Self> {get}
	
}


public extension Injected where InjectedType : AutoInjectable {
	
	static var value: InjectedType {
		get {Self.value(InjectedType.injectionPath)}
		set {Self.setValue(newValue, for: InjectedType.injectionPath)}
	}
	
	init() {
		self.init(InjectedType.injectionPath)
	}
	
}
