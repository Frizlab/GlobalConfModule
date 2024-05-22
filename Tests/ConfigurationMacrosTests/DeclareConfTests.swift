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
	"declareConf": DeclareConfMacro.self,
	"declareConfOnly": DeclareConfMacro.self,
	"declareService": DeclareConfMacro.self,
	"declareServiceFactory": DeclareConfMacro.self,
]
#endif


final class DeclareConfTests : XCTestCase {
	
	func testBasicUsage() throws {
#if canImport(ConfigurationMacros)
		assertMacroExpansion("""
				import Configuration
				#declareConfOnly("myBool", Bool.self, "MyBoolConfKey", defaultValue: true)
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
				"""#,
			macros: testMacros
		)
#else
		throw XCTSkip("Macros are only supported when running tests for the host platform.")
#endif
	}
	
	func testBasicUsageNonStandardContainer() throws {
#if canImport(ConfigurationMacros)
		assertMacroExpansion("""
				import Configuration
				#declareConf("myLib.myBool", Bool.self, in: ConfKeys.MyLib.self, defaultValue: true)
				""",
			expandedSource: #"""
				import Configuration
				extension ConfKeys.MyLib {
				    public struct ConfKey_myBool : ConfKey {
				        public typealias Value = Bool
				        public static let defaultValue: Bool! = true
				    }
				    public var myBool: ConfKey_myBool.Type {
				        ConfKey_myBool.self
				    }
				}
				extension Conf {
				    internal var myBool: Bool {
				        Conf[\ConfKeys.myLib.myBool]
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
				#declareConf("oslog", OSLog?.self, unsafeNonIsolated: true, defaultValue: .default)
				""",
			expandedSource: #"""
				extension ConfKeys {
				    public struct ConfKey_oslog : ConfKey {
				        public typealias Value = OSLog?
				        public nonisolated (unsafe) static let defaultValue: OSLog?! = .default
				    }
				    public var oslog: ConfKey_oslog.Type {
				        ConfKey_oslog.self
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
