import XCTest

import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport



/* Macro implementations build for the host, so the corresponding module is not available when cross-compiling.
 * Cross-compiled tests may still make use of the macro itself in end-to-end tests. */
#if canImport(ConfigurationMacros)
import ConfigurationMacros

let testMacros: [String: Macro.Type] = [
	"conf": ConfKeyMacro.self,
]
#endif


final class ConfigurationMacrosTests : XCTestCase {
	
	func testBasicUsage() throws {
#if canImport(ConfigurationMacros)
		assertMacroExpansion("""
				import Configuration
				#conf("MyBool", Bool.self, ["myBool"], true)
				""",
			expandedSource: #"""
				import Configuration
				public struct MyBool : Sendable {
				    public typealias Value = Bool
				    public static let defaultValue: Value! = true
				}
				extension ConfKeys {
				    public var myBool: MyBool.Type {
				        MyBool.self
				    }
				}
				extension Conf {
				    internal var myBool: Bool {
				        Conf[\ConfKeys.myBool]
				    }
				}
				"""#,
			macros: testMacros
		)
#else
		throw XCTSkip("Macros are only supported when running tests for the host platform.")
#endif
	}
	
	func testBasicUsageNonIsolated() throws {
#if canImport(ConfigurationMacros)
		assertMacroExpansion("""
				#conf("OSLog", OSLog?.self, unsafeNonIsolated: true, ["oslog"], .default)
				""",
			expandedSource: """
				TODO
				""",
			macros: testMacros
		)
#else
		throw XCTSkip("Macros are only supported when running tests for the host platform.")
#endif
	}
	
}
