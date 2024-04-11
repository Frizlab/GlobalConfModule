import Foundation

import SafeGlobal
@_exported import ServiceContextModule



@SafeGlobal
private var context = ServiceContext.topLevel

@propertyWrapper
public struct Injected<Key> {
	
	public static func value(_ keyPath: KeyPath<ServiceContext, Key?>) -> Key! {
		context[keyPath: keyPath]
	}
	
	public static func setValue(_ value: Key, for keyPath: WritableKeyPath<ServiceContext, Key?>) {
		context[keyPath: keyPath] = value
	}
	
	public var wrappedValue: Key! {
		Self.value(keyPath)
	}
	
	public init(_ keyPath: KeyPath<ServiceContext, Key?>) {
		self.keyPath = keyPath
	}
	
	private let keyPath: KeyPath<ServiceContext, Key?>
	
}
