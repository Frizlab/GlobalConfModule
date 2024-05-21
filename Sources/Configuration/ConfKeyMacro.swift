import Foundation



@freestanding(declaration, names: arbitrary)
public macro conf<T>(
	_ confKeyName: String, _ confType: T.Type = T.self, unsafeNonIsolated: Bool = false,
	_ confContainer: Any.Type = ConfKeys.self, _ confKeyPath: [String],
	_ defaultValue: T!
) = #externalMacro(module: "ConfigurationMacros", type: "ConfKeyMacro")
