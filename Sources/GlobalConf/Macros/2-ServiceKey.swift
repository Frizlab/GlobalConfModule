import Foundation



/* A “service” key is a conf key where the default value can be `nil`, but it is implicitly unwrapped so it should not be.
 * When creating a service, it might not make sense to set a default value for it,
 *  but that does not mean we should not declare its key!
 * In this case you can declare the key using declareServiceKey instead of declareConfKey and set a `nil` default value. */


/* Same as declareConfKey, but the default value can be `nil`. */
@freestanding(declaration, names: arbitrary)
public macro declareServiceKey<T>(
	visibility: DeclarationVisibility = .public,
	_ confKey: String?,
	_ confType: T.Type,
	unsafeNonIsolated: Bool = false,
	_ customConfKeyName: String? = nil,
	defaultValue: T!
) = #externalMacro(module: "GlobalConfMacros", type: "DeclareConfMacro")

/* Same as previous, but with a global actor. */
@freestanding(declaration, names: arbitrary)
public macro declareServiceKey<T, A : GlobalActor>(
	visibility: DeclarationVisibility = .public,
	_ confKey: String?,
	_ confType: T.Type,
	on globalActor: A.Type,
	unsafeNonIsolated: Bool = false,
	_ customConfKeyName: String? = nil,
	defaultValue: T!
) = #externalMacro(module: "GlobalConfMacros", type: "DeclareConfMacro")

/* Same as declareServiceKey, but the value is a factory. */
@freestanding(declaration, names: arbitrary)
public macro declareServiceFactoryKey<T>(
	visibility: DeclarationVisibility = .public,
	_ confKey: String?,
	_ confType: T.Type,
	unsafeNonIsolated: Bool = false,
	_ customConfKeyName: String? = nil,
	defaultValue: (@Sendable () -> T)!
) = #externalMacro(module: "GlobalConfMacros", type: "DeclareConfMacro")

/* Same as previous, but with a global actor. */
@freestanding(declaration, names: arbitrary)
public macro declareServiceFactoryKey<T, A : GlobalActor>(
	visibility: DeclarationVisibility = .public,
	_ confKey: String?,
	_ confType: T.Type,
	on globalActor: A.Type,
	unsafeNonIsolated: Bool = false,
	_ customConfKeyName: String? = nil,
	defaultValue: (@Sendable () -> T)!
) = #externalMacro(module: "GlobalConfMacros", type: "DeclareConfMacro")
