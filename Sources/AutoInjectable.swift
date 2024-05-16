import Foundation

import ServiceContextModule



public protocol AutoInjectable : Sendable {
	
	associatedtype AutoInjectionKey : InjectionKey where AutoInjectionKey.Value == Self
	
}
