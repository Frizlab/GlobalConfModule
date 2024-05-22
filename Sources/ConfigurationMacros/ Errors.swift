import Foundation



public enum ConfigurationMacrosError : Error {
	
	case invalidSyntax(message: String)
	case missingArgument(argname: String)
	case invalidArgument(message: String)
	
	case internalError(message: String)
	
}
typealias Err = ConfigurationMacrosError
