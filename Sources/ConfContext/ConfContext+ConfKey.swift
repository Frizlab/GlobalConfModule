import Foundation

import ServiceContextModule



public extension ConfContext {
	
	subscript<Key : ConfKey>(key key: Key.Type = Key.self) -> Key.Value? {
		get {actualContext[Key.self]}
		set {actualContext[Key.self] = newValue}
	}
	
	subscript<Key : ConfKey>(keyPath: KeyPath<ConfKeys, Key.Type>) -> Key.Value? {
		get {actualContext[Key.self]}
		set {actualContext[Key.self] = newValue}
	}
	
}
