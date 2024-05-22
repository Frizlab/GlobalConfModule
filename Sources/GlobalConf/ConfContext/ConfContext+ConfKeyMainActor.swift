import Foundation

import ServiceContextModule



@MainActor
public extension ConfContext {
	
	subscript<Key : ConfKeyMainActor>(key key: Key.Type = Key.self) -> Key.Value? {
		get {actualContext[Key.self]}
		set {actualContext[Key.self] = newValue}
	}
	
	subscript<Key : ConfKeyMainActor>(keyPath: KeyPath<ConfKeys, Key.Type>) -> Key.Value? {
		get {actualContext[Key.self]}
		set {actualContext[Key.self] = newValue}
	}
	
}
