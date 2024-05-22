import Foundation

import SwiftSyntax



extension LabeledExprSyntax {
	
	func extractStaticString(argname: String) throws -> String {
		guard let segments = expression.as(StringLiteralExprSyntax.self)?.segments,
				segments.count == 1,
				case .stringSegment(let literalSegment)? = segments.first
		else {
			throw Err.invalidArgument(message: "Expected a static String argument for \(argname)")
		}
		return literalSegment.content.text
	}
	
	func extractOptionalStaticString(argname: String) throws -> String? {
		if expression.is(NilLiteralExprSyntax.self) {
			return nil
		}
		return try extractStaticString(argname: argname)
	}
	
	func extractKeyPath(argname: String) throws -> [String] {
		let ret: [String]
		if let string = try? extractStaticString(argname: argname) {
			ret = string.split(separator: ".", omittingEmptySubsequences: false).map(String.init)
		} else {
			guard let elements = expression.as(ArrayExprSyntax.self)?.elements else {
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
	
	func extractBool(argname: String) throws -> Bool {
		return switch expression.as(BooleanLiteralExprSyntax.self)?.literal.text {
			case BooleanLiteralExprSyntax(booleanLiteral:  true).literal.text?: true
			case BooleanLiteralExprSyntax(booleanLiteral: false).literal.text?: false
			default:
				throw Err.invalidArgument(message: "Expected a literal Bool argument for \(argname)")
		}
	}
	
	func extractSwiftType(argname: String) throws -> ExprSyntax {
		guard let type = expression.as(MemberAccessExprSyntax.self)?.base else {
			throw Err.invalidArgument(message: "Expected value to be a type for \(argname)")
		}
		return type.trimmed
	}
	
	func extractOptionalSwiftType(argname: String) throws -> ExprSyntax? {
		if expression.is(NilLiteralExprSyntax.self) {
			return nil
		}
		return try extractSwiftType(argname: argname)
	}
	
}
