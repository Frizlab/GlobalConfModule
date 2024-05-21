import Foundation

import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import UnwrapOrThrow



public struct ConfKeyMacro : DeclarationMacro, FreestandingMacro {
	
	/* Example of use:
	 *   #conf("OSLog", OSLog?.self, unsafeNonIsolated: true, ["urlRequestOperation", "oslog"], .default)
	 * Arguments:
	 *   - Name of the key to create for the configuration;
	 *   - Type of the configuration entry;
	 *   - Optional: pass true for unsafeNonIsolated if the configuration uses an unsafe type;
	 *   - The path to the conf key to create;
	 *   - The default value for the configuration. */
	public static func expansion(of node: some FreestandingMacroExpansionSyntax, in context: some MacroExpansionContext) throws -> [DeclSyntax] {
		var args = Array(node.arguments.reversed())
		let confKeyNameArg     = try args.popLast() ?! Err.missingArgument(argname: "confKeyName")
		let confTypeArg        = try args.popLast() ?! Err.missingArgument(argname: "confType")
		let isolationOrPathArg = try args.popLast() ?! Err.missingArgument(argname: "confKeyPath")
		let confPathArg: LabeledExprSyntax
		let nonIsolatedArg: LabeledExprSyntax
		if isolationOrPathArg.label?.text == "unsafeNonIsolated" {
			nonIsolatedArg = isolationOrPathArg
			confPathArg = try args.popLast() ?! Err.missingArgument(argname: "confKeyPath")
		} else {
			/* We do not put the label back in the non-isolated arg as we will not validate it.
			 * If we did, we should add it. */
			nonIsolatedArg = LabeledExprSyntax(/*label: "unsafeNonIsolated", */expression: BooleanLiteralExprSyntax(booleanLiteral: false))
			confPathArg = isolationOrPathArg
		}
		let defaultValueArg = try args.popLast() ?! Err.missingArgument(argname: "defaultValue")
		
		return try expansionFor(
			confKeyNameArg: confKeyNameArg,
			confTypeArg: confTypeArg,
			nonIsolatedArg: nonIsolatedArg,
			confPathArg: confPathArg,
			defaultValueArg: defaultValueArg,
			in: context
		)
	}
	
	private static func expansionFor(
		confKeyNameArg: LabeledExprSyntax,
		confTypeArg: LabeledExprSyntax,
		nonIsolatedArg: LabeledExprSyntax,
		confPathArg: LabeledExprSyntax, 
		defaultValueArg: LabeledExprSyntax,
		in context: some MacroExpansionContext
	) throws -> [DeclSyntax] {
		let confKeyName = try staticString(from: confKeyNameArg, argname: "confKeyName")
		let nonIsolated = try bool(from: nonIsolatedArg,   argname: "unsafeNonIsolated")
		return [
			#"""
				public struct MyBool : Sendable {
				    public typealias Value = Bool
				    public static let defaultValue: Value! = true
				}
				"""#,
			#"""
				extension ConfKeys {
				    public var myBool: MyBool.Type {MyBool.self}
				}
				"""#,
			#"""
				extension Conf {
				    internal var myBool: Bool {Conf[\ConfKeys.myBool]}
				}
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
	
	private static func bool(from expr: LabeledExprSyntax, argname: String) throws -> Bool {
		return switch expr.expression.as(BooleanLiteralExprSyntax.self)?.literal.text {
			case BooleanLiteralExprSyntax(booleanLiteral:  true).literal.text?: true
			case BooleanLiteralExprSyntax(booleanLiteral: false).literal.text?: false
			default:
				throw Err.invalidArgument(message: "Expected a literal Bool argument for \(argname)")
		}
	}
	
}
