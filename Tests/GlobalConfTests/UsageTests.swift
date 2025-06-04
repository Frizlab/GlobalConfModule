import Foundation
import XCTest

/* No @testable import: we mostly test whether the architecture works; we must be as close as possible to a regular client’s use. */
import GlobalConfModule



final class UsageTests : XCTestCase {
	
	func testUsingNoActorService() {
		noActorService.printHello()
		noActorServiceFromKeyPath.printHello()
		InjectedConf<NoActorService>.value.printHello()
		XCTAssertTrue(noActorService === InjectedConf<NoActorService>.value)
		XCTAssertTrue(noActorServiceFromKeyPath === InjectedConf<NoActorService>.value)
	}
	
	func testUsingNoActorServiceWithFactory() {
		XCTAssertTrue(noActorService === noActorService)
		XCTAssertTrue(noActorFactoryService !== noActorFactoryService)
	}
	
	@InjectedConf()
	var noActorService: NoActorService
	@InjectedConf(\.noActorService)
	var noActorServiceFromKeyPath: NoActorService
	@InjectedConf(\.noActorFactoryService)
	var noActorFactoryService: NoActorService
	
	
	func testNoDefaultValueCalledWhenOverrideIsSet() {
		testNoDefaultValueCalledWhenOverrideIsSetLock.lock()
		defer {testNoDefaultValueCalledWhenOverrideIsSetLock.unlock()}
		
		let initialCount = DefaultInitTrackedService.initCount
		Conf.setRootValue(NotTrackedInitTrackedService(), for: \.initTrackedService)
		_ = initTrackedService
		XCTAssertEqual(DefaultInitTrackedService.initCount, initialCount)
	}
	
	private let testNoDefaultValueCalledWhenOverrideIsSetLock = NSLock()
	
	@InjectedConf(\.initTrackedService)
	var initTrackedService: InitTrackedService
	
}


protocol InitTrackedService : Sendable {}
struct DefaultInitTrackedService : InitTrackedService {
	
	static var initCount: Int {
		initLock.withLock{ _initCount }
	}
	nonisolated(unsafe) static var _initCount: Int = 0
	private static let initLock = NSLock()
	
	init() {
		Self.initLock.withLock{
			Self._initCount += 1
		}
	}
	
}
struct NotTrackedInitTrackedService : InitTrackedService {
}
extension ConfKeys {
	#declareServiceKey(visibility: .internal, "initTrackedService", InitTrackedService.self, defaultValue: DefaultInitTrackedService())
}
