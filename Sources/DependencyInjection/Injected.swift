import Foundation



@propertyWrapper
public struct Injected<Key : InjectionKey> : Sendable {
	
	private let key: Key.Type
	
	public var wrappedValue: Key.Value! {
		InjectedValues[key]
	}
	
	public init(_ key: Key.Type = Key.self) {
		self.key = key
	}
	
}
