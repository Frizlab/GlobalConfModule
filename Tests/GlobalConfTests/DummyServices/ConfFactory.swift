import Foundation

import GlobalConfModule



extension ConfKeys {
	#declareConfFactoryKey("randomInt", Int.self, defaultValue: { .random(in: 0..<42) })
}

extension Conf {
	#declareConfFactoryAccessor(\.randomInt, Int.self)
}
