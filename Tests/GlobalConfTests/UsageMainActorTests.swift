import Foundation
import XCTest

/* No @testable import: we mostly test whether the architecture works; we must be as close as possible to a regular client’s use. */
import GlobalConfModule



final class UsageMainActorTests : XCTestCase {
	
	class override func setUp() {
		super.setUp()
		
		/* For the testNoDefaultValueCalledWhenOverrideIsSet test.
		 * **MUST** be done _before_ the test is initialized. */
		if Thread.isMainThread {
			MainActor.assumeIsolated{
				Conf.setRootValue(NotTrackedInitTrackedServiceMainActor(), for: \.initTrackedServiceMainActor)
			}
		} else {
			DispatchQueue.main.sync{
				Conf.setRootValue(NotTrackedInitTrackedServiceMainActor(), for: \.initTrackedServiceMainActor)
			}
		}
	}
	
	@MainActor
	func testUsingMainActorService() {
		MainActor.preconditionIsolated()
		let c = MainActorContainer()
		c.mainActorService.printHello()
		c.mainActorServiceFromKeyPath.printHello()
		InjectedConf<MainActorService>.value.printHello()
		XCTAssertTrue(c.mainActorService === Conf[\.mainActorService])
		XCTAssertTrue(c.mainActorService === Conf[key: MainActorService.AutoInjectionKey.self])
		XCTAssertTrue(c.mainActorService === Conf.rootValue(for: MainActorService.AutoInjectionKey.self))
		XCTAssertTrue(c.mainActorService === InjectedConf<MainActorService>.value)
		XCTAssertTrue(c.mainActorServiceFromKeyPath === InjectedConf<MainActorService>.value)
		
		XCTAssertTrue(c.otherMainActorService !== InjectedConf<MainActorService>.value)
		
		let oldOtherActor = c.otherMainActorService
		Conf.setRootValue(c.mainActorService, for: \.mainActorService2)
		XCTAssertTrue(c.otherMainActorService === InjectedConf<MainActorService>.value)
		
		Conf.withValue(oldOtherActor, for: \.mainActorService2, operation: {
			XCTAssertTrue(c.mainActorService === Conf[\.mainActorService])
			XCTAssertTrue(c.otherMainActorService === oldOtherActor)
			XCTAssertTrue(c.otherMainActorService !== InjectedConf<MainActorService>.value)
		})
		
		Conf.withValues{
			$0[\.mainActorService2] = MainActorService()
		}operation:{
			XCTAssertTrue(c.otherMainActorService !== oldOtherActor)
			XCTAssertTrue(c.otherMainActorService !== InjectedConf<MainActorService>.value)
		}
		
		InjectedConf<MainActorService>.withValue(MainActorService()){
			XCTAssertTrue(c.otherMainActorService !== oldOtherActor)
			XCTAssertTrue(c.otherMainActorService !== InjectedConf<MainActorService>.value)
		}
		
		XCTAssertTrue(c.otherMainActorService === InjectedConf<MainActorService>.value)
		
		InjectedConf<MainActorService>.rootValue = oldOtherActor
		XCTAssertTrue(c.otherMainActorService !== c.mainActorService)
	}
	
	@MainActor
	struct MainActorContainer {
		
		@InjectedConf()
		var mainActorService: MainActorService
		@InjectedConf(\.mainActorService)
		var mainActorServiceFromKeyPath
		
		@InjectedConf(\.mainActorService2)
		var otherMainActorService: MainActorService
		
		@InjectedConf(\.initTrackedServiceMainActor)
		var initTrackedServiceMainActor: InitTrackedServiceMainActor
		
	}
	
	
	@MainActor
	func testNoDefaultValueCalledWhenOverrideIsSet() {
		let c = MainActorContainer()
		_ = c.initTrackedServiceMainActor
		_ = Conf[\.initTrackedServiceMainActor]
		XCTAssertEqual(DefaultInitTrackedServiceMainActor.initCount, 0)
	}
	
}


protocol InitTrackedServiceMainActor : Sendable {}
struct DefaultInitTrackedServiceMainActor : InitTrackedServiceMainActor {
	
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
struct NotTrackedInitTrackedServiceMainActor : InitTrackedServiceMainActor {
}
extension ConfKeys {
	#declareServiceKey(visibility: .internal, "initTrackedServiceMainActor", InitTrackedServiceMainActor.self, on: MainActor.self, defaultValue: DefaultInitTrackedServiceMainActor())
}
