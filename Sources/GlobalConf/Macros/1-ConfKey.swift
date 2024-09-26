import Foundation



/* See eace773efd0435b78ab55a5a67eebb5187b6928b for design I originally wanted, but
 *  that is not possible because freestanding macro with arbitrary names are not allowed at top level. */

public enum DeclarationVisibility : String, Sendable {
	case `public`
	case `internal`
}

@freestanding(declaration, names: arbitrary)
public macro declareConfKey<T>(
	visibility: DeclarationVisibility = .public,
	_ confKey: String?,
	_ confType: T.Type,
	unsafeNonIsolated: Bool = false,
	_ customConfKeyName: String? = nil,
	defaultValue: T
) = #externalMacro(module: "GlobalConfMacros", type: "DeclareConfMacro")

/* Same as previous, but with a global actor. */
@freestanding(declaration, names: arbitrary)
public macro declareConfKey<T, A : GlobalActor>(
	visibility: DeclarationVisibility = .public,
	_ confKey: String?,
	_ confType: T.Type,
	on globalActor: A.Type,
	unsafeNonIsolated: Bool = false,
	_ customConfKeyName: String? = nil,
	defaultValue: T
) = #externalMacro(module: "GlobalConfMacros", type: "DeclareConfMacro")

/* Same as declareServiceKey, but the value is a factory.
 * unsafeNonIsolated is not allowed for this one as it poses some issues:
 *  we’d have to duplicate the definition for the unsafe variant specifically and make the default value a non-sendable block.
 * This in turn will make the macro expansion more complicated…
 * Because the unsafe variant should not be used and it’s a bit annoying to do, I’m not doing it, at least not now. */
@freestanding(declaration, names: arbitrary)
public macro declareConfFactoryKey<T>(
	visibility: DeclarationVisibility = .public,
	_ confKey: String?,
	_ confType: T.Type,
	_ customConfKeyName: String? = nil,
	defaultValue: @Sendable () -> T
) = #externalMacro(module: "GlobalConfMacros", type: "DeclareConfMacro")

/* Same as previous, but with a global actor. */
@freestanding(declaration, names: arbitrary)
public macro declareConfFactoryKey<T, A : GlobalActor>(
	visibility: DeclarationVisibility = .public,
	_ confKey: String?,
	_ confType: T.Type,
	on globalActor: A.Type,
	_ customConfKeyName: String? = nil,
	defaultValue: @Sendable () -> T
) = #externalMacro(module: "GlobalConfMacros", type: "DeclareConfMacro")
