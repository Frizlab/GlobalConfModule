import Foundation

import SafeGlobal
@_exported import ServiceContextModule



@SafeGlobal
private var context = ServiceContext.topLevel

@propertyWrapper
public struct Injected<InjectedType> {
	
	public static func value(_ keyPath: KeyPath<ServiceContext, InjectedType>) -> InjectedType {
		context[keyPath: keyPath]
	}
	
	public static func setValue(_ value: InjectedType, for keyPath: WritableKeyPath<ServiceContext, InjectedType>) {
		context[keyPath: keyPath] = value
	}
	
	public var wrappedValue: InjectedType {
		Self.value(keyPath)
	}
	
	public init(_ keyPath: KeyPath<ServiceContext, InjectedType>) {
		self.keyPath = keyPath
	}
	
	private let keyPath: KeyPath<ServiceContext, InjectedType>
	
}
