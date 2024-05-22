import XCTest

import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport



/* Macro implementations build for the host, so the corresponding module is not available when cross-compiling.
 * Cross-compiled tests may still make use of the macro itself in end-to-end tests. */
#if canImport(ConfigurationMacros)
import ConfigurationMacros

private let testMacros: [String: Macro.Type] = [
	"declareKeyNameSpace": DeclareConfNamespaceMacro.self,
]
#endif


final class DeclareConfNamespaceTests : XCTestCase {
	
	func testBasicUsage() throws {
#if canImport(ConfigurationMacros)
		assertMacroExpansion("""
				import Configuration
				extension ConfKeys {
					#declareKeyNameSpace("myNamespace")
				}
				""",
			expandedSource: #"""
				import Configuration
				extension ConfKeys {
					struct ConfNamespace_myNamespace {
					}
					var myNamespace: ConfNamespace_myNamespace {
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
#if canImport(ConfigurationMacros)
		assertMacroExpansion("""
				import Configuration
				extension ConfKeys {
					#declareKeyNameSpace("myNamespace", "MyNamespace")
				}
				""",
			expandedSource: #"""
				import Configuration
				extension ConfKeys {
					struct MyNamespace {
					}
					var myNamespace: MyNamespace {
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
