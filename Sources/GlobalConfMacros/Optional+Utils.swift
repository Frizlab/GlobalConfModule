import Foundation



extension Optional {
	
	func unwrap(orThrow error: @autoclosure () -> Error) throws -> Wrapped {
		guard let unwrapped = self else {
			throw error()
		}
		return unwrapped
	}
	
}
