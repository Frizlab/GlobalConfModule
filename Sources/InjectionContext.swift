import Foundation

import SafeGlobal
import ServiceContextModule



public enum InjectionContext : Sendable {
	
	@SafeGlobal
	internal static var root = ServiceContext.topLevel
	
	internal static var current: ServiceContext {
		forCurrentTask ?? root
	}
	
	@TaskLocal
	internal static var forCurrentTask: ServiceContext?
	
}


public extension InjectionContext {
	
	/* *** Overridding multiple injected values for the current Task. *** */
	
	static func withValues<T>(contextSetBlock: (inout ServiceContext) -> Void, operation: () throws -> T) rethrows -> T {
		var newContext = InjectionContext.current
		contextSetBlock(&newContext)
		return try InjectionContext.$forCurrentTask.withValue(newContext, operation: operation)
	}
	
	@_unsafeInheritExecutor /* Same as withValue declared in the stdlib (and ServiceContext); because we do not want to hop off the executor at all. */
	static func withValues<T>(contextSetBlock: (inout ServiceContext) -> Void, operation: () async throws -> T) async rethrows -> T {
		var newContext = InjectionContext.current
		contextSetBlock(&newContext)
		return try await ServiceContext.$current.withValue(newContext, operation: operation)
	}

}
