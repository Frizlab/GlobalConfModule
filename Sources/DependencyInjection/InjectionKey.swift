import Foundation



public protocol InjectionKey {
	
	/** The associated type representing the type of the dependency injection key’s value. */
	associatedtype Value
	
	/**
	 The current value for the dependency injection key.
	 
	 The value is not thread-safe (global shared mutable state), hence its unsafe prefix.
	 To use a thread-safe value, use ``currentValue``.
	 
	 In theory you should never have to access the currentValue of an ``InjectionKey`` anyway.
	 Instead you should use the ``Injected`` property wrapper, or the ``InjectedValues`` accessor convenience. */
	static var unsafeCurrentValue: Self.Value! {get set}
	
}


private let lock = NSLock()
public extension InjectionKey {
	
	static var currentValue: Self.Value! {
		@Sendable get {lock.withLock{ unsafeCurrentValue }}
		@Sendable set {lock.withLock{ unsafeCurrentValue = newValue }}
	}
	
}
