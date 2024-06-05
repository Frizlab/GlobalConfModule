import Foundation
#if canImport(os)
import os
#endif

import ServiceContextModule



public enum Conf : Sendable {
	
	internal static var currentContext: ServiceContext {
		currentTaskContext ?? rootContext
	}
	
	internal static var rootContext: ServiceContext {
		get {_rootContext.wrappedValue}
		set {_rootContext.wrappedValue = newValue}
	}
	private static let _rootContext: SafeGlobal<ServiceContext> = SafeGlobal(wrappedValue: .topLevel)
	
	@TaskLocal
	internal static var currentTaskContext: ServiceContext?
	
}


private final class SafeGlobal<T : Sendable> : @unchecked Sendable {
	
	public var wrappedValue: T {
		get {lock.withLock{ _wrappedValue }}
		set {lock.withLock{ _wrappedValue = newValue }}
	}
	
	public init(wrappedValue: T) {
		self._wrappedValue = wrappedValue
	}
	
	public init<V>() where T == Optional<V> {
		self._wrappedValue = nil
	}
	
	private var _wrappedValue: T
	/* OSAllocatedUnfairLock is not available on Linux and is only available from macOS 13. */
	private let lock = NSLock()
	
}


#if os(Linux)

extension NSLock {
	
	func withLock<R>(_ body: () throws -> R) rethrows -> R {
		lock()
		defer {unlock()}
		return try body()
	}
	
}

#endif
