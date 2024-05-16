import Foundation

import ServiceContextModule



public protocol AutoInjectableMainActor : Sendable {
	
	associatedtype AutoInjectionKey : InjectionKeyMainActor where AutoInjectionKey.Value == Self
	
}
