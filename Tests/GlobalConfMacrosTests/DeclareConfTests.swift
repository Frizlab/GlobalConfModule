import XCTest

import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport



/* Macro implementations build for the host, so the corresponding module is not available when cross-compiling.
 * Cross-compiled tests may still make use of the macro itself in end-to-end tests. */
#if canImport(GlobalConfMacros)
import GlobalConfMacros

private let testMacros: [String: Macro.Type] = [
	"declareConfKey":           DeclareConfMacro.self,
	"declareConfFactoryKey":    DeclareConfMacro.self,
	"declareServiceKey":        DeclareConfMacro.self,
	"declareServiceFactoryKey": DeclareConfMacro.self,
]
#endif


final class DeclareConfTests : XCTestCase {
	
	func testBasicUsage() throws {
#if canImport(GlobalConfMacros)
		assertMacroExpansion("""
				import Configuration
				extension ConfKeys {
					#declareConfKey("myBool", Bool.self, "MyBoolConfKey", defaultValue: true)
				}
				""",
			expandedSource: #"""
				import Configuration
				extension ConfKeys {
					public enum MyBoolConfKey : ConfKey {
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
	
	func testBasicInternalUsage() throws {
#if canImport(GlobalConfMacros)
		assertMacroExpansion("""
				import Configuration
				extension ConfKeys {
					#declareConfKey(visibility: .internal, "myBool", Bool.self, "MyBoolConfKey", defaultValue: true)
				}
				""",
			expandedSource: #"""
				import Configuration
				extension ConfKeys {
					internal enum MyBoolConfKey : ConfKey {
						internal typealias Value = Bool
						internal static let defaultValue: Bool! = .some(true)
					}
					internal var myBool: MyBoolConfKey.Type {
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
	
	func testInternalFQNUsage() throws {
#if canImport(GlobalConfMacros)
		assertMacroExpansion("""
				import Configuration
				extension ConfKeys {
					#declareConfKey(visibility: GlobalConfModule.DeclarationVisibility.internal, "myBool", Bool.self, "MyBoolConfKey", defaultValue: true)
				}
				""",
			expandedSource: #"""
				import Configuration
				extension ConfKeys {
					internal enum MyBoolConfKey : ConfKey {
						internal typealias Value = Bool
						internal static let defaultValue: Bool! = .some(true)
					}
					internal var myBool: MyBoolConfKey.Type {
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
#if canImport(GlobalConfMacros)
		assertMacroExpansion("""
				import Configuration
				extension ConfKeys.MyLib {
					#declareConfKey("myBool", Bool.self, on: MainActor.self, defaultValue: true)
				}
				""",
			expandedSource: #"""
				import Configuration
				extension ConfKeys.MyLib {
					public enum ConfKey_myBool : ConfKeyMainActor {
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
#if canImport(GlobalConfMacros)
		assertMacroExpansion("""
				extension ConfKeys {
					#declareConfKey("oslog", OSLog?.self, unsafeNonIsolated: true, defaultValue: .default)
				}
				""",
			expandedSource: #"""
				extension ConfKeys {
					public enum ConfKey_oslog : ConfKey {
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
	
	func testBasicConfFactoryUsage() throws {
#if canImport(GlobalConfMacros)
		assertMacroExpansion("""
				extension ConfKeys {
					#declareConfFactoryKey("randomInt", Int.self, defaultValue: { .random(in: 0..<42) })
				}
				""",
			expandedSource: #"""
				extension ConfKeys {
					public enum ConfKey_randomInt : ConfKey {
						public typealias Value = (@Sendable () -> Int)
						public static let defaultValue: (@Sendable () -> Int)! = .some({
						        .random(in: 0 ..< 42)
						    })
					}
					public var randomInt: ConfKey_randomInt.Type {
					    ConfKey_randomInt.self
					}
				}
				"""#,
			macros: testMacros
		)
#else
		throw XCTSkip("Macros are only supported when running tests for the host platform.")
#endif
	}
	
	func testBasicServiceFactoryUsage() throws {
#if canImport(GlobalConfMacros)
		assertMacroExpansion("""
				extension ConfKeys {
					#declareServiceFactoryKey("oslog", OSLog?.self, unsafeNonIsolated: true, defaultValue: { .default })
				}
				""",
			expandedSource: #"""
				extension ConfKeys {
					public enum ConfKey_oslog : ConfKey {
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
#if canImport(GlobalConfMacros)
		assertMacroExpansion("""
				extension ConfKeys {
					#declareServiceKey("oslog", OSLog?   .self, unsafeNonIsolated: true, defaultValue: .default)
				}
				""",
			expandedSource: #"""
				extension ConfKeys {
					public enum ConfKey_oslog : ConfKey {
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
	
	func testUsageWithoutConfKey() throws {
#if canImport(GlobalConfMacros)
		/* Note I’m not sure the generated name is stable… */
		assertMacroExpansion("""
				extension ConfKeys {
					#declareServiceKey(nil, MyService.self, "MyServiceConfKey", defaultValue: .init())
				}
				""",
			expandedSource: #"""
				extension ConfKeys {
					public enum MyServiceConfKey : ConfKey {
						public typealias Value = MyService
						public static let defaultValue: MyService! = .init()
					}
				}
				"""#,
			macros: testMacros
		)
#else
		throw XCTSkip("Macros are only supported when running tests for the host platform.")
#endif
	}
	
	func testUsageWithoutConfKeyOrType() throws {
#if canImport(GlobalConfMacros)
		/* Note I’m not sure the generated name is stable… */
		assertMacroExpansion("""
				extension ConfKeys {
					#declareServiceKey(nil, MyService.self, defaultValue: .init())
				}
				""",
			expandedSource: #"""
				extension ConfKeys {
					public enum __macro_local_7ConfKeyfMu_ : ConfKey {
						public typealias Value = MyService
						public static let defaultValue: MyService! = .init()
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
