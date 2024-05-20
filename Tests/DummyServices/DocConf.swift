import Foundation

import Configuration



public struct DocConfKey : ConfKey {
	public typealias Value = Int
	public static let defaultValue: Value! = 42
}
public extension ConfKeys {
	var docConf: DocConfKey.Type {DocConfKey.self}
}
internal extension Conf {
	static var docConf: Int {Conf[\.docConf]}
}
