import Foundation

import ServiceContextModule



/* We give convenient access to get/set the value of an auto-injectable type on ConfContext but not on Conf because
 *  there are no other accessors on ConfContext.
 * For Conf, one should usually use Injected instead to access Conf values. */
public extension ConfContext {
	
	subscript<Value : AutoInjectable>(autoInjectable autoInjectable: Value.Type = Value.self) -> Value? {
		get {actualContext[Value.AutoInjectionKey.self]}
		set {actualContext[Value.AutoInjectionKey.self] = newValue}
	}
	
}
