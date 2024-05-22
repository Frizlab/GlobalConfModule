import Foundation

import GlobalConfModule



public protocol DocService : Sendable {
	func doAmazingStuff()
}
public final class DefaultDocService : DocService {
	public func doAmazingStuff() {}
}

extension ConfKeys {
	#declareServiceKey("docService", DocService.self, defaultValue: DefaultDocService())
	#declareServiceFactoryKey("decServiceFactory", DocService.self, defaultValue: { DefaultDocService() })
}
