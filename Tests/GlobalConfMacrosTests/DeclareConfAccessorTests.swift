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
	"declareConfAccessor":        DeclareConfAccessorMacro.self,
	"declareConfFactoryAccessor": DeclareConfAccessorMacro.self,
]
#endif


final class DeclareConfAccessorTests : XCTestCase {
	
	func testBasicUsage() throws {
#if canImport(GlobalConfMacros)
		assertMacroExpansion(#"""
				import Configuration
				extension Conf {
					#declareConfAccessor(\.myBool, Bool.self)
				}
				"""#,
			expandedSource: #"""
				import Configuration
				extension Conf {
					internal static var myBool: Bool {
					    Conf[\.myBool]
					}
				}
				"""#,
			macros: testMacros
		)
#else
		throw XCTSkip("Macros are only supported when running tests for the host platform.")
#endif
	}
	
	func testBasicUsageFQN() throws {
#if canImport(GlobalConfMacros)
		assertMacroExpansion(#"""
				import Configuration
				extension Conf {
					#declareConfAccessor(\ConfKeys.myBool, Bool.self)
				}
				"""#,
			expandedSource: #"""
				import Configuration
				extension Conf {
					internal static var myBool: Bool {
					    Conf[\.myBool]
					}
				}
				"""#,
			macros: testMacros
		)
#else
		throw XCTSkip("Macros are only supported when running tests for the host platform.")
#endif
	}
	
	func testNestedKeyUsage() throws {
#if canImport(GlobalConfMacros)
		assertMacroExpansion(#"""
				import Configuration
				extension Conf {
					#declareConfAccessor(\.amazingNamespace.myBool, Bool.self)
				}
				"""#,
			expandedSource: #"""
				import Configuration
				extension Conf {
					internal static var myBool: Bool {
					    Conf[\.amazingNamespace.myBool]
					}
				}
				"""#,
			macros: testMacros
		)
#else
		throw XCTSkip("Macros are only supported when running tests for the host platform.")
#endif
	}
	
	func testNestedKeyCustomNameUsage() throws {
#if canImport(GlobalConfMacros)
		assertMacroExpansion(#"""
				import Configuration
				extension Conf {
					#declareConfAccessor(\.amazingNamespace.myBool, Bool.self, "bestAccessor")
				}
				"""#,
			expandedSource: #"""
				import Configuration
				extension Conf {
					internal static var bestAccessor: Bool {
					    Conf[\.amazingNamespace.myBool]
					}
				}
				"""#,
			macros: testMacros
		)
#else
		throw XCTSkip("Macros are only supported when running tests for the host platform.")
#endif
	}
	
	func testNestedKeyCustomNameOnMainActorUsage() throws {
#if canImport(GlobalConfMacros)
		assertMacroExpansion(#"""
				import Configuration
				extension Conf {
					#declareConfAccessor(\.amazingNamespace.myBool, Bool.self, on: MainActor.self, "bestAccessor")
				}
				"""#,
			expandedSource: #"""
				import Configuration
				extension Conf {
					@MainActor internal static var bestAccessor: Bool {
					    Conf[\.amazingNamespace.myBool]
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
#if canImport(GlobalConfMacros)
		assertMacroExpansion(#"""
				import Configuration
				extension Conf {
					#declareConfFactoryAccessor(\.myBool, Bool.self)
				}
				"""#,
			expandedSource: #"""
				import Configuration
				extension Conf {
					internal static var myBool: Bool {
					    Conf[\.myBool] ()
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
