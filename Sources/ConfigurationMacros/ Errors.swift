import Foundation



public enum ConfigurationMacrosError : Error {
	
	case missingArgument(argname: String)
	case invalidArgument(message: String)
	
}
typealias Err = ConfigurationMacrosError
