import Foundation

import Configuration



public protocol DocService : Sendable {
	func doAmazingStuff()
}
public final class DefaultDocService : DocService {
	public func doAmazingStuff() {}
}

public struct DocServiceConfKey : ConfKey {
	public typealias Value = DocService
	/* If no default value make sense, you can set `nil` here.
	 * Be aware the app _will_ crash if the dependency is accessed before the value is set! */
	public static let defaultValue: Value! = DefaultDocService()
}
public extension ConfKeys {
	var docService: DocServiceConfKey.Type {DocServiceConfKey.self}
}
