import Foundation
import XCTest

/* No @testable import: we mostly test whether the architecture works; we must be as close as possible to a regular client’s use. */
import DependencyInjection



final class UsageMainActorTests : XCTestCase {
	
	@MainActor
	func testUsingMainActorService() {
		MainActor.preconditionIsolated()
		let c = MainActorContainer()
		c.mainActorService.printHello()
		c.mainActorServiceFromKeyPath.printHello()
		Injected<MainActorService>.value.printHello()
		XCTAssertTrue(c.mainActorService === Injected<MainActorService>.value)
		XCTAssertTrue(c.mainActorServiceFromKeyPath === Injected<MainActorService>.value)
		
		XCTAssertTrue(c.otherMainActorService !== Injected<MainActorService>.value)
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
