import Foundation

import GlobalConfModule



public final class DocAutoInjectedService {
}

extension ConfKeys {
	#declareServiceKey(nil, DocAutoInjectedService.self, "DocAutoInjectedServiceKey", defaultValue: .init())
}
extension DocAutoInjectedService : AutoInjectable {
	public typealias AutoInjectionKey = ConfKeys.DocAutoInjectedServiceKey
}
