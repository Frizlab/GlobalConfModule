import Foundation



@MainActor
public protocol InjectionKey {
	
	/** The associated type representing the type of the dependency injection key’s value. */
	associatedtype Value
	
	/** The default value for the dependency injection key. */
	static var currentValue: Self.Value {get set}
	
}
