import Foundation

import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import UnwrapOrThrow



public struct DeclareConfMacro : DeclarationMacro, FreestandingMacro {
	
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
		if node.macroName.text == "declareServiceFactory" {
			throw Err.internalError(message: "Not Implemented")
		}
		
		var args = Array(node.arguments.reversed())
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
			throw Err.invalidSyntax(message: "too many arguments to the macro")
		}
		
		return try expansionFor(
			confKeyArg: confKeyArg,
			confTypeArg: confTypeArg,
			actorArg: actorArg,
			nonIsolatedArg: nonIsolatedArg,
			confKeyNameArg: confKeyNameArg,
			defaultValueArg: defaultValueArg,
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
		in context: some MacroExpansionContext
	) throws -> [DeclSyntax] {
		let confKey     = try staticString        (from: confKeyArg,     argname: "confKey")
		let confType    = try swiftType           (from: confTypeArg,    argname: "confType")
		let actor       = try optionalSwiftType   (from: actorArg,       argname: "globalActor")
		let nonIsolated = try bool                (from: nonIsolatedArg, argname: "unsafeNonIsolated")
		let confKeyName = try optionalStaticString(from: confKeyNameArg, argname: "customConfKeyName") ?? "ConfKey_\(confKey)"
		return [
			#"""
				public struct \#(raw: confKeyName) : ConfKey\#(raw: actor.flatMap{ "\($0)" } ?? "") {
					public typealias Value = \#(raw: confType)
					public \#(raw: nonIsolated ? "nonisolated(unsafe) " : "")static let defaultValue: \#(raw: confType)! = \#(raw: defaultValueArg.expression)
				}
				"""#,
			#"""
				public var \#(raw: confKey): \#(raw: confKeyName).Type {\#(raw: confKeyName).self}
				"""#
		]
	}
	
	private static func staticString(from expr: LabeledExprSyntax, argname: String) throws -> String {
		guard let segments = expr.expression.as(StringLiteralExprSyntax.self)?.segments,
				segments.count == 1,
				case .stringSegment(let literalSegment)? = segments.first
		else {
			throw Err.invalidArgument(message: "Expected a static String argument for \(argname)")
		}
		return literalSegment.content.text
	}
	
	private static func optionalStaticString(from expr: LabeledExprSyntax, argname: String) throws -> String? {
		if expr.expression.is(NilLiteralExprSyntax.self) {
			return nil
		}
		return try staticString(from: expr, argname: argname)
	}
	
	private static func keyPath(from expr: LabeledExprSyntax, argname: String) throws -> [String] {
		let ret: [String]
		if let string = try? staticString(from: expr, argname: argname) {
			ret = string.split(separator: ".", omittingEmptySubsequences: false).map(String.init)
		} else {
			guard let elements = expr.expression.as(ArrayExprSyntax.self)?.elements else {
				throw Err.invalidArgument(message: "Expected an array of String for \(argname)")
			}
			ret = try elements.map{ element in
				guard let segments = element.expression.as(StringLiteralExprSyntax.self)?.segments,
						segments.count == 1,
						case .stringSegment(let literalSegment)? = segments.first
				else {
					throw Err.invalidArgument(message: "Expected an array of String for \(argname)")
				}
				return literalSegment.content.text
			}
		}
		guard !ret.isEmpty else {
			throw Err.invalidArgument(message: "Expected non-empty array for \(argname)")
		}
		return ret
	}
	
	private static func bool(from expr: LabeledExprSyntax, argname: String) throws -> Bool {
		return switch expr.expression.as(BooleanLiteralExprSyntax.self)?.literal.text {
			case BooleanLiteralExprSyntax(booleanLiteral:  true).literal.text?: true
			case BooleanLiteralExprSyntax(booleanLiteral: false).literal.text?: false
			default:
				throw Err.invalidArgument(message: "Expected a literal Bool argument for \(argname)")
		}
	}
	
	private static func swiftType(from expr: LabeledExprSyntax, argname: String) throws -> ExprSyntax {
		guard let type = expr.expression.as(MemberAccessExprSyntax.self)?.base else {
			throw Err.invalidArgument(message: "Expected value to be a type for \(argname)")
		}
		return type.trimmed
	}
	
	private static func optionalSwiftType(from expr: LabeledExprSyntax, argname: String) throws -> ExprSyntax? {
		if expr.expression.is(NilLiteralExprSyntax.self) {
			return nil
		}
		return try swiftType(from: expr, argname: argname)
	}
	
}
