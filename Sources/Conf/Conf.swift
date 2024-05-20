import Foundation

import SafeGlobal
import ServiceContextModule



public enum Conf : Sendable {
	
	@SafeGlobal
	internal static var rootContext = ServiceContext.topLevel
	
	internal static var currentContext: ServiceContext {
		currentTaskContext ?? rootContext
	}
	
	@TaskLocal
	internal static var currentTaskContext: ServiceContext?
	
}
