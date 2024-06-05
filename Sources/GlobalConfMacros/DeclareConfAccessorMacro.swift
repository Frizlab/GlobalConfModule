import Foundation

import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros



public struct DeclareConfAccessorMacro : DeclarationMacro, FreestandingMacro {
	
	public enum MacroName : String {
		
		case declareConfAccessor
		case declareConfFactoryAccessor
		
	}
	
	public static func expansion(of node: some FreestandingMacroExpansionSyntax, in context: some MacroExpansionContext) throws -> [DeclSyntax] {
#if canImport(SwiftSyntax510)
		guard let macroName = MacroName(rawValue: node.macroName.text) else {
			throw Err.internalError(message: "Unknown macro name")
		}
#else
		guard let macroName = MacroName(rawValue: node.macro.text) else {
			throw Err.internalError(message: "Unknown macro name")
		}
#endif
		
#if canImport(SwiftSyntax510)
		var args = Array(node.arguments.reversed())
#else
		var args = Array(node.argumentList.reversed())
#endif
		var curAmbiguous: LabeledExprSyntax?
		/* Get confKeyPath. */
		let confKeyPathArg = try args.popLast().unwrap(orThrow: Err.missingArgument(argname: "confKeyPath"))
		guard confKeyPathArg.label == nil else {
			throw Err.invalidSyntax(message: "confKeyPath argument should not have a label")
		}
		/* Get confType. */
		let confTypeArg = try args.popLast().unwrap(orThrow: Err.missingArgument(argname: "confType"))
		guard confTypeArg.label == nil else {
			throw Err.invalidSyntax(message: "confType argument should not have a label")
		}
		/* Get optional parameter global actor and next arg. */
		curAmbiguous = args.popLast()
		let actorArg: LabeledExprSyntax
		if let arg = curAmbiguous, arg.label?.text == "on" {
			actorArg = arg
			curAmbiguous = args.popLast()
		} else {
			actorArg = LabeledExprSyntax(label: "on", expression: NilLiteralExprSyntax())
		}
		/* Get optional parameter unsafe nonisolated value and next arg. */
		let nonIsolatedArg: LabeledExprSyntax
		if let arg = curAmbiguous, arg.label?.text == "unsafeNonIsolated" {
			nonIsolatedArg = arg
			curAmbiguous = args.popLast()
		} else {
			nonIsolatedArg = LabeledExprSyntax(label: "unsafeNonIsolated", expression: BooleanLiteralExprSyntax(booleanLiteral: false))
		}
		/* Get optional parameter custom name value and next arg. */
		let customNameArg: LabeledExprSyntax
		if let arg = curAmbiguous, arg.label?.text == nil {
			customNameArg = arg
		} else {
			customNameArg = LabeledExprSyntax(label: nil, expression: NilLiteralExprSyntax())
		}
		
		guard args.isEmpty else {
			throw Err.invalidSyntax(message: "Too many arguments to the macro")
		}
		
		return try expansionFor(
			confKeyPathArg: confKeyPathArg,
			confTypeArg: confTypeArg,
			actorArg: actorArg,
			nonIsolatedArg: nonIsolatedArg,
			customNameArg: customNameArg,
			macroName: macroName,
			in: context
		)
	}
	
	private static func expansionFor(
		confKeyPathArg: LabeledExprSyntax,
		confTypeArg: LabeledExprSyntax,
		actorArg: LabeledExprSyntax,
		nonIsolatedArg: LabeledExprSyntax,
		customNameArg: LabeledExprSyntax,
		macroName: MacroName,
		in context: some MacroExpansionContext
	) throws -> [DeclSyntax] {
		let confKeyPath  = try confKeyPathArg.extractKeyPath             (argname: "confKeyPath")
		let confType     = try confTypeArg   .extractSwiftType           (argname: "confType")
		let actor        = try actorArg      .extractOptionalSwiftType   (argname: "globalActor")
		let nonIsolated  = try nonIsolatedArg.extractBool                (argname: "unsafeNonIsolated")
		let name         = try customNameArg .extractOptionalStaticString(argname: "customConfKeyName") ?? confKeyPath.dropFirst().replacingOccurrences(of: ".", with: "_")
		let isFactory = switch macroName {
			case .declareConfAccessor:        false
			case .declareConfFactoryAccessor: true
		}
		return [
			#"\#(raw: actor.flatMap{ "@\($0)" } ?? "") internal \#(raw: nonIsolated ? "nonisolated(unsafe) " : "")static var \#(raw: name): \#(raw: confType) {Conf[\\#(raw: confKeyPath)]\#(raw: isFactory ? "()" : "")}"#
		]
	}
	
}
