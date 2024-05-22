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
	"declareConfKey": DeclareConfMacro.self,
	"declareServiceKey": DeclareConfMacro.self,
	"declareServiceFactoryKey": DeclareConfMacro.self,
]
#endif


final class DeclareConfTests : XCTestCase {
	
	func testBasicUsage() throws {
#if canImport(ConfigurationMacros)
		assertMacroExpansion("""
				import Configuration
				extension ConfKeys {
					#declareConfKey("myBool", Bool.self, "MyBoolConfKey", defaultValue: true)
				}
				""",
			expandedSource: #"""
				import Configuration
				extension ConfKeys {
					public struct MyBoolConfKey : ConfKey {
						public typealias Value = Bool
						public static let defaultValue: Bool! = .some(true)
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
				extension ConfKeys.MyLib {
					#declareConfKey("myBool", Bool.self, on: MainActor.self, defaultValue: true)
				}
				""",
			expandedSource: #"""
				import Configuration
				extension ConfKeys.MyLib {
					public struct ConfKey_myBool : ConfKeyMainActor {
						public typealias Value = Bool
						public static let defaultValue: Bool! = .some(true)
					}
					public var myBool: ConfKey_myBool.Type {
					    ConfKey_myBool.self
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
				extension ConfKeys {
					#declareConfKey("oslog", OSLog?.self, unsafeNonIsolated: true, defaultValue: .default)
				}
				""",
			expandedSource: #"""
				extension ConfKeys {
					public struct ConfKey_oslog : ConfKey {
						public typealias Value = OSLog?
						public nonisolated (unsafe) static let defaultValue: OSLog?! = .some(.default)
					}
					public var oslog: ConfKey_oslog.Type {
					    ConfKey_oslog.self
					}
				}
				"""#,
			macros: testMacros
		)
#else
		throw XCTSkip("Macros are only supported when running tests for the host platform.")
#endif
	}
	
	func testBasicFactoryUsage() throws {
#if canImport(ConfigurationMacros)
		assertMacroExpansion("""
				extension ConfKeys {
					#declareServiceFactoryKey("oslog", OSLog?.self, unsafeNonIsolated: true, defaultValue: { .default })
				}
				""",
			expandedSource: #"""
				extension ConfKeys {
					public struct ConfKey_oslog : ConfKey {
						public typealias Value = (@Sendable () -> OSLog?)
						public nonisolated (unsafe) static let defaultValue: (@Sendable () -> OSLog?)! = {
						    .default
						}
					}
					public var oslog: ConfKey_oslog.Type {
					    ConfKey_oslog.self
					}
				}
				"""#,
			macros: testMacros
		)
#else
		throw XCTSkip("Macros are only supported when running tests for the host platform.")
#endif
	}
	
	func testUsageWithSpaceBeforeSelf() throws {
#if canImport(ConfigurationMacros)
		assertMacroExpansion("""
				extension ConfKeys {
					#declareServiceKey("oslog", OSLog?   .self, unsafeNonIsolated: true, defaultValue: .default)
				}
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
				"""#,
			macros: testMacros
		)
#else
		throw XCTSkip("Macros are only supported when running tests for the host platform.")
#endif
	}
	
}
