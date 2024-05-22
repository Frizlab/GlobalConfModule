import Foundation
import XCTest

/* No @testable import: we mostly test whether the architecture works; we must be as close as possible to a regular client’s use. */
import Configuration



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
	
}
