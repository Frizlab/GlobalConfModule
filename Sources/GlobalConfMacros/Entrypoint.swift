import Foundation

import SwiftCompilerPlugin
import SwiftSyntaxMacros



@main
struct ConfigurationMacrosPlugin : CompilerPlugin {
	
	let providingMacros: [Macro.Type] = [
		DeclareConfAccessorMacro.self,
		DeclareConfMacro.self,
		DeclareConfNamespaceMacro.self,
	]
	
}
