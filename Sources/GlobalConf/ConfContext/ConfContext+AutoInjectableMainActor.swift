import Foundation

import ServiceContextModule



@MainActor
public extension ConfContext {
	
	subscript<Value : AutoInjectableMainActor>(autoInjectable autoInjectable: Value.Type = Value.self) -> Value? {
		get {actualContext[Value.AutoInjectionKey.self]}
		set {actualContext[Value.AutoInjectionKey.self] = newValue}
	}
	
}
