import Foundation

import ServiceContextModule



public protocol AutoInjectableMainActor : Sendable {
	
	associatedtype AutoInjectionKey : ConfKeyMainActor where AutoInjectionKey.Value == Self
	
}
