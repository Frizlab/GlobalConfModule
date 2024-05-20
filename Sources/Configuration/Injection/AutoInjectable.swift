import Foundation

import ServiceContextModule



public protocol AutoInjectable : Sendable {
	
	associatedtype AutoInjectionKey : ConfKey where AutoInjectionKey.Value == Self
	
}
