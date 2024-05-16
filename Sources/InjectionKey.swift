import Foundation

import ServiceContextModule



public protocol InjectionKey : ServiceContextKey {
	
	associatedtype Isolation : Actor
	
	/**
	 The default value for the injected key.
	 
	 If this is set to `nil`, the value **must** be set by the dependency clients before trying to retrieve it. */
	static var defaultValue: @Sendable (_ on: isolated Isolation) -> Value? {get}
	
}
