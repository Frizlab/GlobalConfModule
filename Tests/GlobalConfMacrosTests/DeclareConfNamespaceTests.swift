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
	"declareNamespaceKey": DeclareConfNamespaceMacro.self,
]
#endif


final class DeclareConfNamespaceTests : XCTestCase {
	
	func testBasicUsage() throws {
#if canImport(GlobalConfMacros)
		assertMacroExpansion("""
				import Configuration
				extension ConfKeys {
					#declareNamespaceKey("myNamespace")
				}
				""",
			expandedSource: #"""
				import Configuration
				extension ConfKeys {
					public struct ConfNamespace_myNamespace {
					}
					public var myNamespace: ConfNamespace_myNamespace {
					    ConfNamespace_myNamespace()
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
					#declareNamespaceKey(visibility: .internal, "myNamespace")
				}
				""",
			expandedSource: #"""
				import Configuration
				extension ConfKeys {
					internal struct ConfNamespace_myNamespace {
					}
					internal var myNamespace: ConfNamespace_myNamespace {
					    ConfNamespace_myNamespace()
					}
				}
				"""#,
			macros: testMacros
		)
#else
		throw XCTSkip("Macros are only supported when running tests for the host platform.")
#endif
	}
	
	func testCustomKeyNameUsage() throws {
#if canImport(GlobalConfMacros)
		assertMacroExpansion("""
				import Configuration
				extension ConfKeys {
					#declareNamespaceKey("myNamespace", "MyNamespace")
				}
				""",
			expandedSource: #"""
				import Configuration
				extension ConfKeys {
					public struct MyNamespace {
					}
					public var myNamespace: MyNamespace {
					    MyNamespace()
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
