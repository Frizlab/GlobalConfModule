import Foundation

import GlobalConfModule



extension ConfKeys {
	#declareConfKey("docConf", Int.self, defaultValue: 42)
}
extension Conf {
	#declareConfAccessor(\.docConf, Int.self)
}
