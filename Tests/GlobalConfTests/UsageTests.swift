import Foundation
import Testing

/* No @testable import: we mostly test whether the architecture works; we must be as close as possible to a regular client’s use. */
import GlobalConfModule



struct UsageTests {
	
	@Test
	func testUsingNoActorService() {
		noActorService.printHello()
		noActorServiceFromKeyPath.printHello()
		InjectedConf<NoActorService>.value.printHello()
		#expect(noActorService === InjectedConf<NoActorService>.value)
		#expect(noActorServiceFromKeyPath === InjectedConf<NoActorService>.value)
	}
	
	@Test
	func testUsingNoActorServiceWithFactory() {
		#expect(noActorService === noActorService)
		#expect(noActorFactoryService !== noActorFactoryService)
	}
	
	@InjectedConf()
	var noActorService: NoActorService
	@InjectedConf(\.noActorService)
	var noActorServiceFromKeyPath: NoActorService
	@InjectedConf(\.noActorFactoryService)
	var noActorFactoryService: NoActorService
	
}
