import Foundation

import ServiceContextModule



public protocol ConfKey : ServiceContextKey {

	/**
	 The default value for the conf key.
	 
	 If this is set to `nil`, the value **must** be set by the dependency clients before trying to retrieve it. */
	static var defaultValue: Value! {get}
	
}
