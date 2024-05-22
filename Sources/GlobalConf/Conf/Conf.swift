import Foundation

import SafeGlobal
import ServiceContextModule



public enum Conf : Sendable {
	
	internal static var currentContext: ServiceContext {
		currentTaskContext ?? rootContext
	}
	
	@SafeGlobal
	internal static var rootContext = ServiceContext.topLevel
	
	@TaskLocal
	internal static var currentTaskContext: ServiceContext?
	
}
