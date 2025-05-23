import Foundation
import Testing

/* No @testable import: we mostly test whether the architecture works; we must be as close as possible to a regular client’s use. */
import GlobalConfModule



/* We mostly just check the examples in the Readme compile. */
struct DocTests {
	
	@Test
	func testDependencyInjectionUsage() {
		Conf.setRootValue(DefaultDocService(), for: \.docService)
		docService.doAmazingStuff()
		#expect(Bool(true))
	}
	
	@InjectedConf(\.docService)
	var docService: DocService
	
	@Test
	func testConfUsage() {
		#expect(Conf[\.docConf] == 42)
		#expect(Conf.docConf == 42)
	}
	
	@Test
	func testAutoInjectedUsage() {
		#expect(docAutoInjectedService as DocAutoInjectedService? != nil)
	}
	
	@InjectedConf()
	var docAutoInjectedService: DocAutoInjectedService

}
