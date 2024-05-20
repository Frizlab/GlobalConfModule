import Foundation

import Configuration



public final class DocAutoInjectedService {
	
}

extension DocAutoInjectedService : AutoInjectable {
	public struct AutoInjectionKey : ConfKey {
		public typealias Value = DocAutoInjectedService
		public static let defaultValue: Value! = .init()
	}
}
