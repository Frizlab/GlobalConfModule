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
				#conf("myBool", Bool.self, "MyBool", true)
				""",
			expandedSource: #"""
				import Configuration
				extension ConfKeys {
				    public struct MyBoolConfKey : ConfKey {
				        public typealias Value = Bool
				        public static let defaultValue: Bool! = true
				    }
				    public var myBool: MyBoolConfKey.Type {
				        MyBoolConfKey.self
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
			expandedSource: #"""
				extension ConfKeys {
				    public struct OSLogConfKey : ConfKey {
				        public typealias Value = OSLog?
				        public nonisolated (unsafe) static let defaultValue: OSLog?! = .default
				    }
				    public var oslog: OSLogConfKey.Type {
				        OSLogConfKey.self
				    }
				}
				extension Conf {
				    internal var oslog: OSLog? {
				        Conf[\ConfKeys.oslog]
				    }
				}
				"""#,
			macros: testMacros
		)
#else
		throw XCTSkip("Macros are only supported when running tests for the host platform.")
#endif
	}
	
}
