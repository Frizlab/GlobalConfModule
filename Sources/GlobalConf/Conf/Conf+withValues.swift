import Foundation

import ServiceContextModule



public extension Conf {
	
	/* *** Overridding multiple injected values for the current Task. *** */
	
	static func withValues<T>(contextSetBlock: (inout ConfContext) -> Void, operation: () throws -> T) rethrows -> T {
		var newContext = ConfContext(Conf.currentContext)
		contextSetBlock(&newContext)
		return try Conf.$currentTaskContext.withValue(newContext.actualContext, operation: operation)
	}
	
	@_unsafeInheritExecutor /* Same as withValue declared in the stdlib (and ServiceContext); because we do not want to hop off the executor at all. */
	static func withValues<T>(contextSetBlock: (inout ConfContext) -> Void, operation: () async throws -> T) async rethrows -> T {
		var newContext = ConfContext(Conf.currentContext)
		contextSetBlock(&newContext)
		return try await Conf.$currentTaskContext.withValue(newContext.actualContext, operation: operation)
	}

}
