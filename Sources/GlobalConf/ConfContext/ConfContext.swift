import Foundation

import ServiceContextModule



/* This is a wrapper around a service context object.
 * We use a ServiceContext directly in most the methods except
 *  when giving the possibility to the user to update multiple configurations at the same time.
 * For this case we give the user a ConfContext in order to prevent him to set weird things in the context.
 * Note it would not matter if he did; we could give the ServiceContext directly. */
public struct ConfContext : Sendable {
	
	public static func new() -> ConfContext {
		return .init(.topLevel)
	}
	
	internal var actualContext: ServiceContext
	
	internal init(_ actualContext: ServiceContext) {
		self.actualContext = actualContext
	}
	
}
