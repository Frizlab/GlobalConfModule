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
	
	/* This would be amazing, but it does not work: <https://github.com/apple/swift/issues/57696>. */
//	public init(_ keyPath: KeyPath<InjectionKeys.Type, Key.Type>) {
//		self.key = InjectionKeys.self[keyPath: keyPath]
//	}
	
}
