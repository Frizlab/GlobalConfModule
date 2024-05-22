import Foundation



@freestanding(declaration, names: arbitrary)
public macro declareConf<T>(
	_ confKeyPath: String/* Dot-separated key-path. */,
	_ confType: T.Type,
	on globalActor: (any GlobalActor).Type? = nil,
	unsafeNonIsolated: Bool = false,
	in confContainer: Any.Type = ConfKeys.self,
	_ customConfKeyName: String? = nil,
	defaultValue: T
) = #externalMacro(module: "ConfigurationMacros", type: "DeclareConfMacro")

/* Same as declareConf but does not declare an internal extension on Conf for easy access to the conf. */
@freestanding(declaration, names: arbitrary)
public macro declareConfOnly<T>(
	_ confKeyPath: String/* Dot-separated key-path. */,
	_ confType: T.Type,
	on globalActor: (any GlobalActor).Type? = nil,
	unsafeNonIsolated: Bool = false,
	in confContainer: Any.Type = ConfKeys.self,
	_ customConfKeyName: String? = nil,
	defaultValue: T
) = #externalMacro(module: "ConfigurationMacros", type: "DeclareConfMacro")

/* Same as declareConfOnly, but the default value can be `nil`. */
@freestanding(declaration, names: arbitrary)
public macro declareService<T>(
	_ confKeyPath: String/* Dot-separated key-path. */,
	_ confType: T.Type,
	on globalActor: (any GlobalActor).Type? = nil,
	unsafeNonIsolated: Bool = false,
	in confContainer: Any.Type = ConfKeys.self,
	_ customConfKeyName: String? = nil,
	defaultValue: T!
) = #externalMacro(module: "ConfigurationMacros", type: "DeclareConfMacro")

/* Same as declareService, but the value is a factory. */
@freestanding(declaration, names: arbitrary)
public macro declareServiceFactory<T>(
	_ confKeyPath: String/* Dot-separated key-path. */,
	_ confType: T.Type,
	on globalActor: (any GlobalActor).Type? = nil,
	unsafeNonIsolated: Bool = false,
	in confContainer: Any.Type = ConfKeys.self,
	_ customConfKeyName: String? = nil,
	defaultValue: (@Sendable () -> T)!
) = #externalMacro(module: "ConfigurationMacros", type: "DeclareConfMacro")
