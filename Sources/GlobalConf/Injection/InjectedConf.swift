import Foundation



@propertyWrapper
public struct InjectedConf<InjectedType : Sendable> : Sendable {
	
	public var wrappedValue: InjectedType {
		return erasedAccessor()
	}
	
	internal let erasedAccessor: @Sendable () -> InjectedType
	
}
