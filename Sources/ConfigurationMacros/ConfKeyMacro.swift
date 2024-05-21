import Foundation

import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import UnwrapOrThrow



public struct ConfKeyMacro : DeclarationMacro, FreestandingMacro {
	
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
		var args = Array(node.arguments.reversed())
		let confKeyNameArg      = try args.popLast() ?! Err.missingArgument(argname: "confKeyName")
		let confTypeArg         = try args.popLast() ?! Err.missingArgument(argname: "confType")
		let isolationOrOtherArg = try args.popLast() ?! Err.missingArgument(argname: "confKeyPath")
		let nonIsolatedArg: LabeledExprSyntax
		let confKeyContainerOrOtherArg: LabeledExprSyntax
		if isolationOrOtherArg.label?.text == "unsafeNonIsolated" {
			nonIsolatedArg = isolationOrOtherArg
			confKeyContainerOrOtherArg = try args.popLast() ?! Err.missingArgument(argname: "confKeyPath")
		} else {
			/* We do not put the label back in the non-isolated arg as we will not validate it.
			 * If we did, we should add it. */
			nonIsolatedArg = LabeledExprSyntax(/*label: "unsafeNonIsolated", */expression: BooleanLiteralExprSyntax(booleanLiteral: false))
			confKeyContainerOrOtherArg = isolationOrOtherArg
		}
		let confKeyContainerArg: LabeledExprSyntax
		let confPathArg: LabeledExprSyntax
		if confKeyContainerOrOtherArg.expression.is(MemberAccessExprSyntax.self) {
			confKeyContainerArg = confKeyContainerOrOtherArg
			confPathArg = try args.popLast() ?! Err.missingArgument(argname: "confKeyPath")
		} else {
			confKeyContainerArg = LabeledExprSyntax(/*label: "confKeyContainer", */expression: ExprSyntax(stringLiteral: "ConfKeys.self"))
			confPathArg = confKeyContainerOrOtherArg
		}
		let defaultValueArg = try args.popLast() ?! Err.missingArgument(argname: "defaultValue")
		
		return try expansionFor(
			confKeyNameArg: confKeyNameArg,
			confTypeArg: confTypeArg,
			nonIsolatedArg: nonIsolatedArg,
			confKeyContainerArg: confKeyContainerArg,
			confPathArg: confPathArg,
			defaultValueArg: defaultValueArg,
			in: context
		)
	}
	
	private static func expansionFor(
		confKeyNameArg: LabeledExprSyntax,
		confTypeArg: LabeledExprSyntax,
		nonIsolatedArg: LabeledExprSyntax,
		confKeyContainerArg: LabeledExprSyntax,
		confPathArg: LabeledExprSyntax,
		defaultValueArg: LabeledExprSyntax,
		in context: some MacroExpansionContext
	) throws -> [DeclSyntax] {
		let confKeyName      = try staticString(from: confKeyNameArg,      argname: "confKeyName") + "ConfKey"
		let confType         = try swiftType   (from: confTypeArg,         argname: "confType")
		let nonIsolated      = try bool        (from: nonIsolatedArg,      argname: "unsafeNonIsolated")
		let confKeyContainer = try swiftType   (from: confKeyContainerArg, argname: "confKeyContainer")
		let confPathArray    = try keyPath     (from: confPathArg,         argname: "confPath")
		guard !confPathArray.isEmpty else {
			throw Err.invalidArgument(message: "confPath cannot be empty")
		}
		let confPath = confPathArray.joined(separator: ".")
		if confPathArray.count == 1 && confKeyContainer.description != "ConfKeys" {
			context.diagnose(
				Diagnostic(
					node: Syntax(confPathArg),
					message: SimpleDiagnosticMessage(
						message: "The conf path only contain one element but the conf keys container is not ConfKeys. This is not possible.",
						diagnosticID: MessageID(domain: "Configuration", id: "InvalidConfig"),
						severity: .error
					)
				)
			)
		} else if confPathArray.count > 1 && confKeyContainer.description == "ConfKeys" {
			context.diagnose(
				Diagnostic(
					node: Syntax(confPathArg),
					message: SimpleDiagnosticMessage(
						message: "The conf path only contain more than one elements but the conf keys container is ConfKeys. This is highly unlikely and probably an error.",
						diagnosticID: MessageID(domain: "Configuration", id: "InvalidConfig"),
						severity: .warning
					)
				)
			)
		}
		return [
			#"""
				extension \#(raw: confKeyContainer) {
				    public struct \#(raw: confKeyName) : ConfKey {
				        public typealias Value = \#(raw: confType)
				        public \#(raw: nonIsolated ? "nonisolated(unsafe) " : "")static let defaultValue: \#(raw: confType)! = \#(raw: defaultValueArg.expression)
				    }
				    public var \#(raw: confPathArray.last!): \#(raw: confKeyName).Type {\#(raw: confKeyName).self}
				}
				"""#,
			#"""
				extension Conf {
				    internal var \#(raw: confPathArray.last!): \#(raw: confType) {Conf[\ConfKeys.\#(raw: confPath)]}
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
	
	private static func keyPath(from expr: LabeledExprSyntax, argname: String) throws -> [String] {
		if let string = try? staticString(from: expr, argname: argname) {
			return [string]
		}
		guard let elements = expr.expression.as(ArrayExprSyntax.self)?.elements else {
			throw Err.invalidArgument(message: "Expected an array of String for \(argname)")
		}
		return try elements.map{ element in
			guard let segments = element.expression.as(StringLiteralExprSyntax.self)?.segments,
					segments.count == 1,
					case .stringSegment(let literalSegment)? = segments.first
			else {
				throw Err.invalidArgument(message: "Expected an array of String for \(argname)")
			}
			return literalSegment.content.text
		}
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
		return type
	}
	
}
