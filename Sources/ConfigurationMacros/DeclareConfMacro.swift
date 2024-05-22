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
	
	/* Example of use:
	 *   #conf("OSLog", OSLog?.self, unsafeNonIsolated: true, ConfKeys.self, ["urlRequestOperation", "oslog"], .default)
	 *   /* The unsafeNonIsolated and conf key container (here `ConfKeys.self`) parameters are optional. */
	 * Arguments:
	 *   - Name of the key to create for the configuration;
	 *   - Type of the configuration entry;
	 *   - Optional: pass true for unsafeNonIsolated if the configuration uses an unsafe type;
	 *   - The path to the conf key to create;
	 *   - The default value for the configuration. */
	public static func expansion(of node: some FreestandingMacroExpansionSyntax, in context: some MacroExpansionContext) throws -> [DeclSyntax] {
#if canImport(SwiftSyntax509)
		guard let macroName = MacroName(rawValue: node.macro.text) else {
			throw Err.internalError(message: "Unknown macro name")
		}
#else
		guard let macroName = MacroName(rawValue: node.macroName.text) else {
			throw Err.internalError(message: "Unknown macro name")
		}
#endif
		
#if canImport(SwiftSyntax509)
		var args = Array(node.argumentList.reversed())
#else
		var args = Array(node.arguments.reversed())
#endif
		/* Get confKey. */
		let confKeyArg = try args.popLast() ?! Err.missingArgument(argname: "confKey")
		guard confKeyArg.label == nil else {
			throw Err.invalidSyntax(message: "confKey argument should not have a label")
		}
		/* Get confType. */
		let confTypeArg = try args.popLast() ?! Err.missingArgument(argname: "confType")
		guard confTypeArg.label == nil else {
			throw Err.invalidSyntax(message: "confType argument should not have a label")
		}
		/* Get optional parameter global actor or next arg. */
		var curAmbiguous = try args.popLast() ?! Err.missingArgument(argname: "defaultValue")
		let actorArg: LabeledExprSyntax
		if curAmbiguous.label?.text == "on" {
			actorArg = curAmbiguous
			curAmbiguous = try args.popLast() ?! Err.missingArgument(argname: "defaultValue")
		} else {
			actorArg = LabeledExprSyntax(label: "on", expression: NilLiteralExprSyntax())
		}
		/* Get optional parameter unsafe nonisolated value or next arg. */
		let nonIsolatedArg: LabeledExprSyntax
		if curAmbiguous.label?.text == "unsafeNonIsolated" {
			nonIsolatedArg = curAmbiguous
			curAmbiguous = try args.popLast() ?! Err.missingArgument(argname: "defaultValue")
		} else {
			nonIsolatedArg = LabeledExprSyntax(label: "unsafeNonIsolated", expression: BooleanLiteralExprSyntax(booleanLiteral: false))
		}
		/* Get optional parameter custom conf key name or next arg. */
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
		confKeyArg: LabeledExprSyntax,
		confTypeArg: LabeledExprSyntax,
		actorArg: LabeledExprSyntax,
		nonIsolatedArg: LabeledExprSyntax,
		confKeyNameArg: LabeledExprSyntax,
		defaultValueArg: LabeledExprSyntax,
		macroName: MacroName,
		in context: some MacroExpansionContext
	) throws -> [DeclSyntax] {
		let confKey      = try confKeyArg    .extractStaticString        (argname: "confKey")
		let confBaseType = try confTypeArg   .extractSwiftType           (argname: "confType")
		let actor        = try actorArg      .extractOptionalSwiftType   (argname: "globalActor")
		let nonIsolated  = try nonIsolatedArg.extractBool                (argname: "unsafeNonIsolated")
		let confKeyName  = try confKeyNameArg.extractOptionalStaticString(argname: "customConfKeyName") ?? "ConfKey_\(confKey)"
		let confType: ExprSyntax
		let defaultValue: ExprSyntax
		switch macroName {
			case .declareConfKey:           defaultValue = ".some(\(raw: defaultValueArg.expression))"; confType = confBaseType
			case .declareServiceKey:        defaultValue = defaultValueArg.expression;                  confType = confBaseType
			case .declareServiceFactoryKey: defaultValue = defaultValueArg.expression;                  confType = "(@Sendable () -> \(raw: confBaseType))"
		}
		return [
			#"""
				public struct \#(raw: confKeyName) : ConfKey\#(raw: actor.flatMap{ "\($0)" } ?? "") {
					public typealias Value = \#(raw: confType)
					public \#(raw: nonIsolated ? "nonisolated(unsafe) " : "")static let defaultValue: \#(raw: confType)! = \#(raw: defaultValue)
				}
				"""#,
			#"""
				public var \#(raw: confKey): \#(raw: confKeyName).Type {\#(raw: confKeyName).self}
				"""#
		]
	}
	
}
