import Foundation

import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import UnwrapOrThrow



public struct DeclareConfNamespaceMacro : DeclarationMacro, FreestandingMacro {
	
	public static func expansion(of node: some FreestandingMacroExpansionSyntax, in context: some MacroExpansionContext) throws -> [DeclSyntax] {
#if canImport(SwiftSyntax510)
		var args = Array(node.arguments.reversed())
#else
		var args = Array(node.argumentList.reversed())
#endif
		var curAmbiguous: LabeledExprSyntax
		/* Get optional parameter visibility and next arg (accessorName). */
		curAmbiguous = try args.popLast() ?! Err.missingArgument(argname: "confKey")
		let visibilityArg: LabeledExprSyntax
		let accessorNameArg: LabeledExprSyntax
		if curAmbiguous.label?.text == "visibility" {
			visibilityArg = curAmbiguous
			accessorNameArg = try args.popLast() ?! Err.missingArgument(argname: "confKey")
		} else {
			visibilityArg = LabeledExprSyntax(label: "visibility", expression: MemberAccessExprSyntax(period: ".", name: "public"))
			accessorNameArg = curAmbiguous
		}
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
		
		let visibility = try visibilityArg.extractVisibility(argname: "visibility")
		
		return [
			/* Would would use an enum and have static vars if <https://forums.swift.org/t/pitch-metatype-keypaths/70767>.
			 * For now we get “Key path cannot refer to static member” if we do this… */
			"\(raw: visibility) struct \(raw: namespaceKeyName) {}",
			/* Would be `TheType.Type {TheType.self}` if we could use an enum. */
			"\(raw: visibility) var \(raw: accessorName): \(raw: namespaceKeyName) {\(raw: namespaceKeyName)()}"
		]
	}
	
}
