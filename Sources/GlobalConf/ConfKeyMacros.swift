import Foundation



/* See eace773efd0435b78ab55a5a67eebb5187b6928b for design I originally wanted, but
 *  that is not possible because freestanding macro with arbitrary names are not allowed at top level. */

@freestanding(declaration, names: arbitrary)
public macro declareConfKey<T>(
	_ confKey: String?,
	_ confType: T.Type,
	on globalActor: (any GlobalActor).Type? = nil,
	unsafeNonIsolated: Bool = false,
	in confContainer: Any.Type = ConfKeys.self,
	_ customConfKeyName: String? = nil,
	defaultValue: T
) = #externalMacro(module: "GlobalConfMacros", type: "DeclareConfMacro")

/* Same as declareConfKey, but the default value can be `nil`. */
@freestanding(declaration, names: arbitrary)
public macro declareServiceKey<T>(
	_ confKey: String?,
	_ confType: T.Type,
	on globalActor: (any GlobalActor).Type? = nil,
	unsafeNonIsolated: Bool = false,
	in confContainer: Any.Type = ConfKeys.self,
	_ customConfKeyName: String? = nil,
	defaultValue: T!
) = #externalMacro(module: "GlobalConfMacros", type: "DeclareConfMacro")

/* Same as declareServiceKey, but the value is a factory. */
@freestanding(declaration, names: arbitrary)
public macro declareServiceFactoryKey<T>(
	_ confKey: String?,
	_ confType: T.Type,
	on globalActor: (any GlobalActor).Type? = nil,
	unsafeNonIsolated: Bool = false,
	in confContainer: Any.Type = ConfKeys.self,
	_ customConfKeyName: String? = nil,
	defaultValue: (@Sendable () -> T)!
) = #externalMacro(module: "GlobalConfMacros", type: "DeclareConfMacro")

/* To declare a new namespace for some conf keys.
 * This is disabled because it does not work.
 * As we cannot specify the output name of the newly created struct,
 *  Swift detects a circular reference and fails compilation.
 * We could create an attached macro to the struct the user would create and have only the accessor be generated instead,
 *  but there’s not really any gain in doing so… */
//@freestanding(declaration, names: arbitrary)
//public macro declareKeyNameSpace(
//	_ accessorName: String,
//	_ namespaceKeyName: String? = nil
//) = #externalMacro(module: "GlobalConfMacros", type: "DeclareConfNamespaceMacro")
