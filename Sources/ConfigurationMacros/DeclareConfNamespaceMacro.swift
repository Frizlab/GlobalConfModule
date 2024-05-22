import Foundation

import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import UnwrapOrThrow



public struct DeclareConfNamespaceMacro : DeclarationMacro, FreestandingMacro {
	
	public static func expansion(of node: some FreestandingMacroExpansionSyntax, in context: some MacroExpansionContext) throws -> [DeclSyntax] {
#if canImport(SwiftSyntax509)
		var args = Array(node.argumentList.reversed())
#else
		var args = Array(node.arguments.reversed())
#endif
		/* Get accessorName. */
		let accessorNameArg = try args.popLast() ?! Err.missingArgument(argname: "accessorName")
		guard accessorNameArg.label == nil else {
			throw Err.invalidSyntax(message: "accessorName argument should not have a label")
		}
		let accessorName = try accessorNameArg.extractStaticString(argname: "accessorName")
		
		/* Get namespaceKeyName. */
		let namespaceKeyName: String
		if let arg = args.popLast() {
			guard arg.label == nil else {
				throw Err.invalidSyntax(message: "namespaceKeyName argument should not have a label")
			}
			namespaceKeyName = try arg.extractStaticString(argname: "namespaceKeyName")
		} else {
			namespaceKeyName = "ConfNamespace_\(accessorName)"
		}
		
		guard args.isEmpty else {
			throw Err.invalidSyntax(message: "Too many arguments to the macro")
		}
		
		return [
			/* Would would use an enum and have static vars if <https://forums.swift.org/t/pitch-metatype-keypaths/70767>.
			 * For now we get “Key path cannot refer to static member” if we do this… */
			"struct \(raw: namespaceKeyName) {}",
			/* Would be `URLRequestOperation.Type {URLRequestOperation.self}` if we could use an enum. */
			"var \(raw: accessorName): \(raw: namespaceKeyName) {\(raw: namespaceKeyName)()}"
		]
	}
	
}
