import Foundation



@propertyWrapper
public struct Injected<InjectedType : Sendable> : Sendable {
	
	public var wrappedValue: InjectedType {
		return erasedAccessor()
	}
	
	internal let erasedAccessor: @Sendable () -> InjectedType
	
}
