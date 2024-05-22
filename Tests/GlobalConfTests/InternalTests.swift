import Foundation
import XCTest

@testable import GlobalConfModule



final class InternalTests : XCTestCase {
	
	override class func setUp() {
		Conf.rootContext = .topLevel
	}
	
	func testContextCount() {
		XCTAssertEqual(Conf.rootContext.count, 0)
		Conf.setRootValue(NoActorService(), for: \.noActorService)
		XCTAssertEqual(Conf.rootContext.count, 1)
	}
	
	@InjectedConf()
	var noActorService: NoActorService
	
}
