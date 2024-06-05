import Foundation



/* To declare a new namespace for some conf keys.
 * This is disabled because it does not work.
 * As we cannot specify the output name of the newly created struct,
 *  Swift detects a circular reference and fails compilation.
 * We could create an attached macro to the struct the user would create and have only the accessor be generated instead,
 *  but there’s not really any gain in doing so… */
//@freestanding(declaration, names: arbitrary)
//public macro declareNamespaceKey(
//	visibility: DeclarationVisibility = .public,
//	_ accessorName: String,
//	_ namespaceKeyName: String? = nil
//) = #externalMacro(module: "GlobalConfMacros", type: "DeclareConfNamespaceMacro")
