import Foundation
import XCTest

/* No @testable import: we mostly test whether the architecture works; we must be as close as possible to a regular client’s use. */
import Configuration



final class UsageMainActorTests : XCTestCase {
	
	@MainActor
	func testUsingMainActorService() {
		MainActor.preconditionIsolated()
		let c = MainActorContainer()
		c.mainActorService.printHello()
		c.mainActorServiceFromKeyPath.printHello()
		Injected<MainActorService>.value.printHello()
		XCTAssertTrue(c.mainActorService === Conf[\.mainActorService])
		XCTAssertTrue(c.mainActorService === Conf[key: MainActorService.AutoInjectionKey.self])
		XCTAssertTrue(c.mainActorService === Conf.rootValue(for: MainActorService.AutoInjectionKey.self))
		XCTAssertTrue(c.mainActorService === Injected<MainActorService>.value)
		XCTAssertTrue(c.mainActorServiceFromKeyPath === Injected<MainActorService>.value)
		
		XCTAssertTrue(c.otherMainActorService !== Injected<MainActorService>.value)
		
		let oldOtherActor = c.otherMainActorService
		Conf.setRootValue(c.mainActorService, for: \.mainActorService2)
		XCTAssertTrue(c.otherMainActorService === Injected<MainActorService>.value)
		
		Conf.withValue(oldOtherActor, for: \.mainActorService2, operation: {
			XCTAssertTrue(c.mainActorService === Conf[\.mainActorService])
			XCTAssertTrue(c.otherMainActorService === oldOtherActor)
			XCTAssertTrue(c.otherMainActorService !== Injected<MainActorService>.value)
		})
		
		Conf.withValues{
			$0[\.mainActorService2] = MainActorService()
		}operation:{
			XCTAssertTrue(c.otherMainActorService !== oldOtherActor)
			XCTAssertTrue(c.otherMainActorService !== Injected<MainActorService>.value)
		}
		
		Injected<MainActorService>.withValue(MainActorService()){
			XCTAssertTrue(c.otherMainActorService !== oldOtherActor)
			XCTAssertTrue(c.otherMainActorService !== Injected<MainActorService>.value)
		}
		
		XCTAssertTrue(c.otherMainActorService === Injected<MainActorService>.value)
		
		Injected<MainActorService>.rootValue = oldOtherActor
		XCTAssertTrue(c.otherMainActorService !== c.mainActorService)
	}
	
	@MainActor
	struct MainActorContainer {
		
		@Injected()
		var mainActorService: MainActorService
		@Injected(\.mainActorService)
		var mainActorServiceFromKeyPath: MainActorService
		
		@Injected(\.mainActorService2)
		var otherMainActorService: MainActorService
		
	}
	
}
