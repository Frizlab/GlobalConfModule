import Foundation
import XCTest

/* No @testable import: we mostly test whether the architecture works; we must be as close as possible to a regular client’s use. */
import GlobalConfModule



/* We mostly just check the examples in the Readme compile. */
final class ConfFactoryTests : XCTestCase {
	
	func testConfFactoryUsage() {
		XCTAssertLessThan(Conf.randomInt, 42)
		XCTAssertLessThan(Conf[\.randomInt](), 42)
		/* Having 7 times the same int is so unlikely we consider this test to be valid (~1 chance out of 5_489_031_744 (42^6) if I’m not mistaken). */
		XCTAssertGreaterThan(Set([newRandomInt, newRandomInt, newRandomInt, newRandomInt, newRandomInt, newRandomInt, newRandomInt]).count, 1)
	}
	
	@InjectedConf(\.randomInt)
	var newRandomInt: Int
	
}
