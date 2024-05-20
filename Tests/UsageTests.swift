import Foundation
import XCTest

/* No @testable import: we mostly test whether the architecture works; we must be as close as possible to a regular client’s use. */
import Configuration



final class UsageTests : XCTestCase {
	
	func testUsingNoActorService() {
		noActorService.printHello()
		noActorServiceFromKeyPath.printHello()
		Injected<NoActorService>.value.printHello()
		XCTAssertTrue(noActorService === Injected<NoActorService>.value)
		XCTAssertTrue(noActorServiceFromKeyPath === Injected<NoActorService>.value)
	}
	
	@Injected()
	var noActorService: NoActorService
	@Injected(\.noActorService)
	var noActorServiceFromKeyPath: NoActorService
	
}
