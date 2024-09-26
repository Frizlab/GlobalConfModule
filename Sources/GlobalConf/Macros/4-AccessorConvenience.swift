import Foundation

import ServiceContextModule



/* We do not let the visibility be set and it is alwasy set to internal.
 * The accessors are conveniences and should not be exported.
 * If you specifically want to export an accessor, define it manually. */


@freestanding(declaration, names: arbitrary)
public macro declareConfAccessor<InjectedKey : ConfKey, AccessedType>(
	_ confKeyPath: KeyPath<ConfKeys, InjectedKey.Type>,
	_ confType: AccessedType.Type/* = InjectedKey.Value.self*/,
	unsafeNonIsolated: Bool = false,
	_ customAccessorName: String? = nil
) = #externalMacro(module: "GlobalConfMacros", type: "DeclareConfAccessorMacro") where InjectedKey.Value == AccessedType

/* Same as previous, but with a global actor. */
@freestanding(declaration, names: arbitrary)
public macro declareConfAccessor<InjectedKey : ConfKey, AccessedType, A : GlobalActor>(
	_ confKeyPath: KeyPath<ConfKeys, InjectedKey.Type>,
	_ confType: AccessedType.Type/* = InjectedKey.Value.self*/,
	on globalActor: A.Type,
	unsafeNonIsolated: Bool = false,
	_ customAccessorName: String? = nil
) = #externalMacro(module: "GlobalConfMacros", type: "DeclareConfAccessorMacro") where InjectedKey.Value == AccessedType

@freestanding(declaration, names: arbitrary)
public macro declareConfFactoryAccessor<InjectedKey : ConfKey, AccessedType>(
	_ confKeyPath: KeyPath<ConfKeys, InjectedKey.Type>,
	_ confType: AccessedType.Type/* = InjectedKey.Value.self*/,
	unsafeNonIsolated: Bool = false,
	_ customAccessorName: String? = nil
) = #externalMacro(module: "GlobalConfMacros", type: "DeclareConfAccessorMacro") where InjectedKey.Value == @Sendable () -> AccessedType

/* Same as previous, but with a global actor. */
@freestanding(declaration, names: arbitrary)
public macro declareConfFactoryAccessor<InjectedKey : ConfKey, AccessedType, A : GlobalActor>(
	_ confKeyPath: KeyPath<ConfKeys, InjectedKey.Type>,
	_ confType: AccessedType.Type/* = InjectedKey.Value.self*/,
	on globalActor: A.Type,
	unsafeNonIsolated: Bool = false,
	_ customAccessorName: String? = nil
) = #externalMacro(module: "GlobalConfMacros", type: "DeclareConfAccessorMacro") where InjectedKey.Value == @Sendable () -> AccessedType
