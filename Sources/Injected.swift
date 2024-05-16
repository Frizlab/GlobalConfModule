import Foundation

import SafeGlobal
import ServiceContextModule



@SafeGlobal
internal var context = ServiceContext.topLevel

@propertyWrapper
public struct Injected<InjectedType : Sendable> : Sendable {
	
	public var wrappedValue: InjectedType {
		return erasedAccessor()
	}
	
	internal let erasedAccessor: @Sendable () -> InjectedType
	
}
