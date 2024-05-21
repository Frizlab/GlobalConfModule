import Foundation

import SwiftCompilerPlugin
import SwiftSyntaxMacros



@main
struct ConfigurationMacrosPlugin : CompilerPlugin {
	
	let providingMacros: [Macro.Type] = [
		ConfKeyMacro.self,
	]
	
}
