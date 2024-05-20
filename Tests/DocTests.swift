import Foundation
import XCTest

/* No @testable import: we mostly test whether the architecture works; we must be as close as possible to a regular client’s use. */
import Configuration



/* We mostly just check the examples in the Readme compile. */
final class DocTests : XCTestCase {
	
	func testDependencyInjectionUsage() {
		Conf.setRootValue(DefaultDocService(), for: \.docService)
		docService.doAmazingStuff()
		XCTAssertTrue(true)
	}
	
	@Injected(\.docService)
	var docService: DocService
	
	func testConfUsage() {
		XCTAssertEqual(Conf[\.docConf], 42)
		XCTAssertEqual(Conf.docConf, 42)
	}
	
	func testAutoInjectedUsage() {
		XCTAssertNotNil(docAutoInjectedService)
	}
	
	@Injected()
	var docAutoInjectedService: DocAutoInjectedService

}
