import Foundation

import GlobalConfModule



extension ConfKeys {
	#declareConfKey("docConf", Int.self, defaultValue: 42)
}
internal extension Conf {
	static var docConf: Int {Conf[\.docConf]}
}
