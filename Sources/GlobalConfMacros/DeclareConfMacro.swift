import Foundation

import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import UnwrapOrThrow



public struct DeclareConfMacro : DeclarationMacro, FreestandingMacro {
	
	public enum MacroName : String {
		
		case declareConfKey
		case declareServiceKey
		case declareServiceFactoryKey
		
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
		var curAmbiguous: LabeledExprSyntax
		/* Get optional parameter visibility and next arg. */
		curAmbiguous = try args.popLast() ?! Err.missingArgument(argname: "confKey")
		let visibilityArg: LabeledExprSyntax
		let confKeyArg: LabeledExprSyntax
		if curAmbiguous.label?.text == "visibility" {
			visibilityArg = curAmbiguous
			confKeyArg = try args.popLast() ?! Err.missingArgument(argname: "confKey")
		} else {
			visibilityArg = LabeledExprSyntax(label: "visibility", expression: MemberAccessExprSyntax(period: ".", name: "public"))
			confKeyArg = curAmbiguous
		}
		/* Get confKey. */
		guard confKeyArg.label == nil else {
			throw Err.invalidSyntax(message: "confKey argument should not have a label")
		}
		/* Get confType. */
		let confTypeArg = try args.popLast() ?! Err.missingArgument(argname: "confType")
		guard confTypeArg.label == nil else {
			throw Err.invalidSyntax(message: "confType argument should not have a label")
		}
		/* Get optional parameter global actor and next arg. */
		curAmbiguous = try args.popLast() ?! Err.missingArgument(argname: "defaultValue")
		let actorArg: LabeledExprSyntax
		if curAmbiguous.label?.text == "on" {
			actorArg = curAmbiguous
			curAmbiguous = try args.popLast() ?! Err.missingArgument(argname: "defaultValue")
		} else {
			actorArg = LabeledExprSyntax(label: "on", expression: NilLiteralExprSyntax())
		}
		/* Get optional parameter unsafe nonisolated value and next arg. */
		let nonIsolatedArg: LabeledExprSyntax
		if curAmbiguous.label?.text == "unsafeNonIsolated" {
			nonIsolatedArg = curAmbiguous
			curAmbiguous = try args.popLast() ?! Err.missingArgument(argname: "defaultValue")
		} else {
			nonIsolatedArg = LabeledExprSyntax(label: "unsafeNonIsolated", expression: BooleanLiteralExprSyntax(booleanLiteral: false))
		}
		/* Get optional parameter custom conf key name and next arg. */
		let confKeyNameArg: LabeledExprSyntax
		let defaultValueArg: LabeledExprSyntax
		if curAmbiguous.label == nil {
			confKeyNameArg = curAmbiguous
			defaultValueArg = try args.popLast() ?! Err.missingArgument(argname: "defaultValue")
		} else {
			confKeyNameArg = LabeledExprSyntax(label: nil, expression: NilLiteralExprSyntax())
			defaultValueArg = curAmbiguous
		}
		guard defaultValueArg.label?.text == "defaultValue" else {
			throw Err.invalidSyntax(message: "Incorrect label for defaultValue argument")
		}
		
		guard args.isEmpty else {
			throw Err.invalidSyntax(message: "Too many arguments to the macro")
		}
		
		return try expansionFor(
			visibilityArg: visibilityArg,
			confKeyArg: confKeyArg,
			confTypeArg: confTypeArg,
			actorArg: actorArg,
			nonIsolatedArg: nonIsolatedArg,
			confKeyNameArg: confKeyNameArg,
			defaultValueArg: defaultValueArg,
			macroName: macroName,
			in: context
		)
	}
	
	private static func expansionFor(
		visibilityArg: LabeledExprSyntax,
		confKeyArg: LabeledExprSyntax,
		confTypeArg: LabeledExprSyntax,
		actorArg: LabeledExprSyntax,
		nonIsolatedArg: LabeledExprSyntax,
		confKeyNameArg: LabeledExprSyntax,
		defaultValueArg: LabeledExprSyntax,
		macroName: MacroName,
		in context: some MacroExpansionContext
	) throws -> [DeclSyntax] {
		let visibility   = try visibilityArg .extractVisibility          (argname: "visibility")
		let confKey      = try confKeyArg    .extractOptionalStaticString(argname: "confKey")
		let confBaseType = try confTypeArg   .extractSwiftType           (argname: "confType")
		let actor        = try actorArg      .extractOptionalSwiftType   (argname: "globalActor")
		let nonIsolated  = try nonIsolatedArg.extractBool                (argname: "unsafeNonIsolated")
		let confKeyName  = try confKeyNameArg.extractOptionalStaticString(argname: "customConfKeyName") ?? confKey.flatMap{ "ConfKey_\($0)" } ?? context.makeUniqueName("ConfKey").text
		let confType: ExprSyntax
		let defaultValue: ExprSyntax
		switch macroName {
			case .declareConfKey:           defaultValue = ".some(\(raw: defaultValueArg.expression))"; confType = confBaseType
			case .declareServiceKey:        defaultValue = defaultValueArg.expression;                  confType = confBaseType
			case .declareServiceFactoryKey: defaultValue = defaultValueArg.expression;                  confType = "(@Sendable () -> \(raw: confBaseType))"
		}
		return [
			#"""
				\#(raw: visibility) enum \#(raw: confKeyName) : ConfKey\#(raw: actor.flatMap{ "\($0)" } ?? "") {
					\#(raw: visibility) typealias Value = \#(raw: confType)
					\#(raw: visibility) \#(raw: nonIsolated ? "nonisolated(unsafe) " : "")static let defaultValue: \#(raw: confType)! = \#(raw: defaultValue)
				}
				"""#,
			confKey.flatMap{ #"\#(raw: visibility) var \#(raw: $0): \#(raw: confKeyName).Type {\#(raw: confKeyName).self}"# },
		].compactMap{ $0 }
	}
	
}
