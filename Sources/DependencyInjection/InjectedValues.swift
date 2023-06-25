import Foundation



/** Provides access to injected dependencies. */
public struct InjectedValues : Sendable {
	
	/** A static subscript for updating the ``InjectionKey/currentValue``. */
	public static subscript<K>(key: K.Type) -> K.Value! where K : InjectionKey {
		get {key.currentValue}
		set {key.currentValue = newValue}
	}
	
}
